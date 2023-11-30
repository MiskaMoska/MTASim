`include "params.svh"

module tile #(
    /* Parameters for Debugging*/
    parameter int x = 0,
    parameter int y = 0,
    parameter bit is_mapped = 0,

    /* input mask parameters */
    parameter int total_ichan = 0,
    parameter int start_ichan = 0,
    parameter int end_ichan = 0,

    /* conv_im2col parameters */
    parameter int conv_kernel_x = 0, 
    parameter int conv_kernel_y = 0,
    parameter int conv_stride_x = 0, 
    parameter int conv_stride_y = 0,
    parameter int conv_ifsize_x = 0, 
    parameter int conv_ifsize_y = 0,
    parameter int conv_ifpads_u = 0, 
    parameter int conv_ifpads_d = 0,
    parameter int conv_ifpads_l = 0, 
    parameter int conv_ifpads_r = 0,
    parameter int conv_ofsize_x = 0, 
    parameter int conv_ofsize_y = 0,
    parameter int xbar_num_ichan = 0, // must equal to end_ichan - start_ichan
    parameter int xbar_num_ochan = 0,

    /* xbar parameters */
    parameter int xbar_adc_trans_delay = 40,

    /* bias parameters */
    parameter bit has_bias = 0,

    /* activation parameters */
    parameter bit has_act = 0,

    /* pooling parameters */
    parameter bit has_pool = 0,
    parameter string pool_mode = "max", // max or avg
    parameter int pool_kernel_x = 0, 
    parameter int pool_kernel_y = 0,
    parameter int pool_stride_x = 0, 
    parameter int pool_stride_y = 0,
    parameter int pool_ifsize_x = 0, 
    parameter int pool_ifsize_y = 0,
    parameter int pool_ifpads_u = 0, 
    parameter int pool_ifpads_d = 0,
    parameter int pool_ifpads_l = 0, 
    parameter int pool_ifpads_r = 0,
    parameter int pool_ofsize_x = 0, 
    parameter int pool_ofsize_y = 0,

    /* data flow parameters */
    parameter bit merge_in = 0,
    parameter bit gather_in = 0,
    parameter bit merge_out = 0,
    parameter bit gather_out = 0,
    parameter bit cast_out = 0
)(
    input   logic                   clk_nw, // network
    input   logic                   clk_bw, // buffer write
    input   logic                   clk_br, // buffer_read
    input   logic                   clk_pc, // post-convolution
    input   logic                   rstn_nw, // network
    input   logic                   rstn_bw, // buffer write
    input   logic                   rstn_br, // buffer read
    input   logic                   rstn_pc, // post-convolution

    input   logic   [`QW-1 : 0]     cast_data_i,
    input   logic                   cast_valid_i,
    output  logic                   cast_ready_o,

    input   logic   [`QW-1 : 0]     merge_data_i,
    input   logic                   merge_valid_i,
    output  logic                   merge_ready_o,

    input   logic   [`QW-1 : 0]     gather_data_i,
    input   logic                   gather_valid_i,
    output  logic                   gather_ready_o,

    output  logic   [`QW-1 : 0]     cast_gather_data_o,
    output  logic                   cast_gather_valid_o,
    input   logic                   cast_gather_ready_i,

    output  logic   [`QW-1 : 0]     merge_data_o,
    output  logic                   merge_valid_o,
    input   logic                   merge_ready_i,

    /* For Debug */
    output  logic                   frame_done
);

logic [`QW-1 : 0] pool_data_o [`XW];
logic [`QW-1 : 0] im2col_data_o [`XH];
logic [`QW-1 : 0] xbar_data_o [`XW];
logic [`QW-1 : 0] split_data_o_mergeout [`XW];
logic [`QW-1 : 0] split_data_o_addbias [`XW];
logic [`QW-1 : 0] bias_data_o [`XW];
logic [`QW-1 : 0] merge_io_data_o [`XW];
logic [`QW-1 : 0] gather_io_data_o [`XW];
logic [`QW-1 : 0] add_data_o [`XW];
logic [`QW-1 : 0] act_data_o [`XW];

