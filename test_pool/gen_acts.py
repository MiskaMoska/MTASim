import torch
import pickle
from pool_config import *

activation = torch.randn(NCHAN, IFSIZE_Y, IFSIZE_X, dtype=torch.float32)

with open("activation.pkl", 'wb') as f:
    pickle.dump(activation, f)