'''
这个文件用来生成随机的权重和激活（输入特征图）张量
然后把他们保存到pickle文件里，之所以保存起来是为了方便重复使用同一个值，有助于调试对比
'''

import torch
import pickle
from conv_config import *

activation = torch.randn(ICHAN, IFSIZE_Y, IFSIZE_X, dtype=torch.float32)
weights = torch.randn(OCHAN, ICHAN, KERNEL_Y, KERNEL_X, dtype=torch.float32)
_weights = torch.zeros_like(weights)
for box in ICFG:
    x = box[0] % KERNEL_X
    y = box[0] // KERNEL_X
    _weights[:, box[1]:box[2], y, x] = weights[:, box[1]:box[2], y, x]

with open("activation.pkl", 'wb') as f:
    print('act_shape: ', activation.shape)
    pickle.dump(activation, f)

with open("weights.pkl", 'wb') as f:
    print('weight_shape: ', weights.shape)
    pickle.dump(_weights, f)

