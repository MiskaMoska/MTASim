from typing import List, Optional

STRIDE_X = 1
STRIDE_Y = 1
PAD_U = 1
PAD_R = 1
PAD_D = 1
PAD_L = 1
IFSIZE_X = 112
IFSIZE_Y = 112
KERNEL_X = 3
KERNEL_Y = 3
OFSIZE_X = 112
OFSIZE_Y = 112

BANK_NUM = 12

XBAR_H = 1152

ICFG = [(0, 0, 256), (1, 0, 256), (2, 0, 256), (3, 0, 256), (4, 0, 128)]
ICFG = [(4, 128, 256), (5, 0, 256), (6, 0, 256), (7, 0, 256), (8, 0, 256)]
# ICFG = [(0, 0, 123), (1, 0, 123), (2, 0, 123), (3, 0, 123), (4, 0, 123), (5, 0, 123), (6, 0, 123), (7, 0, 123), (8, 0, 123)]


min_ichan = min([e[1] for e in ICFG])
max_ichan = max([e[2] for e in ICFG])
xbar_num_ichan = max_ichan - min_ichan

assert (IFSIZE_X + PAD_L + PAD_R - KERNEL_X + 1) % STRIDE_X == 0, "size not matching"
assert (IFSIZE_X + PAD_L + PAD_R - KERNEL_X + 1) // STRIDE_X == OFSIZE_X, "size not matching"
assert (IFSIZE_Y + PAD_U + PAD_D - KERNEL_Y + 1) % STRIDE_Y == 0, "size not matching"
assert (IFSIZE_Y + PAD_U + PAD_D - KERNEL_Y + 1) // STRIDE_Y == OFSIZE_Y, "size not matching"
assert len(set([e[0] for e in ICFG])) == len([e[0] for e in ICFG]), "repeated winpos"
assert sum([e[2]-e[1] for e in ICFG]) <= XBAR_H, "xbar height exceeded"
assert XBAR_H % BANK_NUM == 0, "xbar height not divided by bank number"

ivector_cfg = [[False, 0, 0]] * XBAR_H

idx = 0
for box in ICFG:
    for ichan in range(box[1], box[2]):
        ivector_cfg[idx] = [True, box[0], ichan]
        idx += 1

def get_addr(valid, ox, oy, winpos, ichan):
    if not valid:
        return None
    kx = winpos % KERNEL_X
    ky = winpos // KERNEL_X
    assert ky < KERNEL_Y, "kernel size error"
    rela_ichan = ichan - min_ichan
    ifx = ox * STRIDE_X + kx
    if ifx < PAD_L or ifx >= IFSIZE_X+PAD_R: # left or right padding
        return 'Pad'
    ify = oy * STRIDE_Y + ky
    if ify < PAD_U or ify >= IFSIZE_Y+PAD_D: # up or down padding
        return 'Pad'
    ifx_wopad = ifx - PAD_L
    ify_wopad = ify - PAD_U
    addr = (ify_wopad * IFSIZE_Y + ifx_wopad) * xbar_num_ichan + rela_ichan
    return addr

def get_bank(addr):
    '''
    None: no request, must not be granted
    'Pad': the current request is a padding data, must be granted
    int: normal bank request, can be granted or not
    '''
    if addr is None or addr == 'Pad':
        return addr
    return addr % BANK_NUM

def arbitration(req: List[Optional[int]]) -> List[bool]:
    grant = [0]*BANK_NUM
    for i in range(BANK_NUM):
        if i in req:
            grant[req.index(i)] = 1
        if req[i] == 'Pad':
            grant[i] = 1
    return grant

for oy in range(20, OFSIZE_Y):
    for ox in range(20, OFSIZE_X):
        conflict_cnt = 0
        cycle_cnt = 0
        fill_process = [0]*BANK_NUM
        fill_done = [False]*BANK_NUM
        fill_index = [i*(XBAR_H // BANK_NUM) for i in range(BANK_NUM)]
        fill_valid_len = [sum([int(cfg[0]) for cfg in ivector_cfg[i*(XBAR_H // BANK_NUM):(i+1)*(XBAR_H // BANK_NUM)]]) for i in range(BANK_NUM)]

        while sum(map(int, fill_done)) != BANK_NUM:
            fill_addr = [None] * BANK_NUM
            for i in range(BANK_NUM):
                if not fill_done[i]:
                    cfg = ivector_cfg[fill_index[i]]
                    fill_addr[i] = get_addr(cfg[0], ox, oy, cfg[1], cfg[2])

            fill_bank = [get_bank(addr) for addr in fill_addr]
            fill_grant = arbitration(fill_bank)
        
            fill_process = [fill_process[i] + fill_grant[i] for i in range(BANK_NUM)]
            fill_index = [fill_index[i] + fill_grant[i] for i in range(BANK_NUM)]
            fill_done = [True if fill_process[i] >= fill_valid_len[i] else False for i in range(BANK_NUM)]
            valid_req = [i for i in fill_bank if isinstance(i, int)]
            has_conflict = len(set(valid_req)) < len(valid_req)
            conflict_cnt += int(has_conflict)
            cycle_cnt += 1
            # print('fill_process:', fill_process, 'fill_addr: ', fill_bank, 'fill_done: ', fill_done, "Conflict" if has_conflict else "")
            print(cycle_cnt, "Conflict" if has_conflict else "")
        import sys
        sys.exit()
        print(f"ox:\t{ox},\toy:\t{oy},\tconflicts:\t{conflict_cnt},\tcycles:\t{cycle_cnt}/{XBAR_H//BANK_NUM}")

