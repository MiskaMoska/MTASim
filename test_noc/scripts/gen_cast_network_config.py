'''
Generating the cast network routing tables for each cast router
'''

import os
from typing import Mapping, List
from maptools.core import PhysicalTile
from maptools import dec2bin

__all__ = ['gen_cast_network_config']

def get_sv_rt(rt):
    '''
    This function transforms the routing table from 
    python-represented data structures
    '''
    c0 = "'{\n"
    for ip in rt:
        c1 = "'{"
        for vc in ip:
            c2 = "'b"
            for op in vc[::-1]:
                c2 += f'{op}'
            c1 += c2+', '
        c1 = c1.rstrip(', ')
        c1 += '}'
        c0 += c1+',\n'
    c0 = c0.rstrip(',\n')
    c0 += '}'
    return c0

def gen_cast_network_config(root_dir, crt: Mapping[PhysicalTile, List[List[List[int]]]]):
    '''
    This function generates the systemverilog header file to configure the routing table of the cast network.
    The argument `crt` is obtained from `RoutingConfigurator.get_crt()`
    '''
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'cast_network_config.svh')
    containt = '''
`ifndef __CAST_NETWORK_CONFIG_SVH_
`define __CAST_NETWORK_CONFIG_SVH_
`include "params.svh"
    '''
    for router, table in crt.items():
        svrt = get_sv_rt(table)
        containt += f'''
localparam bit [`PN-1:0] routing_table_{router[0]}_{router[1]} [`PN] [`VN] = {svrt};\n'''

    containt += '''
`endif'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"cast network configuration info has been written to: {file_dir}")