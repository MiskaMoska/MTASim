`include "params.svh"

module monitor #(
    parameter port = 0
)(
    input   wire                clk, rstn,
    input   wire    [`VN-1:0]   vc_i,
    input   wire    [`DW-1:0]   data_i,
    input   wire                valid_i,
    output  wire                ready_o,
    output  bit                 done
);

string files [`VN];
integer f [`VN];
reg [3:0] cnt;
bit [10:0] rcv_cnt [`VN];
bit flag;

initial begin
    done = 0;
    for(int i=0; i<`VN; i=i+1) begin
        files[i] = $sformatf("./receive_pool_p%0d_v%0d.txt", port, i);        
        f[i] = $fopen(files[i], "w");
    end

    while(~done) begin
        @(posedge clk) begin
            flag = 0;
            for(int i=0; i<`VN; i=i+1) begin
                if(rcv_cnt[i] != 1000) flag = 1;
            end
            if(~flag) done = 1;
        end 
    end

    for(int i=0; i<`VN; i=i+1) begin
        $fclose(f[i]);
    end
end

always @(posedge clk) begin
    if(rstn) begin
        for(int i=0; i<`VN; i=i+1) begin
            if(vc_i[i] & valid_i & ready_o) begin
                $fwrite(f[i], "%b\n", data_i);
                rcv_cnt[i] <= rcv_cnt[i] + 1;
            end
        end
    end
end

assign ready_o = cnt < 2;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end

endmodule