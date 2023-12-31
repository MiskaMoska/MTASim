
//Merge Network
//Width: 5
//Height:10

`include "params.svh"
`include "merge_network_config.svh"

module merge_network(
    input       wire                            clk,
    input       wire                            rstn,

    //router local ports
    input       wire        [`DW-1:0]           data_i [`NW] [`NH],
    input       wire                            valid_i [`NW] [`NH],
    output      reg                             ready_o [`NW] [`NH],

    output      reg         [`DW-1:0]           data_o [`NW] [`NH],
    output      reg                             valid_o [`NW] [`NH],
    input       wire                            ready_i [`NW] [`NH]
);

logic [`DW-1:0] data_i_0_0[5];
logic valid_i_0_0[5], ready_i_0_0[5];    
logic [`DW-1:0] data_o_0_0[5];
logic valid_o_0_0[5], ready_o_0_0[5];        

logic [`DW-1:0] data_i_0_1[5];
logic valid_i_0_1[5], ready_i_0_1[5];    
logic [`DW-1:0] data_o_0_1[5];
logic valid_o_0_1[5], ready_o_0_1[5];        

logic [`DW-1:0] data_i_0_2[5];
logic valid_i_0_2[5], ready_i_0_2[5];    
logic [`DW-1:0] data_o_0_2[5];
logic valid_o_0_2[5], ready_o_0_2[5];        

logic [`DW-1:0] data_i_0_3[5];
logic valid_i_0_3[5], ready_i_0_3[5];    
logic [`DW-1:0] data_o_0_3[5];
logic valid_o_0_3[5], ready_o_0_3[5];        

logic [`DW-1:0] data_i_0_4[5];
logic valid_i_0_4[5], ready_i_0_4[5];    
logic [`DW-1:0] data_o_0_4[5];
logic valid_o_0_4[5], ready_o_0_4[5];        

logic [`DW-1:0] data_i_0_5[5];
logic valid_i_0_5[5], ready_i_0_5[5];    
logic [`DW-1:0] data_o_0_5[5];
logic valid_o_0_5[5], ready_o_0_5[5];        

logic [`DW-1:0] data_i_0_6[5];
logic valid_i_0_6[5], ready_i_0_6[5];    
logic [`DW-1:0] data_o_0_6[5];
logic valid_o_0_6[5], ready_o_0_6[5];        

logic [`DW-1:0] data_i_0_7[5];
logic valid_i_0_7[5], ready_i_0_7[5];    
logic [`DW-1:0] data_o_0_7[5];
logic valid_o_0_7[5], ready_o_0_7[5];        

logic [`DW-1:0] data_i_0_8[5];
logic valid_i_0_8[5], ready_i_0_8[5];    
logic [`DW-1:0] data_o_0_8[5];
logic valid_o_0_8[5], ready_o_0_8[5];        

logic [`DW-1:0] data_i_0_9[5];
logic valid_i_0_9[5], ready_i_0_9[5];    
logic [`DW-1:0] data_o_0_9[5];
logic valid_o_0_9[5], ready_o_0_9[5];        

logic [`DW-1:0] data_i_1_0[5];
logic valid_i_1_0[5], ready_i_1_0[5];    
logic [`DW-1:0] data_o_1_0[5];
logic valid_o_1_0[5], ready_o_1_0[5];        

logic [`DW-1:0] data_i_1_1[5];
logic valid_i_1_1[5], ready_i_1_1[5];    
logic [`DW-1:0] data_o_1_1[5];
logic valid_o_1_1[5], ready_o_1_1[5];        

logic [`DW-1:0] data_i_1_2[5];
logic valid_i_1_2[5], ready_i_1_2[5];    
logic [`DW-1:0] data_o_1_2[5];
logic valid_o_1_2[5], ready_o_1_2[5];        

logic [`DW-1:0] data_i_1_3[5];
logic valid_i_1_3[5], ready_i_1_3[5];    
logic [`DW-1:0] data_o_1_3[5];
logic valid_o_1_3[5], ready_o_1_3[5];        

logic [`DW-1:0] data_i_1_4[5];
logic valid_i_1_4[5], ready_i_1_4[5];    
logic [`DW-1:0] data_o_1_4[5];
logic valid_o_1_4[5], ready_o_1_4[5];        

logic [`DW-1:0] data_i_1_5[5];
logic valid_i_1_5[5], ready_i_1_5[5];    
logic [`DW-1:0] data_o_1_5[5];
logic valid_o_1_5[5], ready_o_1_5[5];        

logic [`DW-1:0] data_i_1_6[5];
logic valid_i_1_6[5], ready_i_1_6[5];    
logic [`DW-1:0] data_o_1_6[5];
logic valid_o_1_6[5], ready_o_1_6[5];        

logic [`DW-1:0] data_i_1_7[5];
logic valid_i_1_7[5], ready_i_1_7[5];    
logic [`DW-1:0] data_o_1_7[5];
logic valid_o_1_7[5], ready_o_1_7[5];        

logic [`DW-1:0] data_i_1_8[5];
logic valid_i_1_8[5], ready_i_1_8[5];    
logic [`DW-1:0] data_o_1_8[5];
logic valid_o_1_8[5], ready_o_1_8[5];        

logic [`DW-1:0] data_i_1_9[5];
logic valid_i_1_9[5], ready_i_1_9[5];    
logic [`DW-1:0] data_o_1_9[5];
logic valid_o_1_9[5], ready_o_1_9[5];        

logic [`DW-1:0] data_i_2_0[5];
logic valid_i_2_0[5], ready_i_2_0[5];    
logic [`DW-1:0] data_o_2_0[5];
logic valid_o_2_0[5], ready_o_2_0[5];        

logic [`DW-1:0] data_i_2_1[5];
logic valid_i_2_1[5], ready_i_2_1[5];    
logic [`DW-1:0] data_o_2_1[5];
logic valid_o_2_1[5], ready_o_2_1[5];        

logic [`DW-1:0] data_i_2_2[5];
logic valid_i_2_2[5], ready_i_2_2[5];    
logic [`DW-1:0] data_o_2_2[5];
logic valid_o_2_2[5], ready_o_2_2[5];        

logic [`DW-1:0] data_i_2_3[5];
logic valid_i_2_3[5], ready_i_2_3[5];    
logic [`DW-1:0] data_o_2_3[5];
logic valid_o_2_3[5], ready_o_2_3[5];        

logic [`DW-1:0] data_i_2_4[5];
logic valid_i_2_4[5], ready_i_2_4[5];    
logic [`DW-1:0] data_o_2_4[5];
logic valid_o_2_4[5], ready_o_2_4[5];        

logic [`DW-1:0] data_i_2_5[5];
logic valid_i_2_5[5], ready_i_2_5[5];    
logic [`DW-1:0] data_o_2_5[5];
logic valid_o_2_5[5], ready_o_2_5[5];        

logic [`DW-1:0] data_i_2_6[5];
logic valid_i_2_6[5], ready_i_2_6[5];    
logic [`DW-1:0] data_o_2_6[5];
logic valid_o_2_6[5], ready_o_2_6[5];        

logic [`DW-1:0] data_i_2_7[5];
logic valid_i_2_7[5], ready_i_2_7[5];    
logic [`DW-1:0] data_o_2_7[5];
logic valid_o_2_7[5], ready_o_2_7[5];        

logic [`DW-1:0] data_i_2_8[5];
logic valid_i_2_8[5], ready_i_2_8[5];    
logic [`DW-1:0] data_o_2_8[5];
logic valid_o_2_8[5], ready_o_2_8[5];        

logic [`DW-1:0] data_i_2_9[5];
logic valid_i_2_9[5], ready_i_2_9[5];    
logic [`DW-1:0] data_o_2_9[5];
logic valid_o_2_9[5], ready_o_2_9[5];        

logic [`DW-1:0] data_i_3_0[5];
logic valid_i_3_0[5], ready_i_3_0[5];    
logic [`DW-1:0] data_o_3_0[5];
logic valid_o_3_0[5], ready_o_3_0[5];        

logic [`DW-1:0] data_i_3_1[5];
logic valid_i_3_1[5], ready_i_3_1[5];    
logic [`DW-1:0] data_o_3_1[5];
logic valid_o_3_1[5], ready_o_3_1[5];        

logic [`DW-1:0] data_i_3_2[5];
logic valid_i_3_2[5], ready_i_3_2[5];    
logic [`DW-1:0] data_o_3_2[5];
logic valid_o_3_2[5], ready_o_3_2[5];        

logic [`DW-1:0] data_i_3_3[5];
logic valid_i_3_3[5], ready_i_3_3[5];    
logic [`DW-1:0] data_o_3_3[5];
logic valid_o_3_3[5], ready_o_3_3[5];        

logic [`DW-1:0] data_i_3_4[5];
logic valid_i_3_4[5], ready_i_3_4[5];    
logic [`DW-1:0] data_o_3_4[5];
logic valid_o_3_4[5], ready_o_3_4[5];        

logic [`DW-1:0] data_i_3_5[5];
logic valid_i_3_5[5], ready_i_3_5[5];    
logic [`DW-1:0] data_o_3_5[5];
logic valid_o_3_5[5], ready_o_3_5[5];        

logic [`DW-1:0] data_i_3_6[5];
logic valid_i_3_6[5], ready_i_3_6[5];    
logic [`DW-1:0] data_o_3_6[5];
logic valid_o_3_6[5], ready_o_3_6[5];        

logic [`DW-1:0] data_i_3_7[5];
logic valid_i_3_7[5], ready_i_3_7[5];    
logic [`DW-1:0] data_o_3_7[5];
logic valid_o_3_7[5], ready_o_3_7[5];        

logic [`DW-1:0] data_i_3_8[5];
logic valid_i_3_8[5], ready_i_3_8[5];    
logic [`DW-1:0] data_o_3_8[5];
logic valid_o_3_8[5], ready_o_3_8[5];        

logic [`DW-1:0] data_i_3_9[5];
logic valid_i_3_9[5], ready_i_3_9[5];    
logic [`DW-1:0] data_o_3_9[5];
logic valid_o_3_9[5], ready_o_3_9[5];        

