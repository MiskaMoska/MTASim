import os
from maptools import read_generalcfg, read_castcfg, read_mergecfg
from scripts.gen_cast_network import *
from scripts.gen_merge_network import *
from scripts.gen_cast_network_config import *
from scripts.gen_merge_network_config import *
from scripts.gen_connection_config import *
from scripts.gen_params_header import *
from scripts.gen_system import *
from scripts.gen_top_tb import *
from scripts.gen_packets import *
from scripts.utils import *

mtasim_root = os.environ.get('MTASIM_HOME')
if mtasim_root is None:
    raise EnvironmentError("The path to MTASim root directory need to be added to environment variables named MTASIM_HOME")

root_dir = os.path.join(mtasim_root, 'test_noc')

# parameters
mapname = 'yolo'
datawidth = 32
tile_module_name = 'virtual_tile'
flitnum = 1000
# parameters

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


gen_cast_network(root_dir, datawidth, w, h)
gen_merge_network(root_dir, datawidth, w, h)
gen_cast_network_config(root_dir, crt)
gen_merge_network_config(root_dir, mrt)
gen_connection_config(root_dir, w, h, tile_config)
gen_params_header(root_dir, w, h, datawidth, vcnumber, tail_tiles)
gen_system(root_dir, w, h, tile_module_name, head_tile, tail_tiles)
gen_top_tb(root_dir, tail_tiles, flitnum)
gen_packets(root_dir, datawidth, flitnum)