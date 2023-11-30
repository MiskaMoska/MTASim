import os
import math

__all__ = ['gen_params_header']

def gen_params_header(root_dir, w, h, datawidth, vcnumber, input_size, tail_tiles, cbn, cbd, xw, xh, pbd, gbs):
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'params.svh')
    containt = f'''
`ifndef                 _PARAMS_SVH_
`define                 _PARAMS_SVH_

/****************************** enable calculation ******************************/
`define                 CALC_ON

/****************************** data width (in behavior model, this is fixed to 32) ******************************/
`define                 DW                              {datawidth}

/****************************** quntization width (in behavior model, this is set as equal to data noc data width) ******************************/
`define                 QW                              `DW

/************************** router port number **************************/
`define                 PN                              5

/************************ vc number in each port ************************/
`define                 VN                              {vcnumber}

/**************************** network width *****************************/
`define                 NW                              {w}

/**************************** network height ****************************/
`define                 NH                              {h}

/*************************** eject port number ***************************/
`define                 EPN                             {len(tail_tiles)}

/*************************** convolution bank number ***************************/
`define                 CBN                             {cbn}

/*************************** convolution bank depth ***************************/
`define                 CBD                             {cbd}

/*************************** xbar width (output vector lenghth) ***************************/
`define                 XW                              {xw}

/*************************** xbar height (input vector lenghth) ***************************/
`define                 XH                              {xh}

/*************************** pooling bank depth ***************************/
`define                 PBD                             {pbd}

/*************************** input tensor height ***************************/
`define                 ITH                             {input_size[0]}

/*************************** input tensor width ***************************/
`define                 ITW                             {input_size[1]}

/*************************** input tensor channel ***************************/
`define                 ITC                             {input_size[2]}

/*************************** gather buffer size ***************************/
`define                 GBS                             {gbs}


`endif
'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"params header configuration info has been written to: {file_dir}")