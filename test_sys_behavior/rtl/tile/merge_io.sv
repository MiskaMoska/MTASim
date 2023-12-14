`include "params.svh"

module merge_io #(
    parameter int valid_chans = 128
)(
    input   logic                   clk_nw,
    input   logic                   clk_tl,
    input   logic                   rstn_nw,
    input   logic                   rstn_tl,
    
    input   logic   [`QW-1 : 0]     nw_data_i,
    input   logic                   nw_valid_i,
    output  logic                   nw_ready_o,

    output  logic   [`QW-1 : 0]     tl_data_o [`XW],
    output  logic                   tl_valid_o,
    input   logic                   tl_ready_i,

    input   logic   [`QW-1 : 0]     tl_data_i [`XW],
    input   logic                   tl_valid_i,
    output  logic                   tl_ready_o,

    output  logic   [`QW-1 : 0]     nw_data_o,
    output  logic                   nw_valid_o,
    input   logic                   nw_ready_i
);

logic ibuf_empty, obuf_empty;
logic ibuf_full, obuf_full;

logic [`QW-1 : 0] tl_data_o_reg [valid_chans-1];

logic [`QW-1 : 0] obuf_din;
logic [`QW-1 : 0] ibuf_dout;

logic [$clog2(`XW)-1 : 0] icnt;
logic [$clog2(`XW)-1 : 0] ocnt;

asyn_fifo #(
    .AW                         (3),
    .DW                         (`QW) 
)ibuf(
    .clka                       (clk_nw),
    .clkb                       (clk_tl),
    .rstna                      (rstn_nw),
    .rstnb                      (rstn_tl),

    .din                        (nw_data_i),
    .dout                       (ibuf_dout),

    .write                      (nw_valid_i & nw_ready_o),
    .read                       ((icnt == valid_chans - 1) ? ~ibuf_empty & tl_ready_i : ~ibuf_empty),

    .full                       (ibuf_full),
    .empty                      (ibuf_empty)
);

assign nw_ready_o = ~ibuf_full;

asyn_fifo #(
    .AW                         (3),
    .DW                         (`QW) 
)obuf(
    .clka                       (clk_tl),
    .clkb                       (clk_nw),
    .rstna                      (rstn_tl),
    .rstnb                      (rstn_nw),

    .din                        (obuf_din),
    .dout                       (nw_data_o),

    .write                      (~obuf_full & tl_valid_i),
    .read                       (nw_valid_o & nw_ready_i),

    .full                       (obuf_full),
    .empty                      (obuf_empty)
);

assign nw_valid_o = ~obuf_empty;

always @(posedge clk_tl or negedge rstn_tl) begin
    if(~rstn_tl) begin
        icnt <= 0;
    end else begin
        if(~ibuf_empty) begin
            if(icnt == valid_chans - 1) begin
                if(tl_ready_i) begin
                    icnt <= 0;
                end
            end else begin
                icnt <= icnt + 1;
            end
        end
    end
end

always @(posedge clk_tl or negedge rstn_tl) begin
    if(~rstn_tl) begin
        for(int i=0; i<valid_chans-1; i=i+1) begin
            tl_data_o_reg[i] <= 0;
        end
    end else begin
        if((icnt != valid_chans - 1) & (~ibuf_empty)) begin
            tl_data_o_reg[icnt] <= ibuf_dout;
        end
    end
end

always_comb begin
    for(int i=0; i<`XW; i=i+1) begin
        if(i<valid_chans-1) begin
            tl_data_o[i] = tl_data_o_reg[i];
        end else if (i==valid_chans-1) begin
            tl_data_o[i] = ibuf_dout;
        end else begin
            tl_data_o[i] = 0;
        end
    end
end

assign tl_valid_o = (~ibuf_empty) & (icnt == valid_chans-1);

always @(posedge clk_tl or negedge rstn_tl) begin
    if(~rstn_tl) begin
        ocnt <= 0;
    end else begin
        if(tl_valid_i & ~obuf_full) begin
            if(ocnt == valid_chans - 1) begin
                ocnt <= 0;
            end else begin
                ocnt <= ocnt + 1;
            end
        end
    end
end

assign obuf_din = tl_data_i[ocnt];
assign tl_ready_o = (ocnt == valid_chans - 1) & (~obuf_full);

endmodule