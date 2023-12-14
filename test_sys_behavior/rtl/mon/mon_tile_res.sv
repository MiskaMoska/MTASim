`include "params.svh"

module mon_tile_res_data(
    input logic clk,
    input logic cond,
    input logic [`DW-1 : 0] data_sig,
    input int file
);

initial begin
    int cnt = 0;
    forever begin
        @(posedge clk) begin
            if(cond) begin
                $fwriteb(file, "%u", data_sig);
                if(cnt >= 500) begin
                    cnt = 0;
                    $fflush(file);
                end else cnt ++;
            end
        end
    end
end

endmodule

module mon_tile_res_vector #(
    parameter int valid_chans = 0
)(
    input logic clk,
    input logic cond,
    input logic [`DW-1 : 0] vector_sig [`XW],
    input int file
);

initial begin
    int cnt = 0;
    forever begin
        @(posedge clk) begin
            if(cond) begin
                for(int i=0; i<valid_chans; i++) begin
                    $fwrite(file, "%u", vector_sig[i]);
                end
                if(cnt >= 500) begin
                    cnt = 0;
                    $fflush(file);
                end else cnt ++;
            end
        end
    end
end

endmodule