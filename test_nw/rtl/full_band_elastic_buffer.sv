module full_band_elastic_buffer #(
    parameter DW = 16
)(
    input   wire    clk, rstn,
    input   wire    [DW-1:0] din,
    output  wire    [DW-1:0] dout,
    input   wire    valid_i, ready_i,
    output  wire    valid_o, ready_o
);

reg head, tail;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        head <= 0;
        tail <= 0;
    end else begin
        if(valid_i & ready_o) head <= ~head;
        if(valid_o & ready_i) tail <= ~tail;
    end
end

logic [DW-1:0] ping_dout;
logic ping_ready_o, ping_valid_o;

logic [DW-1:0] pong_dout;
logic pong_ready_o, pong_valid_o;

half_band_elastic_buffer #(
    DW
)ping(
    clk, rstn,
    din, ping_dout,
    ~head & valid_i,
    ~tail & ready_i,
    ping_valid_o, 
    ping_ready_o
);

half_band_elastic_buffer #(
    DW
)pong(
    clk, rstn,
    din, pong_dout,
    head & valid_i,
    tail & ready_i,
    pong_valid_o, 
    pong_ready_o
);

assign ready_o = ping_ready_o | pong_ready_o;
assign valid_o = ping_valid_o | pong_valid_o;
assign dout = tail ? pong_dout : ping_dout;

endmodule