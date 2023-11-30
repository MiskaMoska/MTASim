'''
这个文件根据生成的权重和激活张量进行卷积计算，得到正确的输出特征图
并将该结果按照CHW的维度顺序以字符串的格式保存到output_py.txt文件中，方便和systemverilog生成的output_sv.txt文件进行比对
比对的时候直接使用diff命令即可，由于python和systemverilog的计算精度和四舍五入方法存在一些不同，可能会出现一些mismatch，但是一般不多，而且差别很小(0.01左右)
'''

import pickle
import torch
from torch.nn.functional import max_pool2d, pad

with open("activation.pkl", 'rb') as f:
    activation: torch.Tensor = pickle.load(f)

activation = pad(activation, [1, 1, 1, 1])

print(torch.max(activation[4,10:10+3,3:3+3]))


output: torch.Tensor = max_pool2d(activation, [3, 3], stride=[1, 1])
print(output[4,10,3])
output = output.flatten()

with open('output_py.txt', 'w') as f:
    for i in range(output.size(0)):
        f.write("%.2f\n" % output[i])