logic [`DW-1:0] data_i_4_0[5];
logic valid_i_4_0[5], ready_i_4_0[5];    
logic [`DW-1:0] data_o_4_0[5];
logic valid_o_4_0[5], ready_o_4_0[5];        

logic [`DW-1:0] data_i_4_1[5];
logic valid_i_4_1[5], ready_i_4_1[5];    
logic [`DW-1:0] data_o_4_1[5];
logic valid_o_4_1[5], ready_o_4_1[5];        

logic [`DW-1:0] data_i_4_2[5];
logic valid_i_4_2[5], ready_i_4_2[5];    
logic [`DW-1:0] data_o_4_2[5];
logic valid_o_4_2[5], ready_o_4_2[5];        

logic [`DW-1:0] data_i_4_3[5];
logic valid_i_4_3[5], ready_i_4_3[5];    
logic [`DW-1:0] data_o_4_3[5];
logic valid_o_4_3[5], ready_o_4_3[5];        

logic [`DW-1:0] data_i_4_4[5];
logic valid_i_4_4[5], ready_i_4_4[5];    
logic [`DW-1:0] data_o_4_4[5];
logic valid_o_4_4[5], ready_o_4_4[5];        

logic [`DW-1:0] data_i_4_5[5];
logic valid_i_4_5[5], ready_i_4_5[5];    
logic [`DW-1:0] data_o_4_5[5];
logic valid_o_4_5[5], ready_o_4_5[5];        

logic [`DW-1:0] data_i_4_6[5];
logic valid_i_4_6[5], ready_i_4_6[5];    
logic [`DW-1:0] data_o_4_6[5];
logic valid_o_4_6[5], ready_o_4_6[5];        

logic [`DW-1:0] data_i_4_7[5];
logic valid_i_4_7[5], ready_i_4_7[5];    
logic [`DW-1:0] data_o_4_7[5];
logic valid_o_4_7[5], ready_o_4_7[5];        

logic [`DW-1:0] data_i_4_8[5];
logic valid_i_4_8[5], ready_i_4_8[5];    
logic [`DW-1:0] data_o_4_8[5];
logic valid_o_4_8[5], ready_o_4_8[5];        

logic [`DW-1:0] data_i_4_9[5];
logic valid_i_4_9[5], ready_i_4_9[5];    
logic [`DW-1:0] data_o_4_9[5];
logic valid_o_4_9[5], ready_o_4_9[5];        

always_comb begin
    data_o[0][0] = data_o_0_0[0];
    valid_o[0][0] = valid_o_0_0[0];
    ready_o[0][0] = ready_o_0_0[0];
    data_o[0][1] = data_o_0_1[0];
    valid_o[0][1] = valid_o_0_1[0];
    ready_o[0][1] = ready_o_0_1[0];
    data_o[0][2] = data_o_0_2[0];
    valid_o[0][2] = valid_o_0_2[0];
    ready_o[0][2] = ready_o_0_2[0];
    data_o[0][3] = data_o_0_3[0];
    valid_o[0][3] = valid_o_0_3[0];
    ready_o[0][3] = ready_o_0_3[0];
    data_o[0][4] = data_o_0_4[0];
    valid_o[0][4] = valid_o_0_4[0];
    ready_o[0][4] = ready_o_0_4[0];
    data_o[0][5] = data_o_0_5[0];
    valid_o[0][5] = valid_o_0_5[0];
    ready_o[0][5] = ready_o_0_5[0];
    data_o[0][6] = data_o_0_6[0];
    valid_o[0][6] = valid_o_0_6[0];
    ready_o[0][6] = ready_o_0_6[0];
    data_o[0][7] = data_o_0_7[0];
    valid_o[0][7] = valid_o_0_7[0];
    ready_o[0][7] = ready_o_0_7[0];
    data_o[0][8] = data_o_0_8[0];
    valid_o[0][8] = valid_o_0_8[0];
    ready_o[0][8] = ready_o_0_8[0];
    data_o[0][9] = data_o_0_9[0];
    valid_o[0][9] = valid_o_0_9[0];
    ready_o[0][9] = ready_o_0_9[0];
    data_o[1][0] = data_o_1_0[0];
    valid_o[1][0] = valid_o_1_0[0];
    ready_o[1][0] = ready_o_1_0[0];
    data_o[1][1] = data_o_1_1[0];
    valid_o[1][1] = valid_o_1_1[0];
    ready_o[1][1] = ready_o_1_1[0];
    data_o[1][2] = data_o_1_2[0];
    valid_o[1][2] = valid_o_1_2[0];
    ready_o[1][2] = ready_o_1_2[0];
    data_o[1][3] = data_o_1_3[0];
    valid_o[1][3] = valid_o_1_3[0];
    ready_o[1][3] = ready_o_1_3[0];
    data_o[1][4] = data_o_1_4[0];
    valid_o[1][4] = valid_o_1_4[0];
    ready_o[1][4] = ready_o_1_4[0];
    data_o[1][5] = data_o_1_5[0];
    valid_o[1][5] = valid_o_1_5[0];
    ready_o[1][5] = ready_o_1_5[0];
    data_o[1][6] = data_o_1_6[0];
    valid_o[1][6] = valid_o_1_6[0];
    ready_o[1][6] = ready_o_1_6[0];
    data_o[1][7] = data_o_1_7[0];
    valid_o[1][7] = valid_o_1_7[0];
    ready_o[1][7] = ready_o_1_7[0];
    data_o[1][8] = data_o_1_8[0];
    valid_o[1][8] = valid_o_1_8[0];
    ready_o[1][8] = ready_o_1_8[0];
    data_o[1][9] = data_o_1_9[0];
    valid_o[1][9] = valid_o_1_9[0];
    ready_o[1][9] = ready_o_1_9[0];
    data_o[2][0] = data_o_2_0[0];
    valid_o[2][0] = valid_o_2_0[0];
    ready_o[2][0] = ready_o_2_0[0];
    data_o[2][1] = data_o_2_1[0];
    valid_o[2][1] = valid_o_2_1[0];
    ready_o[2][1] = ready_o_2_1[0];
    data_o[2][2] = data_o_2_2[0];
    valid_o[2][2] = valid_o_2_2[0];
    ready_o[2][2] = ready_o_2_2[0];
    data_o[2][3] = data_o_2_3[0];
    valid_o[2][3] = valid_o_2_3[0];
    ready_o[2][3] = ready_o_2_3[0];
    data_o[2][4] = data_o_2_4[0];
    valid_o[2][4] = valid_o_2_4[0];
    ready_o[2][4] = ready_o_2_4[0];
    data_o[2][5] = data_o_2_5[0];
    valid_o[2][5] = valid_o_2_5[0];
    ready_o[2][5] = ready_o_2_5[0];
    data_o[2][6] = data_o_2_6[0];
    valid_o[2][6] = valid_o_2_6[0];
    ready_o[2][6] = ready_o_2_6[0];
    data_o[2][7] = data_o_2_7[0];
    valid_o[2][7] = valid_o_2_7[0];
    ready_o[2][7] = ready_o_2_7[0];
    data_o[2][8] = data_o_2_8[0];
    valid_o[2][8] = valid_o_2_8[0];
    ready_o[2][8] = ready_o_2_8[0];
    data_o[2][9] = data_o_2_9[0];
    valid_o[2][9] = valid_o_2_9[0];
    ready_o[2][9] = ready_o_2_9[0];
    data_o[3][0] = data_o_3_0[0];
    valid_o[3][0] = valid_o_3_0[0];
    ready_o[3][0] = ready_o_3_0[0];
    data_o[3][1] = data_o_3_1[0];
    valid_o[3][1] = valid_o_3_1[0];
    ready_o[3][1] = ready_o_3_1[0];
    data_o[3][2] = data_o_3_2[0];
    valid_o[3][2] = valid_o_3_2[0];
    ready_o[3][2] = ready_o_3_2[0];
    data_o[3][3] = data_o_3_3[0];
    valid_o[3][3] = valid_o_3_3[0];
    ready_o[3][3] = ready_o_3_3[0];
    data_o[3][4] = data_o_3_4[0];
    valid_o[3][4] = valid_o_3_4[0];
    ready_o[3][4] = ready_o_3_4[0];
    data_o[3][5] = data_o_3_5[0];
    valid_o[3][5] = valid_o_3_5[0];
    ready_o[3][5] = ready_o_3_5[0];
    data_o[3][6] = data_o_3_6[0];
    valid_o[3][6] = valid_o_3_6[0];
    ready_o[3][6] = ready_o_3_6[0];
    data_o[3][7] = data_o_3_7[0];
    valid_o[3][7] = valid_o_3_7[0];
    ready_o[3][7] = ready_o_3_7[0];
    data_o[3][8] = data_o_3_8[0];
    valid_o[3][8] = valid_o_3_8[0];
    ready_o[3][8] = ready_o_3_8[0];
    data_o[3][9] = data_o_3_9[0];
    valid_o[3][9] = valid_o_3_9[0];
    ready_o[3][9] = ready_o_3_9[0];
    data_o[4][0] = data_o_4_0[0];
    valid_o[4][0] = valid_o_4_0[0];
    ready_o[4][0] = ready_o_4_0[0];
    data_o[4][1] = data_o_4_1[0];
    valid_o[4][1] = valid_o_4_1[0];
    ready_o[4][1] = ready_o_4_1[0];
    data_o[4][2] = data_o_4_2[0];
    valid_o[4][2] = valid_o_4_2[0];
    ready_o[4][2] = ready_o_4_2[0];
    data_o[4][3] = data_o_4_3[0];
    valid_o[4][3] = valid_o_4_3[0];
    ready_o[4][3] = ready_o_4_3[0];
    data_o[4][4] = data_o_4_4[0];
    valid_o[4][4] = valid_o_4_4[0];
    ready_o[4][4] = ready_o_4_4[0];
    data_o[4][5] = data_o_4_5[0];
    valid_o[4][5] = valid_o_4_5[0];
    ready_o[4][5] = ready_o_4_5[0];
    data_o[4][6] = data_o_4_6[0];
    valid_o[4][6] = valid_o_4_6[0];
    ready_o[4][6] = ready_o_4_6[0];
    data_o[4][7] = data_o_4_7[0];
    valid_o[4][7] = valid_o_4_7[0];
    ready_o[4][7] = ready_o_4_7[0];
    data_o[4][8] = data_o_4_8[0];
    valid_o[4][8] = valid_o_4_8[0];
    ready_o[4][8] = ready_o_4_8[0];
    data_o[4][9] = data_o_4_9[0];
    valid_o[4][9] = valid_o_4_9[0];
    ready_o[4][9] = ready_o_4_9[0];
