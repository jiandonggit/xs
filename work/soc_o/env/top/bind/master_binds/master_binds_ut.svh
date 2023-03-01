/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : master_binds_ut.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:09:34
 * Description: 
 * 
 */

`ifndef __MASTER_BINDS_UT_SVH__
`define __MASTER_BINDS_UT_SVH__

`ifndef DISABLE_DDR_PORT0_BIND
    `include "ddr_port0_binds.svh"
`endif
`ifndef DISABLE_DDR_PORT1_BIND
    `include "ddr_port1_binds.svh"
`endif
`ifndef DISABLE_DDR_PORT2_BIND
    `include "ddr_port2_binds.svh"
`endif
`ifndef DISABLE_DDR_PORT3_BIND
    `include "ddr_port3_binds.svh"
`endif
`ifndef DISABLE_DDR_PORT4_BIND
    `include "ddr_port4_binds.svh"
`endif
`ifndef DISABLE_DDR_PORT5_BIND
    `include "ddr_port5_binds.svh"
`endif

`endif

// vim: et:ts=4:sw=4:ft=sverilog
