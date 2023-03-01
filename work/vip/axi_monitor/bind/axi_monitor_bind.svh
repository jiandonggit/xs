/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor_bind.svh
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 16:32:57
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_BIND_SVH__
`define __AXI_MONITOR_BIND_SVH__

wire bus_mon_ref_clk ;
wire bus_mon_ref_clk_rst_n ;

clockgen #(1000) gen_hvl_clk(bus_mon_ref_clk,bus_mon_ref_clk_rst_n) ;

axi_monitor_top u_axi_monitor_top() ;

assign u_axi_monitor_top.ref_clk = bus_mon_ref_clk ;
assign u_axi_monitor_top.rst_n = bus_mon_ref_clk_rst_n ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
