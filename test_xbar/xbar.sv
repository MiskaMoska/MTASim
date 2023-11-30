/*
    This is a simple xbar model without output handshake
*/

`include "params.svh"

module xbar #(
    parameter int trans_delay = 40,
    parameter shortreal weights [`XH] [`XW] = '{(`XH){'{(`XW){0.5}}}}
)(
    input   logic                   clk,
    input   logic                   rstn,
    input   logic   [`QW-1 : 0]     vector_i [`XH],
    output  logic   [`QW-1 : 0]     vector_o [`XW],
    input   logic                   valid_i_tg,
    output  logic                   ready_o_tg
);

shortreal accum;

logic valid_i_tg_s1, valid_i_tg_s2;
logic valid_i_pulse;

logic [`QW-1 : 0] vector_reg [`XH];

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        valid_i_tg_s1 <= 0;
        valid_i_tg_s2 <= 0;
    end else begin
        valid_i_tg_s1 <= valid_i_tg;
        valid_i_tg_s2 <= valid_i_tg_s1;
    end
end

assign valid_i_pulse = valid_i_tg_s1 ^ valid_i_tg_s2;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        vector_reg <= '{(`XH){{(`QW){1'b0}}}};
    end else begin
        if(valid_i_pulse) begin
            vector_reg <= vector_i;
        end
    end
end

// in real xbar, only when the xbar has accomplished transfer and 
// the downstream has accepted the output data successfully, can the ready_o_tg signal toggle once.
always@(valid_i_tg) begin
    ready_o_tg <= #(trans_delay+10) valid_i_tg;
end

always_comb begin
    for(int i=0; i<`XW; i=i+1) begin
        accum = 0;
        for(int j=0; j<`XH; j=j+1) begin
            accum = accum + $bitstoshortreal(vector_i[j]) * weights[j][i];
        end
        vector_o[i] <= #(trans_delay) $shortrealtobits(accum);
    end
end

endmodule