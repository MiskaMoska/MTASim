//Not a behavior Tile model, but a "virtual" Tile model
//This Tile model only simulates the data dependencies between different network interfaces, but does not simulate the computational behavior of the Tile
//This Tile model can only be used to verify where there exist deadlocks in the whole network
`include "params.svh"
`include "tile_config.svh"

module virtual_tile #(
    parameter   int                             cast_out = 0,
    parameter   int                             merge_in = 0,
    parameter   int                             merge_out = 0,
    parameter   int                             gather_in = 0,
    parameter   int                             gather_out = 0,
    parameter   int                             x = 0,
    parameter   int                             y = 0
)(
    input       wire                            clk,
    input       wire                            rstn, 

    // cast in
    input       wire        [`DW-1:0]           cast_data_i,
    input       wire                            cast_valid_i,
    output      wire                            cast_ready_o,

    // merge in
    input       wire        [`DW-1:0]           merge_data_i,
    input       wire                            merge_valid_i,
    output      wire                            merge_ready_o,

    // gather in 
    input       wire        [`DW-1:0]           gather_data_i,
    input       wire                            gather_valid_i,
    output      wire                            gather_ready_o,

    //cast gather out
    output      wire        [`DW-1:0]           cast_gather_data_o,
    output      wire                            cast_gather_valid_o,
    input       wire                            cast_gather_ready_i,

    // merge out
    output      wire        [`DW-1:0]           merge_data_o,
    output      wire                            merge_valid_o,
    input       wire                            merge_ready_i
);

// for cast/gather receive buffer
localparam receive_depth_log = 2;

// All xbars have cast_in
wire valid_all; // cast_in, [merge_in], [gather_in] all valid (only for merge_out == 0)
wire ready_all; // [cast_out], [gather_out] all valid (only for merge_out == 0)
wire [`DW-1 : 0] data_sum;

int crcnt = 0;
int mrcnt = 0;
int grcnt = 0;
int scnt = 0;

always@(posedge clk) begin
    if(cast_valid_i & cast_ready_o) crcnt <= crcnt + 1;
    if(merge_valid_i & merge_ready_o) mrcnt <= mrcnt + 1;
    if(gather_valid_i & gather_ready_o) grcnt <= grcnt + 1;
    if(crcnt == 0 && cast_valid_i && cast_ready_o)
        $display("time %0t: node (%0d, %0d) starting computing ...", $time, x, y);
end


always@(posedge clk) begin
    if(merge_out == 1) begin
        if(merge_valid_o & merge_ready_i) begin
            scnt <= scnt + 1;
            if(scnt == 999) 
                $display("time %0t: node (%0d, %0d) finished computing ...", $time, x, y);
        end
    end else begin
        if(valid_all & ready_all) begin
            scnt <= scnt + 1;
            if(scnt == 999)
                $display("time %0t: node (%0d, %0d) finished computing ...", $time, x, y);
        end
    end
end

wire cast_rbuf_empty, cast_rbuf_full, cast_rbuf_read;
wire cast_valid_i_, _cast_ready_o;
wire [`DW-1:0] cast_data_i_;
assign cast_valid_i_ = ~cast_rbuf_empty;
assign cast_rbuf_read = cast_valid_i_ & _cast_ready_o;

wire gather_rbuf_empty, gather_rbuf_full, gather_rbuf_read;
wire gather_valid_i_, _gather_ready_o;
wire [`DW-1:0] gather_data_i_;
assign gather_valid_i_ = ~gather_rbuf_empty;
assign gather_rbuf_read = gather_valid_i_ & _gather_ready_o;

// cast receive buffer, infinity
network_fifo #(
    .width                   (`DW),
    .depth                   (2**receive_depth_log),
    .depth_LOG               (receive_depth_log),
    .FWFT                    (1)
)cast_receive_fifo(
    .clk_i                   (clk),
    .rst_i                   (~rstn),
    .read_i                  (cast_rbuf_read),
    .write_i                 (cast_valid_i),
    .empty_o                 (cast_rbuf_empty),
    .full_o                  (cast_rbuf_full),
    .data_i                  (cast_data_i),
    .data_o                  (cast_data_i_)
);

// gather receive buffer, infinity
network_fifo #(
    .width                   (`DW),
    .depth                   (2**receive_depth_log),
    .depth_LOG               (receive_depth_log),
    .FWFT                    (1)
)gather_receive_fifo(
    .clk_i                   (clk),
    .rst_i                   (~rstn),
    .read_i                  (gather_rbuf_read),
    .write_i                 (gather_valid_i),
    .empty_o                 (gather_rbuf_empty),
    .full_o                  (gather_rbuf_full),
    .data_i                  (gather_data_i),
    .data_o                  (gather_data_i_)
);

assign valid_all = cast_valid_i_ & 
                    (merge_in == 1 ? merge_valid_i : 1'b1) &
                    (gather_in == 1 ? gather_valid_i_ : 1'b1);

assign ready_all = cast_gather_ready_i; 
// assign data_sum = cast_data_i_; // no need to add, only simulate dependency
assign data_sum = (gather_in == 1) ? gather_data_i_ : cast_data_i_; // no need to add, only simulate dependency
assign cast_gather_valid_o = (merge_out == 0) & valid_all;
assign _cast_ready_o = (merge_out == 0) ? valid_all & ready_all : merge_ready_i; // ready to buffer out
assign cast_ready_o = ~cast_rbuf_full; // ready to outside
assign _gather_ready_o = (merge_out == 0) ? (gather_in == 1) & valid_all & ready_all : 1'b0; // ready to buffer out
assign gather_ready_o = ~gather_rbuf_full; // ready to outside
assign merge_ready_o = (merge_out == 0) ? (merge_in == 1) & valid_all & ready_all : 1'b0;
assign merge_valid_o = (merge_out == 1) & cast_valid_i_;
assign merge_data_o = data_sum;
assign cast_gather_data_o = data_sum;

// credit updating assignment
// assign cast_credit_upd = {31'b0, cast_rbuf_read};
// assign gather_credit_upd = {31'b0, gather_rbuf_read};

endmodule