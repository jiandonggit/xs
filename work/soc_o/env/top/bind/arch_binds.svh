/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : arch_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 16:57:29
 * Description: 
 * 
 */

`ifndef __ARCH_BINDS_SVH__
`define __ARCH_BINDS_SVH__

ddr_intf u_mem_intf() ;

    assign u_mem_intf.clk       = `DDR_TOP.u0_ddr3.clk        ;
    assign u_mem_intf.rst_n     = `DDR_TOP.u0_ddr3.rst_n      ;
    assign u_mem_intf.cke       = `DDR_TOP.u0_ddr3.cke        ;
    assign u_mem_intf.cs_n      = `DDR_TOP.u0_ddr3.cs_n       ;
    assign u_mem_intf.ras_n     = `DDR_TOP.u0_ddr3.ras_n      ;
    assign u_mem_intf.cas_n     = `DDR_TOP.u0_ddr3.cas_n      ;
    assign u_mem_intf.we_n      = `DDR_TOP.u0_ddr3.we_n       ;
    assign u_mem_intf.bank      = `DDR_TOP.u0_ddr3.bank       ;
    assign u_mem_intf.ddr_addr  = `DDR_TOP.u0_ddr3.ddr_addr   ;
    assign u_mem_intf.ddr_dq    = `DDR_TOP.u0_ddr3.ddr_dq     ;
    assign u_mem_intf.ddr_dqs   = `DDR_TOP.u0_ddr3.ddr_dqs    ;
    assign u_mem_intf.ddr_dqsb  = `DDR_TOP.u0_ddr3.ddr_dqsb   ;
    assign u_mem_intf.ddr_dm    = `DDR_TOP.u0_ddr3.ddr_dm     ;
    assign u_mem_intf.mon_start = u_ctrl_intf.init_done ;

    `include "master_binds.svh"
    `include "ddr_port_ass_binds.svh"


`endif

// vim: et:ts=4:sw=4:ft=sverilog
