import struct
import torch
import torch.nn.functional as F
import pickle
import numpy as np
import maptools
from pool_config import *

XBAR_W = 256

'''
Pooling Parameters Configuration
'''
with open('pooling_config.svh', 'w') as f:
    f.write('`ifndef __POOL_CONFIG_SVH__\n')
    f.write('`define __POOL_CONFIG_SVH__\n')
    f.write('`include "params.svh"\n\n')
    f.write(f'localparam string mode = "{MODE}";\n')
    f.write(f'localparam int kernel_x = {KERNEL_X};\n')
    f.write(f'localparam int kernel_y = {KERNEL_Y};\n')
    f.write(f'localparam int stride_x = {STRIDE_X};\n')
    f.write(f'localparam int stride_y = {STRIDE_Y};\n')
    f.write(f'localparam int ifsize_x = {IFSIZE_X};\n')
    f.write(f'localparam int ifsize_y = {IFSIZE_Y};\n')
    f.write(f'localparam int ifpads_u = {PAD_U};\n')
    f.write(f'localparam int ifpads_d = {PAD_D};\n')
    f.write(f'localparam int ifpads_l = {PAD_L};\n')
    f.write(f'localparam int ifpads_r = {PAD_R};\n')
    f.write(f'localparam int ofsize_x = {OFSIZE_X};\n')
    f.write(f'localparam int ofsize_y = {OFSIZE_Y};\n')
    f.write('\n\n`endif')

print("pooling parameters has been written to 'pooling_config.svh'")


'''
Activation Configuration
'''
with open("activation.pkl", 'rb') as f:
    activation: torch.Tensor = pickle.load(f)

activation = activation.flatten(start_dim=1)
activation = activation.permute(1, 0)
activation = activation.flatten()

with open("activation.bin", 'wb') as f:
	for i in range(activation.size(0)):
		f.write(struct.pack("f", activation[i]))

print("conv_activation has been written to 'activation.bin'")