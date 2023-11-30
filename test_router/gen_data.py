import random

VN = 4
PN = 5

def dec2bin(dec_num, bit_wide: int = 16) -> str:    
    _, bin_num_abs = bin(dec_num).split('b')    
    if len(bin_num_abs) > bit_wide:        
        raise ValueError   
    else:        
        if dec_num >= 0:            
            bin_num = bin_num_abs.rjust(bit_wide, '0')        
        else:            
            _, bin_num = bin(2**bit_wide + dec_num).split('b')    
    return bin_num


for i in range(PN):
    for j in range(VN):
        file_name = f"./send_pool_p{i}_v{j}.txt"
        with open(file_name, 'w') as f:
            for t in range(1000):
                data = dec2bin(random.randint(0, 65535), bit_wide=16)
                f.write(data+"\n")