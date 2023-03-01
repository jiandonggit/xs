/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_pkg.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 11:18:11
 * Description: 
 * 
 */

`ifndef __RGP_PKG_SV__
`define __RGP_PKG_SV__

package rgp_pkg;
    import uvm_pkg::*;
    `include "rgp_rw.sv"
    `include "rgp_master.sv"
    `include "rgp_monitor.sv"
    `include "rgp_sequencer.sv"
    `include "rgp_agent.sv"
endpackage : rgp_pkg


`endif

// vim: et:ts=4:sw=4:ft=sverilog
