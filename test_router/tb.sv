`timescale 1ns/1ps

module tb;

/* total number of data for each VC */
localparam ndata = 1000;

/* routing table configuration */
localparam bit [`PN-1:0] routing_table [`PN] [`VN] = '{
    '{5'b00000, 5'b00100, 5'b01000, 5'b10000}, //0
    '{5'b00000, 5'b01000, 5'b10000, 5'b00001}, //1
    '{5'b00000, 5'b10000, 5'b00001, 5'b00010}, //2
    '{5'b00000, 5'b00001, 5'b00010, 5'b00100}, //3
    '{5'b11111, 5'b00010, 5'b00100, 5'b01000}  //4
};

logic clk, rstn;

logic [`VN-1:0] vc_i [`PN];
logic [`DW-1:0] data_i [`PN];
logic           valid_i [`PN];
logic           ready_o [`PN];

logic [`VN-1:0] vc_o [`PN];
logic [`DW-1:0] data_o [`PN];
logic           valid_o [`PN];
logic           ready_i [`PN];

bit done, flag;
bit mon_done [`PN];

always #5 clk = ~clk;

initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, tb);
    $fsdbDumpMDA(); //show array values
    clk = 0; rstn = 1;
    # 33 rstn = 0;
    # 70 rstn = 1;

    // wait(done);
    # 10000000 $finish;
end

initial begin
    done = 0;
    while(~done) begin
        @(posedge clk) begin
            flag = 0;
            for(int i=0; i<`PN; i=i+1)
                if(~mon_done[i]) flag = 1;
            if(~flag) done = 1;
        end
    end
end

genvar pt;
generate
    for(pt=0; pt<`PN; pt=pt+1) begin: INPUT_PORT
        driver #(
            .port                       (pt),
            .ndata                      (ndata)
        )drv(
            .clk                        (clk), 
            .rstn                       (rstn),
            .vc_o                       (vc_i[pt]),
            .data_o                     (data_i[pt]),
            .valid_o                    (valid_i[pt]),
            .ready_i                    (ready_o[pt])
        );
    end
endgenerate

generate
    for(pt=0; pt<`PN; pt=pt+1) begin: OUTPUT_PORT
        monitor #(
            .port                       (pt)
        )mon(
            .clk                        (clk), 
            .rstn                       (rstn),
            .vc_i                       (vc_o[pt]),
            .data_i                     (data_o[pt]),
            .valid_i                    (valid_o[pt]),
            .ready_o                    (ready_i[pt]),
            .done                       (mon_done[pt])
        );
    end
endgenerate

cast_router #(
    .routing_table              (routing_table)
)dut(
    .clk                        (clk),
    .rstn                       (rstn),

    .vc_i                       (vc_i),
    .data_i                     (data_i),
    .valid_i                    (valid_i),
    .ready_o                    (ready_o),
    
    .vc_o                       (vc_o),
    .data_o                     (data_o),
    .valid_o                    (valid_o),
    .ready_i                    (ready_i)
);

endmodule