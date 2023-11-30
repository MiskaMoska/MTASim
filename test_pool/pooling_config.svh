`ifndef __POOL_CONFIG_SVH__
`define __POOL_CONFIG_SVH__
`include "params.svh"

localparam string mode = "max";
localparam int kernel_x = 3;
localparam int kernel_y = 3;
localparam int stride_x = 1;
localparam int stride_y = 1;
localparam int ifsize_x = 14;
localparam int ifsize_y = 14;
localparam int ifpads_u = 1;
localparam int ifpads_d = 1;
localparam int ifpads_l = 1;
localparam int ifpads_r = 1;
localparam int ofsize_x = 14;
localparam int ofsize_y = 14;


`endif