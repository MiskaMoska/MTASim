/*
    Convolution Buffer-Bank Depth can be any number
    Convolution Buffer-Bank Number must be 2^N
    Note that it is ensured by the offline mapping program that the kernel size is larger
    than the padding at any edge of the input feature map
*/
`include "params.svh"

module conv_im2col #(
    /* ------------------------------------------------------------------------- 
        This is the configuration information about the convolution operation 
    ------------------------------------------------------------------------- */
    parameter int kernel_x = 0, 
    parameter int kernel_y = 0,
    parameter int stride_x = 0, 
    parameter int stride_y = 0,
    parameter int ifsize_x = 0, 
    parameter int ifsize_y = 0,
    parameter int ifpads_u = 0, 
    parameter int ifpads_d = 0,
    parameter int ifpads_l = 0, 
    parameter int ifpads_r = 0,
    parameter int ofsize_x = 0, 
    parameter int ofsize_y = 0,

    /* ------------------------------------------------------------------------- 
        This is the configuration information about the xbar 
    ------------------------------------------------------------------------- */
    parameter int xbar_num_ichan = 0,

    parameter bit vcfg_valid [`CBN] [`XH/`CBN] = '{(`CBN){'{(`XH/`CBN){1'b0}}}}, // indicate whether the current position is a valid position, that is, been mapped or not
    parameter int vcfg_winx [`CBN] [`XH/`CBN] = '{(`CBN){'{(`XH/`CBN){0}}}}, // kernel window x position
    parameter int vcfg_winy [`CBN] [`XH/`CBN] = '{(`CBN){'{(`XH/`CBN){0}}}}, // kernel window y position
    parameter int vcfg_rela_ichan [`CBN] [`XH/`CBN] = '{(`CBN){'{(`XH/`CBN){0}}}} // relative input channel index
)(
    input     logic                     clk_bufw, 
    input     logic                     clk_bufr, 
    input     logic                     rstn_bufw,
    input     logic                     rstn_bufr,
    
    input     logic     [`QW-1 : 0]     data_i,
    input     logic                     valid_i,
    output    logic                     ready_o,

    output    logic     [`QW-1 : 0]     data_o [`XH],
    output    logic                     valid_o_tg,
    input     logic                     ready_i_tg
);

/* --------------------------------------------------------------------------- 
    This is the configuration information about each position in the i-vector 
--------------------------------------------------------------------------- */
// where [`CBN] is for each bank slice of the i-vector, and [`XH/`CBN] is for each 
// relative position inside the bank slice.

// Note that vcfg_rela_ichan is the relative input channel index that the position is responsible
// for, for example, if the current xbar is responsible for input channel slice (256, 512), then the 
// vcfg_rela_ichan at the second position is 1 rather than 257, because it is set relative to 256

// Note that the configuration information cannot be implemented in real hardware, because they can
// induce high hardware cost. The configuration information is only used for functionality verification,
// in real hardware implementation, it should be replaced by hardware-friendly logic structures.

// bit vcfg_valid [`CBN] [`XH/`CBN]; // indicate whether the current position is a valid position, that is, been mapped or not
// int vcfg_winx [`CBN] [`XH/`CBN]; // kernel window x position
// int vcfg_winy [`CBN] [`XH/`CBN]; // kernel window y position
// int vcfg_rela_ichan [`CBN] [`XH/`CBN]; // relative input channel index

logic [`CBN-1 : 0] buf_wen;
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_waddr;
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_raddr_slice [`CBN]; // buffer read address genrated at each slice
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_raddr_bank [`CBN]; // buffer read address traversed to each buffer bank
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_hold_addr; // the holding address of buffer, the data beyond the holding address is held, the data after the holding address is released
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_want_addr; // the wanting address of buffer
logic buf_waddr_ind, buf_hold_addr_ind, buf_want_addr_ind;

logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_hold_addr_s1;
logic [$clog2(`CBD)+$clog2(`CBN)-1 : 0] buf_waddr_s1;
logic buf_hold_addr_ind_s1, buf_waddr_ind_s1;

logic [`QW-1 : 0] buf_dout [`CBN];

// buffer write related counter
logic [$clog2(ifsize_x)-1 : 0] if_x;
logic [$clog2(ifsize_y)-1 : 0] if_y;
logic [$clog2(xbar_num_ichan)-1 : 0] if_chan;

logic [$clog2(ifsize_x)-1 : 0] if_x_reg;
logic [$clog2(ifsize_y)-1 : 0] if_y_reg;
logic [$clog2(xbar_num_ichan)-1 : 0] if_chan_reg;

logic [$clog2(ifsize_x)-1 : 0] _if_x;
logic [$clog2(ifsize_y)-1 : 0] _if_y;
logic [$clog2(xbar_num_ichan)-1 : 0] _if_chan;

// buffer read related counter
logic [$clog2(ofsize_x)-1 : 0] of_x;
logic [$clog2(ofsize_y)-1 : 0] of_y;
logic [$clog2(ofsize_y)-1 : 0] nxt_of_x;
logic [$clog2(ofsize_y)-1 : 0] nxt_of_y;


// frame done and ack CDC
logic frame_done_bufr_pulse;
logic frame_done_bufr_tg;
logic frame_done_tg_s1, frame_done_tg_s2;
logic frame_done_bufw_pulse;
logic frame_done_bufw_level;
logic frame_done_ack_tg, frame_done_ack_tg_s1, frame_done_ack_tg_s2;
logic frame_done_ack_bufr_pulse;

logic [`QW-1 : 0] crossbar_data_o [`CBN];
logic [`QW-1 : 0] ping_vector [`CBN] [`XH/`CBN];
logic [`QW-1 : 0] pong_vector [`CBN] [`XH/`CBN];
logic [`QW-1 : 0] mcp_vector [`CBN] [`XH/`CBN];
logic ping_valid, pong_valid;
logic [`XH/`CBN-1 : 0] fill_sel [`CBN]; // one-hot form of fill_addr
logic [$clog2(`XH/`CBN)-1 : 0] fill_addr [`CBN];
logic [`CBN-1 : 0] fill_done;
logic vector_write_sel, vector_read_sel;

logic fill_granted [`CBN];
logic fill_is_pad [`CBN];
logic fill_is_valid [`CBN];
logic [$clog2(kernel_x)-1 : 0] fill_winx [`CBN];
logic [$clog2(kernel_y)-1 : 0] fill_winy [`CBN];
logic [$clog2(xbar_num_ichan)-1 : 0] fill_ichan [`CBN];

logic [`CBN-1 : 0] fill_req [`CBN]; // request signal from each fill slice
logic [`CBN-1 : 0] fill_grt [`CBN]; // grant signal to each fill slice
logic [`CBN-1 : 0] req_to_each_arb [`CBN]; // request vector to each arbiter 
logic [`CBN-1 : 0] grt_from_each_arb [`CBN]; // grant vector from each arbiter

int buffer_cnt; // how many data are in the buffer
logic win_data_ready; // the data in the current convolution window is ready in the buffer

logic valid_o_pulse, ready_i_pulse, now_is_ready;

logic buffer_state, nxt_buffer_state; 

localparam OKAY = 1'b0;
localparam BUSY = 1'b1;

logic [1:0] fill_state, nxt_fill_state;

localparam WAIT = 0;
localparam FILL = 1;
localparam SUSPEND = 2;

logic now_is_valid, now_is_valid_s1;

/* Buffer Banks */
genvar bank;
generate
    for(bank=0; bank<`CBN; bank=bank+1) begin: BUFFER_BANK
        sdpram #(
            .AW                         ($clog2(`CBD)),
            .DW                         (`QW)
        )conv_buffer_bank(
            .clka                       (clk_bufw),
            .clkb                       (clk_bufr),
            .wea                        (buf_wen[bank]),
            .addra                      (buf_waddr[$clog2(`CBN) +: $clog2(`CBD)]),
            .addrb                      (buf_raddr_bank[bank][$clog2(`CBN) +: $clog2(`CBD)]),
            .dia                        (data_i),
            .dob                        (buf_dout[bank])
        );

        assign buf_wen[bank] = (buf_waddr[$clog2(`CBN)-1 : 0] == bank) & valid_i & ready_o;
    end
endgenerate


/* Buffer Count Calculating */
always_comb begin
    // when the fill state is SUSPEND, the hold address is reset to 0 but it takes some time  
    // for the write address to react to reset to 0, too, in this period, the buffer_cnt can
    // be calculated as an invalid value, so we set buffer_cnt to 0 in this period.
    if(fill_state == SUSPEND) begin 
        buffer_cnt = 0;
    end else if(buf_hold_addr_ind == buf_waddr_ind) begin
        buffer_cnt = buf_waddr - buf_hold_addr;
    end else begin
        buffer_cnt = buf_waddr + `CBN * `CBD - buf_hold_addr;
    end
end


/* Window Data Ready Judging */
// write address synchronize to read clock domain
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        buf_waddr_ind_s1 <= 0;
        buf_waddr_s1 <= 0;
    end else begin
        buf_waddr_ind_s1 <= buf_waddr_ind;
        buf_waddr_s1 <= buf_waddr;        
    end
end

// why use > rather than >=? because due to the write address counting mechanism, the data at buf_waddr has 
// not been written to the buffer, so the data in the window is actually not prepared well when buf_waddr == buf_want_addr,
// so we should use > rather than >=. However, the buf_waddr cannot exceed buf_want_addr at the last data of the input
// feature map, so we use another trick to handle this problem: we make the write address plus one when all data has been
// written to the buffer and the buffer_state turns to BUSY
// And there are other means to achieve this, we can use:
// win_data_ready = (buf_waddr_s1 == buf_want_addr) & valid_i & ready_o | (buf_waddr_s1 > buf_want_addr);
always_comb begin
    if(buf_waddr_ind_s1 == buf_want_addr_ind) begin
        win_data_ready = buf_waddr_s1 > buf_want_addr;
    end else begin
        win_data_ready = buf_want_addr > buf_waddr_s1;
    end
end


/* Buffer State FSM */
// buffer state is a frame-perioded FSM
// when buffer state is BUSY, data is not permitted to be written to buffer
// when all data is read from the buffer, the buffer state turns to OKAY and 
// the next frame is written to the buffer from address 0

always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        buffer_state <= OKAY;
    end else begin
        buffer_state <= nxt_buffer_state;
    end
end

always_comb begin
    case(buffer_state)
        OKAY: begin
            if((if_x == ifsize_x-1) & 
            (if_y == ifsize_y-1) & 
            (if_chan == xbar_num_ichan-1) & 
            (valid_i & ready_o)) begin
                nxt_buffer_state = BUSY;
            end else begin
                nxt_buffer_state = buffer_state;
            end
        end
        BUSY: begin
            if(frame_done_bufw_level) begin
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


/* Write Address Holding When Waiting for Frame Releasing */
always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        if_x_reg <= 0;
        if_y_reg <= 0;
        if_chan_reg <= 0;
    end else begin
        if(buffer_state == OKAY) begin
            if((if_x == ifsize_x-1) & 
            (if_y == ifsize_y-1) & 
            (if_chan == xbar_num_ichan-1) & 
            (valid_i & ready_o)) begin
                if_x_reg <= if_x;
                if_y_reg <= if_y;
                if_chan_reg <= if_chan;
            end
        end
    end
end

assign {_if_x, _if_y, _if_chan} = (buffer_state == BUSY) ? {if_x_reg, if_y_reg, if_chan_reg} : {if_x, if_y, if_chan};


/* Fill State FSM */
// fill state is a vector-perioded FSM
// before launching a vector fill, the state of the target ping-pong register set and the 
// validity of the needed data in the buffer are evaluated first,
// if the target ping-pong register set is ready for new data and the needed data has arrived
// at the buffer, a vector fill is launched, otherwise, the fill state FSM stays at the WAIT state 
// to wait for the two conditions to be met.

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        fill_state <= WAIT;
    end else begin
        fill_state <= nxt_fill_state; 
    end
end

always_comb begin
    case(fill_state)
        WAIT: begin
            if((~ping_valid | ~pong_valid) & win_data_ready) begin
                nxt_fill_state = FILL;
            end else begin
                nxt_fill_state = fill_state;
            end
        end
        FILL: begin
            if(& fill_done) begin
                if(frame_done_bufr_pulse) begin
                    nxt_fill_state = SUSPEND;
                end else begin
                    nxt_fill_state = WAIT;
                end
            end else begin
                nxt_fill_state = fill_state;
            end
        end
        SUSPEND: begin
            if(frame_done_ack_bufr_pulse) begin
                nxt_fill_state = WAIT;
            end else begin
                nxt_fill_state = fill_state;
            end
        end
        default: begin
            nxt_fill_state = WAIT;
        end
    endcase
end


/* Frame Done Signal Generating and CDC Transferring */
// frame_done signal is originally generated at bufr clock domain, and
// then transferred to bufw clock domain, then transferred back as an
// ACK signal to bufr clock domain.

// when the bufr clock domain encounters a frame_done_bufr_pulse, it means the whole current frame is
// written to ping-pong vector registers, and the current frame can be released, the it sends a frame_done_bufr_tg
// signal to bufw clock domain and the fill_state FSM turns to SUSPEND to wait for the buffer to be released.

// threre is a special situation where the frame_done signal is generated earlier than all input data is written to
// the buffer, this can happen when the conv_kernel_size is 1x1 and stride is larger than 1, where not all input data 
// is needed to calculate the output data, so the convolution may ends earlier than buffer writing.

// to handle this problem, we stipulate that whenever the frame_done signal is generated in bufr clock domain,
// the buffer_state FSM in bufw clock domain must first wait until all data is written into the buffer, then it 
// turns to BUSY state. to hold the frame_done signal when buffer writing is not completed, we set another signal:
// frame_done_bufw_level as a sampling register of frame_done_bufw_pulse.

// when bufw clock domain detects the frame_done_bufw_level HIGH, the if_x, if_y, if_chan counters
// are reset and the buffer_state FSM turns from BUSY to OKAY.

// when bufr clock domain detects a frame_done_ack_bufr_pulse, it means the buffer has been released for the curren
// frame, and the fill_state FSM returns from SUSPEND to WAIT, ready for filling the first vector of the next frame.

assign frame_done_bufr_pulse = ((of_x == ofsize_x-1) & (of_y == ofsize_y-1) & (& fill_done));
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        frame_done_bufr_tg <= 0;
    end else begin
        if(frame_done_bufr_pulse)
            frame_done_bufr_tg <= ~frame_done_bufr_tg;
    end
end

always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        frame_done_tg_s1 <= 0;
        frame_done_tg_s2 <= 0;
    end else begin
        frame_done_tg_s1 <= frame_done_bufr_tg;
        frame_done_tg_s2 <= frame_done_tg_s1;
    end
end

assign frame_done_bufw_pulse = frame_done_tg_s1 ^ frame_done_tg_s2;

always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        frame_done_bufw_level <= 0;
    end else begin
        if((buffer_state == BUSY) & frame_done_bufw_level) begin
            frame_done_bufw_level <= 0;
        end else if(frame_done_bufw_pulse) begin
            frame_done_bufw_level <= 1;
        end
    end
end

always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        frame_done_ack_tg <= 0;
    end else begin
        if((buffer_state == BUSY) & frame_done_bufw_level) begin
            frame_done_ack_tg <= ~frame_done_ack_tg;
        end
    end
end

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        frame_done_ack_tg_s1 <= 0;
        frame_done_ack_tg_s2 <= 0;
    end else begin
        frame_done_ack_tg_s1 <= frame_done_ack_tg;
        frame_done_ack_tg_s2 <= frame_done_ack_tg_s1;
    end
end

assign frame_done_ack_bufr_pulse = frame_done_ack_tg_s1 ^ frame_done_ack_tg_s2;


/* Input Feature Map Counting */
always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        if_x <= 0;
        if_y <= 0;
        if_chan <= 0;
    end else begin
        if((buffer_state == BUSY) & frame_done_bufw_level) begin
            if_x <= 0;
            if_y <= 0;
            if_chan <= 0;
        end else begin
            if(valid_i & ready_o) begin
                if(if_chan == xbar_num_ichan - 1) begin
                    if_chan <= 0;
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
                end else begin
                    if_chan <= if_chan + 1;
                end
            end
        end
    end
end


/* Output Feature Map Counting */
always_comb begin
    if(frame_done_bufr_pulse) begin // start a new frame
        nxt_of_x = 0;
        nxt_of_y = 0;
    end else if (& fill_done) begin
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
    end else begin // hold
        nxt_of_x = of_x;
        nxt_of_y = of_y;
    end
end

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        of_x <= 0;
        of_y <= 0;
    end else begin
        of_x <= nxt_of_x;
        of_y <= nxt_of_y;
    end
end


/* Buffer Write Address Calculation */
int real_waddr;
always_comb begin
    real_waddr = (_if_chan + (_if_x + (_if_y * ifsize_x)) * xbar_num_ichan);
    if(buffer_state == BUSY) begin
        real_waddr ++; // when write done, write address plus one to exceed want_addr to ensure win_data_ready
    end
    buf_waddr = real_waddr % (`CBD * `CBN);
    buf_waddr_ind = (real_waddr / (`CBD * `CBN)) % 2 == 1;
end


/* Holding Address Calculation */
int temp_hold_addr;
bit keep_hold;
int temp_hold_x, temp_hold_y;
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        buf_hold_addr <= 0;
        buf_hold_addr_ind <= 0;
    end else begin
        if(frame_done_bufr_pulse) begin
            buf_hold_addr <= 0;
            buf_hold_addr_ind <= 0;
        end else if(& fill_done) begin
            temp_hold_x = nxt_of_x * stride_x - ifpads_l;
            temp_hold_y = nxt_of_y * stride_y - ifpads_u;
            keep_hold = 0;
            if(nxt_of_y * stride_y < ifpads_u) begin // reach up pad
                keep_hold = 1;
            end
            else if(nxt_of_x * stride_x < ifpads_l) begin // not up pad but reach left pad
                temp_hold_x = 0;
            end
            if((nxt_of_y * stride_y >= ifpads_u + ifsize_y) || 
                (nxt_of_x * stride_x >= ifpads_l + ifsize_x)) begin // reach down pad or right pad, illegal
                // $display("convolution reach right or down padding when calculating hold_addr at tile (%0d, %0d), of_x: %0d, of_y: %0d", x, y, of_x, of_y);
                $finish;
            end

            if(keep_hold) begin
                buf_hold_addr <= buf_hold_addr;
                buf_hold_addr_ind <= buf_hold_addr_ind;
            end else begin
                temp_hold_addr = ((temp_hold_x + temp_hold_y * ifsize_x) * xbar_num_ichan);
                buf_hold_addr <= temp_hold_addr % (`CBD * `CBN);
                buf_hold_addr_ind <= ((temp_hold_addr / (`CBD * `CBN)) % 2 == 1);
            end

        end
    end
end

// always @(posedge clk_bufr or negedge rstn_bufr) begin
//     if(~rstn_bufr) begin
//         buf_hold_addr <= 0;
//         buf_hold_addr_ind <= 0;
//     end else begin
//         if(frame_done_bufr_pulse) begin
//             buf_hold_addr <= 0;
//             buf_hold_addr_ind <= 0;
//         end else if(& fill_done) begin
//             if((nxt_of_x * stride_x < ifpads_l) || 
//             (nxt_of_x * stride_x >= ifpads_l + ifsize_x) || 
//             (nxt_of_y * stride_y < ifpads_u) ||
//             (nxt_of_y * stride_y >= ifpads_u + ifsize_y)) begin 
//                 // next window base is padding, keep the holding address uchanged
//                 buf_hold_addr <= buf_hold_addr;
//                 buf_hold_addr_ind <= buf_hold_addr_ind;
//             end else begin
//                 // next window base is not padding, update the holding address to the base address
//                 buf_hold_addr <= (((nxt_of_x * stride_x - ifpads_l) + 
//                                     (nxt_of_y * stride_y - ifpads_u) * ifsize_x) * 
//                                     xbar_num_ichan) % (`CBD * `CBN);
//                 buf_hold_addr_ind <= ((((nxt_of_x * stride_x - ifpads_l) + 
//                                     (nxt_of_y * stride_y - ifpads_u) * ifsize_x) * 
//                                     xbar_num_ichan) / (`CBD * `CBN)) % 2 == 1;
//             end
//         end
//     end
// end


/* Wanting Address Calculation */
// here is a special problem that only occurs when kernel size is smaller than stride, more specifically, in 1x1 convolution.
// if we calculate the buf_want_addr by the kernel size, when the buf_hold_addr is updated, it may exceed buf_waddr, which is strictly not permitted.
// to handle this problem, whe calculate the buf_want_addr by the maximum number in kernel size and stride to ensure that the 
// buf_hold_addr will never exceed buf_waddr. this will induce some performance costs because some oppotunities to produce convolution
// results are lost when the needed data are prepared in conv_buffer but a line fill cannot be started immediately, 
// but it guarantees calculation safety.
int t1, t2, t3, t4, t5;
always_comb begin
    t1 = of_x * stride_x + $max(kernel_x, stride_x) - 1;
    t2 = ifpads_l + ifsize_x - 1;
    t3 = $min(t1, t2) - ifpads_l;
    t1 = of_y * stride_y + $max(kernel_y, stride_y) - 1;
    t2 = ifpads_u + ifsize_y - 1;
    t4 = $min(t1, t2) - ifpads_u;
    t5 = (t3 + t4 * ifsize_x + 1) * xbar_num_ichan - 1; // must minus one!!
    buf_want_addr = t5 % (`CBD * `CBN);
    buf_want_addr_ind = (t5 / (`CBD * `CBN)) % 2 == 1;
end


/* Input Port Ready Out Signal Control */
// read address synchronize to write clock domain
always @(posedge clk_bufw or negedge rstn_bufw) begin
    if(~rstn_bufw) begin
        buf_hold_addr_ind_s1 <= 0;
        buf_hold_addr_s1 <= 0;
    end else begin
        buf_hold_addr_ind_s1 <= buf_hold_addr_ind;
        buf_hold_addr_s1 <= buf_hold_addr;        
    end
end

always_comb begin
    if(~rstn_bufw) ready_o = 0;
    else begin
        if(buffer_state == BUSY) begin
            ready_o = 0;
        end else begin
            if((buf_hold_addr_ind_s1 != buf_waddr_ind) && 
            (buf_hold_addr_s1 == buf_waddr)) begin // buffer full
                ready_o = 0;
            end else begin
                ready_o = 1;
            end
        end
    end
end


/* Vector Configuration Addressing */
genvar slice;
generate
    for(slice=0; slice<`CBN; slice=slice+1) begin: VCFG_SLICE
        assign fill_is_valid[slice] = vcfg_valid[slice][fill_addr[slice]];
        assign fill_winx[slice] = vcfg_winx[slice][fill_addr[slice]];
        assign fill_winy[slice] = vcfg_winy[slice][fill_addr[slice]];
        assign fill_ichan[slice] = vcfg_rela_ichan[slice][fill_addr[slice]];
    end
endgenerate

logic vector_write_ena[`CBN];
generate
    for(bank=0; bank<`CBN; bank=bank+1) begin
        assign vector_write_ena[bank] = (fill_state == FILL) & (~fill_done[bank]) & fill_is_valid[bank] & (| fill_sel[bank]) & (fill_granted[bank] | fill_is_pad[bank]);
    end
endgenerate


/* Vector Writing Control */
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        for(int i=0; i<`CBN; i=i+1) begin
            for(int j=0; j<`XH/`CBN; j=j+1) begin
                ping_vector[i][j] <= 0;
                pong_vector[i][j] <= 0;
            end
        end
    end else begin
        if(fill_state == FILL) begin
            for(int i=0; i<`CBN; i=i+1) begin
                for(int j=0; j<`XH/`CBN; j=j+1) begin
                    if((~fill_done[i]) & fill_is_valid[i] & fill_sel[i][j] & 
                        (fill_granted[i] | fill_is_pad[i])) begin
                        if(vector_write_sel) begin
                            pong_vector[i][j] <= fill_is_pad[i] ? 0 : crossbar_data_o[i];
                        end else begin
                            ping_vector[i][j] <= fill_is_pad[i] ? 0 : crossbar_data_o[i];
                        end
                    end
                end
            end
        end
    end
end


/* Vector Validity Control */
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        ping_valid <= 0;
        pong_valid <= 0;
    end else begin
        if(& fill_done) begin
            if(vector_write_sel) begin
                pong_valid <= 1;
            end else begin
                ping_valid <= 1;
            end
        end else if(now_is_valid & now_is_ready) begin
            if(vector_read_sel) begin
                pong_valid <= 0;
            end else begin
                ping_valid <= 0;
            end
        end
    end
end


/* Vector Write and Read Selecting Control */
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        vector_write_sel <= 0;
    end else begin
        if(& fill_done) begin
            vector_write_sel <= ~vector_write_sel;
        end
    end
end

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        vector_read_sel <= 0;
    end else begin
        if(now_is_valid & now_is_ready) begin
            vector_read_sel <= ~vector_read_sel;
        end
    end
end


/* Fill Address Control */
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        for(int i=0; i<`CBN; i=i+1) begin
            fill_addr[i] <= 'b0;
            fill_sel[i] <= 'b1;
        end
    end else begin
        for(int i=0; i<`CBN; i=i+1) begin
            if(fill_state == FILL) begin
                if(& fill_done) begin
                    fill_addr[i] <= 0;
                    fill_sel[i] <= 1;
                end else begin
                    if(fill_is_valid[i] & (fill_is_pad[i] | fill_granted[i])) begin
                        fill_addr[i] <= fill_addr[i] + 1;
                        fill_sel[i] <= (fill_sel[i] << 1);
                    end
                end
            end
        end
    end
end


/* Fill Done Signal Generating */
always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        fill_done <= 0;
    end else begin
        for(int i=0; i<`CBN; i=i+1) begin
            if(fill_state == FILL) begin
                if(& fill_done) begin
                    fill_done[i] <= 0;
                end else if((~fill_is_valid[i]) | 
                ((fill_is_pad[i] | fill_granted[i]) & 
                (fill_sel[i][`XH/`CBN-1]))) begin
                    fill_done[i] <= 1;
                end
            end
        end
    end
end


/* Buffer Read Address & Bank Request Calculation */
generate
    for(slice=0; slice<`CBN; slice=slice+1) begin: RADDR_SLICE
        // when the current slice is on a invalid unit, it shouldn't send bank request
        // when the current slice fill done, it cannot send bank request anymore
        // when the current requesting activation is from padding, it shouldn't send bank request
        assign fill_req[slice] = (fill_state != FILL) | (~fill_is_valid[slice]) | fill_done[slice] | fill_is_pad[slice] ? 0 : (1 << buf_raddr_slice[slice][$clog2(`CBN)-1:0]); 
        assign buf_raddr_slice[slice] = (fill_ichan[slice] + ((of_x * stride_x + fill_winx[slice] - ifpads_l) + 
                                        (of_y * stride_y + fill_winy[slice] - ifpads_u) * ifsize_x) * 
                                        xbar_num_ichan) % (`CBD * `CBN);
    end
