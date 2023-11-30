/*
    All channels are processed in parallel and synchronously
*/

`include "params.svh"

module pooling_unit #(
    parameter string                mode = "max", // max or avg
    parameter int                   kernel_x = 0, 
    parameter int                   kernel_y = 0,
    parameter int                   stride_x = 0, 
    parameter int                   stride_y = 0,
    parameter int                   ifsize_x = 0, 
    parameter int                   ifsize_y = 0,
    parameter int                   ifpads_u = 0, 
    parameter int                   ifpads_d = 0,
    parameter int                   ifpads_l = 0, 
    parameter int                   ifpads_r = 0,
    parameter int                   ofsize_x = 0, 
    parameter int                   ofsize_y = 0
)(
    input   logic                   clk,
    input   logic                   rstn,

    input   logic   [`QW-1 : 0]     data_i [`XW],
    input   logic                   valid_i,
    output  logic                   ready_o,
    
    output  logic   [`QW-1 : 0]     data_o [`XW],
    output  logic                   valid_o,
    input   logic                   ready_i
);

localparam int win_ndata = kernel_x * kernel_y;

logic buf_wen, frame_done, win_start, win_end, is_pad;
logic win_done, win_cnt_en, win_data_ready;

logic [$clog2(`PBD)-1 : 0] buf_waddr;
logic [$clog2(`PBD)-1 : 0] buf_raddr;
logic [$clog2(`PBD)-1 : 0] buf_hold_addr;
logic [$clog2(`PBD)-1 : 0] buf_want_addr;
logic buf_waadr_ind, buf_hold_addr_ind, buf_want_addr_ind;

logic [$clog2(ifsize_x)-1 : 0] if_x;
logic [$clog2(ifsize_y)-1 : 0] if_y;
logic [$clog2(ifsize_x)-1 : 0] if_x_reg;
logic [$clog2(ifsize_y)-1 : 0] if_y_reg;
logic [$clog2(ifsize_y)-1 : 0] _if_x;
logic [$clog2(ifsize_y)-1 : 0] _if_y;

logic [$clog2(ofsize_x)-1 : 0] of_x;
logic [$clog2(ofsize_y)-1 : 0] of_y;
logic [$clog2(kernel_x)-1 : 0] win_x;
logic [$clog2(kernel_y)-1 : 0] win_y;
logic [$clog2(ofsize_x)-1 : 0] nxt_of_x;
logic [$clog2(ofsize_y)-1 : 0] nxt_of_y;

logic [`QW-1 : 0] buf_dout [`XW];
logic buffer_state, nxt_buffer_state;

logic [`QW-1 : 0] maxpool_reg [`XW];
logic [`QW-1 : 0] maxpool_reg_din [`XW];
logic [`QW-1 : 0] avgpool_reg [`XW];
logic [`QW-1 : 0] avgpool_reg_din [`XW];

localparam OKAY = 1'b0;
localparam BUSY = 1'b1;

genvar chan;

/* Channel Buffers */
generate
    for(chan=0; chan<`XW; chan=chan+1) begin: CHAN_BUFFER
        sdpram #(
            .AW                         ($clog2(`PBD)),
            .DW                         (`QW)
        )pool_buffer(
            .clka                       (clk),
            .clkb                       (clk),
            .wea                        (buf_wen),
            .addra                      (buf_waddr),
            .addrb                      (buf_raddr),
            .dia                        (data_i[chan]),
            .dob                        (buf_dout[chan])
        );
    end
endgenerate


/* Buffer State FSM */
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        buffer_state <= 0;
    end else begin
        buffer_state <= nxt_buffer_state;
    end
end

always_comb begin
    case(buffer_state)
        OKAY: begin
            if((if_x == ifsize_x-1) &
            (if_y == ifsize_y-1) &
            (valid_i & ready_o)) begin
                nxt_buffer_state = BUSY;
            end else begin
                nxt_buffer_state = buffer_state;
            end
        end
        BUSY: begin
            if(frame_done) begin
                nxt_buffer_state = OKAY;
            end else begin
                nxt_buffer_state = buffer_state;
            end
        end
        default: begin
            nxt_buffer_state = OKAY;
        end
    endcase
end


/* Frame Done Signal Generating */
assign frame_done = (of_x == ofsize_x-1) &
                    (of_y == ofsize_y-1) & 
                    (win_x == kernel_x-1) & 
                    (win_y == kernel_y-1) &
                    (valid_o & ready_i);


/* Input Feature Map Counting */
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        if_x <= 0;
        if_y <= 0;
    end else begin
        if(frame_done) begin
            if_x <= 0;
            if_y <= 0;
        end else begin
            if(valid_i & ready_o) begin
                if(if_x == ifsize_x - 1) begin
                    if_x <= 0;
                    if(if_y == ifsize_y - 1) begin
                        if_y <= 0;
                    end else begin
                        if_y <= if_y + 1;
                    end
                end else begin
                    if_x <= if_x + 1;
                end
            end
        end
    end
end


/* Write Address Holding When Waiting for Frame Releasing */
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        if_x_reg <= 0;
        if_y_reg <= 0;
    end else begin
        if(buffer_state == OKAY) begin
            if((if_x == ifsize_x - 1) &
            (if_y == ifsize_y - 1) &
            (valid_i & ready_o)) begin
                if_x_reg <= if_x;
                if_y_reg <= if_y;
            end
        end
    end
end

assign {_if_x, _if_y} = {buffer_state == BUSY} ? {if_x_reg, if_y_reg} : {if_x, if_y};


/* Output Feature Map Counting */
assign win_cnt_en = (~win_start | win_data_ready) & (~win_end | ready_i);
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        of_x <= 0;
        of_y <= 0;
    end else begin
        of_x <= nxt_of_x;
        of_y <= nxt_of_y;
    end
end

always_comb begin
    if(win_done) begin
        if(of_x == ofsize_x - 1) begin
            nxt_of_x = 0;
            if(of_y == ofsize_y - 1) begin
                nxt_of_y = 0;
            end else begin
                nxt_of_y = of_y + 1;
            end
        end else begin
            nxt_of_x = of_x + 1;
        end
    end else begin
        nxt_of_x = of_x;
        nxt_of_y = of_y;
    end
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        win_x <= 0;
        win_y <= 0;
    end else begin
        if(win_cnt_en) begin
            if(win_x == kernel_x - 1) begin
                win_x <= 0;
                if(win_y == kernel_y - 1) begin
                    win_y <= 0;
                end else begin
                    win_y <= win_y + 1;
                end
            end else begin
                win_x <= win_x + 1;
            end
        end
    end
end

assign win_start = (win_x == 0) & (win_y == 0);
assign win_end = (win_x == kernel_x - 1) & (win_y == kernel_y - 1);
assign win_done = win_end & win_cnt_en;

/* Buffer Write Address Calculation */
assign buf_waddr = (_if_x + (_if_y * ifsize_x)) % `PBD;
assign buf_waddr_ind = ((_if_x + (_if_y * ifsize_x)) / `PBD) % 2 == 1;


