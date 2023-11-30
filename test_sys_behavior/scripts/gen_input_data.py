import os 
import struct
import random
import torch
from maptools import dec2bin
from .utils import write_3dtensor_to_bin

__all__ = ['gen_input_data']

def gen_input_data(root_dir, input_data: torch.Tensor):
    save_dir = os.path.join(root_dir, 'config', 'input')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_path = os.path.join(save_dir, 'input.bin')
    write_3dtensor_to_bin(input_data, file_path)
    print(f"input data has been written to: {file_path}")