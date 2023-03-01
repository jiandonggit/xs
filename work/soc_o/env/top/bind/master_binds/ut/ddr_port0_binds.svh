/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_port0_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:11:21
 * Description: 
 * 
 */

`ifndef __DDR_PORT0_BINDS_SVH__
`define __DDR_PORT0_BINDS_SVH__

    assign `DDR_TOP.i_awvalid_0 = bus0_master_m0_awvalid    ;
    assign `DDR_TOP.i_awaddr_0  = bus0_master_m0_awaddr     ;
    assign `DDR_TOP.i_awlen_0   = bus0_master_m0_awlen      ;
    assign `DDR_TOP.i_awsize_0  = bus0_master_m0_awsize     ;
    assign `DDR_TOP.i_awburst_0 = bus0_master_m0_awburst    ;
    assign `DDR_TOP.i_awlock_0  = bus0_master_m0_awlock     ;
    assign `DDR_TOP.i_awcache_0 = bus0_master_m0_awcache    ;
    assign `DDR_TOP.i_awprot_0  = bus0_master_m0_awprot     ;
    assign `DDR_TOP.i_awid_0    = bus0_master_m0_awid       ;

    assign `DDR_TOP.i_wvalid_0  = bus0_master_m0_wvalid     ;
    assign `DDR_TOP.i_wdata_0   = bus0_master_m0_wdata      ;
    assign `DDR_TOP.i_wstrb_0   = bus0_master_m0_wstrb      ;
    assign `DDR_TOP.i_wid_0     = bus0_master_m0_wid        ;
    assign `DDR_TOP.i_wlast_0   = bus0_master_m0_wlast      ;

    assign `DDR_TOP.i_bready_0  = bus0_master_m0_bready     ;

    assign `DDR_TOP.i_arvalid_0 = bus0_master_m0_arvalid    ;
    assign `DDR_TOP.i_araddr_0  = bus0_master_m0_araddr     ;
    assign `DDR_TOP.i_arlen_0   = bus0_master_m0_arlen      ;
    assign `DDR_TOP.i_arsize_0  = bus0_master_m0_arsize     ;
    assign `DDR_TOP.i_arburst_0 = bus0_master_m0_arburst    ;
    assign `DDR_TOP.i_arlock_0  = bus0_master_m0_arlock     ;
    assign `DDR_TOP.i_arcache_0 = bus0_master_m0_arcache    ;
    assign `DDR_TOP.i_arprot_0  = bus0_master_m0_arprot     ;
    assign `DDR_TOP.i_arid_0    = bus0_master_m0_arid       ;
    assign `DDR_TOP.i_rready_0  = bus0_master_m0_rready     ;

    assign bus0_master_m0_awready  = `DDR_TOP.o_awready_0 ;
    assign bus0_master_m0_wready   = `DDR_TOP.o_wready_0  ;
    assign bus0_master_m0_bvalid   = `DDR_TOP.o_bvalid_0  ;
    assign bus0_master_m0_bresp    = `DDR_TOP.o_bresp_0   ;
    assign bus0_master_m0_bid      = `DDR_TOP.o_bid_0     ;
    assign bus0_master_m0_arready  = `DDR_TOP.o_arready_0 ;
    assign bus0_master_m0_rvalid   = `DDR_TOP.o_rvalid_0  ;
    assign bus0_master_m0_rdata    = `DDR_TOP.o_rdata_0   ;
    assign bus0_master_m0_rid      = `DDR_TOP.o_rid_0     ;
    assign bus0_master_m0_rlast    = `DDR_TOP.o_rlast_0   ;

    assign bus0_master_m0_clk   = `DDR_TOP.aclk_0 ;
    assign bus0_master_m0_rst_n = `DDR_TOP.i_reg_ddr_axi0_usw_rst_n ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
