import torch
import struct
from typing import Dict, Tuple, List

def crt_check(crt: Dict[Tuple, List[List[List[int]]]]):
    flag = True
    cont_dict = {}
    for tile, rt in crt.items():
        for ipn, ip in enumerate(rt):
            for vcn, vc in enumerate(ip):
                for opn, op in enumerate(vc):
                    if bool(op):
                        key = (tile, vcn, opn)
                        if key not in cont_dict:
                            cont_dict[key] = []
                        cont_dict[key].append(ipn)

    for k, v in cont_dict.items():
        if len(v) > 1:
            flag = False
            print(f"ERROR detected at router {k[0]} vc {k[1]} oport {k[2]}, multiple iports requested: {v}")

    return flag


def write_3dtensor_to_bin(tensor: torch.Tensor, file_path: str, format: str = '>f'):

    with open(file_path, 'wb') as f:
        for i in range(tensor.size(0)):
            for j in range(tensor.size(1)):
                for k in range(tensor.size(2)):
                    f.write(struct.pack(format, tensor[i, j, k]))


def write_2dtensor_to_bin(tensor: torch.Tensor, file_path: str, format: str = '>f'):

    with open(file_path, 'wb') as f:
        for i in range(tensor.size(0)):
            for j in range(tensor.size(1)):
                f.write(struct.pack(format, tensor[i, j]))


def write_1dtensor_to_bin(tensor: torch.Tensor, file_path: str, format: str = '>f'):

    with open(file_path, 'wb') as f:
        for i in range(tensor.size(0)):
            f.write(struct.pack(format, tensor[i]))