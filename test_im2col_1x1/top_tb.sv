`timescale 1ns/1ns
`include "im2col_config.svh"

module top_tb;

localparam CLK1_PERIOD = 24;
localparam CLK2_PERIOD = 4;
localparam CLK3_PERIOD = 4;

logic clk1, clk2, clk3;
logic rstn1, rstn2, rstn3;

logic [`QW-1 : 0] vector_inter [`XH];
logic [`QW-1 : 0] vector_o [`XW];

logic xbar_valid_o, xbar_ready_i;
logic valid_tg, ready_tg;

logic [`QW-1 : 0] im2col_din;
logic im2col_valid_i, im2col_ready_o;

int fd1, fd2;
bit [31:0] temp1, temp2;
bit [31:0] activation [ifsize_x * ifsize_y * xbar_num_ichan];

int input_cnt;
logic sim_done;

shortreal xbar_ovector [ofsize_y] [ofsize_x] [`XW];
shortreal xbar_ivector [`XH];

conv_im2col #(
    .kernel_x                   (kernel_x), 
    .kernel_y                   (kernel_y),
    .stride_x                   (stride_x), 
    .stride_y                   (stride_y),
    .ifsize_x                   (ifsize_x), 
    .ifsize_y                   (ifsize_y),
    .ifpads_u                   (ifpads_u), 
    .ifpads_d                   (ifpads_d),
    .ifpads_l                   (ifpads_l), 
    .ifpads_r                   (ifpads_r),
    .ofsize_x                   (ofsize_x), 
    .ofsize_y                   (ofsize_y),
    .xbar_num_ichan             (xbar_num_ichan),    

    .vcfg_valid                 (vcfg_valid), // indicate whether the current position is a valid position, that is, been mapped or not
    .vcfg_winx                  (vcfg_winx), // kernel window x position
    .vcfg_winy                  (vcfg_winy), // kernel window y position
    .vcfg_rela_ichan            (vcfg_rela_ichan) // relative input channel index
)im2col(
    .clk_bufw                   (clk1), 
    .clk_bufr                   (clk2), 
    .rstn_bufw                  (rstn1),
    .rstn_bufr                  (rstn2),
    
    .data_i                     (im2col_din),
    .valid_i                    (im2col_valid_i),
    .ready_o                    (im2col_ready_o),

    .data_o                     (vector_inter),
    .valid_o_tg                 (valid_tg),
    .ready_i_tg                 (ready_tg)
);

xbar #(
    .trans_delay                (100)
)xbar(
    .clk                        (clk3),
    .rstn                       (rstn3),
    .vector_i                   (vector_inter),
    .vector_o                   (vector_o),
    .valid_i_tg                 (valid_tg),
    .ready_o_tg                 (ready_tg),
    .valid_o                    (xbar_valid_o),
    .ready_i                    (xbar_ready_i)
);

assign xbar_ready_i = 1; // always data ready

initial begin
    clk1 = 0;
    clk2 = 0;
    clk3 = 0;
    rstn1 = 1;
    rstn2 = 1;
    rstn3 = 1;
    input_cnt = 0;
    # 50 
    rstn1 = 0;
    rstn2 = 0;
    rstn3 = 0;
    # 100;
    @(posedge clk3) rstn3 <= 1;
    @(posedge clk2) rstn2 <= 1; 
    @(posedge clk1) rstn1 <= 1;
    // # 500000 $finish;
    wait(sim_done);
    report_phase();
end

initial begin // initialize convolution weights and activations
    fd1 = $fopen("./weights.bin", "rb");
    for(int i=0; i<`XH; i=i+1) begin
        for(int j=0; j<`XW; j=j+1) begin
            $fread(temp1, fd1);
            xbar.weights[i][j]=$bitstoshortreal({temp1[7:0],temp1[15:8],temp1[23:16],temp1[31:24]});
        end
    end

    fd2 = $fopen("./activation.bin", "rb");
    for(int i=0; i<ifsize_x * ifsize_y * xbar_num_ichan; i=i+1) begin
        $fread(temp2, fd2);
        activation[i]={temp2[7:0],temp2[15:8],temp2[23:16],temp2[31:24]};
    end

    $fclose(fd1);
    $fclose(fd2);
end


initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA(); //show array values
end

always@(posedge clk1 or negedge rstn1) begin
    if(~rstn1) begin
        input_cnt <= 0;
    end else begin
        if(im2col_valid_i & im2col_ready_o) begin
            if(input_cnt == ifsize_x * ifsize_y * xbar_num_ichan - 1) begin
                input_cnt <= 0;
            end else begin
                input_cnt <= input_cnt + 1;
            end
        end
    end
end

assign im2col_din = activation[input_cnt];
assign im2col_valid_i = 1;

always #(CLK1_PERIOD/2) clk1 = ~clk1;
always #(CLK2_PERIOD/2) clk2 = ~clk2;
always #(CLK3_PERIOD/2) clk3 = ~clk3;

/* Collecting Output Vectors */
int xbar_of_x, xbar_of_y;
initial begin
    xbar_of_x = 0;
    xbar_of_y = 0;
    forever begin
        @(posedge clk3);
        if(xbar_valid_o & xbar_ready_i) begin
            if(xbar_of_x == ofsize_x - 1) begin
                xbar_of_y <= xbar_of_y + 1;
                xbar_of_x <= 0;
            end else begin
                xbar_of_x <= xbar_of_x + 1;
            end
            for(int i=0; i<`XW; i=i+1) begin
                xbar_ovector[xbar_of_y][xbar_of_x][i] = $bitstoshortreal(vector_o[i]);
            end
        end
    end
end

initial begin
    @(posedge rstn1);
    @(negedge xbar.valid_i_pulse);
    repeat(2) begin
        @(posedge clk3);
    end
    for(int i=0; i<`XH; i=i+1) begin
        xbar_ivector[i] = $bitstoshortreal(xbar.vector_reg[i]);
    end
end

assign sim_done = (xbar_of_x == ofsize_x - 1) & (xbar_of_y == ofsize_y - 1) & (xbar_valid_o & xbar_ready_i);

task report_phase;
    # 1000;
    saveOutputFeatureMap();
    $finish;
endtask

function void saveOutputFeatureMap;
    int f1, f2;
    f1 = $fopen("./output_sv.txt", "w");
    for(int c=0; c<`XW; c=c+1) begin
        for(int y=0; y<ofsize_y; y=y+1) begin
            for(int x=0; x<ofsize_x; x=x+1) begin
                $fwrite(f1, $sformatf("%.2f\n", xbar_ovector[y][x][c]));
            end
        end
    end
    $fflush(f1); $fclose(f1);

    f2 = $fopen("./ivector_sv.txt", "w");
    for(int c=0; c<`XH; c=c+1) begin
        $fwrite(f2, $sformatf("%f\n", xbar_ivector[c]));
    end
    $fflush(f2); $fclose(f2);
endfunction

endmodule