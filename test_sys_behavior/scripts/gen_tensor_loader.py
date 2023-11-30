import os, io
import torch.nn.functional as F
from typing import List, Union, Tuple, Mapping
from maptools import TileConfig, ModelParams, PhysicalTile

__all__ = ['gen_tensor_loader']

def gen_tensor_loader(
    root_dir: str, 
    tile_config: Mapping[PhysicalTile, TileConfig], 
    cbn: int
) -> None:
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    tensor_loader_path = os.path.join(save_dir, 'tensor_loader.svh')
    with open(tensor_loader_path, 'w') as f:
        f.write('''
`ifndef                 _TENSOR_LOADER_SVH_
`define                 _TENSOR_LOADER_SVH_

bit [31:0] temp_4b;
bit [7:0] temp_1b;
integer code;
int f_input, f_weight, f_bias, f_linecfg;
                
initial begin
'''
        )
        write_fread_sentences(root_dir, tile_config, cbn, f)
        f.write('''
end
        
`endif
''')
        f.flush()

    print(f"test loader has been written to: {tensor_loader_path}")


def write_fread_sentences(
    root_dir: str, 
    tile_config: Mapping[PhysicalTile, TileConfig], 
    cbn: int, 
    f: io.TextIOWrapper
) -> None:
    for tile, config in tile_config.items():
        x, y = tile
        if 'Conv' in config['op_type']:
            xbar_w = config['xbar_width']
            xbar_h = config['xbar_height']
            f.write(f'''
    f_weight=$fopen("{os.path.join(root_dir, 'config', 'weight', f'weight_tile_{x}_{y}.bin')}", "rb");
    for(int y=0; y<{xbar_h}; y=y+1) for(int x=0; x<{xbar_w}; x=x+1) begin
        code=$fread(temp_4b, f_weight);
        system.tile_{x}_{y}.xbar.weights[y][x] = $bitstoshortreal(temp_4b);
    end
    $fclose(f_weight);
    $display("conv_weight of tile {tile} initializing complete ...");
''')
        if 'Bias' in config['op_type']:
            xbar_w = config['xbar_width']
            f.write(f'''
    f_bias=$fopen("{os.path.join(root_dir, 'config', 'bias', f'bias_tile_{x}_{y}.bin')}", "rb");
    for(int x=0; x<{xbar_w}; x=x+1) begin
        code=$fread(temp_4b, f_bias);
        system.tile_{x}_{y}.bias.biases[x] = $bitstoshortreal(temp_4b);
    end
    $fclose(f_bias);
    $display("conv_bias of tile {tile} initializing complete ...");
''')
            
    for tile, config in tile_config.items():
        x, y = tile
        xbar_h = config['xbar_height']
        assert xbar_h % cbn == 0, f"illegal cbn: {cbn}"
        slen = xbar_h // cbn
        f.write(f'''
    f_linecfg=$fopen("{os.path.join(root_dir, 'config', 'line_config', f'vcfg_valid_tile_{x}_{y}.bin')}", "rb");
    for(int y=0; y<{cbn}; y=y+1) for(int x=0; x<{slen}; x=x+1) begin
        code=$fread(temp_1b, f_linecfg);
        system.tile_{x}_{y}.im2col.vcfg_valid[y][x] = temp_1b;
    end
    $fclose(f_linecfg);
    f_linecfg=$fopen("{os.path.join(root_dir, 'config', 'line_config', f'vcfg_winx_tile_{x}_{y}.bin')}", "rb");
    for(int y=0; y<{cbn}; y=y+1) for(int x=0; x<{slen}; x=x+1) begin
        code=$fread(temp_1b, f_linecfg);
        system.tile_{x}_{y}.im2col.vcfg_winx[y][x] = temp_1b;
    end
    $fclose(f_linecfg);
    f_linecfg=$fopen("{os.path.join(root_dir, 'config', 'line_config', f'vcfg_winy_tile_{x}_{y}.bin')}", "rb");
    for(int y=0; y<{cbn}; y=y+1) for(int x=0; x<{slen}; x=x+1) begin
        code=$fread(temp_1b, f_linecfg);
        system.tile_{x}_{y}.im2col.vcfg_winy[y][x] = temp_1b;
    end
    $fclose(f_linecfg);
    f_linecfg=$fopen("{os.path.join(root_dir, 'config', 'line_config', f'vcfg_rela_ichan_tile_{x}_{y}.bin')}", "rb");
    for(int y=0; y<{cbn}; y=y+1) for(int x=0; x<{slen}; x=x+1) begin
        code=$fread(temp_4b, f_linecfg);
        system.tile_{x}_{y}.im2col.vcfg_rela_ichan[y][x] = temp_4b;
    end
    $fclose(f_linecfg);
    $display("line_config of tile {tile} initializing complete ...");
''')
        
    f.write(f'''
    f_input=$fopen("{os.path.join(root_dir, 'config', 'input', 'input.bin')}", "rb");
    for(int y=0; y<`ITH; y=y+1) for(int x=0; x<`ITW; x=x+1) for(int c=0; c<`ITC; c=c+1) begin
        code=$fread(temp_4b, f_input);
        input_data[`ITC * (y * `ITW + x) + c] = $bitstoshortreal(temp_4b);
    end
    $fclose(f_input);
    $display("input_data initializing complete ...");
''')
            