/* Holding Address Calculation */
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        buf_hold_addr <= 0;
        buf_hold_addr_ind <= 0;
    end else begin
        if(frame_done) begin
            buf_hold_addr <= 0;
            buf_hold_addr_ind <= 0;
        end else if(win_done) begin
            if((nxt_of_x * stride_x < ifpads_l) ||
            (nxt_of_x * stride_x >= ifpads_l + ifsize_x) ||
            (nxt_of_y * stride_y < ifpads_u) ||
            (nxt_of_y * stride_y >= ifpads_u + ifsize_y)) begin
                // next window base if padding, keep the holding address unchanged
                buf_hold_addr <= buf_hold_addr;
                buf_hold_addr_ind <= buf_hold_addr_ind;
            end else begin
                buf_hold_addr  <=  ((nxt_of_x * stride_x - ifpads_l) + 
                                    (nxt_of_y * stride_y - ifpads_u) * 
                                    ifsize_x) % `PBD;

                buf_hold_addr_ind  <=  (((nxt_of_x * stride_x - ifpads_l) + 
                                        (nxt_of_y * stride_y - ifpads_u) * 
                                        ifsize_x) / `PBD) % 2 == 1;
            end
        end
    end
end


/* Input Port Ready Out Signal Control */
always_comb begin
    if(~rstn) ready_o = 0;
    else begin
        if(buffer_state == BUSY) begin
            ready_o = 0;
        end else begin
            if((buf_hold_addr_ind != buf_waddr_ind) &&
            (buf_hold_addr == buf_waddr)) begin // buffer full
                ready_o = 0;
            end else begin
                ready_o = 1;
            end
        end
    end
