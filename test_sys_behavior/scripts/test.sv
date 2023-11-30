`timescale 100ps/1ps

module test;

localparam real a = 1;

initial begin
    # 1;
    $display("%0t!!!!!!!!!!!!!!!!!%f", $time, a/2);
end


// bit [31:0] temp_4b;
// bit [7:0] temp_1b;

// initial begin
//     f_weight=$fopen("./...", "rb");
//     for(int y=0; y<1000; y=y+1) for(int x=0; x<1000; x=x+1) begin
//         $fread(temp_4b, f_weight);
//         system.tile_0_0.xbar.weights[y][x] = $bitstoshortreal(temp_4b);
//     end
//     $display("weight of tile (0, 0) initializing complete ...")
// end

endmodule