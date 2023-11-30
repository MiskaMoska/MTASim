import struct
from maptools import dec2bin
XH=1152

with open("./send_data.txt", "w") as f:
    for i in range(XH):
        a = int.from_bytes(struct.pack("f", 0.8),'little')
        f.write(str(dec2bin(a,bit_wide=32))+'\n')