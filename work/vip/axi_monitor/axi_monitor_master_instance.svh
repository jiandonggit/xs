/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor_master_instance.svh
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 16:54:37
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_MASTER_INSTANCE_SVH__
`define __AXI_MONITOR_MASTER_INSTANCE_SVH__


reg sram_addr_range_check_en ;
reg [31:0] sram_addr_range_min ;
reg [31:0] sram_addr_range_max ;

reg reg_dat_traffic_statistic_en ;
reg reg_dat_traffic_statistic_clr ;

wire m1_dat_traffic_statistic_en ;
wire m1_dat_traffic_statistic_clr ;

initial begin
    reg_dat_traffic_statistic_en = 1'b0 ;
    reg_dat_traffic_statistic_clr = 1'b0 ;
    forever begin
        repeat(100) @(posedge sample_sync_ns_1000ns) ;
        reg_dat_traffic_statistic_en = ~reg_dat_traffic_statistic_en ;
    end
end

assign m1_dat_traffic_statistic_en = m1.o_v_valid ;
assign m1_dat_traffic_statistic_clr = ~m1.o_v_valid ;

axi_monitor u_m1_mon(
    .aclk() ,
    .aresetn() ,
    // axi bus 
    // aw
    // w
    // b
    // ar
    // r
    .i_addr_range_check_en ,
    .i_addr_range_wr_min ,
    .i_addr_range_wr_max ,
    .i_addr_range_rd_min ,
    .i_addr_range_rd_max ,

    .i_dat_traffic_statistic_en (m1_dat_traffic_statistic_en),
    .i_dat_traffic_statistic_clr (m1_dat_traffic_statistic_clr),

    .i_sample_sync_ns_10ns_edge (sample_sync_ns_10ns_edge ),
    .i_sample_sync_ns_100ns_edge(sample_sync_ns_100ns_edge) ,
    .i_sample_sync_ns_500ns_edge(sample_sync_ns_500ns_edge) ,
    .i_sample_sync_ns_1000ns_edge(sample_sync_ns_1000ns_edge) ,
    .i_sample_sync_ns_100000ns_edge(sample_sync_ns_10000ns_edge)



`endif

// vim: et:ts=4:sw=4:ft=sverilog