end

/*Router 0,0*/    
merge_router #(
    .input_mask                     (input_mask_0_0),
    .output_sel                     (output_sel_0_0)
)router_0_0(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_0),
    .valid_i                        (valid_i_0_0),
    .ready_o                        (ready_o_0_0),
    .data_o                         (data_o_0_0),
    .valid_o                        (valid_o_0_0),
    .ready_i                        (ready_i_0_0)
);


always_comb begin
    data_i_0_0[4] = data_o_0_1[3];
    valid_i_0_0[4] = valid_o_0_1[3];
    ready_i_0_0[4] = ready_o_0_1[3];
    data_i_0_0[2] = data_o_1_0[1];
    valid_i_0_0[2] = valid_o_1_0[1];
    ready_i_0_0[2] = ready_o_1_0[1];
    data_i_0_0[0] = data_i[0][0];
    valid_i_0_0[0] = valid_i[0][0];
    ready_i_0_0[0] = ready_i[0][0];
end


/*Router 0,1*/    
merge_router #(
    .input_mask                     (input_mask_0_1),
    .output_sel                     (output_sel_0_1)
)router_0_1(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_1),
    .valid_i                        (valid_i_0_1),
    .ready_o                        (ready_o_0_1),
    .data_o                         (data_o_0_1),
    .valid_o                        (valid_o_0_1),
    .ready_i                        (ready_i_0_1)
);


always_comb begin
    data_i_0_1[3] = data_o_0_0[4];
    valid_i_0_1[3] = valid_o_0_0[4];
    ready_i_0_1[3] = ready_o_0_0[4];
    data_i_0_1[4] = data_o_0_2[3];
    valid_i_0_1[4] = valid_o_0_2[3];
    ready_i_0_1[4] = ready_o_0_2[3];
    data_i_0_1[2] = data_o_1_1[1];
    valid_i_0_1[2] = valid_o_1_1[1];
    ready_i_0_1[2] = ready_o_1_1[1];
    data_i_0_1[0] = data_i[0][1];
    valid_i_0_1[0] = valid_i[0][1];
    ready_i_0_1[0] = ready_i[0][1];
end


/*Router 0,2*/    
merge_router #(
    .input_mask                     (input_mask_0_2),
    .output_sel                     (output_sel_0_2)
)router_0_2(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_2),
    .valid_i                        (valid_i_0_2),
    .ready_o                        (ready_o_0_2),
    .data_o                         (data_o_0_2),
    .valid_o                        (valid_o_0_2),
    .ready_i                        (ready_i_0_2)
);


always_comb begin
    data_i_0_2[3] = data_o_0_1[4];
    valid_i_0_2[3] = valid_o_0_1[4];
    ready_i_0_2[3] = ready_o_0_1[4];
    data_i_0_2[4] = data_o_0_3[3];
    valid_i_0_2[4] = valid_o_0_3[3];
    ready_i_0_2[4] = ready_o_0_3[3];
    data_i_0_2[2] = data_o_1_2[1];
    valid_i_0_2[2] = valid_o_1_2[1];
    ready_i_0_2[2] = ready_o_1_2[1];
    data_i_0_2[0] = data_i[0][2];
    valid_i_0_2[0] = valid_i[0][2];
    ready_i_0_2[0] = ready_i[0][2];
end


/*Router 0,3*/    
merge_router #(
    .input_mask                     (input_mask_0_3),
    .output_sel                     (output_sel_0_3)
)router_0_3(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_3),
    .valid_i                        (valid_i_0_3),
    .ready_o                        (ready_o_0_3),
    .data_o                         (data_o_0_3),
    .valid_o                        (valid_o_0_3),
    .ready_i                        (ready_i_0_3)
);


always_comb begin
    data_i_0_3[3] = data_o_0_2[4];
    valid_i_0_3[3] = valid_o_0_2[4];
    ready_i_0_3[3] = ready_o_0_2[4];
    data_i_0_3[4] = data_o_0_4[3];
    valid_i_0_3[4] = valid_o_0_4[3];
    ready_i_0_3[4] = ready_o_0_4[3];
    data_i_0_3[2] = data_o_1_3[1];
    valid_i_0_3[2] = valid_o_1_3[1];
    ready_i_0_3[2] = ready_o_1_3[1];
    data_i_0_3[0] = data_i[0][3];
    valid_i_0_3[0] = valid_i[0][3];
    ready_i_0_3[0] = ready_i[0][3];
end


/*Router 0,4*/    
merge_router #(
    .input_mask                     (input_mask_0_4),
    .output_sel                     (output_sel_0_4)
)router_0_4(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_4),
    .valid_i                        (valid_i_0_4),
    .ready_o                        (ready_o_0_4),
    .data_o                         (data_o_0_4),
    .valid_o                        (valid_o_0_4),
    .ready_i                        (ready_i_0_4)
);


always_comb begin
    data_i_0_4[3] = data_o_0_3[4];
    valid_i_0_4[3] = valid_o_0_3[4];
    ready_i_0_4[3] = ready_o_0_3[4];
    data_i_0_4[4] = data_o_0_5[3];
    valid_i_0_4[4] = valid_o_0_5[3];
    ready_i_0_4[4] = ready_o_0_5[3];
    data_i_0_4[2] = data_o_1_4[1];
    valid_i_0_4[2] = valid_o_1_4[1];
    ready_i_0_4[2] = ready_o_1_4[1];
    data_i_0_4[0] = data_i[0][4];
    valid_i_0_4[0] = valid_i[0][4];
    ready_i_0_4[0] = ready_i[0][4];
end


/*Router 0,5*/    
merge_router #(
    .input_mask                     (input_mask_0_5),
    .output_sel                     (output_sel_0_5)
)router_0_5(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_5),
    .valid_i                        (valid_i_0_5),
    .ready_o                        (ready_o_0_5),
    .data_o                         (data_o_0_5),
    .valid_o                        (valid_o_0_5),
    .ready_i                        (ready_i_0_5)
);


always_comb begin
    data_i_0_5[3] = data_o_0_4[4];
    valid_i_0_5[3] = valid_o_0_4[4];
    ready_i_0_5[3] = ready_o_0_4[4];
    data_i_0_5[4] = data_o_0_6[3];
    valid_i_0_5[4] = valid_o_0_6[3];
    ready_i_0_5[4] = ready_o_0_6[3];
    data_i_0_5[2] = data_o_1_5[1];
    valid_i_0_5[2] = valid_o_1_5[1];
    ready_i_0_5[2] = ready_o_1_5[1];
    data_i_0_5[0] = data_i[0][5];
    valid_i_0_5[0] = valid_i[0][5];
    ready_i_0_5[0] = ready_i[0][5];
end


/*Router 0,6*/    
merge_router #(
    .input_mask                     (input_mask_0_6),
    .output_sel                     (output_sel_0_6)
)router_0_6(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_6),
    .valid_i                        (valid_i_0_6),
    .ready_o                        (ready_o_0_6),
    .data_o                         (data_o_0_6),
    .valid_o                        (valid_o_0_6),
    .ready_i                        (ready_i_0_6)
);


always_comb begin
    data_i_0_6[3] = data_o_0_5[4];
    valid_i_0_6[3] = valid_o_0_5[4];
    ready_i_0_6[3] = ready_o_0_5[4];
    data_i_0_6[4] = data_o_0_7[3];
    valid_i_0_6[4] = valid_o_0_7[3];
    ready_i_0_6[4] = ready_o_0_7[3];
    data_i_0_6[2] = data_o_1_6[1];
    valid_i_0_6[2] = valid_o_1_6[1];
    ready_i_0_6[2] = ready_o_1_6[1];
    data_i_0_6[0] = data_i[0][6];
    valid_i_0_6[0] = valid_i[0][6];
    ready_i_0_6[0] = ready_i[0][6];
end


/*Router 0,7*/    
merge_router #(
    .input_mask                     (input_mask_0_7),
    .output_sel                     (output_sel_0_7)
)router_0_7(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_7),
    .valid_i                        (valid_i_0_7),
    .ready_o                        (ready_o_0_7),
    .data_o                         (data_o_0_7),
    .valid_o                        (valid_o_0_7),
    .ready_i                        (ready_i_0_7)
);


always_comb begin
    data_i_0_7[3] = data_o_0_6[4];
    valid_i_0_7[3] = valid_o_0_6[4];
    ready_i_0_7[3] = ready_o_0_6[4];
    data_i_0_7[4] = data_o_0_8[3];
    valid_i_0_7[4] = valid_o_0_8[3];
    ready_i_0_7[4] = ready_o_0_8[3];
    data_i_0_7[2] = data_o_1_7[1];
    valid_i_0_7[2] = valid_o_1_7[1];
    ready_i_0_7[2] = ready_o_1_7[1];
    data_i_0_7[0] = data_i[0][7];
    valid_i_0_7[0] = valid_i[0][7];
    ready_i_0_7[0] = ready_i[0][7];
end


/*Router 0,8*/    
merge_router #(
    .input_mask                     (input_mask_0_8),
    .output_sel                     (output_sel_0_8)
)router_0_8(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_8),
    .valid_i                        (valid_i_0_8),
    .ready_o                        (ready_o_0_8),
    .data_o                         (data_o_0_8),
    .valid_o                        (valid_o_0_8),
    .ready_i                        (ready_i_0_8)
);


always_comb begin
    data_i_0_8[3] = data_o_0_7[4];
    valid_i_0_8[3] = valid_o_0_7[4];
    ready_i_0_8[3] = ready_o_0_7[4];
    data_i_0_8[4] = data_o_0_9[3];
    valid_i_0_8[4] = valid_o_0_9[3];
    ready_i_0_8[4] = ready_o_0_9[3];
    data_i_0_8[2] = data_o_1_8[1];
    valid_i_0_8[2] = valid_o_1_8[1];
    ready_i_0_8[2] = ready_o_1_8[1];
    data_i_0_8[0] = data_i[0][8];
    valid_i_0_8[0] = valid_i[0][8];
    ready_i_0_8[0] = ready_i[0][8];
