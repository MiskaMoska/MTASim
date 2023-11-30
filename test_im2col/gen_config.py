'''
这个文件用来根据硬件规格参数和保存的权重激活张量生成对应的systemverilog配置文件和存有权重和激活值的bin文件
'''

import struct
import torch
import torch.nn.functional as F
import pickle
import numpy as np
import maptools
from conv_config import *

XBAR_H = 1152
XBAR_W = 256
CBN = 2

assert XBAR_H % CBN == 0, "illegal XBAR and CBN"
SLEN = XBAR_H // CBN

'''
Convolution Weights Configuration
'''
with open("weights.pkl", 'rb') as f:
    weights: torch.Tensor = pickle.load(f)

weights = weights.permute(0, 2, 3, 1)
weights = weights.flatten(start_dim=1)
weights = weights.permute(1, 0)
assert weights.shape[0] <= XBAR_H and weights.shape[1] <= XBAR_W, (
    "the size of the weight tensor exceeds the size of the xbar"
)

rows_to_pad = XBAR_H - weights.size(0)
cols_to_pad = XBAR_W - weights.size(1)

# Now we got the final weight array organized as (XBAR_H, XBAR_W)
weights = F.pad(weights, (0, cols_to_pad, 0, rows_to_pad))

with open("weights.bin", 'wb') as f:
	for i in range(weights.size(0)):
		for j in range(weights.size(1)):
			f.write(struct.pack("f", weights[i][j]))

print("conv_weights has been written to 'weights.bin'")

# # This is to generate systemverilog-array-like weights
# weight_list = weights.tolist()
# systemverilog_array = "localparam shortreal weights[`XH][`XW] = '{{{}}};".format(", ".join(["\n'{" + ", ".join(map(str, sublist)) + "}" for sublist in weight_list]))

# with open('conv_weights.svh', 'w') as f:
#     f.write('`ifndef __CONV_WEIGHTS_SVH__\n')
#     f.write('`define __CONV_WEIGHTS_SVH__\n')
#     f.write('`include "params.svh"\n\n')
#     f.write(systemverilog_array)
#     f.write('\n\n`endif')

# print("conv_weights has been written to 'conv_weights.svh'")

'''
Convolution Parameters Configuration
'''
vcfg_valid = []
vcfg_winx = []
vcfg_winy = []
vcfg_rela_ichan = []

base_ichan = min([box[1] for box in ICFG])
row = 0
for box in ICFG:
	for ichan in range(box[1], box[2]):
		vcfg_valid.append(1)
		vcfg_winx.append(box[0] % KERNEL_X)
		vcfg_winy.append(box[0] // KERNEL_X)
		vcfg_rela_ichan.append(ichan - base_ichan)

	row += box[2] - box[1]

if row < XBAR_H:
	for i in range(row, XBAR_H):
		vcfg_valid.append(0)
		vcfg_winx.append(0)
		vcfg_winy.append(0)
		vcfg_rela_ichan.append(0)

sv_vcfg_valid = "\nlocalparam bit vcfg_valid [`CBN] [`XH/`CBN] = '{{{}}};\n".format(", ".join(["\n'{" + ", ".join(map(str, vcfg_valid[SLEN*i:SLEN*(i+1)])) + "}" for i in range(CBN)]))
sv_vcfg_winx = "\nlocalparam int vcfg_winx [`CBN] [`XH/`CBN] = '{{{}}};\n".format(", ".join(["\n'{" + ", ".join(map(str, vcfg_winx[SLEN*i:SLEN*(i+1)])) + "}" for i in range(CBN)]))
sv_vcfg_winy = "\nlocalparam int vcfg_winy [`CBN] [`XH/`CBN] = '{{{}}};\n".format(", ".join(["\n'{" + ", ".join(map(str, vcfg_winy[SLEN*i:SLEN*(i+1)])) + "}" for i in range(CBN)]))
sv_vcfg_rela_ichan = "\nlocalparam int vcfg_rela_ichan [`CBN] [`XH/`CBN] = '{{{}}};\n".format(", ".join(["\n'{" + ", ".join(map(str, vcfg_rela_ichan[SLEN*i:SLEN*(i+1)])) + "}" for i in range(CBN)]))

with open('im2col_config.svh', 'w') as f:
    f.write('`ifndef __IM2COL_CONFIG_SVH__\n')
    f.write('`define __IM2COL_CONFIG_SVH__\n')
    f.write('`include "params.svh"\n\n')
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
    f.write(f'localparam int xbar_num_ichan = {ICHAN};\n')
    f.write(sv_vcfg_valid)
    f.write(sv_vcfg_winx)
    f.write(sv_vcfg_winy)
    f.write(sv_vcfg_rela_ichan)
    f.write('\n\n`endif')

print("conv_parameters has been written to 'im2col_config.svh'")


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