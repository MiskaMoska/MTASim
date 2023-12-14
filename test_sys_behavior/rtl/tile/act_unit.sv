`include "params.svh"

module act_unit #(
    parameter bit has_act = 0
)(
    input   logic   [`QW-1 : 0]     data_i [`XW],
    input   logic                   valid_i,
    output  logic                   ready_o,

    output  logic   [`QW-1 : 0]     data_o [`XW],
    output  logic                   valid_o,
    input   logic                   ready_i
);

genvar c;
generate
    if(has_act) begin: ACTIVE_ACT
        for(c=0; c<`XW; c=c+1) begin
            always_comb begin
                data_o[c] = $shortrealtobits(
                    $max($bitstoshortreal(data_i[c]), 0)
                );
            end
        end
    end
    else begin: BYPASS_ACT
        assign data_o = data_i;
    end
endgenerate

assign valid_o = valid_i;
assign ready_o = ready_i;

endmodule