`timescale 1ns/1ns

module test;
int a = 0;
logic clk = 0;
always #5 clk = ~clk;
always@(posedge clk) begin
    a <= a + 1;
end

always@(posedge a) begin
    $display("[Display]@%0t, a = %0d", $time, a);
end

// always@(posedge clk) begin
//     $strobe("[Strobe]@%0t, a = %0d", $time, a);
// end

initial begin
    // $monitor("[Monitor]@%0t, a = %0d", $time, a);
    # 100;
    $finish;
end

endmodule