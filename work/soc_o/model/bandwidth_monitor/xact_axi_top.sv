/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_axi_top.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 20:01:12
 * Description: 
 * 
 */

`ifndef __XACT_AXI_TOP_SV__
`define __XACT_AXI_TOP_SV__


module xact_axi_top ();
    xact_time_intf u_time() ;
    `include "master0_bind.v"
    `include "master1_bind.v"
    `include "master2_bind.v"
    `include "master3_bind.v"
    `include "master4_bind.v"

endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
