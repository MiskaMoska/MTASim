`include "params.svh"

module add_unit #(
    parameter bit merge_in = 0,
    parameter bit merge_out = 0,
    parameter bit gather_in = 0,
    parameter bit gather_out = 0,
    parameter bit cast_out = 0
)(
    input   logic                   clk,
    input   logic                   rstn,

    input   logic   [`QW-1 : 0]     bias_data_i [`XW],
    input   logic                   bias_valid_i,
    output  logic                   bias_ready_o,

    input   logic   [`QW-1 : 0]     merge_data_i [`XW],
    input   logic                   merge_valid_i,
    output  logic                   merge_ready_o,

    input   logic   [`QW-1 : 0]     gather_data_i [`XW],
    input   logic                   gather_valid_i,
    output  logic                   gather_ready_o,

    output  logic   [`QW-1 : 0]     data_o [`XW],
    output  logic                   valid_o,
    input   logic                   ready_i
);

genvar c;
generate
    if(merge_out) begin: OMIT_ADD
        genvar c;
        assign bias_ready_o = 0;
        assign merge_ready_o = 0;
        assign gather_ready_o = 0;
        assign valid_o = 0;
        for(c=0; c<`XW; c=c+1) begin: DATA_O_ASSIGN
            assign data_o[c] = 0;
        end
    end else begin: ACTIVE_ADD
        shortreal sum [`XW];
        for(c=0; c<`XW; c=c+1) begin: ADD_CHAN
            always_comb begin
                sum[c] = $bitstoshortreal(bias_data_i[c]);
                if(merge_in) begin
                    sum[c] = sum[c] + $bitstoshortreal(merge_data_i[c]);
                end
                if(gather_in) begin
                    sum[c] = sum[c] + $bitstoshortreal(gather_data_i[c]);
                end
                data_o[c] = $shortrealtobits(sum[c]);
            end
        end
        assign valid_o = bias_valid_i & 
                            (merge_in ? merge_valid_i : 1'b1) &
                            (gather_in ? gather_valid_i : 1'b1);

        assign bias_ready_o = valid_o & ready_i;
        assign merge_ready_o = merge_in & valid_o & ready_i;
        assign gather_ready_o = gather_in & valid_o & ready_i;
    end
endgenerate
endmodule