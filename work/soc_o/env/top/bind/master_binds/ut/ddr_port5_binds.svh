/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_port5_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:19:08
 * Description: 
 * 
 */

`ifndef __DDR_PORT5_BINDS_SVH__
`define __DDR_PORT5_BINDS_SVH__

    assign `DDR_TOP.i_hsel_5 = 1 ;
    assign `DDR_TOP.i_hmaster_5 = 1 ;
    assign `DDR_TOP.i_hmastlock_5 = 0 ;
    assign `DDR_TOP.i_hincr_arlen_5 = 0 ;
    assign `DDR_TOP.i_hqos_5 = 0 ;

    assign `DDR_TOP.i_haddr_5  = ahb_bus0_master_m1_haddr ;
    assign `DDR_TOP.i_hwrite_5 = ahb_bus0_master_m1_hwrite ;
    assign `DDR_TOP.i_hburst_5 = ahb_bus0_master_m1_hburst ;
    assign `DDR_TOP.i_htrans_5 = ahb_bus0_master_m1_htrans ;
    assign `DDR_TOP.i_hsize_5  = ahb_bus0_master_m1_hsize ;
    assign `DDR_TOP.i_hprot_5  = ahb_bus0_master_m1_hprot ;
    assign `DDR_TOP.i_hwdata_5 = ahb_bus0_master_m1_hwdata ;
    assign `DDR_TOP.i_hready_5 = ahb_bus0_master_m1_hready ;

    assign ahb_bus0_master_m1_hgrant = 1 ; 
    assign ahb_bus0_master_m1_hrdata = `DDR_TOP.i_hrdata_5 ;
    assign ahb_bus0_master_m1_hresp  = `DDR_TOP.i_hresp_5  ;
    assign ahb_bus0_master_m1_hlock  = `DDR_TOP.i_hlock_5  ;

    assign ahb_bus0_master_m1_clk   = `DDR_TOP.hclk_5 ;
    assign ahb_bus0_master_m1_rst_n = `DDR_TOP.hresetn_5 ;



`endif

// vim: et:ts=4:sw=4:ft=sverilog
