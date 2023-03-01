/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_bind.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:57:16
 * Description: 
 * 
 */

`ifndef __DDR_BIND_V__
`define __DDR_BIND_V__

`ifdef DDR3
    `include "ddr3_binds.sv"
`endif

`ifdef XS_VIP_SDRAM
    `include "ddr_vip_bind.sv"
`endif

`endif

// vim: et:ts=4:sw=4:ft=sverilog
