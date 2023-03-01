/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : master_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:08:42
 * Description: 
 * 
 */

`ifndef __MASTER_BINDS_SVH__
`define __MASTER_BINDS_SVH__

`ifndef RUN_UT
    `include "master_binds_st.svh"
`else
    `include "master_binds_ut.svh"
`endif


`endif

// vim: et:ts=4:sw=4:ft=sverilog
