from typing import Dict, List, Tuple

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