`timescale 1ns/1ns
`include "pooling_config.svh"

module top_tb;

localparam CLK_PERIOD = 18;

logic clk, rstn;
logic valid_i, ready_o;
logic valid_o, ready_i;
logic [`QW-1 : 0] data_i [`XW];
logic [`QW-1 : 0] data_o [`XW];

int input_cnt;
int facts;
bit [`QW-1 : 0] temp;

logic sim_done;

shortreal results [ofsize_y] [ofsize_x] [`XW];
bit [`QW-1 : 0] activation [ifsize_x * ifsize_y * `XW];

int ready_cnt;

pooling_unit #(
    .mode                           (mode), // max or avg
    .kernel_x                       (kernel_x), 
    .kernel_y                       (kernel_y),
    .stride_x                       (stride_x), 
    .stride_y                       (stride_y),
    .ifsize_x                       (ifsize_x), 
    .ifsize_y                       (ifsize_y),
    .ifpads_u                       (ifpads_u), 
    .ifpads_d                       (ifpads_d),
    .ifpads_l                       (ifpads_l), 
    .ifpads_r                       (ifpads_r),
    .ofsize_x                       (ofsize_x), 
    .ofsize_y                       (ofsize_y)
)pooling_unit(
    .clk                            (clk),
    .rstn                           (rstn),

    .data_i                         (data_i),
    .valid_i                        (valid_i),
    .ready_o                        (ready_o),
    
    .data_o                         (data_o),
    .valid_o                        (valid_o),
    .ready_i                        (ready_i)
);

initial begin
    clk = 0;
    rstn = 1;
    input_cnt = 0;
    # 50 
    rstn = 0;
    # 100;
    @(posedge clk) rstn <= 1;
    // # 500000 $finish;
    wait(sim_done);
    report_phase();
end

initial begin // initialize convolution weights and activations
    facts = $fopen("./activation.bin", "rb");
    for(int i=0; i<ifsize_x * ifsize_y * `XW; i=i+1) begin
        $fread(temp, facts);
        activation[i]={temp[7:0],temp[15:8],temp[23:16],temp[31:24]};
    end
    $fclose(facts);
end


initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA(); //show array values
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
        input_cnt <= 0;
    end else begin
        if(valid_i & ready_o) begin
            if(input_cnt == ifsize_x * ifsize_y - 1) begin
                input_cnt <= 0;
            end else begin
                input_cnt <= input_cnt + 1;
            end
        end
    end
end

always_comb begin
    for(int i=0; i<`XW; i=i+1) begin
        data_i[i] = activation[input_cnt * `XW + i];
    end
end

assign valid_i = 1;

always #(CLK_PERIOD) clk = ~clk;

/* Collecting Output Vectors */
int pool_of_x, pool_of_y;
initial begin
    pool_of_x = 0;
    pool_of_y = 0;
    forever begin
        @(posedge clk);
        if(valid_o & ready_i) begin
            if(pool_of_x == ofsize_x - 1) begin
                pool_of_y <= pool_of_y + 1;
                pool_of_x <= 0;
            end else begin
                pool_of_x <= pool_of_x + 1;
            end
            for(int i=0; i<`XW; i=i+1) begin
                results[pool_of_y][pool_of_x][i] = $bitstoshortreal(data_o[i]);
            end
        end
    end
end

assign ready_i = (ready_cnt > 17);

initial begin
    ready_cnt = 0;
    forever begin
        @(posedge clk) begin
            if(ready_cnt == 20) ready_cnt <= 0;
            else ready_cnt <= ready_cnt + 1;
        end  
    end
end


assign sim_done = (pool_of_x == ofsize_x - 1) & (pool_of_y == ofsize_y - 1) & (valid_o & ready_i);

task report_phase;
    # 1000;
    saveOutputFeatureMap();
    $finish;
endtask

function void saveOutputFeatureMap;
    int f1;
    f1 = $fopen("./output_sv.txt", "w");
    for(int c=0; c<`XW; c=c+1) begin
        for(int y=0; y<ofsize_y; y=y+1) begin
            for(int x=0; x<ofsize_x; x=x+1) begin
                $fwrite(f1, $sformatf("%.2f\n", results[y][x][c]));
            end
        end
    end
    $fflush(f1); $fclose(f1);
endfunction

endmodule