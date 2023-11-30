/*
    Cast router with VC-isolated crossbars
    [0]-local [1]-west [2]-east [3]-north [4]-south
*/
`include "params.svh"

module cast_router #(
    parameter bit [`PN-1:0] routing_table [`PN] [`VN] = '{(`PN){'{(`VN){{(`PN){1'b0}}}}}}
)(
    input   wire                clk,
    input   wire                rstn,

    input   wire    [`VN-1:0]   vc_i [`PN],
    input   wire    [`DW-1:0]   data_i [`PN],
    input   wire                valid_i [`PN],
    output  wire                ready_o [`PN],
    
    output  wire    [`VN-1:0]   vc_o [`PN],
    output  wire    [`DW-1:0]   data_o [`PN],
    output  wire                valid_o [`PN],
    input   wire                ready_i [`PN]
);

// data path signals
logic   [`DW-1:0]   data_istage_pv [`PN] [`VN]; // data from input_port_stage
logic   [`DW-1:0]   data_istage_vp [`VN] [`PN]; // data to crossbar
logic               valid_istage_pv [`PN] [`VN]; // valid from input_port_stage
logic               valid_istage_vp [`VN] [`PN]; // valid to crossbar
logic               ready_istage_vp [`VN] [`PN]; // ready from crossbar
logic               ready_istage_pv [`PN] [`VN]; // ready to input_port_stage

logic   [`DW-1:0]   data_ostage_vp [`VN] [`PN]; // data from crossbar
logic   [`DW-1:0]   data_ostage_pv [`PN] [`VN]; // data to output_arbitration
logic               valid_ostage_vp [`VN] [`PN]; // valid from crossbar
logic               valid_ostage_pv [`PN] [`VN]; // valid to output_arbitration
logic               ready_ostage_pv [`PN] [`VN]; // ready from output_arbitration
logic               ready_ostage_vp [`VN] [`PN]; // ready to crossbar

// control path signals
logic   [`PN-1:0]   xbar_sel_i_pv [`PN] [`VN]; // connected from input_port_stage
logic   [`PN-1:0]   xbar_sel_i_vp [`VN] [`PN]; // connected to crossbar

// transposing
always_comb begin
    for(int i=0; i<`PN; i=i+1) begin
        for(int j=0; j<`VN; j=j+1) begin
            data_istage_vp[j][i] = data_istage_pv[i][j];
            valid_istage_vp[j][i] = valid_istage_pv[i][j];
            ready_istage_pv[i][j] = ready_istage_vp[j][i];

            data_ostage_pv[i][j] = data_ostage_vp[j][i];
            valid_ostage_pv[i][j] = valid_ostage_vp[j][i];
            ready_ostage_vp[j][i] = ready_ostage_pv[i][j];

            xbar_sel_i_vp[j][i] = xbar_sel_i_pv[i][j];
        end
    end
end

genvar pt;
generate
    for(pt=0; pt<`PN; pt=pt+1) begin: INPUT_PORT
        cast_input_port_stage #(
            .routing_table              (routing_table[pt])
        )istage(
            .clk                        (clk),
            .rstn                       (rstn),
            
            // data path inputs
            .vc_i                       (vc_i[pt]), // input VC indicator, synchronous with data
            .data_i                     (data_i[pt]),
            .valid_i                    (valid_i[pt]),
            .ready_o                    (ready_o[pt]),

            // data path outputs
            .data_o                     (data_istage_pv[pt]),
            .valid_o                    (valid_istage_pv[pt]),
            .ready_i                    (ready_istage_pv[pt]),

            // control path outputs
            .req_port                   (xbar_sel_i_pv[pt]) // for ready mux
        );
    end
endgenerate

genvar vc;
generate
    for(vc=0; vc<`VN; vc=vc+1) begin: VIRTUAL_CHANNEL

        cast_crossabr xbar(
            .xbar_sel_i                 (xbar_sel_i_vp[vc]), // selection signal for each input port 

            .data_i                     (data_istage_vp[vc]), // data signal from each input port
            .valid_i                    (valid_istage_vp[vc]), // valid signal from each input port
            .ready_i                    (ready_ostage_vp[vc]), // ready signal from each output port

            .data_o                     (data_ostage_vp[vc]), // data signal to each output port
            .valid_o                    (valid_ostage_vp[vc]), // valid signal to each output port
            .ready_o                    (ready_istage_vp[vc]) // ready signal to each input port
        );

    end
endgenerate

generate
    for(pt=0; pt<`PN; pt=pt+1) begin: OUTPUT_PORT
        cast_output_arbitration ostage(
            .clk                        (clk),
            .rstn                       (rstn),

            .data_i                     (data_ostage_pv[pt]),
            .valid_i                    (valid_ostage_pv[pt]),
            .ready_o                    (ready_ostage_pv[pt]),

            .vc_o                       (vc_o[pt]),
            .data_o                     (data_o[pt]),
            .valid_o                    (valid_o[pt]),
            .ready_i                    (ready_i[pt])
        );
    end
endgenerate

endmodule