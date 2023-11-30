module sdpram #(
    parameter AW = 16,
    parameter DW = 16
)(
    input   logic clka,
    input   logic clkb,
    input   logic wea,
    input   logic [AW-1:0] addra,
    input   logic [AW-1:0] addrb,
    input   logic [DW-1:0] dia,
    output  logic [DW-1:0] dob
);

reg [DW-1:0] ram [0:(1<<AW)-1];

always @(posedge clka) begin
    if (wea) ram[addra] <= dia;
end

assign dob = ram[addrb];

endmodule