endgenerate


/* Padding Zone Detection */
generate
    for(slice=0; slice<`CBN; slice=slice+1) begin: PAD_SLICE
        assign fill_is_pad[slice] = (of_x * stride_x + fill_winx[slice] < ifpads_l) | 
                                    (of_x * stride_x + fill_winx[slice] >= ifsize_x + ifpads_l) | 
                                    (of_y * stride_y + fill_winy[slice] < ifpads_u) | 
                                    (of_y * stride_y + fill_winy[slice] >= ifsize_y + ifpads_u);
    end
endgenerate


/* Multi-bank Arbitration */
always_comb begin
    for(int i=0; i<`CBN; i=i+1) begin
        for(int j=0; j<`CBN; j=j+1) begin
            req_to_each_arb[i][j] = fill_req[j][i];
            fill_grt[i][j] = grt_from_each_arb[j][i];
        end
    end
end

always_comb begin
    for(int i=0; i<`CBN; i=i+1) begin
        fill_granted[i] = (| (fill_grt[i]));
    end
end

generate
    for(bank=0; bank<`CBN; bank=bank+1) begin: ARB_BANK
        mtx_arbiter #(
            .LEN                            (`CBN)
        )arb(
            .clk                            (clk_bufr),
            .rstn                           (rstn_bufr),
            .request                        (req_to_each_arb[bank]),
            .grant                          (grt_from_each_arb[bank]),
            .update                         (1'b1) // keep updating priority
        );
    end
endgenerate


/* Multi-bank Crossbar */
generate
    for(bank=0; bank<`CBN; bank=bank+1) begin: RADDR_MUX_BANK
        mux #(
            .DWIDTH                         ($clog2(`CBD)+$clog2(`CBN)),
            .WAYS                           (`CBN)
        )raddr_mux(
            .sel                            (grt_from_each_arb[bank]),
            .data_i                         (buf_raddr_slice),
            .data_o                         (buf_raddr_bank[bank])
        );
    end
