`timescale 1ns/1ns
`include "params.svh"

module top_tb;

bit [`QW-1 : 0] din1 [`XH];
bit [`QW-1 : 0] din2 [`XH];
bit [`QW-1 : 0] din3 [`XH];

bit [`QW-1 : 0] vector_i [`XH];
bit [`QW-1 : 0] vector_o [`XW];
shortreal real_vector_o [`XW];

logic valid, ready;
logic clk, rstn;

xbar #(
    .trans_delay(40)
)xbar(
    .clk(clk),
    .rstn(rstn),
    .vector_i(vector_i),
    .vector_o(vector_o),
    .valid_i_tg(valid),
    .ready_o_tg(ready)
);

initial begin
    $readmemb("./send_data1.txt", din1);
    $readmemb("./send_data2.txt", din2);
    $readmemb("./send_data3.txt", din3);
end

initial begin
    clk = 0;
    rstn = 1;
    # 33 rstn = 0;
    # 70 rstn = 1;
    valid = 0;
    # 20
    vector_i = din1;
    # 5
    valid = ~valid;

    # 80 
    vector_i = din2;
    # 5
    valid = ~valid;

    # 80 
    vector_i = din3;
    # 5
    valid = ~valid;

    # 80;
    $finish;
end

initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA(); //show array values
end

always #2 clk = ~clk;

always_comb begin
    for(int i=0; i<`XW; i=i+1) begin
        real_vector_o[i] = $bitstoshortreal(vector_o[i]);
    end
end

endmodule