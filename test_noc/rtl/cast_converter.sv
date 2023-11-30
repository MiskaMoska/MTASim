`include "params.svh"

module cast_converter #(
    parameter   int                     cast_in_vc    = 0,
    parameter   int                     gather_in_vc  = 0,
    parameter   int                     cast_out_vc   = 0,
    parameter   int                     gather_out_vc = 0,
    parameter   int                     is_cast_out   = 0,
    parameter   int                     is_gather_out = 0
)(
    input       wire                    clk,
    input       wire                    rstn,

    // router end
    input       wire    [`VN-1:0]       local_vc_i,
    input       wire    [`DW-1:0]       local_data_i,
    input       wire                    local_valid_i,
    output      wire                    local_ready_o,

    output      wire    [`VN-1:0]       local_vc_o,
    output      wire    [`DW-1:0]       local_data_o,
    output      wire                    local_valid_o,
    input       wire                    local_ready_i,

    // tile end
    input       wire    [`DW-1:0]       cast_gather_data_i,
    input       wire                    cast_gather_valid_i,
    output      wire                    cast_gather_ready_o,

    output      wire    [`DW-1:0]       cast_data_o,
    output      wire                    cast_valid_o,
    input       wire                    cast_ready_i,

    output      wire    [`DW-1:0]       gather_data_o,
    output      wire                    gather_valid_o,
    input       wire                    gather_ready_i
);


// from router to tile
assign cast_data_o = local_data_i;
assign gather_data_o = local_data_i;
assign cast_valid_o = local_valid_i & (local_vc_i == (1<<cast_in_vc));
assign gather_valid_o = local_valid_i & (local_vc_i == (1<<gather_in_vc));
assign local_ready_o = (local_vc_i == (1<<cast_in_vc)) & cast_ready_i | (local_vc_i == (1<<gather_in_vc)) & gather_ready_i;

// from tile to router
reg state; 
wire full_state;

// when cast_out_vc == gather_out_vc, (hote that this is logal), there is no need to copy the data 
// to seperate VCs, the router whill copy it automatically
assign full_state = is_gather_out & is_cast_out & (cast_out_vc != gather_out_vc);

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= 0;
    end else begin
        if(cast_gather_valid_i & local_ready_i) begin
            if(state == full_state) state <= 0;
            else state <= state + 1;
        end
    end
end

assign local_vc_o = (is_cast_out & is_gather_out & (cast_out_vc != gather_out_vc)) ? (state ? (1<<gather_out_vc) : (1<<cast_out_vc)): (
                    is_cast_out ? (1<<cast_out_vc) : (1<<gather_out_vc));

assign local_data_o = cast_gather_data_i;
assign local_valid_o = cast_gather_valid_i;
assign cast_gather_ready_o = (is_cast_out & is_gather_out & (cast_out_vc != gather_out_vc)) ? state & local_ready_i : local_ready_i;

endmodule