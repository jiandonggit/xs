/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_env_config.sv
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 14:20:29
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_ENV_CONFIG_SV__
`define __FLASHCTRL_ENV_CONFIG_SV__

class flashctrl_env_config extends "flashctrl_env_config" ;
    // data or class properties
    localparam string s_my_config_id = "flashctrl_env_config" ;
    localparam string s_no_config_id = "no_config" ;
    localparam string s_my_config_type_error_id = "config type error" ;

    `uvm_object_utils(flashctrl_env_config)

    virtual clock_if AHB_CLK ;
    virtual reset_if RST ;
    virtual flashctrl_if fc_if ;
    virtual flash_if flash_if ;
    virtual rgp_if rgp_if ;

    flashctrl_flash_mirror flash_mirror ;
    bit has_ahb_env = 1 ;
    bit has_dpi = 0 ;
    bit has_scoreboard = 1 ;
    bit has_virtual_sequencer = 1 ;
    bit has_functional_cov = 0 ; 
    bit has_fc_agent = 0 ; 

    svt_ahb_system_configuration m_ahb_system_env_cfg ;

    flashctrl_reg_model fc_rm ;

    time timeout = 10us ;

    // initialization
    function new(string name = "flashctrl_env_config");
        super.new(name) ;
        flash_mirror = new ;
    endfunction : new

    function flashctrl_env_config get_config(uvm_component c) ;
        flashctrl_env_config t ;
        if (!uvm_config_db #(flashctrl_env_config)::get(c, "", s_my_config_id, t)) begin
            `uvm_fatal("CONFIG_LOAD",$sformatf("Cannot get() configuration \%s from uvm_config_db. Have you set() it?", s_my_config_id))
        end
        return t ;
    endfunction : get_config

endclass : flashctrl_env_config


`endif

// vim: et:ts=4:sw=4:ft=sverilog
