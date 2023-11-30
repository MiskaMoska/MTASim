`include "params.svh"

module driver #(
    parameter port = 0,
    parameter ndata = 1000
)(
    input   wire                clk, rstn,
    output  wire    [`VN-1:0]   vc_o,
    output  wire    [`DW-1:0]   data_o,
    output  wire                valid_o,
    input   wire                ready_i
);

// typedef struct {
//   reg [`DW-1:0] data [0:ndata-1];
// } Pool;

class Pool;
    reg [`DW-1:0] data [0:ndata-1];
endclass

string files [`VN];
Pool pool [`VN];
logic [$clog2(ndata):0] addr [`VN];
logic [`DW-1:0] data [`VN];
logic ready [`VN];
logic valid [`VN];

logic [`VN-1:0] arb_request;
logic [`VN-1:0] mux_sel;

initial begin
    for(int vc=0; vc<`VN; vc=vc+1) begin
        files[vc] = $sformatf("./send_pool_p%0d_v%0d.txt", port, vc);
        pool[vc] = new; // don't forget to new a class
        $readmemb(files[vc], pool[vc].data);
    end
end

genvar vc;
generate
    for(vc=0; vc<`VN; vc=vc+1) begin
        // assign data[vc] = pool[vc].data[addr[vc]];
        assign valid[vc] = addr[vc] < ndata;
        assign ready[vc] = mux_sel[vc] & ready_i;
        assign arb_request[vc] = valid[vc];
    end 
endgenerate

always_comb begin
    for(int vc=0; vc<`VN; vc=vc+1) begin
        data[vc] = pool[vc].data[addr[vc]];
    end
end

mtx_arbiter #(
    .LEN            (`VN)
)arbiter(
    .clk            (clk),
    .rstn           (rstn),
    .request        (arb_request),
    .grant          (mux_sel),
    .update         (| mux_sel)
);

mux #(
    .DWIDTH         (`DW),
    .WAYS           (`VN)
)mux_data(
    .sel            (mux_sel),
    .data_i         (data),
    .data_o         (data_o)
);

mux #(
    .DWIDTH         (1),
    .WAYS           (`VN)
)mux_valid(
    .sel            (mux_sel),
    .data_i         (valid),
    .data_o         (valid_o)
);

assign vc_o = mux_sel;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        for(int i=0; i<`VN; i=i+1) begin
            addr[i] <= 0;
        end
    end else begin
        for(int i=0; i<`VN; i=i+1) begin
            if(valid[i] & ready[i])
                addr[i] <= addr[i] + 1;
        end
    end
end

endmodule