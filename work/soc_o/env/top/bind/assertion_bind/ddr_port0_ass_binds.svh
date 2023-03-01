/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_port0_ass_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:03:04
 * Description: 
 * 
 */

`ifndef __DDR_PORT0_ASS_BINDS_SVH__
`define __DDR_PORT0_ASS_BINDS_SVH__

    assign u_port0_ass_inst.awvalid    = `DDR_TOP.i_awvalid ;
    assign u_port0_ass_inst.awaddr     = `DDR_TOP.i_awaddr  ;
    assign u_port0_ass_inst.awlen      = `DDR_TOP.i_awlen   ;
    assign u_port0_ass_inst.awsize     = `DDR_TOP.i_awsize  ;
    assign u_port0_ass_inst.awburst    = `DDR_TOP.i_awburst ;
    assign u_port0_ass_inst.awlock     = `DDR_TOP.i_awlock  ;
    assign u_port0_ass_inst.awcache    = `DDR_TOP.i_awcache ;
    assign u_port0_ass_inst.awprot     = `DDR_TOP.i_awprot  ;
    assign u_port0_ass_inst.awid       = `DDR_TOP.i_awid    ;
    assign u_port0_ass_inst.awready    = `DDR_TOP.o_awready ;
                                                  
    assign u_port0_ass_inst.wvalid     = `DDR_TOP.i_wvalid  ;
    assign u_port0_ass_inst.wdata      = `DDR_TOP.i_wdata   ;
    assign u_port0_ass_inst.wstrb      = `DDR_TOP.i_wstrb   ;
    assign u_port0_ass_inst.wid        = `DDR_TOP.i_wid     ;
    assign u_port0_ass_inst.wready     = `DDR_TOP.o_wready  ;
    assign u_port0_ass_inst.wlast      = `DDR_TOP.i_wlast   ;
                                                 
    assign u_port0_ass_inst.bvalid     = `DDR_TOP.o_bvalid  ;
    assign u_port0_ass_inst.bresp      = `DDR_TOP.o_bresp   ;
    assign u_port0_ass_inst.bid        = `DDR_TOP.o_bid     ;
    assign u_port0_ass_inst.bready     = `DDR_TOP.i_bready  ;
                                                
    assign u_port0_ass_inst.arvalid    = `DDR_TOP.i_arvalid ;
    assign u_port0_ass_inst.araddr     = `DDR_TOP.i_araddr  ;
    assign u_port0_ass_inst.arlen      = `DDR_TOP.i_arlen   ;
    assign u_port0_ass_inst.arsize     = `DDR_TOP.i_arsize  ;
    assign u_port0_ass_inst.arburst    = `DDR_TOP.i_arburst ;
    assign u_port0_ass_inst.arlock     = `DDR_TOP.i_arlock  ;
    assign u_port0_ass_inst.arcache    = `DDR_TOP.i_arcache ;
    assign u_port0_ass_inst.arprot     = `DDR_TOP.i_arprot  ;
    assign u_port0_ass_inst.arid       = `DDR_TOP.i_arid    ;
    assign u_port0_ass_inst.arready    = `DDR_TOP.o_arready ;
                                               
    assign u_port0_ass_inst.rvalid     = `DDR_TOP.o_rvalid  ;
    assign u_port0_ass_inst.rdata      = `DDR_TOP.o_rdata   ;
    assign u_port0_ass_inst.rid        = `DDR_TOP.o_rid     ;
    assign u_port0_ass_inst.rready     = `DDR_TOP.i_rready  ;
    assign u_port0_ass_inst.rlast      = `DDR_TOP.o_rlast   ;

    assign u_port0_ass_inst.aclk = `DDR_TOP.aclk_0 ;
    assign u_port0_ass_inst.areset_n = `DDR_TOP.i_reg_ddr_axi0_usw_rst_n ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
