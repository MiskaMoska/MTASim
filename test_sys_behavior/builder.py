import os, sys
from typing import Dict, List, Tuple
from maptools import (
    read_generalcfg, read_castcfg, 
    read_mergecfg, read_params, get_input
)
from scripts.gen_cast_network import *
from scripts.gen_merge_network import *
from scripts.gen_cast_network_config import *
from scripts.gen_merge_network_config import *
from scripts.gen_tile_config import *
from scripts.gen_params_header import *
from scripts.gen_system import *
from scripts.gen_input_data import *
from scripts.gen_tensors import *
from scripts.gen_tensor_loader import *
from scripts.utils import *

######################################### parameters #####################################################
root_dir = os.path.join(os.environ.get('MTASIM_HOME'), 'test_sys_behavior') #? absolute path to the current directory
input_img_path = os.path.join(os.environ.get('MPTLS_HOME'), 'work', 'test.jpg') #* user-defined
input_size = (224, 224, 3) #? (H, W, C) 
mapname = 'resnet18' #? must be consistent with the mapname of the maptools mapping program
conv_bank_num = 4 #* user-defined, = 2^N (N=0, 1, 2, 3, ...)
conv_bank_depth = 1985 #* user-defined, = max_convifsize_x * corresp_inputchannel_num * (max_convkernelsize_y + 1) / conv_bank_num
pool_bank_depth = 12544 #* user-defined, = max_poolifsize_x * (max_poolkernelsize_y + 1)
gather_buffer_size = 20000 #* user-defined, refer to the running results of TokSim
datawidth = 32 #! don't touch
xbar_width = 256 #? must be consistent with the parameter set in maptools mapping program
xbar_height = 1152 #? must be consistent with the parameter set in maptools mapping program
xbar_adc_trans_delay = 3200 #* user-defined, unit: 100ps
tile_module_name = 'tile' #! don't touch
regen_tensor = False #* user-defined
######################################### parameters #####################################################

gcfg = read_generalcfg(mapname)
crt = read_castcfg(mapname)

if not crt_check(crt):
    raise AssertionError("cast routing table check fails")

mrt = read_mergecfg(mapname)
w = gcfg['network_width']
h = gcfg['network_height']
tile_config = gcfg['tile_config']
vcnumber = gcfg['vcnumber']
head_tile = gcfg['head_tile']
tail_tiles = gcfg['tail_tiles']
model_params = read_params(mapname)
input_data: torch.Tensor = get_input(input_img_path, input_size[:2])
input_data = input_data[0, :, :, :]

if regen_tensor:
    gen_tensor_bin_files(tile_config, model_params, conv_bank_num, root_dir)

gen_tensor_loader(root_dir, tile_config, conv_bank_num)
gen_cast_network(root_dir, datawidth, w, h)
gen_merge_network(root_dir, datawidth, w, h)
gen_cast_network_config(root_dir, crt)
gen_merge_network_config(root_dir, mrt)
gen_tile_config(root_dir, w, h, tile_config, xbar_adc_trans_delay)
gen_params_header(
    root_dir, w, h, datawidth, vcnumber, input_size,
    tail_tiles, conv_bank_num, conv_bank_depth, 
    xbar_width, xbar_height, pool_bank_depth, gather_buffer_size
)
gen_system(root_dir, w, h, tile_module_name, head_tile, tail_tiles)
gen_input_data(root_dir, input_data)