logic [`QW-1 : 0] cast_io_data_o;
logic [`QW-1 : 0] input_mask_data_o;

logic input_mask_ready_o;
logic input_mask_valid_o;
logic im2col_ready_o;
logic im2col_valid_o;
logic xbar_ready_o;
logic xbar_valid_o;
logic split_ready_o;
logic split_valid_o_mergeout;
logic split_valid_o_addbias;
logic merge_io_ready_o;
logic merge_io_valid_o;
logic gather_io_valid_o;
logic bias_ready_o;
logic bias_valid_o;
logic add_ready_o_bias;
logic add_ready_o_merge;
logic add_ready_o_gather;
logic add_valid_o;
logic act_ready_o;
logic act_valid_o;
logic pool_ready_o;
logic pool_valid_o;
logic cast_io_ready_o;

cast_io #(
    .valid_chans                (xbar_num_ochan)
)cast_io(
    .clk_nw                     (clk_nw),
    .clk_tl                     (clk_bw),
    .rstn_nw                    (rstn_nw),
    .rstn_tl                    (rstn_bw),
    
    .nw_data_i                  (cast_data_i),
    .nw_valid_i                 (cast_valid_i),
    .nw_ready_o                 (cast_ready_o),

    .tl_data_o                  (cast_io_data_o),
    .tl_valid_o                 (cast_io_valid_o),
    .tl_ready_i                 (input_mask_ready_o),

    .tl_data_i                  (pool_data_o),
    .tl_valid_i                 (pool_valid_o),
    .tl_ready_o                 (cast_io_ready_o),

    .nw_data_o                  (cast_gather_data_o),
    .nw_valid_o                 (cast_gather_valid_o),
    .nw_ready_i                 (cast_gather_ready_i)
);

input_mask #(
    .total_ichan                (total_ichan),
    .start_ichan                (start_ichan),
    .end_ichan                  (end_ichan)
)input_mask(
    .clk                        (clk_bw),
    .rstn                       (rstn_bw),

    .data_i                     (cast_io_data_o),
    .valid_i                    (cast_io_valid_o),
    .ready_o                    (input_mask_ready_o),

    .data_o                     (input_mask_data_o),
    .valid_o                    (input_mask_valid_o),
    .ready_i                    (im2col_ready_o)
);

conv_im2col #(
    .x                          (x),
    .y                          (y),
    .kernel_x                   (conv_kernel_x), 
    .kernel_y                   (conv_kernel_y),
    .stride_x                   (conv_stride_x), 
    .stride_y                   (conv_stride_y),
    .ifsize_x                   (conv_ifsize_x), 
    .ifsize_y                   (conv_ifsize_y),
    .ifpads_u                   (conv_ifpads_u), 
    .ifpads_d                   (conv_ifpads_d),
    .ifpads_l                   (conv_ifpads_l), 
    .ifpads_r                   (conv_ifpads_r),
    .ofsize_x                   (conv_ofsize_x), 
    .ofsize_y                   (conv_ofsize_y),
    .xbar_num_ichan             (xbar_num_ichan)
)im2col(
    .clk_bufw                   (clk_bw), 
    .clk_bufr                   (clk_br), 
    .rstn_bufw                  (rstn_bw),
    .rstn_bufr                  (rstn_br),
    
    .data_i                     (input_mask_data_o),
    .valid_i                    (input_mask_valid_o),
    .ready_o                    (im2col_ready_o),

    .data_o                     (im2col_data_o),
    .valid_o_tg                 (im2col_valid_o),
    .ready_i_tg                 (xbar_ready_o)
);

xbar #(
    .trans_delay                (xbar_adc_trans_delay)
)xbar(
    .clk                        (clk_pc),
    .rstn                       (rstn_pc),
    .vector_i                   (im2col_data_o),
    .vector_o                   (xbar_data_o),
    .valid_i_tg                 (im2col_valid_o),
    .ready_o_tg                 (xbar_ready_o),
    .valid_o                    (xbar_valid_o),
    .ready_i                    (split_ready_o)
);

