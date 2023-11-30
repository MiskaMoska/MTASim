module asyn_fifo #(
    parameter   AW = 4,
    parameter   DW = 16
)(
    input   logic               clka,
    input   logic               clkb,
    input   logic               rstna,
    input   logic               rstnb

    input   logic   [DW-1:0]    din,
    output  logic   [DW-1:0]    dout,

    input   logic               write,
    input   logic               read,

    output  logic               full,
    output  logic               empty
);

logic [AW:0] waddr_bin, raddr_bin;
logic [AW:0] waddr_gray, raddr_gray;
logic [AW:0] nxt_waddr_bin, nxt_waddr_gray;
logic [AW:0] nxt_raddr_bin, nxt_raddr_gray;
logic [AW:0] raddr_gray_1, raddr_gray_2;
logic [AW:0] waddr_gray_1, waddr_gray_2;

/* dual port RAM */
sdpram #(
    AW, DW
)ram(
    clka, clkb,
    write & ~full,
    waddr_bin[AW-1:0], 
    raddr_bin[AW-1:0],
    din, dout
);

/* write addr generate */
assign nxt_waddr_bin = waddr_bin + (write & ~full);
assign nxt_waddr_gray = (nxt_waddr_bin >> 1) ^ nxt_waddr_bin;

always @(posedge clka or negedge rstna) begin
    if(~rstna) begin
        waddr_bin <= 0;
        waddr_gray <= 0;
    end else begin
        waddr_bin <= nxt_waddr_bin;
        waddr_gray <= nxt_waddr_gray;
    end
end


/* read addr generate */
assign nxt_raddr_bin = raddr_bin + (read & ~empty);
assign nxt_raddr_gray = (nxt_raddr_bin >> 1) ^ nxt_raddr_bin;

always @(posedge clkb or negedge rstnb) begin
    if(~rstnb) begin
        raddr_bin <= 0;
        raddr_gray <= 0;
    end else begin
        raddr_bin <= nxt_raddr_bin;
        raddr_gray <= nxt_raddr_gray;
    end
end

/* sync */
always @(posedge clka or negedge rstna) begin
    if(~rstna) begin
        raddr_gray_1 <= 0;
        raddr_gray_2 <= 0;
    end else begin
        raddr_gray_1 <= raddr_gray;
        raddr_gray_2 <= raddr_gray_1;
    end
end

always @(posedge clkb or negedge rstnb) begin
    if(~rstnb) begin
        waddr_gray_1 <= 0;
        waddr_gray_2 <= 0;
    end else begin
        waddr_gray_1 <= waddr_gray;
        waddr_gray_2 <= waddr_gray_1;
    end
end

/* full signal generate */
assign full = (& (waddr_gray[AW:AW-1] ^ raddr_gray_2[AW:AW-1])) & 
                (waddr_gray[AW-2:0] == raddr_gray_2[AW-2:0]);

/* empty signal generate */
assign empty = raddr_gray == waddr_gray_2;
    
endmodule