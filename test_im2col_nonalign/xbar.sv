`include "params.svh"

module xbar #(
    parameter int trans_delay = 40
    // parameter shortreal weights [`XH] [`XW] = '{(`XH){'{(`XW){0.5}}}}
)(
    input   logic                   clk,
    input   logic                   rstn,
    input   logic   [`QW-1 : 0]     vector_i [`XH],
    output  logic   [`QW-1 : 0]     vector_o [`XW],
    input   logic                   valid_i_tg,
    output  logic                   ready_o_tg,
    output  logic                   valid_o,
    input   logic                   ready_i
);

// this is the convolution weights, which will be assigned value in testbench
shortreal weights [0:`XH-1] [0:`XW-1];

shortreal accum;

logic valid_i_tg_s1, valid_i_tg_s2;
logic valid_i_pulse;

logic valid_i_tg_delay;
logic valid_i_tg_delay_s1, valid_i_tg_delay_s2;
logic valid_i_delay_pulse;

logic pre_ready_o_tg;

logic [`QW-1 : 0] vector_reg [`XH];

always@(valid_i_tg) begin
    valid_i_tg_delay <= #(trans_delay+10) valid_i_tg;
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        valid_i_tg_s1 <= 0;
        valid_i_tg_s2 <= 0;
    end else begin
        valid_i_tg_s1 <= valid_i_tg;
        valid_i_tg_s2 <= valid_i_tg_s1;
    end
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        valid_i_tg_delay_s1 <= 0;
        valid_i_tg_delay_s2 <= 0;
    end else begin
        valid_i_tg_delay_s1 <= valid_i_tg_delay;
        valid_i_tg_delay_s2 <= valid_i_tg_delay_s1;
    end
end

assign valid_i_pulse = valid_i_tg_s1 ^ valid_i_tg_s2;
assign valid_i_delay_pulse = valid_i_tg_delay_s1 ^ valid_i_tg_delay_s2;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        vector_reg <= '{(`XH){{(`QW){1'b0}}}};
    end else begin
        if(valid_i_pulse) begin
            vector_reg <= vector_i;
        end
    end
end

always_comb begin
    for(int i=0; i<`XW; i=i+1) begin
        accum = 0;
        for(int j=0; j<`XH; j=j+1) begin
            accum = accum + $bitstoshortreal(vector_reg[j]) * weights[j][i];
        end
        vector_o[i] <= #(trans_delay) $shortrealtobits(accum);
    end
end

logic [1:0] state, nxt_state;

localparam IDLE = 0;
localparam TRANS = 1; // in transfer
localparam WAIT = 2; // wait for downstream

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= IDLE;
    end else begin
        state <= nxt_state;
    end
end

// in real xbar, only when the xbar has accomplished transfer and 
// the downstream has accepted the output data successfully, can the ready_o_tg signal toggle once.
always_comb begin
    case(state)
        IDLE: begin
            if(valid_i_pulse) begin
                nxt_state = TRANS;
            end else begin
                nxt_state = state;
            end
        end
        TRANS: begin
            if(valid_i_delay_pulse) begin
                nxt_state = WAIT;
            end else begin
                nxt_state = state;
            end
        end
        WAIT: begin
            if(ready_i) begin
                nxt_state = IDLE;
            end else begin
                nxt_state = state;
            end
        end
        default: begin
            nxt_state = state;
        end
    endcase
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        pre_ready_o_tg <= 0;
    end else begin
        if(state == WAIT && ready_i) begin
            pre_ready_o_tg <= ~pre_ready_o_tg;
        end
    end
end

// delay one cycle to provide enough time for IDLE state to detect the valid_i_tg signal
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        ready_o_tg <= 0;
    end else begin
        ready_o_tg <= pre_ready_o_tg;
    end
end

assign valid_o = (state == WAIT);

endmodule