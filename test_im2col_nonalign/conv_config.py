'''
Convolution Configuration
'''
STRIDE_X = 2
STRIDE_Y = 2

PAD_U = 0
PAD_R = 1
PAD_D = 1
PAD_L = 0

KERNEL_X = 3
KERNEL_Y = 3

IFSIZE_X = 14
IFSIZE_Y = 14

OFSIZE_X = 7
OFSIZE_Y = 7

ICHAN = 78
OCHAN = 256

ICFG = [(0, 60, ICHAN), (1, 0, ICHAN), (2, 0, ICHAN), (3, 0, ICHAN), (4, 0, ICHAN), (5, 0, ICHAN), (6, 0, ICHAN), (7, 0, ICHAN), (8, 0, 30)]