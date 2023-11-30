`include "params.svh"

module bias_unit #(
    parameter bit has_bias = 0
)(
    input   logic   [`QW-1 : 0]     data_i [`XW],
    input   logic                   valid_i,
    output  logic                   ready_o,

    output  logic   [`QW-1 : 0]     data_o [`XW],
    output  logic                   valid_o,
    input   logic                   ready_i
);

shortreal biases [`XW];

genvar c;
generate 
if(has_bias) begin: ACTIVE_BIAS
    for(c=0; c<`XW; c=c+1) begin: BIAS_CHAN
        always_comb begin
            data_o[c] = $shortrealtobits(
                $bitstoshortreal(data_i[c]) + biases[c]
            );
        end
    end
end
else begin: BYPASS_BIAS
    genvar c;
    for(c=0; c<`XW; c=c+1) begin: BIAS_CHAN
        assign data_o[c] = data_i[c];
    end
end
endgenerate

assign valid_o = valid_i;
assign ready_o = ready_i;

endmodule