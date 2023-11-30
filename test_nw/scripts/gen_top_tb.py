import os

__all__ = ['gen_top_tb']

def gen_top_tb(root_dir, tail_tiles, flitnum):
    nf = range(len(tail_tiles))
    save_dir = os.path.join(root_dir)
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'top_tb.sv')
    state_file = os.path.join(root_dir, 'run_state')
    send_pool_file = os.path.join(root_dir, 'send_pool.txt')
    receive_pool_files = []
    for i in nf:
        receive_pool_files.append(os.path.join(root_dir, f'receive_pool_eject{i}.txt'))
    containt = f'''
`timescale 1ns/1ns
`include "params.svh"

module top_tb;

reg clk;
reg rstn;
reg [31:0] addr;

integer state_file;
(* ramstyle = "AUTO" *) reg [`DW-1 : 0] packets [0:{flitnum-1}];
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
'''

    for i in nf:
        containt += f"integer file{i}; \n"
        containt += f"// assign ready_i_eject[{i}] = rstn;\n"

    containt += f'''
initial begin
    clk = 0;
    rstn = 1;
    # 33 rstn = 0;
    # 71 rstn = 1;
    valid_i_inject = 1;
    while(1) begin
        @(posedge clk);
        if((addr == {flitnum-1}) & valid_i_inject & ready_o_inject) begin
            valid_i_inject <= 1'b0;
            break;
        end
    end
    # 10000000
    $fwrite(state_file,"%s","normal");
'''

    for i in nf:
        containt += f'''
    $fclose(file{i});'''
    containt +='''
    $fclose(state_file);
    $finish;
end

initial begin
    // $fsdbDumpfile("wave.fsdb");
    // $fsdbDumpvars(0,top_tb);
    // $fsdbDumpMDA(); //show array values
'''
    for i in nf:
        containt += f'''
    file{i} = $fopen("{receive_pool_files[i]}");'''
    containt += f'''
    state_file = $fopen("{state_file}");
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
            else if(addr != {flitnum-1} & addr != 0 & win == 9999 && addr == start_addr) begin // deadlock occurs
                $fwrite(state_file,"%s","deadlock");
'''
    for i in nf:
        containt += f'''
                $fclose(file{i});'''
    containt += f'''
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
    $readmemb("{send_pool_file}",packets);
end

always@(posedge clk or negedge rstn)
begin
    if(~rstn) addr <= 0;
    else if(valid_i_inject & ready_o_inject) begin
        if(addr == {flitnum-1}) addr <= 0;
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
);\n'''

    containt += '''
always@(posedge clk) begin'''
    for i in nf:
        containt += f'''
    if(valid_o_eject[{i}] & ready_i_eject[{i}])  
        $fwrite(file{i}, "%b\\n", data_o_eject[{i}]);'''

    containt += '''
end

endmodule
'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"top testbench has been written to: {file_dir}")