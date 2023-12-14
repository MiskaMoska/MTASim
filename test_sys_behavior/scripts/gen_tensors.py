import os
import torch
import struct
import torch.nn.functional as F
from typing import List, Union, Tuple, Mapping
from maptools import TileConfig, ModelParams, PhysicalTile
from .utils import write_1dtensor_to_bin, write_2dtensor_to_bin

__all__ = ['gen_tensor_bin_files']

def get_tile_weight_from_layer_weight(weight: torch.Tensor, config: TileConfig) -> torch.Tensor:
    icfg = config['xbar_icfg']
    ocfg = config['xbar_ocfg']
    xbar_w = config['xbar_width']
    xbar_h = config['xbar_height']
    kernel_x = config['conv_kernel_size'][1]
    s_ochan, d_ochan = ocfg
    weight = weight[s_ochan : d_ochan, :, :, :] # output channel slicing

    slices_to_concat = []
    for box in icfg: # input channel and window unit slicing
        winx = box[0] % kernel_x
        winy = box[0] // kernel_x
        s_ichan, d_ichan = box[1], box[2]
        weight_slice = weight[:, s_ichan : d_ichan, winy, winx]
        slices_to_concat.append(torch.flatten(weight_slice, start_dim=1))
    
    tile_weight = torch.concat(slices_to_concat, dim=1) # concatenate all window unit slices
    tile_weight = tile_weight.permute(1, 0)

    assert tile_weight.shape[0] <= xbar_h and tile_weight.shape[1] <= xbar_w, (
        "the size of the weight tensor exceeds the size of the xbar"
    )

    rows_to_pad = xbar_h - tile_weight.size(0)
    cols_to_pad = xbar_w - tile_weight.size(1)

    # Now we got the final weight array organized as (xbar_h, xbar_w)
    tile_weight = F.pad(tile_weight, (0, cols_to_pad, 0, rows_to_pad))

    return tile_weight


def get_tile_bias_from_layer_bias(bias: torch.Tensor, config: TileConfig) -> torch.Tensor:
    ocfg = config['xbar_ocfg']
    xbar_w = config['xbar_width']

    s_ochan, d_ochan = ocfg
    tile_bias = bias[s_ochan : d_ochan]
    tile_bias = F.pad(tile_bias, (0, xbar_w-tile_bias.size(0)))
    return tile_bias


def get_line_config_from_icfg(config: TileConfig, cbn: int) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor, torch.Tensor]:
    icfg = config['xbar_icfg']
    kernel_y, kernel_x = config['conv_kernel_size']
    xbar_h = config['xbar_height']
    assert xbar_h % cbn == 0, f"illegal cbn: {cbn}"
    slen = xbar_h // cbn

    vcfg_valid = []
    vcfg_winx = []
    vcfg_winy = []
    vcfg_rela_ichan = []

    base_ichan = min([box[1] for box in icfg])

    row = 0
    for box in icfg:
        for ichan in range(box[1], box[2]):
            vcfg_valid.append(True)
            vcfg_winx.append(box[0] % kernel_x)
            vcfg_winy.append(box[0] // kernel_y)
            vcfg_rela_ichan.append(ichan - base_ichan)

        row += box[2] - box[1]

    if row < xbar_h:
        for i in range(row, xbar_h):
            vcfg_valid.append(False)
            vcfg_winx.append(0)
            vcfg_winy.append(0)
            vcfg_rela_ichan.append(0)

    valid_tensor = torch.zeros([cbn, slen], dtype=torch.bool)
    winx_tensor = torch.zeros([cbn, slen], dtype=torch.int8)
    winy_tensor = torch.zeros([cbn, slen], dtype=torch.int8)
    rela_ichan_tensor = torch.zeros([cbn, slen], dtype=torch.int32)

    for i in range(cbn):
        for j in range(slen):
            valid_tensor[i, j] = vcfg_valid[i*slen + j]
            winx_tensor[i, j] = vcfg_winx[i*slen + j]
            winy_tensor[i, j] = vcfg_winy[i*slen + j]
            rela_ichan_tensor[i, j] = vcfg_rela_ichan[i*slen + j]

    return (valid_tensor, winx_tensor, winy_tensor, rela_ichan_tensor)


def gen_tensor_bin_files(
    tile_config: Mapping[PhysicalTile, TileConfig], 
    model_params: ModelParams, 
    cbn: int, root_dir: str
) -> None:
    weight_save_dir = os.path.join(root_dir, 'config', 'weight')
    bias_save_dir = os.path.join(root_dir, 'config', 'bias')
    line_config_save_dir = os.path.join(root_dir, 'config', 'line_config')
    
    for dir in {weight_save_dir, bias_save_dir, line_config_save_dir}:
        if not os.path.exists(dir):
            os.makedirs(dir)

    # generate weight and bias tensor bin files
    for tile, config in tile_config.items():
        x, y = tile
        if 'Conv' in config['op_type']:
            layer_weight = torch.from_numpy(model_params[config['conv_weight']])
            tile_weight = get_tile_weight_from_layer_weight(layer_weight, config)
            weight_path = os.path.join(weight_save_dir, f'weight_tile_{x}_{y}.bin') # 4-byte-float big end

            write_2dtensor_to_bin(tile_weight, weight_path)
            print(f"conv_weight {tuple(tile_weight.size())} has been written to {weight_path}")

        if 'Bias' in config['op_type']:
            layer_bias = torch.from_numpy(model_params[config['conv_bias']])
            tile_bias = get_tile_bias_from_layer_bias(layer_bias, config)
            bias_path = os.path.join(bias_save_dir, f'bias_tile_{x}_{y}.bin') # 4-byte-float big end
            
            write_1dtensor_to_bin(tile_bias, bias_path)
            print(f"conv_bias {tuple(tile_bias.size())} has been written to {bias_path}")

    # generate line config bin files
    for tile, config in tile_config.items():
        x, y = tile
        config = tile_config[tile]
        vcfg_valid, vcfg_winx, vcfg_winy, vcfg_rela_ichan = get_line_config_from_icfg(config, cbn)
        valid_path = os.path.join(line_config_save_dir, f'vcfg_valid_tile_{x}_{y}.bin') # 1 byte
        winx_path = os.path.join(line_config_save_dir, f'vcfg_winx_tile_{x}_{y}.bin') # 1 byte
        winy_path = os.path.join(line_config_save_dir, f'vcfg_winy_tile_{x}_{y}.bin') # 1 byte
        rela_ichan_path = os.path.join(line_config_save_dir, f'vcfg_rela_ichan_tile_{x}_{y}.bin') # 4-byte-int big end

        write_2dtensor_to_bin(vcfg_valid, valid_path, format='B')
        write_2dtensor_to_bin(vcfg_winx, winx_path, format='B')
        write_2dtensor_to_bin(vcfg_winy, winy_path, format='B')
        write_2dtensor_to_bin(vcfg_rela_ichan, rela_ichan_path, format='>I')

        print(f"line config has been written to {valid_path}")

