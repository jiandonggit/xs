/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : arch_proj_tb.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 16:08:23
 * Description: 
 * 
 */

`ifndef __ARCH_PROJ_TB_V__
`define __ARCH_PROJ_TB_V__

module arch_proj_tb ();
    axi_master_test #(.T(axi_bus0_master_m0_gen), .B_ID(0), .M_ID(0)) bus0_master_m0_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.bus0_master_m0_if, `ARCH_XACT_TOP.u_mem_intf) ;
    axi_master_test #(.T(axi_bus0_master_m0_gen), .B_ID(0), .M_ID(1)) bus0_master_m1_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.bus0_master_m0_if, `ARCH_XACT_TOP.u_mem_intf) ;
    axi_master_test #(.T(axi_bus0_master_m0_gen), .B_ID(0), .M_ID(2)) bus0_master_m2_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.bus0_master_m0_if, `ARCH_XACT_TOP.u_mem_intf) ;
    axi_master_test #(.T(axi_bus0_master_m0_gen), .B_ID(0), .M_ID(3)) bus0_master_m3_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.bus0_master_m0_if, `ARCH_XACT_TOP.u_mem_intf) ;
    axi_master_test #(.T(axi_bus0_master_m0_gen), .B_ID(0), .M_ID(4)) bus0_master_m4_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.bus0_master_m0_if, `ARCH_XACT_TOP.u_mem_intf) ;
    
    ahb_master_test #(.T(ahb_bus0_master_m1_gen)) ahb_bus0_master_m1_test(`ARCH_XACT_TOP.u_ctrl_intf, `ARCH_XACT_TOP.ahb_bus0_master_m1_intf, `ARCH_XACT_TOP.u_mem_intf) ;
    
endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
