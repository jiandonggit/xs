/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_env_pkg.sv
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 14:31:50
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_ENV_PKG_SV__
`define __FLASHCTRL_ENV_PKG_SV__

package flashctrl_env_pkg;
    `include "uvm_macros.svh"
    immport uvm_pkg::* ;
    
    import svt_uvm_pkg::* ;
    import svt_ahb_uvm_pkg::* ;
    import svt_amba_common_uvm_pkg::* ;
    import flashctrl_register_pkg::* ;
    import custom_uvm_reg_pkg::* ;

    `include "flashctrl_item.sv"
    `include "flashctrl_svt_ahb_system_configuration.sv"
    `include "flashctrl_flash_mirror.sv"
    `include "flashctrl_env_config"
    `include "flashctrl_virtual_sequencer.svh"
    `include "flashctrl_env.svh"
endpackage


`endif

// vim: et:ts=4:sw=4:ft=sverilog