end


/*Router 0,9*/    
merge_router #(
    .input_mask                     (input_mask_0_9),
    .output_sel                     (output_sel_0_9)
)router_0_9(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_0_9),
    .valid_i                        (valid_i_0_9),
    .ready_o                        (ready_o_0_9),
    .data_o                         (data_o_0_9),
    .valid_o                        (valid_o_0_9),
    .ready_i                        (ready_i_0_9)
);


always_comb begin
    data_i_0_9[3] = data_o_0_8[4];
    valid_i_0_9[3] = valid_o_0_8[4];
    ready_i_0_9[3] = ready_o_0_8[4];
    data_i_0_9[2] = data_o_1_9[1];
    valid_i_0_9[2] = valid_o_1_9[1];
    ready_i_0_9[2] = ready_o_1_9[1];
    data_i_0_9[0] = data_i[0][9];
    valid_i_0_9[0] = valid_i[0][9];
    ready_i_0_9[0] = ready_i[0][9];
end


/*Router 1,0*/    
merge_router #(
    .input_mask                     (input_mask_1_0),
    .output_sel                     (output_sel_1_0)
)router_1_0(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_0),
    .valid_i                        (valid_i_1_0),
    .ready_o                        (ready_o_1_0),
    .data_o                         (data_o_1_0),
    .valid_o                        (valid_o_1_0),
    .ready_i                        (ready_i_1_0)
);


always_comb begin
    data_i_1_0[4] = data_o_1_1[3];
    valid_i_1_0[4] = valid_o_1_1[3];
    ready_i_1_0[4] = ready_o_1_1[3];
    data_i_1_0[1] = data_o_0_0[2];
    valid_i_1_0[1] = valid_o_0_0[2];
    ready_i_1_0[1] = ready_o_0_0[2];
    data_i_1_0[2] = data_o_2_0[1];
    valid_i_1_0[2] = valid_o_2_0[1];
    ready_i_1_0[2] = ready_o_2_0[1];
    data_i_1_0[0] = data_i[1][0];
    valid_i_1_0[0] = valid_i[1][0];
    ready_i_1_0[0] = ready_i[1][0];
end


/*Router 1,1*/    
merge_router #(
    .input_mask                     (input_mask_1_1),
    .output_sel                     (output_sel_1_1)
)router_1_1(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_1),
    .valid_i                        (valid_i_1_1),
    .ready_o                        (ready_o_1_1),
    .data_o                         (data_o_1_1),
    .valid_o                        (valid_o_1_1),
    .ready_i                        (ready_i_1_1)
);


always_comb begin
    data_i_1_1[3] = data_o_1_0[4];
    valid_i_1_1[3] = valid_o_1_0[4];
    ready_i_1_1[3] = ready_o_1_0[4];
    data_i_1_1[4] = data_o_1_2[3];
    valid_i_1_1[4] = valid_o_1_2[3];
    ready_i_1_1[4] = ready_o_1_2[3];
    data_i_1_1[1] = data_o_0_1[2];
    valid_i_1_1[1] = valid_o_0_1[2];
    ready_i_1_1[1] = ready_o_0_1[2];
    data_i_1_1[2] = data_o_2_1[1];
    valid_i_1_1[2] = valid_o_2_1[1];
    ready_i_1_1[2] = ready_o_2_1[1];
    data_i_1_1[0] = data_i[1][1];
    valid_i_1_1[0] = valid_i[1][1];
    ready_i_1_1[0] = ready_i[1][1];
end


/*Router 1,2*/    
merge_router #(
    .input_mask                     (input_mask_1_2),
    .output_sel                     (output_sel_1_2)
)router_1_2(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_2),
    .valid_i                        (valid_i_1_2),
    .ready_o                        (ready_o_1_2),
    .data_o                         (data_o_1_2),
    .valid_o                        (valid_o_1_2),
    .ready_i                        (ready_i_1_2)
);


always_comb begin
    data_i_1_2[3] = data_o_1_1[4];
    valid_i_1_2[3] = valid_o_1_1[4];
    ready_i_1_2[3] = ready_o_1_1[4];
    data_i_1_2[4] = data_o_1_3[3];
    valid_i_1_2[4] = valid_o_1_3[3];
    ready_i_1_2[4] = ready_o_1_3[3];
    data_i_1_2[1] = data_o_0_2[2];
    valid_i_1_2[1] = valid_o_0_2[2];
    ready_i_1_2[1] = ready_o_0_2[2];
    data_i_1_2[2] = data_o_2_2[1];
    valid_i_1_2[2] = valid_o_2_2[1];
    ready_i_1_2[2] = ready_o_2_2[1];
    data_i_1_2[0] = data_i[1][2];
    valid_i_1_2[0] = valid_i[1][2];
    ready_i_1_2[0] = ready_i[1][2];
end


/*Router 1,3*/    
merge_router #(
    .input_mask                     (input_mask_1_3),
    .output_sel                     (output_sel_1_3)
)router_1_3(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_3),
    .valid_i                        (valid_i_1_3),
    .ready_o                        (ready_o_1_3),
    .data_o                         (data_o_1_3),
    .valid_o                        (valid_o_1_3),
    .ready_i                        (ready_i_1_3)
);


always_comb begin
    data_i_1_3[3] = data_o_1_2[4];
    valid_i_1_3[3] = valid_o_1_2[4];
    ready_i_1_3[3] = ready_o_1_2[4];
    data_i_1_3[4] = data_o_1_4[3];
    valid_i_1_3[4] = valid_o_1_4[3];
    ready_i_1_3[4] = ready_o_1_4[3];
    data_i_1_3[1] = data_o_0_3[2];
    valid_i_1_3[1] = valid_o_0_3[2];
    ready_i_1_3[1] = ready_o_0_3[2];
    data_i_1_3[2] = data_o_2_3[1];
    valid_i_1_3[2] = valid_o_2_3[1];
    ready_i_1_3[2] = ready_o_2_3[1];
    data_i_1_3[0] = data_i[1][3];
    valid_i_1_3[0] = valid_i[1][3];
    ready_i_1_3[0] = ready_i[1][3];
end


/*Router 1,4*/    
merge_router #(
    .input_mask                     (input_mask_1_4),
    .output_sel                     (output_sel_1_4)
)router_1_4(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_4),
    .valid_i                        (valid_i_1_4),
    .ready_o                        (ready_o_1_4),
    .data_o                         (data_o_1_4),
    .valid_o                        (valid_o_1_4),
    .ready_i                        (ready_i_1_4)
);


always_comb begin
    data_i_1_4[3] = data_o_1_3[4];
    valid_i_1_4[3] = valid_o_1_3[4];
    ready_i_1_4[3] = ready_o_1_3[4];
    data_i_1_4[4] = data_o_1_5[3];
    valid_i_1_4[4] = valid_o_1_5[3];
    ready_i_1_4[4] = ready_o_1_5[3];
    data_i_1_4[1] = data_o_0_4[2];
    valid_i_1_4[1] = valid_o_0_4[2];
    ready_i_1_4[1] = ready_o_0_4[2];
    data_i_1_4[2] = data_o_2_4[1];
    valid_i_1_4[2] = valid_o_2_4[1];
    ready_i_1_4[2] = ready_o_2_4[1];
    data_i_1_4[0] = data_i[1][4];
    valid_i_1_4[0] = valid_i[1][4];
    ready_i_1_4[0] = ready_i[1][4];
end


/*Router 1,5*/    
merge_router #(
    .input_mask                     (input_mask_1_5),
    .output_sel                     (output_sel_1_5)
)router_1_5(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_5),
    .valid_i                        (valid_i_1_5),
    .ready_o                        (ready_o_1_5),
    .data_o                         (data_o_1_5),
    .valid_o                        (valid_o_1_5),
    .ready_i                        (ready_i_1_5)
);


always_comb begin
    data_i_1_5[3] = data_o_1_4[4];
    valid_i_1_5[3] = valid_o_1_4[4];
    ready_i_1_5[3] = ready_o_1_4[4];
    data_i_1_5[4] = data_o_1_6[3];
    valid_i_1_5[4] = valid_o_1_6[3];
    ready_i_1_5[4] = ready_o_1_6[3];
    data_i_1_5[1] = data_o_0_5[2];
    valid_i_1_5[1] = valid_o_0_5[2];
    ready_i_1_5[1] = ready_o_0_5[2];
    data_i_1_5[2] = data_o_2_5[1];
    valid_i_1_5[2] = valid_o_2_5[1];
    ready_i_1_5[2] = ready_o_2_5[1];
    data_i_1_5[0] = data_i[1][5];
    valid_i_1_5[0] = valid_i[1][5];
    ready_i_1_5[0] = ready_i[1][5];
end


/*Router 1,6*/    
merge_router #(
    .input_mask                     (input_mask_1_6),
    .output_sel                     (output_sel_1_6)
)router_1_6(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_6),
    .valid_i                        (valid_i_1_6),
    .ready_o                        (ready_o_1_6),
    .data_o                         (data_o_1_6),
    .valid_o                        (valid_o_1_6),
    .ready_i                        (ready_i_1_6)
);


always_comb begin
    data_i_1_6[3] = data_o_1_5[4];
    valid_i_1_6[3] = valid_o_1_5[4];
    ready_i_1_6[3] = ready_o_1_5[4];
    data_i_1_6[4] = data_o_1_7[3];
    valid_i_1_6[4] = valid_o_1_7[3];
    ready_i_1_6[4] = ready_o_1_7[3];
    data_i_1_6[1] = data_o_0_6[2];
    valid_i_1_6[1] = valid_o_0_6[2];
    ready_i_1_6[1] = ready_o_0_6[2];
    data_i_1_6[2] = data_o_2_6[1];
    valid_i_1_6[2] = valid_o_2_6[1];
    ready_i_1_6[2] = ready_o_2_6[1];
    data_i_1_6[0] = data_i[1][6];
    valid_i_1_6[0] = valid_i[1][6];
    ready_i_1_6[0] = ready_i[1][6];
