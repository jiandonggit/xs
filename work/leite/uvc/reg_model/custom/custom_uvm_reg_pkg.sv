/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : custom_uvm_reg_pkg.sv
 * Author : dongj
 * Create : 2023-01-06
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/06 17:09:20
 * Description: 
 * 
 */

`ifndef __CUSTOM_UVM_REG_PKG_SV__
`define __CUSTOM_UVM_REG_PKG_SV__

package custom_uvm_reg_pkg ;
    import uvm_pkg::* ;
    `include "custom_uvm_reg_by_name.sv"
    `include "custom_uvm_reg_cbs.sv"
endpackage

`endif

// vim: et:ts=4:sw=4:ft=sverilog
