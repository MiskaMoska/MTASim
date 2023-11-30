`include "params.svh"

module cast_crossabr(
    input   wire    [`PN-1:0]   xbar_sel_i [`PN], // selection signal for each input port

    input   wire    [`DW-1:0]   data_i [`PN], // data signal from each input port
    input   wire                valid_i [`PN], // valid signal from each input port
    input   wire                ready_i [`PN], // ready signal from each output port

    output  wire    [`DW-1:0]   data_o [`PN], // data signal to each output port
    output  wire                valid_o [`PN], // valid signal to each output port
    output  wire                ready_o [`PN] // ready signal to each input port
);

logic [`PN-1:0] xbar_sel_o [`PN];

always_comb begin
    for(int i=0; i<`PN; i=i+1) begin
        for(int j=0; j<`PN; j=j+1) begin
            xbar_sel_o[i][j] = xbar_sel_i[j][i];
        end
    end
end

genvar pt;
generate
    for(pt=0; pt<`PN; pt=pt+1) begin: OUTPUT_PORT
        mux #(
            .DWIDTH             (`DW),
            .WAYS               (`PN)
        )mux_data(
            .sel                (xbar_sel_o[pt]),
            .data_i             (data_i),
            .data_o             (data_o[pt])
        );

        mux #(
            .DWIDTH             (1),
            .WAYS               (`PN)
        )mux_valid(
            .sel                (xbar_sel_o[pt]),
            .data_i             (valid_i),
            .data_o             (valid_o[pt])
        );
    end
endgenerate

generate
    for(pt=0; pt<`PN; pt=pt+1) begin: INPUT_PORT
        mux #(
            .DWIDTH             (1),
            .WAYS               (`PN)
        )mux_ready(
            .sel                (xbar_sel_i[pt]),
            .data_i             (ready_i),
            .data_o             (ready_o[pt])
        );
    end
endgenerate

endmodule