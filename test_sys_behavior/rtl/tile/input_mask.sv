`include "params.svh"

module input_mask #(
    parameter   int     total_ichan = 0,
    parameter   int     start_ichan = 0,
    parameter   int     end_ichan = 0
)(
    input   logic                       clk,
    input   logic                       rstn,

    input   logic   [`QW-1 : 0]         data_i,
    input   logic                       valid_i,
    output  logic                       ready_o,

    output  logic   [`QW-1 : 0]         data_o,
    output  logic                       valid_o,
    input   logic                       ready_i
);

generate
    if(total_ichan == end_ichan - start_ichan) begin: TRANSPARENT_MODE
        assign {data_o, valid_o, ready_o} = {data_i, valid_i, ready_i};
    end else begin: MASK_MODE
        logic  [$clog2(total_ichan-1)-1:0] ichan_cnt;
        logic mask;
        always @(posedge clk or negedge rstn) begin
            if(~rstn) begin
                ichan_cnt <= 0;
            end else begin
                if(valid_i & ready_o) begin
                    if(ichan_cnt == total_ichan - 1) begin
                        ichan_cnt <= 0;
                    end else begin
                        ichan_cnt <= ichan_cnt + 1;
                    end
                end
            end
        end
        assign mask = ~((ichan_cnt >= start_ichan) & (ichan_cnt < end_ichan));
        assign valid_o = valid_i & (~ mask);
        assign ready_o = mask | ready_i;
    end
endgenerate


endmodule