'''
Generating the merge network routing tables for each merge router
'''

import os
from typing import Mapping, Dict, Any, List
from maptools.core import PhysicalTile

__all__ = ['gen_merge_network_config']

def gen_merge_network_config(root_dir, mrt: Mapping[PhysicalTile, Dict[str, List[int]]]):
    '''
    This function generates the systemverilog header file to configure the routing table of the merge network.
    The argument `mrt` is obtained from `RoutingConfigurator.get_mrt()`
    '''
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'merge_network_config.svh')
    containt = '''
`ifndef __MERGE_NETWORK_CONFIG_SVH_
`define __MERGE_NETWORK_CONFIG_SVH_
`include "params.svh"
'''
    for (x, y), cfg in mrt.items():
        i = cfg['input_mask']
        o = cfg['output_sel']
        input_mask = f'{i[0]}{i[1]}{i[2]}{i[3]}{i[4]}'
        output_sel = f'{o[0]}{o[1]}{o[2]}{o[3]}{o[4]}'
        containt += f"\nlocalparam input_mask_{x}_{y} = 5'b"+input_mask+";"
        containt += f"\nlocalparam output_sel_{x}_{y} = 5'b"+output_sel+";"

    containt += '''
`endif'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"merge network configuration info has been written to: {file_dir}")