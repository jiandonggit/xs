/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_instance.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 10:44:45
 * Description: 
 * 
 */

`ifndef __XACT_INSTANCE_V__
`define __XACT_INSTANCE_V__

ctrl_intf u_ctrl_intf(`TOP.osc_clk, `TOP.sys_rstn) ;

`ifndef RUN_UT
    `include "xact_instance_st.v"
`else
    `include "xact_instance_ut.v"
`endif

`endif

// vim: et:ts=4:sw=4:ft=sverilog