res_split #(
    .merge_out                  (merge_out)
)split(
    .data_i                     (xbar_data_o),
    .valid_i                    (xbar_valid_o),
    .ready_o                    (split_ready_o),

    .data_o_mergeout            (split_data_o_mergeout),
    .valid_o_mergeout           (split_valid_o_mergeout),
    .ready_i_mergeout           (merge_io_ready_o),

    .data_o_addbias             (split_data_o_addbias),
    .valid_o_addbias            (split_valid_o_addbias),
    .ready_i_addbias            (bias_ready_o)
);

bias_unit #(
    .has_bias                   (has_bias)
)bias(
    .data_i                     (split_data_o_addbias),
    .valid_i                    (split_valid_o_addbias),
    .ready_o                    (bias_ready_o),

    .data_o                     (bias_data_o),
    .valid_o                    (bias_valid_o),
    .ready_i                    (add_ready_o_bias)
);

merge_io #(
    .valid_chans                (xbar_num_ochan)
)merge_io(
    .clk_nw                     (clk_nw),
    .clk_tl                     (clk_pc),
    .rstn_nw                    (rstn_nw),
    .rstn_tl                    (rstn_pc),
    
    .nw_data_i                  (merge_data_i),
    .nw_valid_i                 (merge_valid_i),
    .nw_ready_o                 (merge_ready_o),

    .tl_data_o                  (merge_io_data_o),
    .tl_valid_o                 (merge_io_valid_o),
    .tl_ready_i                 (add_ready_o_merge),

    .tl_data_i                  (split_data_o_mergeout),
    .tl_valid_i                 (split_valid_o_mergeout),
    .tl_ready_o                 (merge_io_ready_o),

    .nw_data_o                  (merge_data_o),
    .nw_valid_o                 (merge_valid_o),
    .nw_ready_i                 (merge_ready_i)
);

gather_io #(
    .valid_chans                (xbar_num_ochan)
)gather_io(
    .clk_nw                     (clk_nw),
    .clk_tl                     (clk_pc),
    .rstn_nw                    (rstn_nw),
    .rstn_tl                    (rstn_pc),
    
    .nw_data_i                  (gather_data_i),
    .nw_valid_i                 (gather_valid_i),
    .nw_ready_o                 (gather_ready_o),

    .tl_data_o                  (gather_io_data_o),
    .tl_valid_o                 (gather_io_valid_o),
    .tl_ready_i                 (add_ready_o_gather)
);

add_unit #(
    .merge_in                   (merge_in),
    .merge_out                  (merge_out),
    .gather_in                  (gather_in),
    .gather_out                 (gather_out),
    .cast_out                   (cast_out)
)add(
    .clk                        (clk_pc),
    .rstn                       (rstn_pc),

    .bias_data_i                (bias_data_o),
    .bias_valid_i               (bias_valid_o),
    .bias_ready_o               (add_ready_o_bias),

    .merge_data_i               (merge_io_data_o),
    .merge_valid_i              (merge_io_valid_o),
    .merge_ready_o              (add_ready_o_merge),

    .gather_data_i              (gather_io_data_o),
    .gather_valid_i             (gather_io_valid_o),
    .gather_ready_o             (add_ready_o_gather),

    .data_o                     (add_data_o),
    .valid_o                    (add_valid_o),
    .ready_i                    (act_ready_o)
);

act_unit #(
    .has_act                    (has_act)
)act(
    .data_i                     (add_data_o),
    .valid_i                    (add_valid_o),
    .ready_o                    (act_ready_o),

    .data_o                     (act_data_o),
    .valid_o                    (act_valid_o),
    .ready_i                    (pool_ready_o)
);