end


/* Wanting Address Calculation */
always_comb begin
    int t1, t2, t3, t4, t5;
    t1 = of_x * stride_x + kernel_x - 1;
    t2 = ifpads_l + ifsize_x - 1;
    t3 = $min(t1, t2) - ifpads_l;
    t1 = of_y * stride_y + kernel_y - 1;
    t2 = ifpads_u + ifsize_y - 1;
    t4 = $min(t1, t2) - ifpads_u;
    t5 = (t3 + t4 * ifsize_x + 1) - 1; // must minus one
    buf_want_addr = t5 % `PBD;
    buf_want_addr_ind = (t5 / `PBD) % 2 == 1;
end


/* Window Data Ready Judging */
always_comb begin
    if(buf_waddr_ind == buf_want_addr_ind) begin
        win_data_ready = buf_waddr >= buf_want_addr;
    end else begin
        win_data_ready = buf_want_addr > buf_waddr;
    end
end


/* Buffer Read Address Calculation */
assign buf_raddr = ((of_x * stride_x + win_x - ifpads_l) +
                    (of_y * stride_y + win_y - ifpads_u) * 
                    ifsize_x) % `PBD;


/* Is Padding Signal Generating */
assign is_pad = (of_x * stride_x + win_x < ifpads_l) |
                (of_x * stride_x + win_x >= ifsize_x + ifpads_l) |
                (of_y * stride_y + win_y < ifpads_u) |
                (of_y * stride_y + win_y >= ifsize_y + ifpads_u);


/* MaxPool and AvgPool Data Path */
generate
    if(mode == "max") begin: MAX_POOL
        always @(posedge clk or negedge rstn) begin
            if(~rstn) begin
                for(int i=0; i<`XW; i=i+1) begin
                    maxpool_reg[i] <= 0;
                end
            end else begin
                for(int i=0; i<`XW; i=i+1) begin
                    if(~win_end | ready_i) begin
                        maxpool_reg[i] <= maxpool_reg_din[i];
                    end
                end
            end
        end

        always_comb begin
            shortreal now_reg, now_din, now_dout;
            for(int i=0; i<`XW; i=i+1) begin
                now_reg = $bitstoshortreal(maxpool_reg[i]);
                now_din = is_pad ? 0 : $bitstoshortreal(buf_dout[i]);
                now_dout = $max(now_reg, now_din);
                data_o[i] = $shortrealtobits(now_dout);
                maxpool_reg_din[i] = win_end ? $shortrealtobits(-1e30) : data_o[i];
            end
        end
    end

    else if(mode == "avg") begin: AVG_POOL
        always @(posedge clk or negedge rstn) begin
            if(~rstn) begin
                for(int i=0; i<`XW; i=i+1) begin
                    avgpool_reg[i] <= 0;
                end
            end else begin
                for(int i=0; i<`XW; i=i+1) begin
                    if(~win_end | ready_i) begin
                        avgpool_reg[i] <= avgpool_reg_din[i];
                    end
                end
            end
        end

        always_comb begin
            shortreal now_reg, now_din, now_dout, now_accum;
            for(int i=0; i<`XW; i=i+1) begin
                now_reg = $bitstoshortreal(maxpool_reg[i]);
                now_din = is_pad ? 0 : $bitstoshortreal(buf_dout[i]);
                now_accum = now_reg + now_din;
                now_dout = now_accum / win_ndata;
                data_o[i] = $shortrealtobits(now_dout);
                avgpool_reg_din[i] = win_end ? 0 : $shortrealtobits(now_accum);
            end
        end
    end
endgenerate


/* Output Valid & Ready Control */
assign valid_o = win_end;


/* Buffer Write Control */
assign buf_wen = valid_i & ready_o;


/* For Debugging */
initial begin
    forever begin
        @(posedge clk)
        if(win_done)
        $display("Window done, now of_x: %0d, now of_y %0d", of_x, of_y);
    end
end

endmodule