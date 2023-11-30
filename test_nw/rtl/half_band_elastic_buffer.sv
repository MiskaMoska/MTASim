module half_band_elastic_buffer #(
    parameter   DW = 16
)(
    input clk, rstn,
    input [DW-1:0] din,
    output reg [DW-1:0] dout,
    input valid_i, ready_i,
    output valid_o, ready_o
);

reg full;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        full <= 0;
        dout <= 0;
    end else begin
        if(valid_i & ready_o) begin 
            full <= 1;
            dout <= din;
        end else if(valid_o & ready_i) begin
            full <= 0;
        end
    end
end

assign ready_o = ~full;
assign valid_o = full;

endmodule