end


/*Router 1,7*/    
merge_router #(
    .input_mask                     (input_mask_1_7),
    .output_sel                     (output_sel_1_7)
)router_1_7(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_7),
    .valid_i                        (valid_i_1_7),
    .ready_o                        (ready_o_1_7),
    .data_o                         (data_o_1_7),
    .valid_o                        (valid_o_1_7),
    .ready_i                        (ready_i_1_7)
);


always_comb begin
    data_i_1_7[3] = data_o_1_6[4];
    valid_i_1_7[3] = valid_o_1_6[4];
    ready_i_1_7[3] = ready_o_1_6[4];
    data_i_1_7[4] = data_o_1_8[3];
    valid_i_1_7[4] = valid_o_1_8[3];
    ready_i_1_7[4] = ready_o_1_8[3];
    data_i_1_7[1] = data_o_0_7[2];
    valid_i_1_7[1] = valid_o_0_7[2];
    ready_i_1_7[1] = ready_o_0_7[2];
    data_i_1_7[2] = data_o_2_7[1];
    valid_i_1_7[2] = valid_o_2_7[1];
    ready_i_1_7[2] = ready_o_2_7[1];
    data_i_1_7[0] = data_i[1][7];
    valid_i_1_7[0] = valid_i[1][7];
    ready_i_1_7[0] = ready_i[1][7];
end


/*Router 1,8*/    
merge_router #(
    .input_mask                     (input_mask_1_8),
    .output_sel                     (output_sel_1_8)
)router_1_8(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_8),
    .valid_i                        (valid_i_1_8),
    .ready_o                        (ready_o_1_8),
    .data_o                         (data_o_1_8),
    .valid_o                        (valid_o_1_8),
    .ready_i                        (ready_i_1_8)
);


always_comb begin
    data_i_1_8[3] = data_o_1_7[4];
    valid_i_1_8[3] = valid_o_1_7[4];
    ready_i_1_8[3] = ready_o_1_7[4];
    data_i_1_8[4] = data_o_1_9[3];
    valid_i_1_8[4] = valid_o_1_9[3];
    ready_i_1_8[4] = ready_o_1_9[3];
    data_i_1_8[1] = data_o_0_8[2];
    valid_i_1_8[1] = valid_o_0_8[2];
    ready_i_1_8[1] = ready_o_0_8[2];
    data_i_1_8[2] = data_o_2_8[1];
    valid_i_1_8[2] = valid_o_2_8[1];
    ready_i_1_8[2] = ready_o_2_8[1];
    data_i_1_8[0] = data_i[1][8];
    valid_i_1_8[0] = valid_i[1][8];
    ready_i_1_8[0] = ready_i[1][8];
end


/*Router 1,9*/    
merge_router #(
    .input_mask                     (input_mask_1_9),
    .output_sel                     (output_sel_1_9)
)router_1_9(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_1_9),
    .valid_i                        (valid_i_1_9),
    .ready_o                        (ready_o_1_9),
    .data_o                         (data_o_1_9),
    .valid_o                        (valid_o_1_9),
    .ready_i                        (ready_i_1_9)
);


always_comb begin
    data_i_1_9[3] = data_o_1_8[4];
    valid_i_1_9[3] = valid_o_1_8[4];
    ready_i_1_9[3] = ready_o_1_8[4];
    data_i_1_9[1] = data_o_0_9[2];
    valid_i_1_9[1] = valid_o_0_9[2];
    ready_i_1_9[1] = ready_o_0_9[2];
    data_i_1_9[2] = data_o_2_9[1];
    valid_i_1_9[2] = valid_o_2_9[1];
    ready_i_1_9[2] = ready_o_2_9[1];
    data_i_1_9[0] = data_i[1][9];
    valid_i_1_9[0] = valid_i[1][9];
    ready_i_1_9[0] = ready_i[1][9];
end


/*Router 2,0*/    
merge_router #(
    .input_mask                     (input_mask_2_0),
    .output_sel                     (output_sel_2_0)
)router_2_0(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_0),
    .valid_i                        (valid_i_2_0),
    .ready_o                        (ready_o_2_0),
    .data_o                         (data_o_2_0),
    .valid_o                        (valid_o_2_0),
    .ready_i                        (ready_i_2_0)
);


always_comb begin
    data_i_2_0[4] = data_o_2_1[3];
    valid_i_2_0[4] = valid_o_2_1[3];
    ready_i_2_0[4] = ready_o_2_1[3];
    data_i_2_0[1] = data_o_1_0[2];
    valid_i_2_0[1] = valid_o_1_0[2];
    ready_i_2_0[1] = ready_o_1_0[2];
    data_i_2_0[2] = data_o_3_0[1];
    valid_i_2_0[2] = valid_o_3_0[1];
    ready_i_2_0[2] = ready_o_3_0[1];
    data_i_2_0[0] = data_i[2][0];
    valid_i_2_0[0] = valid_i[2][0];
    ready_i_2_0[0] = ready_i[2][0];
end


/*Router 2,1*/    
merge_router #(
    .input_mask                     (input_mask_2_1),
    .output_sel                     (output_sel_2_1)
)router_2_1(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_1),
    .valid_i                        (valid_i_2_1),
    .ready_o                        (ready_o_2_1),
    .data_o                         (data_o_2_1),
    .valid_o                        (valid_o_2_1),
    .ready_i                        (ready_i_2_1)
);


always_comb begin
    data_i_2_1[3] = data_o_2_0[4];
    valid_i_2_1[3] = valid_o_2_0[4];
    ready_i_2_1[3] = ready_o_2_0[4];
    data_i_2_1[4] = data_o_2_2[3];
    valid_i_2_1[4] = valid_o_2_2[3];
    ready_i_2_1[4] = ready_o_2_2[3];
    data_i_2_1[1] = data_o_1_1[2];
    valid_i_2_1[1] = valid_o_1_1[2];
    ready_i_2_1[1] = ready_o_1_1[2];
    data_i_2_1[2] = data_o_3_1[1];
    valid_i_2_1[2] = valid_o_3_1[1];
    ready_i_2_1[2] = ready_o_3_1[1];
    data_i_2_1[0] = data_i[2][1];
    valid_i_2_1[0] = valid_i[2][1];
    ready_i_2_1[0] = ready_i[2][1];
end


/*Router 2,2*/    
merge_router #(
    .input_mask                     (input_mask_2_2),
    .output_sel                     (output_sel_2_2)
)router_2_2(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_2),
    .valid_i                        (valid_i_2_2),
    .ready_o                        (ready_o_2_2),
    .data_o                         (data_o_2_2),
    .valid_o                        (valid_o_2_2),
    .ready_i                        (ready_i_2_2)
);


always_comb begin
    data_i_2_2[3] = data_o_2_1[4];
    valid_i_2_2[3] = valid_o_2_1[4];
    ready_i_2_2[3] = ready_o_2_1[4];
    data_i_2_2[4] = data_o_2_3[3];
    valid_i_2_2[4] = valid_o_2_3[3];
    ready_i_2_2[4] = ready_o_2_3[3];
    data_i_2_2[1] = data_o_1_2[2];
    valid_i_2_2[1] = valid_o_1_2[2];
    ready_i_2_2[1] = ready_o_1_2[2];
    data_i_2_2[2] = data_o_3_2[1];
    valid_i_2_2[2] = valid_o_3_2[1];
    ready_i_2_2[2] = ready_o_3_2[1];
    data_i_2_2[0] = data_i[2][2];
    valid_i_2_2[0] = valid_i[2][2];
    ready_i_2_2[0] = ready_i[2][2];
end


/*Router 2,3*/    
merge_router #(
    .input_mask                     (input_mask_2_3),
    .output_sel                     (output_sel_2_3)
)router_2_3(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_3),
    .valid_i                        (valid_i_2_3),
    .ready_o                        (ready_o_2_3),
    .data_o                         (data_o_2_3),
    .valid_o                        (valid_o_2_3),
    .ready_i                        (ready_i_2_3)
);


always_comb begin
    data_i_2_3[3] = data_o_2_2[4];
    valid_i_2_3[3] = valid_o_2_2[4];
    ready_i_2_3[3] = ready_o_2_2[4];
    data_i_2_3[4] = data_o_2_4[3];
    valid_i_2_3[4] = valid_o_2_4[3];
    ready_i_2_3[4] = ready_o_2_4[3];
    data_i_2_3[1] = data_o_1_3[2];
    valid_i_2_3[1] = valid_o_1_3[2];
    ready_i_2_3[1] = ready_o_1_3[2];
    data_i_2_3[2] = data_o_3_3[1];
    valid_i_2_3[2] = valid_o_3_3[1];
    ready_i_2_3[2] = ready_o_3_3[1];
    data_i_2_3[0] = data_i[2][3];
    valid_i_2_3[0] = valid_i[2][3];
    ready_i_2_3[0] = ready_i[2][3];
end


/*Router 2,4*/    
merge_router #(
    .input_mask                     (input_mask_2_4),
    .output_sel                     (output_sel_2_4)
)router_2_4(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_4),
    .valid_i                        (valid_i_2_4),
    .ready_o                        (ready_o_2_4),
    .data_o                         (data_o_2_4),
    .valid_o                        (valid_o_2_4),
    .ready_i                        (ready_i_2_4)
);


always_comb begin
    data_i_2_4[3] = data_o_2_3[4];
    valid_i_2_4[3] = valid_o_2_3[4];
    ready_i_2_4[3] = ready_o_2_3[4];
    data_i_2_4[4] = data_o_2_5[3];
    valid_i_2_4[4] = valid_o_2_5[3];
    ready_i_2_4[4] = ready_o_2_5[3];
    data_i_2_4[1] = data_o_1_4[2];
    valid_i_2_4[1] = valid_o_1_4[2];
    ready_i_2_4[1] = ready_o_1_4[2];
    data_i_2_4[2] = data_o_3_4[1];
    valid_i_2_4[2] = valid_o_3_4[1];
    ready_i_2_4[2] = ready_o_3_4[1];
    data_i_2_4[0] = data_i[2][4];
    valid_i_2_4[0] = valid_i[2][4];
    ready_i_2_4[0] = ready_i[2][4];
