import os
from typing import Tuple, List, Optional
from maptools.core import PhysicalTile

__all__ = ['gen_cast_network']

def gen_ports(w, h):
    port_str = '''
//Cast Network
//Width: '''+str(w)+'''
//Height:'''+str(h)+'''\n
`include "params.svh"
`include "cast_network_config.svh"

module cast_network(
    input       wire                            clk,
    input       wire                            rstn,

    input       wire        [`VN-1:0]           vc_i [`NW] [`NH],
    input       wire        [`DW-1:0]           data_i [`NW] [`NH],
    input       wire                            valid_i [`NW] [`NH],
    output      reg                             ready_o [`NW] [`NH],

    output      reg         [`VN-1:0]           vc_o [`NW] [`NH],
    output      reg         [`DW-1:0]           data_o [`NW] [`NH],
    output      reg                             valid_o [`NW] [`NH],
    input       wire                            ready_i [`NW] [`NH]
);
'''
    return port_str

def gen_instances(data_width, w, h):
    data_width = str(data_width)
    inst_str = ""
    for j in range(w): 
        for i in range(h): 
            id = w*i+j
            sigs = ''

            '''
            generate north port signals
            '''
            if i == 0: #north boundary
                north_vc_in = ''
                north_data_in = ''
                north_valid_in = ''
                north_ready_in = ''
            else:
                north_vc_in = '    vc_i_'+str(j)+'_'+str(i)+'[3] = vc_o_'+str(j)+'_'+str(i-1)+'[4];\n'
                north_data_in = '    data_i_'+str(j)+'_'+str(i)+'[3] = data_o_'+str(j)+'_'+str(i-1)+'[4];\n'
                north_valid_in = '    valid_i_'+str(j)+'_'+str(i)+'[3] = valid_o_'+str(j)+'_'+str(i-1)+'[4];\n'
                north_ready_in = '    ready_i_'+str(j)+'_'+str(i)+'[3] = ready_o_'+str(j)+'_'+str(i-1)+'[4];\n'
            
            sigs += north_vc_in + north_data_in + north_valid_in + north_ready_in 

            '''
            generate south port signals
            '''
            if i == h-1: #south boundary
                south_vc_in = ''
                south_data_in = ''
                south_valid_in = ''
                south_ready_in = ''
            else:
                south_vc_in = '    vc_i_'+str(j)+'_'+str(i)+'[4] = vc_o_'+str(j)+'_'+str(i+1)+'[3];\n'
                south_data_in = '    data_i_'+str(j)+'_'+str(i)+'[4] = data_o_'+str(j)+'_'+str(i+1)+'[3];\n'
                south_valid_in = '    valid_i_'+str(j)+'_'+str(i)+'[4] = valid_o_'+str(j)+'_'+str(i+1)+'[3];\n'
                south_ready_in = '    ready_i_'+str(j)+'_'+str(i)+'[4] = ready_o_'+str(j)+'_'+str(i+1)+'[3];\n'
            
            sigs += south_vc_in + south_data_in + south_valid_in + south_ready_in

            '''
            generate west port signals
            '''
            if j == 0: #west boundary
                west_vc_in = ''
                west_data_in = ''
                west_valid_in = ''
                west_ready_in = ''
            else:
                west_vc_in = '    vc_i_'+str(j)+'_'+str(i)+'[1] = vc_o_'+str(j-1)+'_'+str(i)+'[2];\n'
                west_data_in = '    data_i_'+str(j)+'_'+str(i)+'[1] = data_o_'+str(j-1)+'_'+str(i)+'[2];\n'
                west_valid_in = '    valid_i_'+str(j)+'_'+str(i)+'[1] = valid_o_'+str(j-1)+'_'+str(i)+'[2];\n'
                west_ready_in = '    ready_i_'+str(j)+'_'+str(i)+'[1] = ready_o_'+str(j-1)+'_'+str(i)+'[2];\n'
            
            sigs += west_vc_in + west_data_in + west_valid_in + west_ready_in

            '''
            generate east port signals
            '''
            if j == w-1: #east boundary
                east_vc_in = ''
                east_data_in = ''
                east_valid_in = ''
                east_ready_in = ''
            else:
                east_vc_in = '    vc_i_'+str(j)+'_'+str(i)+'[2] = vc_o_'+str(j+1)+'_'+str(i)+'[1];\n'
                east_data_in = '    data_i_'+str(j)+'_'+str(i)+'[2] = data_o_'+str(j+1)+'_'+str(i)+'[1];\n'
                east_valid_in = '    valid_i_'+str(j)+'_'+str(i)+'[2] = valid_o_'+str(j+1)+'_'+str(i)+'[1];\n'
                east_ready_in = '    ready_i_'+str(j)+'_'+str(i)+'[2] = ready_o_'+str(j+1)+'_'+str(i)+'[1];\n'
            
            sigs += east_vc_in + east_data_in + east_valid_in + east_ready_in

            '''
            generate local port signals
            '''
            local_vc_in = '    vc_i_'+str(j)+'_'+str(i)+'[0] = vc_i['+str(j)+']['+str(i)+'];\n'
            local_data_in = '    data_i_'+str(j)+'_'+str(i)+'[0] = data_i['+str(j)+']['+str(i)+'];\n'
            local_valid_in = '    valid_i_'+str(j)+'_'+str(i)+'[0] = valid_i['+str(j)+']['+str(i)+'];\n'
            local_ready_in = '    ready_i_'+str(j)+'_'+str(i)+'[0] = ready_i['+str(j)+']['+str(i)+'];\n'
            sigs += local_vc_in + local_data_in + local_valid_in + local_ready_in

            router_txt = '''
/*Router '''+str(j)+''','''+str(i)+'''*/    
cast_router #(
    .routing_table                  (routing_table_'''+str(j)+'''_'''+str(i)+f''')
)router_{j}_{i}(
    .clk                            (clk),
    .rstn                           (rstn),
    .vc_i                           (vc_i_'''+str(j)+'''_'''+str(i)+'''),
    .data_i                         (data_i_'''+str(j)+'''_'''+str(i)+'''),
    .valid_i                        (valid_i_'''+str(j)+'''_'''+str(i)+'''),
    .ready_o                        (ready_o_'''+str(j)+'''_'''+str(i)+'''),
    .vc_o                           (vc_o_'''+str(j)+'''_'''+str(i)+'''),
    .data_o                         (data_o_'''+str(j)+'''_'''+str(i)+'''),
    .valid_o                        (valid_o_'''+str(j)+'''_'''+str(i)+'''),
    .ready_i                        (ready_i_'''+str(j)+'''_'''+str(i)+''')
);\n'''     
            router_txt += '''
\nalways_comb begin
'''+sigs+'''end\n\n'''
            inst_str += router_txt
    return inst_str

