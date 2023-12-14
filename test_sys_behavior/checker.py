
import os
import torch
import struct
from typing import Tuple, TypeVar
from maptools import PhysicalTile, LogicalTile, read_results
from builder import mapname, match_dict, model_params, tile_config

sim_root = os.path.join(os.environ.get('MTASIM_HOME'), 'test_sys_behavior')
results = read_results(mapname, 'results')

def extract_tensor_from_binfile(tensor_file: str, shape: Tuple[int, int, int]) -> torch.Tensor:
    tensor = torch.zeros(shape) # HWC
    with open(tensor_file, 'rb') as f:
        for y in range(shape[0]):
            for x in range(shape[1]):
                for c in range(shape[2]):
                    tensor[y, x, c] = struct.unpack('<f', f.read(4))[0]

    return tensor


def get_shape(shape_file) -> Tuple[int, int, int]:
    shape = []
    with open(shape_file, 'r') as f:
        for line in f:
            shape.append(int(line))

    return tuple(shape[0:3])


def get_mtasim_tile_result(tile: LogicalTile, test_point: str) -> torch.Tensor:
    '''
    This method returns the MTASim result of the given test point in the given tile.
    To view all legal test points, please refer to the names in maptools.calcusim.device.tile_task.OBSERVE_VARS without `float`
    '''
    ptile: PhysicalTile = match_dict[tile]
    x, y = ptile
    print(f"accessing physical tile: {ptile}")
    tensor_file = os.path.join(sim_root, 'res', f'tile_{x}_{y}_{test_point}.bin')
    assert os.path.exists(tensor_file), f"expected file not exist: {tensor_file}"
    shape_file = os.path.join(sim_root, 'res', 'shapes', f'tile_{x}_{y}_{test_point}.txt')
    assert os.path.exists(shape_file), f"expected file not exist: {shape_file}"
    size = os.path.getsize(tensor_file)
    shape = get_shape(shape_file)
    exp_size = shape[0]*shape[1]*shape[2]*4
    assert exp_size == size, f"tensor file size not match, expected: {shape}*4={exp_size}, but got file size: {size}"
    tensor = extract_tensor_from_binfile(tensor_file, shape)
    return tensor


def get_calcusim_tile_result(tile: LogicalTile, test_point: str) -> torch.Tensor:
    '''
    This method returns the CalcuSim result of the given test point in the given tile.
    To view all legal test points, please refer to the names in maptools.calcusim.device.tile_task.OBSERVE_VARS without `float`
    '''
    tensor: torch.Tensor = results[tile][test_point]
    tensor = tensor[0, :, :, :] # from NCHW to CHW
    tensor = tensor.permute(1, 2, 0) # from CHW to HWC
    return tensor

if __name__ == "__main__":
    # print(results.keys())
    for tile in [x for x in results.keys() if isinstance(x, tuple)]:
        print("\nlogical tile: ", tile)
        point = 'data_out'
        tm = get_mtasim_tile_result(tile, point)
        tc = get_calcusim_tile_result(tile, point)
        diff = torch.abs(tm.cpu()-tc.cpu())
        print("max diff: ", torch.max(diff))
        print("avg diff: ", torch.mean(diff))