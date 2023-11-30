`include "params.svh"

module cast_input_port_stage #(
    parameter bit [`PN-1:0] routing_table [`VN] = '{(`VN){{(`PN){1'b0}}}}
)(
    input   wire                clk,
    input   wire                rstn,
    
    // data path inputs
    input   wire    [`VN-1:0]   vc_i, // input VC indicator, synchronous with data
    input   wire    [`DW-1:0]   data_i,
    input   wire                valid_i,
    output  wire                ready_o,

    // data path outputs
    output  wire    [`DW-1:0]   data_o [`VN],
    output  wire                valid_o [`VN],
    input   wire                ready_i [`VN], // req_port selected output port ready signal

    // control path outputs
    output  wire    [`PN-1:0]   req_port [`VN] // for crossbar selecting
);

bit     [`PN-1:0]   roll_ind [`VN];
bit     [`PN-1:0]   roll_init_val [`VN] [`PN];

wire                fifo_read [`VN];
wire                fifo_write [`VN];
wire                fifo_full [`VN];
wire                fifo_empty [`VN];
wire    [`DW-1:0]   fifo_dout [`VN];

// indicate when to fire a flit
wire                fire [`VN]; 

// wire    [`PN-1:0]   req_port [`VN];
wire                last [`VN];


/* 
    this block is for parameter configuration,
    this procedure exists only in half-software-half-rtl modeling, and 
    need to be replaced by hardware power-on configuration in ASIC design
*/
int j;
initial begin
    for(int vc=0; vc<`VN; vc=vc+1) begin
        roll_ind[vc] = {(`PN){1'b0}};
        roll_init_val[vc] = '{(`PN){{(`PN){1'b0}}}};
    end
    for(int vc=0; vc<`VN; vc=vc+1) begin
        j=0;
        for(int i=0; i<`PN; i=i+1) begin
            if(routing_table[vc][i]) begin
                roll_ind[vc] = (1 << j);
                roll_init_val[vc][j] = (1 << i);
                j = j + 1;
            end
        end
    end
end


/* input data dispatched to different VCs */
genvar vc;
generate
    for(vc=0; vc<`VN; vc=vc+1) begin: INPUT_VC
        syn_fifo #(
            .width                   (`DW),
            .depth                   (4),
            .depth_LOG               (2),
            .FWFT                    (1)
        )fifo(
            .clk_i                   (clk),
            .rst_i                   (~rstn),
            .read_i                  (fifo_read[vc]),
            .write_i                 (fifo_write[vc]),
            .full_o                  (fifo_full[vc]),
            .empty_o                 (fifo_empty[vc]),
            .data_i                  (data_i),
            .data_o                  (data_o[vc])
        );

        cast_routing_table_roller rtr(
            .roll_ind                (roll_ind[vc]), 
            .roll_init_val           (roll_init_val[vc]),

            .clk                     (clk),
            .rstn                    (rstn),
            .en                      (fire[vc]), // enable rolling once
            .req_port                (req_port[vc]), // output request port
            .last                    (last[vc]) // indicate this is the last transfer of the current flit, only for unicast-based-multicast
        );

        assign fire[vc] = ready_i[vc] & valid_o[vc];

        // only when the last transfer of the current data is traversed
        // can the current data be read out from the FIFO
        assign fifo_read[vc] = fire[vc] & last[vc];

        assign fifo_write[vc] = ~fifo_full[vc] & valid_i & vc_i[vc];
        assign valid_o[vc] = ~fifo_empty[vc];
    end
endgenerate

/* input ready_o multiplexer */
logic is_full;
assign ready_o = ~is_full;

mux #(
    .DWIDTH             (1),
    .WAYS               (`VN)
)mux_ready(
    .sel                (vc_i),
    .data_i             (fifo_full),
    .data_o             (is_full)
);

endmodule