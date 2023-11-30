/* 
    arbitration and transfer for data from different VCs
    arbitration and transfer is accomplished in one cycle
*/
`include "params.svh"

module cast_output_arbitration(
    input   wire                clk,
    input   wire                rstn,

    input   wire    [`DW-1:0]   data_i [`VN],
    input   wire                valid_i [`VN],
    output  wire                ready_o [`VN],

    output  wire    [`VN-1:0]   vc_o,
    output  wire    [`DW-1:0]   data_o,
    output  wire                valid_o,
    input   wire                ready_i
);

wire    [`DW-1:0]   data_piped [`VN];
wire                valid_piped [`VN];

logic   [`VN-1:0]   arb_request;
logic   [`VN-1:0]   arb_grant;

genvar vc;
generate
    for(vc=0; vc<`VN; vc=vc+1) begin: VC

        full_band_elastic_buffer #(
            .DW                 (`DW)
        )stage(
            .clk                (clk), 
            .rstn               (rstn),
            .din                (data_i[vc]),
            .dout               (data_piped[vc]),
            .valid_i            (valid_i[vc]),
            .valid_o            (valid_piped[vc]),
            .ready_o            (ready_o[vc]),
            .ready_i            (arb_grant[vc] & ready_i)
        );

        // reg_pipeline_stage #(
        //     .DWIDTH             (`DW)
        // )stage(
        //     .clk                (clk),
        //     .rstn               (rstn),
        //     .data_i             (data_i[vc]),
        //     .data_o             (data_piped[vc]),
        //     .valid_i            (valid_i[vc]),
        //     .valid_o            (valid_piped[vc]),
        //     .ready_o            (ready_o[vc]),
        //     .ready_i            (arb_grant[vc] & ready_i)
        // );
        assign arb_request[vc] = valid_piped[vc];
    end
endgenerate

mtx_arbiter #(
    .LEN            (`VN)
)arbiter(
    .clk            (clk),
    .rstn           (rstn),
    .request        (arb_request),
    .grant          (arb_grant),
    .update         (| arb_grant)
);

mux #(
    .DWIDTH         (`DW),
    .WAYS           (`VN)
)mux_data(
    .sel            (arb_grant),
    .data_i         (data_piped),
    .data_o         (data_o)
);

mux #(
    .DWIDTH         (1),
    .WAYS           (`VN)
)mux_valid(
    .sel            (arb_grant),
    .data_i         (valid_piped),
    .data_o         (valid_o)
);

assign vc_o = arb_grant;

endmodule