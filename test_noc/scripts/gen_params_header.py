import os
import math

__all__ = ['gen_params_header']

def gen_params_header(root_dir, w, h, datawidth, vcnumber, tail_tiles):
    save_dir = os.path.join(root_dir, 'config')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'params.svh')
    containt = f'''
`ifndef                 _PARAMS_SVH_
`define                 _PARAMS_SVH_

/****************************** data width ******************************/
`define                 DW                              {datawidth}

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

`endif
'''
    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()
    
    print(f"params header configuration info has been written to: {file_dir}")