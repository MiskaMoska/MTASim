`include "params.svh"

module top_tb;

// `define BACK_PRESS_ON
// `define TIMEOUT_DETECT_ON 

localparam longint TIMEOUT_THRESHOLD = 100000; // only valid when TIMEOUT_DETECT_ON is defined
localparam int DEADLOCK_THRESHOLD = 1000000; // unit: 100ps
localparam int NW_CLOCK_PERIOD = 12; // unit: 100ps
localparam int BW_CLOCK_PERIOD = 12; // unit: 100ps
localparam int BR_CLOCK_PERIOD = 12; // unit: 100ps
localparam int PC_CLOCK_PERIOD = 12; // unit: 100ps

logic clk_nw, clk_bw, clk_br, clk_pc;
logic rstn_nw, rstn_bw, rstn_br, rstn_pc;

shortreal input_data [`ITW * `ITH * `ITC];
int num_idata;
int send_addr;
logic [`DW-1:0] data_i_inject;
logic valid_i_inject;
logic ready_o_inject;

int receive_addr [`EPN];
logic [`DW-1:0] data_o_eject [`EPN]; 
logic valid_o_eject [`EPN]; 
logic ready_i_eject [`EPN];

string quiting_state;

int state_file;
// int receive_file [`EPN];

bit all_tile_done;

/* Task Definations */
task resetClockDomainPC();
    rstn_pc = 1'b1;
    # 10 rstn_pc <= 1'b0;
endtask

task resetClockDomainBR();
    rstn_br = 1'b1;
    # 10 rstn_br <= 1'b0;
endtask

task resetClockDomainBW();
    rstn_bw = 1'b1;
    # 10 rstn_bw <= 1'b0;
endtask

task resetClockDomainNW();
    rstn_nw = 1'b1;
    # 10 rstn_nw <= 1'b0;
endtask

task releaseResetClockDomainPC();
    @(posedge clk_pc) rstn_pc <= 1'b1;
endtask

task releaseResetClockDomainBR();
    @(posedge clk_br) rstn_br <= 1'b1;
endtask

task releaseResetClockDomainBW();
    @(posedge clk_bw) rstn_bw <= 1'b1;
endtask

task releaseResetClockDomainNW();
    @(posedge clk_nw) rstn_nw <= 1'b1;
endtask

task detectNormalQuiting();
    while(1) begin
        @(posedge clk_nw) begin
            if(all_tile_done) begin
                quiting_state = "normal";
                break;
            end
        end
    end
endtask

task detectDeadlockQuiting();
    int win = 0;
    int start_addr;
    while(1) begin
        @(posedge clk_nw)
        if(~rstn_nw) win <= 0;
        else begin
            if(win == num_idata-1) win <= 0;
            else win <= win + 1;
            if(win == 0) start_addr <= send_addr;
            else if(send_addr != num_idata-1 && 
            send_addr != 0 && win == DEADLOCK_THRESHOLD && 
            send_addr == start_addr) begin // deadlock occurs
                $display("ERROR: deadlock detected!!!!!");
                quiting_state = "deadlock";
                break;
            end
        end
    end
endtask

task detectTimeoutQuiting();
    `ifdef TIMEOUT_DETECT_ON
    #(TIMEOUT_THRESHOLD);
    quiting_state = "timeout";
    `else
    while(1) begin
        @(posedge clk_nw);
    end
    `endif
endtask

task quitSimulation();
    state_file = $fopen("./quit_state.log");
    $fwrite(state_file, "%s", quiting_state);
    $finish;
endtask


/* Clock Generating */
always #(NW_CLOCK_PERIOD/2) clk_nw = ~clk_nw;
always #(BW_CLOCK_PERIOD/2) clk_bw = ~clk_bw;
always #(BR_CLOCK_PERIOD/2) clk_br = ~clk_br;
always #(PC_CLOCK_PERIOD/2) clk_pc = ~clk_pc;

initial begin
    num_idata = `ITW * `ITH * `ITC;
end