end


/*Router 2,5*/    
merge_router #(
    .input_mask                     (input_mask_2_5),
    .output_sel                     (output_sel_2_5)
)router_2_5(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_5),
    .valid_i                        (valid_i_2_5),
    .ready_o                        (ready_o_2_5),
    .data_o                         (data_o_2_5),
    .valid_o                        (valid_o_2_5),
    .ready_i                        (ready_i_2_5)
);


always_comb begin
    data_i_2_5[3] = data_o_2_4[4];
    valid_i_2_5[3] = valid_o_2_4[4];
    ready_i_2_5[3] = ready_o_2_4[4];
    data_i_2_5[4] = data_o_2_6[3];
    valid_i_2_5[4] = valid_o_2_6[3];
    ready_i_2_5[4] = ready_o_2_6[3];
    data_i_2_5[1] = data_o_1_5[2];
    valid_i_2_5[1] = valid_o_1_5[2];
    ready_i_2_5[1] = ready_o_1_5[2];
    data_i_2_5[2] = data_o_3_5[1];
    valid_i_2_5[2] = valid_o_3_5[1];
    ready_i_2_5[2] = ready_o_3_5[1];
    data_i_2_5[0] = data_i[2][5];
    valid_i_2_5[0] = valid_i[2][5];
    ready_i_2_5[0] = ready_i[2][5];
end


/*Router 2,6*/    
merge_router #(
    .input_mask                     (input_mask_2_6),
    .output_sel                     (output_sel_2_6)
)router_2_6(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_6),
    .valid_i                        (valid_i_2_6),
    .ready_o                        (ready_o_2_6),
    .data_o                         (data_o_2_6),
    .valid_o                        (valid_o_2_6),
    .ready_i                        (ready_i_2_6)
);


always_comb begin
    data_i_2_6[3] = data_o_2_5[4];
    valid_i_2_6[3] = valid_o_2_5[4];
    ready_i_2_6[3] = ready_o_2_5[4];
    data_i_2_6[4] = data_o_2_7[3];
    valid_i_2_6[4] = valid_o_2_7[3];
    ready_i_2_6[4] = ready_o_2_7[3];
    data_i_2_6[1] = data_o_1_6[2];
    valid_i_2_6[1] = valid_o_1_6[2];
    ready_i_2_6[1] = ready_o_1_6[2];
    data_i_2_6[2] = data_o_3_6[1];
    valid_i_2_6[2] = valid_o_3_6[1];
    ready_i_2_6[2] = ready_o_3_6[1];
    data_i_2_6[0] = data_i[2][6];
    valid_i_2_6[0] = valid_i[2][6];
    ready_i_2_6[0] = ready_i[2][6];
end


/*Router 2,7*/    
merge_router #(
    .input_mask                     (input_mask_2_7),
    .output_sel                     (output_sel_2_7)
)router_2_7(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_7),
    .valid_i                        (valid_i_2_7),
    .ready_o                        (ready_o_2_7),
    .data_o                         (data_o_2_7),
    .valid_o                        (valid_o_2_7),
    .ready_i                        (ready_i_2_7)
);


always_comb begin
    data_i_2_7[3] = data_o_2_6[4];
    valid_i_2_7[3] = valid_o_2_6[4];
    ready_i_2_7[3] = ready_o_2_6[4];
    data_i_2_7[4] = data_o_2_8[3];
    valid_i_2_7[4] = valid_o_2_8[3];
    ready_i_2_7[4] = ready_o_2_8[3];
    data_i_2_7[1] = data_o_1_7[2];
    valid_i_2_7[1] = valid_o_1_7[2];
    ready_i_2_7[1] = ready_o_1_7[2];
    data_i_2_7[2] = data_o_3_7[1];
    valid_i_2_7[2] = valid_o_3_7[1];
    ready_i_2_7[2] = ready_o_3_7[1];
    data_i_2_7[0] = data_i[2][7];
    valid_i_2_7[0] = valid_i[2][7];
    ready_i_2_7[0] = ready_i[2][7];
end


/*Router 2,8*/    
merge_router #(
    .input_mask                     (input_mask_2_8),
    .output_sel                     (output_sel_2_8)
)router_2_8(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_8),
    .valid_i                        (valid_i_2_8),
    .ready_o                        (ready_o_2_8),
    .data_o                         (data_o_2_8),
    .valid_o                        (valid_o_2_8),
    .ready_i                        (ready_i_2_8)
);


always_comb begin
    data_i_2_8[3] = data_o_2_7[4];
    valid_i_2_8[3] = valid_o_2_7[4];
    ready_i_2_8[3] = ready_o_2_7[4];
    data_i_2_8[4] = data_o_2_9[3];
    valid_i_2_8[4] = valid_o_2_9[3];
    ready_i_2_8[4] = ready_o_2_9[3];
    data_i_2_8[1] = data_o_1_8[2];
    valid_i_2_8[1] = valid_o_1_8[2];
    ready_i_2_8[1] = ready_o_1_8[2];
    data_i_2_8[2] = data_o_3_8[1];
    valid_i_2_8[2] = valid_o_3_8[1];
    ready_i_2_8[2] = ready_o_3_8[1];
    data_i_2_8[0] = data_i[2][8];
    valid_i_2_8[0] = valid_i[2][8];
    ready_i_2_8[0] = ready_i[2][8];
end


/*Router 2,9*/    
merge_router #(
    .input_mask                     (input_mask_2_9),
    .output_sel                     (output_sel_2_9)
)router_2_9(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_2_9),
    .valid_i                        (valid_i_2_9),
    .ready_o                        (ready_o_2_9),
    .data_o                         (data_o_2_9),
    .valid_o                        (valid_o_2_9),
    .ready_i                        (ready_i_2_9)
);


always_comb begin
    data_i_2_9[3] = data_o_2_8[4];
    valid_i_2_9[3] = valid_o_2_8[4];
    ready_i_2_9[3] = ready_o_2_8[4];
    data_i_2_9[1] = data_o_1_9[2];
    valid_i_2_9[1] = valid_o_1_9[2];
    ready_i_2_9[1] = ready_o_1_9[2];
    data_i_2_9[2] = data_o_3_9[1];
    valid_i_2_9[2] = valid_o_3_9[1];
    ready_i_2_9[2] = ready_o_3_9[1];
    data_i_2_9[0] = data_i[2][9];
    valid_i_2_9[0] = valid_i[2][9];
    ready_i_2_9[0] = ready_i[2][9];
end


/*Router 3,0*/    
merge_router #(
    .input_mask                     (input_mask_3_0),
    .output_sel                     (output_sel_3_0)
)router_3_0(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_0),
    .valid_i                        (valid_i_3_0),
    .ready_o                        (ready_o_3_0),
    .data_o                         (data_o_3_0),
    .valid_o                        (valid_o_3_0),
    .ready_i                        (ready_i_3_0)
);


always_comb begin
    data_i_3_0[4] = data_o_3_1[3];
    valid_i_3_0[4] = valid_o_3_1[3];
    ready_i_3_0[4] = ready_o_3_1[3];
    data_i_3_0[1] = data_o_2_0[2];
    valid_i_3_0[1] = valid_o_2_0[2];
    ready_i_3_0[1] = ready_o_2_0[2];
    data_i_3_0[2] = data_o_4_0[1];
    valid_i_3_0[2] = valid_o_4_0[1];
    ready_i_3_0[2] = ready_o_4_0[1];
    data_i_3_0[0] = data_i[3][0];
    valid_i_3_0[0] = valid_i[3][0];
    ready_i_3_0[0] = ready_i[3][0];
end


/*Router 3,1*/    
merge_router #(
    .input_mask                     (input_mask_3_1),
    .output_sel                     (output_sel_3_1)
)router_3_1(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_1),
    .valid_i                        (valid_i_3_1),
    .ready_o                        (ready_o_3_1),
    .data_o                         (data_o_3_1),
    .valid_o                        (valid_o_3_1),
    .ready_i                        (ready_i_3_1)
);


always_comb begin
    data_i_3_1[3] = data_o_3_0[4];
    valid_i_3_1[3] = valid_o_3_0[4];
    ready_i_3_1[3] = ready_o_3_0[4];
    data_i_3_1[4] = data_o_3_2[3];
    valid_i_3_1[4] = valid_o_3_2[3];
    ready_i_3_1[4] = ready_o_3_2[3];
    data_i_3_1[1] = data_o_2_1[2];
    valid_i_3_1[1] = valid_o_2_1[2];
    ready_i_3_1[1] = ready_o_2_1[2];
    data_i_3_1[2] = data_o_4_1[1];
    valid_i_3_1[2] = valid_o_4_1[1];
    ready_i_3_1[2] = ready_o_4_1[1];
    data_i_3_1[0] = data_i[3][1];
    valid_i_3_1[0] = valid_i[3][1];
    ready_i_3_1[0] = ready_i[3][1];
end


/*Router 3,2*/    
merge_router #(
    .input_mask                     (input_mask_3_2),
    .output_sel                     (output_sel_3_2)
)router_3_2(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_2),
    .valid_i                        (valid_i_3_2),
    .ready_o                        (ready_o_3_2),
    .data_o                         (data_o_3_2),
    .valid_o                        (valid_o_3_2),
    .ready_i                        (ready_i_3_2)
);


always_comb begin
    data_i_3_2[3] = data_o_3_1[4];
    valid_i_3_2[3] = valid_o_3_1[4];
    ready_i_3_2[3] = ready_o_3_1[4];
    data_i_3_2[4] = data_o_3_3[3];
    valid_i_3_2[4] = valid_o_3_3[3];
    ready_i_3_2[4] = ready_o_3_3[3];
    data_i_3_2[1] = data_o_2_2[2];
    valid_i_3_2[1] = valid_o_2_2[2];
    ready_i_3_2[1] = ready_o_2_2[2];
    data_i_3_2[2] = data_o_4_2[1];
    valid_i_3_2[2] = valid_o_4_2[1];
    ready_i_3_2[2] = ready_o_4_2[1];
    data_i_3_2[0] = data_i[3][2];
    valid_i_3_2[0] = valid_i[3][2];
    ready_i_3_2[0] = ready_i[3][2];
