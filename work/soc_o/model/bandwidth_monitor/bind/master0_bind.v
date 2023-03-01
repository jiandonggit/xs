/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : master0_bind.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 20:04:11
 * Description: 
 * 
 */

`ifndef __MASTER0_BIND_V__
`define __MASTER0_BIND_V__

`define MASTER0 `DDR_TOP
`define MASTER0_NAME "DDR_PORT0"
axi_intf master0_axi_intf(`MASTER0.aclk_0)

assign master0_axi_intf.awvalid = `MASTER0.i_awvalid_0 ;
// ...

xact_axi_intf master0_xact_intf(master0_axi_intf, u_time) ;
assign master0_xact_intf.type_id = `MASTER0_NAME ;
xact_axi_test master0_test(master0_xact_intf) ;

`endif

// vim: et:ts=4:sw=4:ft=sverilog
