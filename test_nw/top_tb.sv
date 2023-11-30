
`timescale 1ns/1ns
`include "params.svh"

module top_tb;

reg clk;
reg rstn;
reg [31:0] addr;

integer state_file;
(* ramstyle = "AUTO" *) reg [`DW-1 : 0] packets [0:999];
logic [`DW-1:0] data_i_inject;
logic valid_i_inject;
logic ready_o_inject;

logic [`DW-1:0] data_o_eject [`EPN]; 
logic valid_o_eject [`EPN]; 
logic ready_i_eject [`EPN];

// back pressure control
initial begin
    for(int i=0; i<`EPN; i=i+1) begin
        ready_i_eject[i] = 0;
    end
    wait(~rstn);
    wait(rstn);
    while(1) begin
        @(posedge clk)
        for(int i=0; i<`EPN; i=i+1) begin
            ready_i_eject[i] <= ~ready_i_eject[i];
        end
        repeat(50) begin
            @(posedge clk);
        end
    end
end
integer file0; 
// assign ready_i_eject[0] = rstn;
integer file1; 
// assign ready_i_eject[1] = rstn;
integer file2; 
// assign ready_i_eject[2] = rstn;

initial begin
    clk = 0;
    rstn = 1;
    # 33 rstn = 0;
    # 71 rstn = 1;
    valid_i_inject = 1;
    while(1) begin
        @(posedge clk);
        if((addr == 999) & valid_i_inject & ready_o_inject) begin
            valid_i_inject <= 1'b0;
            break;
        end
    end
    # 10000000
    $fwrite(state_file,"%s","normal");

    $fclose(file0);
    $fclose(file1);
    $fclose(file2);
    $fclose(state_file);
    $finish;
end

initial begin
    // $fsdbDumpfile("wave.fsdb");
    // $fsdbDumpvars(0,top_tb);
    // $fsdbDumpMDA(); //show array values

    file0 = $fopen("/mnt/c/git/nvcim-nw/test_nw/receive_pool_eject0.txt");
    file1 = $fopen("/mnt/c/git/nvcim-nw/test_nw/receive_pool_eject1.txt");
    file2 = $fopen("/mnt/c/git/nvcim-nw/test_nw/receive_pool_eject2.txt");
    state_file = $fopen("/mnt/c/git/nvcim-nw/test_nw/run_state");
end

// deadlock detection
initial begin
    int win;
    int start_addr;
    forever begin
        @(posedge clk)
        if(~rstn) win <= 0;
        else begin
            if(win == 9999) win <= 0;
            else win <= win + 1;
            if(win == 0) start_addr <= addr;
            else if(addr != 999 & addr != 0 & win == 9999 && addr == start_addr) begin // deadlock occurs
                $fwrite(state_file,"%s","deadlock");

                $fclose(file0);
                $fclose(file1);
                $fclose(file2);
                $fclose(state_file);
                $display("ERROR: deadlock detected!!!!!");
                $finish;
            end
        end
    end
end

always #5 clk = ~clk;

initial begin
    addr = 0;
    $readmemb("/mnt/c/git/nvcim-nw/test_nw/send_pool.txt",packets);
end

always@(posedge clk or negedge rstn)
begin
    if(~rstn) addr <= 0;
    else if(valid_i_inject & ready_o_inject) begin
        if(addr == 999) addr <= 0;
        else addr <= addr + 1;
    end 
end

//always@(posedge clk) begin
//    $display("addr@driver: %d",addr);
//end

assign data_i_inject = packets[addr];

system dut(
    .clk                         (clk),
    .rstn                        (rstn),

    .data_i_inject                 (data_i_inject),
    .valid_i_inject                (valid_i_inject),
    .ready_o_inject                (ready_o_inject),

    .data_o_eject                 (data_o_eject),
    .valid_o_eject                (valid_o_eject),
    .ready_i_eject                (ready_i_eject)
);

always@(posedge clk) begin
    if(valid_o_eject[0] & ready_i_eject[0])  
        $fwrite(file0, "%b\n", data_o_eject[0]);
    if(valid_o_eject[1] & ready_i_eject[1])  
        $fwrite(file1, "%b\n", data_o_eject[1]);
    if(valid_o_eject[2] & ready_i_eject[2])  
        $fwrite(file2, "%b\n", data_o_eject[2]);
end

endmodule