end


/*Router 3,3*/    
merge_router #(
    .input_mask                     (input_mask_3_3),
    .output_sel                     (output_sel_3_3)
)router_3_3(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_3),
    .valid_i                        (valid_i_3_3),
    .ready_o                        (ready_o_3_3),
    .data_o                         (data_o_3_3),
    .valid_o                        (valid_o_3_3),
    .ready_i                        (ready_i_3_3)
);


always_comb begin
    data_i_3_3[3] = data_o_3_2[4];
    valid_i_3_3[3] = valid_o_3_2[4];
    ready_i_3_3[3] = ready_o_3_2[4];
    data_i_3_3[4] = data_o_3_4[3];
    valid_i_3_3[4] = valid_o_3_4[3];
    ready_i_3_3[4] = ready_o_3_4[3];
    data_i_3_3[1] = data_o_2_3[2];
    valid_i_3_3[1] = valid_o_2_3[2];
    ready_i_3_3[1] = ready_o_2_3[2];
    data_i_3_3[2] = data_o_4_3[1];
    valid_i_3_3[2] = valid_o_4_3[1];
    ready_i_3_3[2] = ready_o_4_3[1];
    data_i_3_3[0] = data_i[3][3];
    valid_i_3_3[0] = valid_i[3][3];
    ready_i_3_3[0] = ready_i[3][3];
end


/*Router 3,4*/    
merge_router #(
    .input_mask                     (input_mask_3_4),
    .output_sel                     (output_sel_3_4)
)router_3_4(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_4),
    .valid_i                        (valid_i_3_4),
    .ready_o                        (ready_o_3_4),
    .data_o                         (data_o_3_4),
    .valid_o                        (valid_o_3_4),
    .ready_i                        (ready_i_3_4)
);


always_comb begin
    data_i_3_4[3] = data_o_3_3[4];
    valid_i_3_4[3] = valid_o_3_3[4];
    ready_i_3_4[3] = ready_o_3_3[4];
    data_i_3_4[4] = data_o_3_5[3];
    valid_i_3_4[4] = valid_o_3_5[3];
    ready_i_3_4[4] = ready_o_3_5[3];
    data_i_3_4[1] = data_o_2_4[2];
    valid_i_3_4[1] = valid_o_2_4[2];
    ready_i_3_4[1] = ready_o_2_4[2];
    data_i_3_4[2] = data_o_4_4[1];
    valid_i_3_4[2] = valid_o_4_4[1];
    ready_i_3_4[2] = ready_o_4_4[1];
    data_i_3_4[0] = data_i[3][4];
    valid_i_3_4[0] = valid_i[3][4];
    ready_i_3_4[0] = ready_i[3][4];
end


/*Router 3,5*/    
merge_router #(
    .input_mask                     (input_mask_3_5),
    .output_sel                     (output_sel_3_5)
)router_3_5(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_5),
    .valid_i                        (valid_i_3_5),
    .ready_o                        (ready_o_3_5),
    .data_o                         (data_o_3_5),
    .valid_o                        (valid_o_3_5),
    .ready_i                        (ready_i_3_5)
);


always_comb begin
    data_i_3_5[3] = data_o_3_4[4];
    valid_i_3_5[3] = valid_o_3_4[4];
    ready_i_3_5[3] = ready_o_3_4[4];
    data_i_3_5[4] = data_o_3_6[3];
    valid_i_3_5[4] = valid_o_3_6[3];
    ready_i_3_5[4] = ready_o_3_6[3];
    data_i_3_5[1] = data_o_2_5[2];
    valid_i_3_5[1] = valid_o_2_5[2];
    ready_i_3_5[1] = ready_o_2_5[2];
    data_i_3_5[2] = data_o_4_5[1];
    valid_i_3_5[2] = valid_o_4_5[1];
    ready_i_3_5[2] = ready_o_4_5[1];
    data_i_3_5[0] = data_i[3][5];
    valid_i_3_5[0] = valid_i[3][5];
    ready_i_3_5[0] = ready_i[3][5];
end


/*Router 3,6*/    
merge_router #(
    .input_mask                     (input_mask_3_6),
    .output_sel                     (output_sel_3_6)
)router_3_6(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_6),
    .valid_i                        (valid_i_3_6),
    .ready_o                        (ready_o_3_6),
    .data_o                         (data_o_3_6),
    .valid_o                        (valid_o_3_6),
    .ready_i                        (ready_i_3_6)
);


always_comb begin
    data_i_3_6[3] = data_o_3_5[4];
    valid_i_3_6[3] = valid_o_3_5[4];
    ready_i_3_6[3] = ready_o_3_5[4];
    data_i_3_6[4] = data_o_3_7[3];
    valid_i_3_6[4] = valid_o_3_7[3];
    ready_i_3_6[4] = ready_o_3_7[3];
    data_i_3_6[1] = data_o_2_6[2];
    valid_i_3_6[1] = valid_o_2_6[2];
    ready_i_3_6[1] = ready_o_2_6[2];
    data_i_3_6[2] = data_o_4_6[1];
    valid_i_3_6[2] = valid_o_4_6[1];
    ready_i_3_6[2] = ready_o_4_6[1];
    data_i_3_6[0] = data_i[3][6];
    valid_i_3_6[0] = valid_i[3][6];
    ready_i_3_6[0] = ready_i[3][6];
end


/*Router 3,7*/    
merge_router #(
    .input_mask                     (input_mask_3_7),
    .output_sel                     (output_sel_3_7)
)router_3_7(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_7),
    .valid_i                        (valid_i_3_7),
    .ready_o                        (ready_o_3_7),
    .data_o                         (data_o_3_7),
    .valid_o                        (valid_o_3_7),
    .ready_i                        (ready_i_3_7)
);


always_comb begin
    data_i_3_7[3] = data_o_3_6[4];
    valid_i_3_7[3] = valid_o_3_6[4];
    ready_i_3_7[3] = ready_o_3_6[4];
    data_i_3_7[4] = data_o_3_8[3];
    valid_i_3_7[4] = valid_o_3_8[3];
    ready_i_3_7[4] = ready_o_3_8[3];
    data_i_3_7[1] = data_o_2_7[2];
    valid_i_3_7[1] = valid_o_2_7[2];
    ready_i_3_7[1] = ready_o_2_7[2];
    data_i_3_7[2] = data_o_4_7[1];
    valid_i_3_7[2] = valid_o_4_7[1];
    ready_i_3_7[2] = ready_o_4_7[1];
    data_i_3_7[0] = data_i[3][7];
    valid_i_3_7[0] = valid_i[3][7];
    ready_i_3_7[0] = ready_i[3][7];
end


/*Router 3,8*/    
merge_router #(
    .input_mask                     (input_mask_3_8),
    .output_sel                     (output_sel_3_8)
)router_3_8(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_8),
    .valid_i                        (valid_i_3_8),
    .ready_o                        (ready_o_3_8),
    .data_o                         (data_o_3_8),
    .valid_o                        (valid_o_3_8),
    .ready_i                        (ready_i_3_8)
);


always_comb begin
    data_i_3_8[3] = data_o_3_7[4];
    valid_i_3_8[3] = valid_o_3_7[4];
    ready_i_3_8[3] = ready_o_3_7[4];
    data_i_3_8[4] = data_o_3_9[3];
    valid_i_3_8[4] = valid_o_3_9[3];
    ready_i_3_8[4] = ready_o_3_9[3];
    data_i_3_8[1] = data_o_2_8[2];
    valid_i_3_8[1] = valid_o_2_8[2];
    ready_i_3_8[1] = ready_o_2_8[2];
    data_i_3_8[2] = data_o_4_8[1];
    valid_i_3_8[2] = valid_o_4_8[1];
    ready_i_3_8[2] = ready_o_4_8[1];
    data_i_3_8[0] = data_i[3][8];
    valid_i_3_8[0] = valid_i[3][8];
    ready_i_3_8[0] = ready_i[3][8];
end


/*Router 3,9*/    
merge_router #(
    .input_mask                     (input_mask_3_9),
    .output_sel                     (output_sel_3_9)
)router_3_9(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_3_9),
    .valid_i                        (valid_i_3_9),
    .ready_o                        (ready_o_3_9),
    .data_o                         (data_o_3_9),
    .valid_o                        (valid_o_3_9),
    .ready_i                        (ready_i_3_9)
);


always_comb begin
    data_i_3_9[3] = data_o_3_8[4];
    valid_i_3_9[3] = valid_o_3_8[4];
    ready_i_3_9[3] = ready_o_3_8[4];
    data_i_3_9[1] = data_o_2_9[2];
    valid_i_3_9[1] = valid_o_2_9[2];
    ready_i_3_9[1] = ready_o_2_9[2];
    data_i_3_9[2] = data_o_4_9[1];
    valid_i_3_9[2] = valid_o_4_9[1];
    ready_i_3_9[2] = ready_o_4_9[1];
    data_i_3_9[0] = data_i[3][9];
    valid_i_3_9[0] = valid_i[3][9];
    ready_i_3_9[0] = ready_i[3][9];
end


/*Router 4,0*/    
merge_router #(
    .input_mask                     (input_mask_4_0),
    .output_sel                     (output_sel_4_0)
)router_4_0(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_0),
    .valid_i                        (valid_i_4_0),
    .ready_o                        (ready_o_4_0),
    .data_o                         (data_o_4_0),
    .valid_o                        (valid_o_4_0),
    .ready_i                        (ready_i_4_0)
);


always_comb begin
    data_i_4_0[4] = data_o_4_1[3];
    valid_i_4_0[4] = valid_o_4_1[3];
    ready_i_4_0[4] = ready_o_4_1[3];
    data_i_4_0[1] = data_o_3_0[2];
    valid_i_4_0[1] = valid_o_3_0[2];
    ready_i_4_0[1] = ready_o_3_0[2];
    data_i_4_0[0] = data_i[4][0];
    valid_i_4_0[0] = valid_i[4][0];
    ready_i_4_0[0] = ready_i[4][0];
