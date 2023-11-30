/* register-based pipeline stage */
module reg_pipeline_stage #(
    parameter DWIDTH = 16
)(
    input   wire    clk,
    input   wire    rstn,

    input   wire    [DWIDTH-1:0]    data_i,
    output  reg     [DWIDTH-1:0]    data_o,

    input   wire    valid_i,
    output  reg     valid_o,

    output  wire    ready_o,
    input   wire    ready_i
);

assign ready_o = ~valid_o | ready_i;

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        data_o <= 0;
        valid_o <= 0;
    end 
    else if(valid_i & ready_o) begin
        data_o <= data_i;
        valid_o <= valid_i;
    end 
    else if(valid_o & ready_i) begin
        valid_o <= 1'b0;
    end
end

endmodule