/* Back Pressure Control */
`ifdef BACK_PRESS_ON
initial begin
    for(int i=0; i<`EPN; i=i+1) begin
        ready_i_eject[i] = 0;
    end
    wait(rstn_nw);
    while(1) begin
        @(posedge clk_nw)
        for(int i=0; i<`EPN; i=i+1) begin
            ready_i_eject[i] <= ~ready_i_eject[i];
        end
        repeat(50) begin
            @(posedge clk_nw);
        end
    end
end
`else
initial begin
    for(int i=0; i<`EPN; i=i+1) begin
        ready_i_eject[i] = 0;
    end
    wait(rstn_nw);
    @(posedge clk_nw)
    for(int i=0; i<`EPN; i=i+1) begin
        ready_i_eject[i] <= 1;
    end
end
`endif


// assign ready_i_eject = '{(`EPN){rstn_nw}};

/* Reset Control */
initial begin
    {clk_nw, clk_bw, clk_br, clk_pc} = 4'b0;
    valid_i_inject = 0;

    resetClockDomainPC();
    resetClockDomainBR();
    resetClockDomainBW();
    resetClockDomainNW();

    repeat(2) begin
        @(posedge clk_nw);
    end
    
    releaseResetClockDomainPC();
    releaseResetClockDomainBR();
    releaseResetClockDomainBW();
    releaseResetClockDomainNW();
    @(posedge clk_nw)
    valid_i_inject <= 1;
end


/* Quiting Control */
initial begin
    fork 
        detectNormalQuiting();
        detectDeadlockQuiting();
        detectTimeoutQuiting();
    join_any
    quitSimulation();
end

/* Wave Dump */
initial begin
    // $fsdbDumpfile("wave.fsdb");
// //    $fsdbDumpvars(0, top_tb.system.tile_0_0);
// //    $fsdbDumpvars(0, top_tb.system.noc);
//    $fsdbDumpvars(3, top_tb.system);
    // $fsdbDumpvars(0, top_tb.system.tile_2_0);
    // $fsdbDumpvars(0, top_tb.system.tile_2_0.im2col);
    // $fsdbDumpvars(0, top_tb.system.tile_1_0.xbar);
    // $fsdbDumpvars(0, top_tb.system.tile_0_0.im2col);
//    $fsdbDumpMDA(0, top_tb.system.tile_2_1); //show array values
//    $fsdbDumpMDA(0, top_tb.system.tile_0_2); //show array values
    // $fsdbDumpMDA(0, top_tb.system.tile_2_0); //show array values
    // $fsdbDumpMDA(0, top_tb.system.tile_2_0.im2col); //show array values
    // $fsdbDumpMDA(0, top_tb.system.tile_1_0.xbar); //show array values
    // $fsdbDumpMDA(0, top_tb.system.tile_0_0.im2col); //show array values
end

/* Tile Done Moniting */
always_comb begin
    all_tile_done = 1;
    for(int x=0; x<`NW; x=x+1) begin
        for(int y=0; y<`NH; y=y+1) begin
            if(~(system.tile_done[x][y])) begin
                all_tile_done = 0;
            end
        end
    end
end

/* Address Counting Control */
initial begin
    send_addr = 0;
    receive_addr = '{(`EPN){0}};
end

final begin
    $fclose(state_file);
end

always @(posedge clk_nw or negedge rstn_nw) begin
    if(valid_i_inject & ready_o_inject) begin
        if(send_addr == num_idata-1) begin
            send_addr <= 0;
            valid_i_inject <= 0;
        end
        else send_addr <= send_addr + 1;
    end 
end

always @(posedge clk_nw) begin
    for(int i=0; i<`EPN; i=i+1) begin
        if(valid_o_eject[i] & ready_i_eject[i]) begin
            if(receive_addr[i] == num_idata-1) begin
                receive_addr[i] <= 0;
            end else begin
                receive_addr[i] <= receive_addr[i] + 1;
            end
        end
    end
end

assign data_i_inject = $shortrealtobits(input_data[send_addr]);

system system(
    .clk_nw                      (clk_nw),
    .clk_bw                      (clk_bw),
    .clk_br                      (clk_br),
    .clk_pc                      (clk_pc),
    .rstn_nw                     (rstn_nw), 
    .rstn_bw                     (rstn_bw), 
    .rstn_br                     (rstn_br), 
    .rstn_pc                     (rstn_pc), 

    .data_i_inject               (data_i_inject),
    .valid_i_inject              (valid_i_inject),
    .ready_o_inject              (ready_o_inject),

    .data_o_eject                (data_o_eject),
    .valid_o_eject               (valid_o_eject),
    .ready_i_eject               (ready_i_eject)
);

`include "tensor_loader.svh"

endmodule