end


/*Router 4,1*/    
merge_router #(
    .input_mask                     (input_mask_4_1),
    .output_sel                     (output_sel_4_1)
)router_4_1(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_1),
    .valid_i                        (valid_i_4_1),
    .ready_o                        (ready_o_4_1),
    .data_o                         (data_o_4_1),
    .valid_o                        (valid_o_4_1),
    .ready_i                        (ready_i_4_1)
);


always_comb begin
    data_i_4_1[3] = data_o_4_0[4];
    valid_i_4_1[3] = valid_o_4_0[4];
    ready_i_4_1[3] = ready_o_4_0[4];
    data_i_4_1[4] = data_o_4_2[3];
    valid_i_4_1[4] = valid_o_4_2[3];
    ready_i_4_1[4] = ready_o_4_2[3];
    data_i_4_1[1] = data_o_3_1[2];
    valid_i_4_1[1] = valid_o_3_1[2];
    ready_i_4_1[1] = ready_o_3_1[2];
    data_i_4_1[0] = data_i[4][1];
    valid_i_4_1[0] = valid_i[4][1];
    ready_i_4_1[0] = ready_i[4][1];
end


/*Router 4,2*/    
merge_router #(
    .input_mask                     (input_mask_4_2),
    .output_sel                     (output_sel_4_2)
)router_4_2(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_2),
    .valid_i                        (valid_i_4_2),
    .ready_o                        (ready_o_4_2),
    .data_o                         (data_o_4_2),
    .valid_o                        (valid_o_4_2),
    .ready_i                        (ready_i_4_2)
);


always_comb begin
    data_i_4_2[3] = data_o_4_1[4];
    valid_i_4_2[3] = valid_o_4_1[4];
    ready_i_4_2[3] = ready_o_4_1[4];
    data_i_4_2[4] = data_o_4_3[3];
    valid_i_4_2[4] = valid_o_4_3[3];
    ready_i_4_2[4] = ready_o_4_3[3];
    data_i_4_2[1] = data_o_3_2[2];
    valid_i_4_2[1] = valid_o_3_2[2];
    ready_i_4_2[1] = ready_o_3_2[2];
    data_i_4_2[0] = data_i[4][2];
    valid_i_4_2[0] = valid_i[4][2];
    ready_i_4_2[0] = ready_i[4][2];
end


/*Router 4,3*/    
merge_router #(
    .input_mask                     (input_mask_4_3),
    .output_sel                     (output_sel_4_3)
)router_4_3(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_3),
    .valid_i                        (valid_i_4_3),
    .ready_o                        (ready_o_4_3),
    .data_o                         (data_o_4_3),
    .valid_o                        (valid_o_4_3),
    .ready_i                        (ready_i_4_3)
);


always_comb begin
    data_i_4_3[3] = data_o_4_2[4];
    valid_i_4_3[3] = valid_o_4_2[4];
    ready_i_4_3[3] = ready_o_4_2[4];
    data_i_4_3[4] = data_o_4_4[3];
    valid_i_4_3[4] = valid_o_4_4[3];
    ready_i_4_3[4] = ready_o_4_4[3];
    data_i_4_3[1] = data_o_3_3[2];
    valid_i_4_3[1] = valid_o_3_3[2];
    ready_i_4_3[1] = ready_o_3_3[2];
    data_i_4_3[0] = data_i[4][3];
    valid_i_4_3[0] = valid_i[4][3];
    ready_i_4_3[0] = ready_i[4][3];
end


/*Router 4,4*/    
merge_router #(
    .input_mask                     (input_mask_4_4),
    .output_sel                     (output_sel_4_4)
)router_4_4(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_4),
    .valid_i                        (valid_i_4_4),
    .ready_o                        (ready_o_4_4),
    .data_o                         (data_o_4_4),
    .valid_o                        (valid_o_4_4),
    .ready_i                        (ready_i_4_4)
);


always_comb begin
    data_i_4_4[3] = data_o_4_3[4];
    valid_i_4_4[3] = valid_o_4_3[4];
    ready_i_4_4[3] = ready_o_4_3[4];
    data_i_4_4[4] = data_o_4_5[3];
    valid_i_4_4[4] = valid_o_4_5[3];
    ready_i_4_4[4] = ready_o_4_5[3];
    data_i_4_4[1] = data_o_3_4[2];
    valid_i_4_4[1] = valid_o_3_4[2];
    ready_i_4_4[1] = ready_o_3_4[2];
    data_i_4_4[0] = data_i[4][4];
    valid_i_4_4[0] = valid_i[4][4];
    ready_i_4_4[0] = ready_i[4][4];
end


/*Router 4,5*/    
merge_router #(
    .input_mask                     (input_mask_4_5),
    .output_sel                     (output_sel_4_5)
)router_4_5(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_5),
    .valid_i                        (valid_i_4_5),
    .ready_o                        (ready_o_4_5),
    .data_o                         (data_o_4_5),
    .valid_o                        (valid_o_4_5),
    .ready_i                        (ready_i_4_5)
);


always_comb begin
    data_i_4_5[3] = data_o_4_4[4];
    valid_i_4_5[3] = valid_o_4_4[4];
    ready_i_4_5[3] = ready_o_4_4[4];
    data_i_4_5[4] = data_o_4_6[3];
    valid_i_4_5[4] = valid_o_4_6[3];
    ready_i_4_5[4] = ready_o_4_6[3];
    data_i_4_5[1] = data_o_3_5[2];
    valid_i_4_5[1] = valid_o_3_5[2];
    ready_i_4_5[1] = ready_o_3_5[2];
    data_i_4_5[0] = data_i[4][5];
    valid_i_4_5[0] = valid_i[4][5];
    ready_i_4_5[0] = ready_i[4][5];
end


/*Router 4,6*/    
merge_router #(
    .input_mask                     (input_mask_4_6),
    .output_sel                     (output_sel_4_6)
)router_4_6(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_6),
    .valid_i                        (valid_i_4_6),
    .ready_o                        (ready_o_4_6),
    .data_o                         (data_o_4_6),
    .valid_o                        (valid_o_4_6),
    .ready_i                        (ready_i_4_6)
);


always_comb begin
    data_i_4_6[3] = data_o_4_5[4];
    valid_i_4_6[3] = valid_o_4_5[4];
    ready_i_4_6[3] = ready_o_4_5[4];
    data_i_4_6[4] = data_o_4_7[3];
    valid_i_4_6[4] = valid_o_4_7[3];
    ready_i_4_6[4] = ready_o_4_7[3];
    data_i_4_6[1] = data_o_3_6[2];
    valid_i_4_6[1] = valid_o_3_6[2];
    ready_i_4_6[1] = ready_o_3_6[2];
    data_i_4_6[0] = data_i[4][6];
    valid_i_4_6[0] = valid_i[4][6];
    ready_i_4_6[0] = ready_i[4][6];
end


/*Router 4,7*/    
merge_router #(
    .input_mask                     (input_mask_4_7),
    .output_sel                     (output_sel_4_7)
)router_4_7(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_7),
    .valid_i                        (valid_i_4_7),
    .ready_o                        (ready_o_4_7),
    .data_o                         (data_o_4_7),
    .valid_o                        (valid_o_4_7),
    .ready_i                        (ready_i_4_7)
);


always_comb begin
    data_i_4_7[3] = data_o_4_6[4];
    valid_i_4_7[3] = valid_o_4_6[4];
    ready_i_4_7[3] = ready_o_4_6[4];
    data_i_4_7[4] = data_o_4_8[3];
    valid_i_4_7[4] = valid_o_4_8[3];
    ready_i_4_7[4] = ready_o_4_8[3];
    data_i_4_7[1] = data_o_3_7[2];
    valid_i_4_7[1] = valid_o_3_7[2];
    ready_i_4_7[1] = ready_o_3_7[2];
    data_i_4_7[0] = data_i[4][7];
    valid_i_4_7[0] = valid_i[4][7];
    ready_i_4_7[0] = ready_i[4][7];
end


/*Router 4,8*/    
merge_router #(
    .input_mask                     (input_mask_4_8),
    .output_sel                     (output_sel_4_8)
)router_4_8(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_8),
    .valid_i                        (valid_i_4_8),
    .ready_o                        (ready_o_4_8),
    .data_o                         (data_o_4_8),
    .valid_o                        (valid_o_4_8),
    .ready_i                        (ready_i_4_8)
);


always_comb begin
    data_i_4_8[3] = data_o_4_7[4];
    valid_i_4_8[3] = valid_o_4_7[4];
    ready_i_4_8[3] = ready_o_4_7[4];
    data_i_4_8[4] = data_o_4_9[3];
    valid_i_4_8[4] = valid_o_4_9[3];
    ready_i_4_8[4] = ready_o_4_9[3];
    data_i_4_8[1] = data_o_3_8[2];
    valid_i_4_8[1] = valid_o_3_8[2];
    ready_i_4_8[1] = ready_o_3_8[2];
    data_i_4_8[0] = data_i[4][8];
    valid_i_4_8[0] = valid_i[4][8];
    ready_i_4_8[0] = ready_i[4][8];
end


/*Router 4,9*/    
merge_router #(
    .input_mask                     (input_mask_4_9),
    .output_sel                     (output_sel_4_9)
)router_4_9(
    .clk                            (clk),
    .rstn                           (rstn),
    .data_i                         (data_i_4_9),
    .valid_i                        (valid_i_4_9),
    .ready_o                        (ready_o_4_9),
    .data_o                         (data_o_4_9),
    .valid_o                        (valid_o_4_9),
    .ready_i                        (ready_i_4_9)
);


always_comb begin
    data_i_4_9[3] = data_o_4_8[4];
    valid_i_4_9[3] = valid_o_4_8[4];
    ready_i_4_9[3] = ready_o_4_8[4];
    data_i_4_9[1] = data_o_3_9[2];
    valid_i_4_9[1] = valid_o_3_9[2];
    ready_i_4_9[1] = ready_o_3_9[2];
    data_i_4_9[0] = data_i[4][9];
    valid_i_4_9[0] = valid_i[4][9];
    ready_i_4_9[0] = ready_i[4][9];
end


endmodule
