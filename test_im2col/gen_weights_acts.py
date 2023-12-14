'''
这个文件用来生成随机的权重和激活（输入特征图）张量
然后把他们保存到pickle文件里，之所以保存起来是为了方便重复使用同一个值，有助于调试对比
'''

import torch
import pickle
from conv_config import *

activation = torch.randn(ICHAN, IFSIZE_Y, IFSIZE_X, dtype=torch.float32)
weights = torch.randn(OCHAN, ICHAN, KERNEL_Y, KERNEL_X, dtype=torch.float32)

with open("activation.pkl", 'wb') as f:
    pickle.dump(activation, f)

with open("weights.pkl", 'wb') as f:
    pickle.dump(weights, f)
