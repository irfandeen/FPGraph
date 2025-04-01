// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Mon Mar 31 21:57:11 2025
// Host        : zx_thinkpad running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/zexue/OneDrive/Desktop/EE2026/Project/FPGraph/FPGraph.srcs/sources_1/ip/coord_mem/coord_mem_stub.v
// Design      : coord_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module coord_mem(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[17:0],dina[0:0],clkb,enb,addrb[17:0],doutb[0:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [17:0]addra;
  input [0:0]dina;
  input clkb;
  input enb;
  input [17:0]addrb;
  output [0:0]doutb;
endmodule
