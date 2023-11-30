`include "params.svh"

module cast_routing_table_roller(
    input   bit     [`PN-1:0]       roll_ind, // onehot-encoded rolling indicator
    input   bit     [`PN-1:0]       roll_init_val [`PN], // initial value for rolling registers

    input   wire                    clk,
    input   wire                    rstn,
    input   wire                    en, // enable rolling once
    output  wire    [`PN-1:0]       req_port, // output request port
    output  wire                    last // indicate this is the last transfer of the current flit, only for unicast-based-multicast
);

reg [`PN-1:0] roll_reg [0:`PN-1]; // rolling registers
reg ind_reg [0:`PN-1]; // indicator registers

wire [`PN-1:0] roll_reg_i [0:`PN-1]; // input ports of rolling registers
wire ind_reg_i [0:`PN-1]; // input ports of indicator registers

genvar i;
generate
    for(i=0; i<`PN; i=i+1) begin
        if(i == `PN-1) begin
            assign roll_reg_i[i] = roll_ind[i] ? roll_reg[0] : 0;
            assign ind_reg_i[i] = roll_ind[i] ? ind_reg[0] : 0;
        end else begin
            assign roll_reg_i[i] = roll_ind[i] ? roll_reg[0] : roll_reg[i+1];
            assign ind_reg_i[i] = roll_ind[i] ? ind_reg[0] : ind_reg[i+1];
        end
    end
endgenerate

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        for(int j=0; j<`PN; j=j+1) begin
            roll_reg[j] <= roll_init_val[j];
            ind_reg[j] <= roll_ind[j];
        end
    end else begin
        for(int j=0; j<`PN; j=j+1) begin
            if(en) begin
                roll_reg[j] <= roll_reg_i[j];
                ind_reg[j] <= ind_reg_i[j];
            end
        end
    end
end

assign last = ind_reg[0];
assign req_port = roll_reg[0];

endmodule