pooling_unit #(
    .x                          (x),
    .y                          (y),
    .has_pool                   (has_pool),
    .mode                       (pool_mode),
    .kernel_x                   (pool_kernel_x), 
    .kernel_y                   (pool_kernel_y),
    .stride_x                   (pool_stride_x), 
    .stride_y                   (pool_stride_y),
    .ifsize_x                   (pool_ifsize_x), 
    .ifsize_y                   (pool_ifsize_y),
    .ifpads_u                   (pool_ifpads_u), 
    .ifpads_d                   (pool_ifpads_d),
    .ifpads_l                   (pool_ifpads_l), 
    .ifpads_r                   (pool_ifpads_r),
    .ofsize_x                   (pool_ofsize_x), 
    .ofsize_y                   (pool_ofsize_y)
)pool(
    .clk                        (clk_pc),
    .rstn                       (rstn_pc),

    .data_i                     (act_data_o),
    .valid_i                    (act_valid_o),
    .ready_o                    (pool_ready_o),
    
    .data_o                     (pool_data_o),
    .valid_o                    (pool_valid_o),
    .ready_i                    (cast_io_ready_o)
);

/* For debugging */
int crcnt = 0;
int mrcnt = 0;
int grcnt = 0;
int scnt = 0;
int ofsize_x, ofsize_y, ochan;
int num_odata, num_cidata, num_midata, num_gidata;
bit cast_receive_done = 0;
bit send_done = 0;

initial begin
    ofsize_x = has_pool ? pool_ofsize_x : conv_ofsize_x;
    ofsize_y = has_pool ? pool_ofsize_y : conv_ofsize_y;
    ochan = xbar_num_ochan;
    num_odata = ofsize_x * ofsize_y * ochan;
    num_cidata = conv_ifsize_x * conv_ifsize_y * xbar_num_ichan;
    num_midata = merge_in ? conv_ofsize_x * conv_ofsize_y * xbar_num_ichan : 0;
    num_gidata = gather_in ? conv_ofsize_x * conv_ofsize_y * xbar_num_ichan : 0;
end

always@(posedge clk_nw) begin
    if(cast_valid_i & cast_ready_o) begin 
        crcnt <= crcnt + 1;
        if(crcnt == num_cidata - 1) begin
            cast_receive_done <= 1;
        end else if (crcnt == 0) begin
            $display("time %0t: node (%0d, %0d) starting computing ...", $time, x, y);
        end
    end
    if(merge_valid_i & merge_ready_o) mrcnt <= mrcnt + 1;
    if(gather_valid_i & gather_ready_o) grcnt <= grcnt + 1;
end

always@(posedge clk_nw) begin
    if(merge_out & merge_valid_o & merge_ready_i | 
    (~merge_out) & cast_gather_valid_o & cast_gather_ready_i) begin
        scnt <= scnt + 1;
        if(scnt == num_odata - 1) begin
            send_done <= 1;
            $display("time %0t: node (%0d, %0d) finished computing ...", $time, x, y);
        end 
    end
end

assign frame_done = ~is_mapped | send_done;

// shortreal result [ofsize_y] [ofsize_x] [ochan];
// int oy, ox, oc;

// always @(posedge clk_nw) begin
//     if(cast_gather_valid_o & cast_gather_ready_i) begin
//         result[oy][ox][oc] = $bitstoshortreal(cast_gather_data_o); 
//         if(oc == ochan - 1) begin
//             oc <= 0;
//             if(ox == ofsize_x - 1) begin
//                 ox <= 0;
//                 if(oy == ofsize_y - 1) begin
//                     oy <= 0;
//                 end else begin
//                     oy <= oy + 1;
//                 end
//             end else begin
//                 ox <= ox + 1;
//             end
//         end else begin
//             oc <= oc + 1;
//         end
//     end
// end

// int fres;
// initial begin
//     fres = $fopen($sformatf("./res/tile_%0d_%0d.bin", x, y));
//     oy = 0; ox = 0; oc = 0;
//     wait(send_done) begin
//         for(int i=0; i<ofsize_y; i=i+1) begin
//             for(int j=0; j<ofsize_x; j=j+1) begin
//                 for(int k=0; k<ochan; k=k+1) begin
//                     $fwrite($bitstoshortreal(result[i][j][k]));
//                 end
//             end
//         end
//     end
//     $fclose(fres);
// end

endmodule 