endgenerate

generate
    for(slice=0; slice<`CBN; slice=slice+1) begin: DOUT_MUX_SLICE
        mux #(
            .DWIDTH                         (`QW),
            .WAYS                           (`CBN)
        )dout_mux(
            .sel                            (fill_grt[slice]),
            .data_i                         (buf_dout),
            .data_o                         (crossbar_data_o[slice])
        );
    end
endgenerate


/* Valid and Ready Pulse-Toggle Converting */
logic ready_i_tg_s1, ready_i_tg_s2, ready_i_tg_s3;
always @(posedge clk_bufr or negedge rstn_bufr) begin // ready signal synchronization
    if(~rstn_bufr) begin
        ready_i_tg_s1 <= 0;
        ready_i_tg_s2 <= 0;
        ready_i_tg_s3 <= 0;
    end else begin
        ready_i_tg_s1 <= ready_i_tg;
        ready_i_tg_s2 <= ready_i_tg_s1;
        ready_i_tg_s3 <= ready_i_tg_s2;
    end
end

assign ready_i_pulse = ready_i_tg_s3 ^ ready_i_tg_s2;

assign now_is_valid = vector_read_sel ? pong_valid : ping_valid;

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        now_is_valid_s1 <= 0;
    end else begin
        now_is_valid_s1 <= now_is_valid;
    end
end

localparam READY = 1'b0;
logic mcp_state, nxt_mcp_state;

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        mcp_state <= READY;
    end else begin
        mcp_state <= nxt_mcp_state;
    end
end

always_comb begin
    case(mcp_state)
        READY: begin
            nxt_mcp_state = now_is_valid ? BUSY : mcp_state;
        end
        BUSY: begin
            nxt_mcp_state = ready_i_pulse ? READY : mcp_state;
        end
    endcase
end

assign valid_o_pulse = now_is_valid & (~now_is_valid_s1);
assign now_is_ready = (mcp_state == READY);

always @(posedge clk_bufr or negedge rstn_bufr) begin
    if(~rstn_bufr) begin
        valid_o_tg <= 0;
        for(int i=0; i<`CBN; i=i+1) begin
            for(int j=0; j<`XH/`CBN; j=j+1) begin
                mcp_vector[i][j] <= 0;
            end
        end
    end else begin
        if(now_is_valid & now_is_ready) begin
            valid_o_tg <= ~valid_o_tg;
            mcp_vector <= vector_read_sel ? pong_vector : ping_vector;
        end
    end
end

/* Output Data Control */
always_comb begin
    for(int i=0; i<`CBN; i=i+1) begin
        for(int j=0; j<`XH/`CBN; j=j+1) begin
            data_o[i*(`XH/`CBN)+j] = mcp_vector[i][j];
        end
    end
end

/* For Debugging */
int flog;
initial begin
    // flog = $fopen($sformatf("./log/im2col_tile_%0d_%0d.log", x, y), "w");
    forever begin
        @(posedge clk_bufr)
        if(& fill_done) begin
            $display("time %0t: Vector fill done, now of_x: %0d, now of_y %0d", $time, of_x, of_y);
            // $fwrite(flog, "time %0t: Vector fill done, now of_x: %0d, now of_y %0d\n", $time, of_x, of_y);
            // $fflush(flog);
        end
    end
end

endmodule