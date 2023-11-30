`include "params.svh"

module res_split #(
    parameter bit merge_out = 0
)(
    input   logic   [`QW-1 : 0]     data_i [`XW],
    input   logic                   valid_i,
    output  logic                   ready_o,

    output  logic   [`QW-1 : 0]     data_o_mergeout [`XW],
    output  logic                   valid_o_mergeout,
    input   logic                   ready_i_mergeout,

    output  logic   [`QW-1 : 0]     data_o_addbias [`XW],
    output  logic                   valid_o_addbias,
    input   logic                   ready_i_addbias
);

assign ready_o = merge_out ? ready_i_mergeout : ready_i_addbias;
assign valid_o_mergeout = valid_i & merge_out;
assign valid_o_addbias = valid_i & (~merge_out);
assign data_o_mergeout = data_i;
assign data_o_addbias = data_i;

endmodule