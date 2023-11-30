`ifndef     __PARAMS_SVH__
`define     __PARAMS_SVH__

`define     QW          32 // 数据位宽，现在是用浮点数测试的，还没有做定点量化，所以固定为32bit，对应一个float32或shortreal

`define     XH          1152 // Xbar高度
`define     XW          256 // Xbar宽度

`define     CBN         8 // convolution bank number
`define     CBD         1000 // convolution bank depth, 注意是每个bank的深度，所以卷积buffer的总容量为`CBN * `CBD

`endif