def gen_wires(w,h):
    wires_str = ''
    for j in range(w):
        for i in range(h):
            wires_str += '''
logic [`VN-1:0] vc_i_'''+str(j)+'''_'''+str(i)+'''[5];
logic [`DW-1:0] data_i_'''+str(j)+'''_'''+str(i)+'''[5];
logic valid_i_'''+str(j)+'''_'''+str(i)+'''[5], ready_i_'''+str(j)+'''_'''+str(i)+'''[5];    
logic [`VN-1:0] vc_o_'''+str(j)+'''_'''+str(i)+'''[5];
logic [`DW-1:0] data_o_'''+str(j)+'''_'''+str(i)+'''[5];
logic valid_o_'''+str(j)+'''_'''+str(i)+'''[5], ready_o_'''+str(j)+'''_'''+str(i)+'''[5];        
'''
    return wires_str

def gen_outputs(w, h):
    out_str = "\nalways_comb begin\n"
    for i in range(w):
        for j in range(h):
            out_str += "    vc_o["+str(i)+"]["+str(j)+"] = vc_o_"+str(i)+"_"+str(j)+"[0];\n"
            out_str += "    data_o["+str(i)+"]["+str(j)+"] = data_o_"+str(i)+"_"+str(j)+"[0];\n"
            out_str += "    valid_o["+str(i)+"]["+str(j)+"] = valid_o_"+str(i)+"_"+str(j)+"[0];\n"
            out_str += "    ready_o["+str(i)+"]["+str(j)+"] = ready_o_"+str(i)+"_"+str(j)+"[0];\n"

    out_str += "end\n"
    return out_str

def gen_cast_network(root_dir, data_width, w, h):
    save_dir = os.path.join(root_dir, 'rtl', 'generated')
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    file_dir = os.path.join(save_dir, 'cast_network.sv')
    containt = ""
    containt += gen_ports(w, h)
    containt += gen_wires(w, h)
    containt += gen_outputs(w, h)
    containt += gen_instances(data_width, w, h)
    containt += "\nendmodule"

    with open(file_dir,"w") as my_file:
        my_file.write("{0}\n".format(containt))
        my_file.flush()
        my_file.close()

    print(f"cast network has been written to: {file_dir}")