module mux #(
    parameter DWIDTH = 16,
    parameter WAYS = 4
)(  
    input   wire    [WAYS-1:0]      sel,
    input   wire    [DWIDTH-1:0]    data_i [WAYS],
    output  logic   [DWIDTH-1:0]    data_o
);

always_comb begin
    data_o = 0;
    for(int i=0; i<WAYS; i=i+1) begin
        data_o |= {(DWIDTH){sel[i]}} & data_i[i];
    end
end

endmodule