1. 仿真相关的RTL文件请见filelist.f，最核心的是conv_im2col.sv
2. top_tb.sv是顶层testbench
3. 硬件配置相关的参数请见params.svh
4. 请仔细查看每个py脚本的headline注释
5. 只建议修改bank数量和三个时钟频率这几个参数，其他的不建议修改
6. 修改bank数量的步骤：首先在gen_config.py文件中修改CBN为指定的bank数量，然后运行python gen_config.py，然后在params.svh文件中修改CBN，注意CBD也要跟着修改。
7. 修改三个时钟频率的方法，在top_tb.sv文件中修改CLK$_PERIOD，$=1,2,3, clk1是buffer的写时钟，clk2是buffer的读时钟，clk3是xbar中的时钟，一般来说clk1频率高的时候写得快，buffer容易满，从而给上级形成反压，clk2频率高的时候读得快，运行稳定时buffer中数据的数量基本等于buffer的容量下界（buffer容量小于这个值就会死锁），clk3其实影响不大，频率给多少都行
8. conv_im2col.sv中地址的生成用了很多行为级的计算，xbar每一个row的配置信息是直接用parameter传过去的（1152长度的配置向量），而且没有考虑buffer访问和crossbar的打拍等，不适合综合
9. 目前bank数量2,4,6,8,16,32在不同的buffer读写速度比例下均完成了测试