`include "params.svh"

interface TileInterface;
    logic [`DW-1:0] cast_gather_data_o;
    logic           cast_gather_valid_o;
    logic           cast_gather_ready_i;

    logic [`DW-1:0] cast_data_i;
    logic           cast_valid_i;
    logic           cast_ready_o;

    logic [`DW-1:0] gather_data_i;
    logic           gather_valid_i;
    logic           gather_ready_o;

    logic [`DW-1:0] merge_data_o;
    logic           merge_valid_o;
    logic           merge_ready_i;

    logic [`DW-1:0] merge_data_i;
    logic           merge_valid_i;
    logic           merge_ready_o;

    modport TileSide(
        output          cast_gather_data_o;
        output          cast_gather_valid_o;
        input           cast_gather_ready_i;

        input           cast_data_i;
        input           cast_valid_i;
        output          cast_ready_o;

        input           gather_data_i;
        input           gather_valid_i;
        output          gather_ready_o;

        output          merge_data_o;
        output          merge_valid_o;
        input           merge_ready_i;

        input           merge_data_i;
        input           merge_valid_i;
        output          merge_ready_o;      
    );

    modport TilePartner(
        input           cast_gather_data_o;
        input           cast_gather_valid_o;
        output          cast_gather_ready_i;

        output          cast_data_i;
        output          cast_valid_i;
        input           cast_ready_o;

        output          gather_data_i;
        output          gather_valid_i;
        input           gather_ready_o;

        input           merge_data_o;
        input           merge_valid_o;
        output          merge_ready_i;

        output          merge_data_i;
        output          merge_valid_i;
        input           merge_ready_o;      
    );

endinterface

interface RouterPort;

    modport RouterSide(

    );

    modport RouterPartner(

    );

endinterface