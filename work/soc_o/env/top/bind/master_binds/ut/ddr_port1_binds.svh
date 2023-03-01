/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_port1_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:11:21
 * Description: 
 * 
 */

`ifndef __DDR_PORT1_BINDS_SVH__
`define __DDR_PORT1_BINDS_SVH__

    assign `DDR_TOP.i_awvalid_1 = bus0_master_m1_awvalid    ;
    assign `DDR_TOP.i_awaddr_1  = bus0_master_m1_awaddr     ;
    assign `DDR_TOP.i_awlen_1   = bus0_master_m1_awlen      ;
    assign `DDR_TOP.i_awsize_1  = bus0_master_m1_awsize     ;
    assign `DDR_TOP.i_awburst_1 = bus0_master_m1_awburst    ;
    assign `DDR_TOP.i_awlock_1  = bus0_master_m1_awlock     ;
    assign `DDR_TOP.i_awcache_1 = bus0_master_m1_awcache    ;
    assign `DDR_TOP.i_awprot_1  = bus0_master_m1_awprot     ;
    assign `DDR_TOP.i_awid_1    = bus0_master_m1_awid       ;

    assign `DDR_TOP.i_wvalid_1  = bus0_master_m1_wvalid     ;
    assign `DDR_TOP.i_wdata_1   = bus0_master_m1_wdata      ;
    assign `DDR_TOP.i_wstrb_1   = bus0_master_m1_wstrb      ;
    assign `DDR_TOP.i_wid_1     = bus0_master_m1_wid        ;
    assign `DDR_TOP.i_wlast_1   = bus0_master_m1_wlast      ;

    assign `DDR_TOP.i_bready_1  = bus0_master_m1_bready     ;

    assign `DDR_TOP.i_arvalid_1 = bus0_master_m1_arvalid    ;
    assign `DDR_TOP.i_araddr_1  = bus0_master_m1_araddr     ;
    assign `DDR_TOP.i_arlen_1   = bus0_master_m1_arlen      ;
    assign `DDR_TOP.i_arsize_1  = bus0_master_m1_arsize     ;
    assign `DDR_TOP.i_arburst_1 = bus0_master_m1_arburst    ;
    assign `DDR_TOP.i_arlock_1  = bus0_master_m1_arlock     ;
    assign `DDR_TOP.i_arcache_1 = bus0_master_m1_arcache    ;
    assign `DDR_TOP.i_arprot_1  = bus0_master_m1_arprot     ;
    assign `DDR_TOP.i_arid_1    = bus0_master_m1_arid       ;
    assign `DDR_TOP.i_rready_1  = bus0_master_m1_rready     ;

    assign bus0_master_m1_awready  = `DDR_TOP.o_awready_1 ;
    assign bus0_master_m1_wready   = `DDR_TOP.o_wready_1  ;
    assign bus0_master_m1_bvalid   = `DDR_TOP.o_bvalid_1  ;
    assign bus0_master_m1_bresp    = `DDR_TOP.o_bresp_1   ;
    assign bus0_master_m1_bid      = `DDR_TOP.o_bid_1     ;
    assign bus0_master_m1_arready  = `DDR_TOP.o_arready_1 ;
    assign bus0_master_m1_rvalid   = `DDR_TOP.o_rvalid_1  ;
    assign bus0_master_m1_rdata    = `DDR_TOP.o_rdata_1   ;
    assign bus0_master_m1_rid      = `DDR_TOP.o_rid_1     ;
    assign bus0_master_m1_rlast    = `DDR_TOP.o_rlast_1   ;

    assign bus0_master_m1_clk   = `DDR_TOP.aclk_1 ;
    assign bus0_master_m1_rst_n = `DDR_TOP.i_reg_ddr_axi0_usw_rst_n ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
