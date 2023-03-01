/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_env.svh
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 14:39:24
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_ENV_SVH__
`define __FLASHCTRL_ENV_SVH__


class flashctrl_env extends uvm_env ;
    `uvm_component_utils(flashctrl_env)

    flashctrl_env_config m_cfg ;
    svt_ahb_system_env m_ahb_system_env ;
    flashctrl_scoreboard m_scoreboard ;
    flashctrl_virtual_sequencer m_vsqr ;

    custom_uvm_reg_cbs flash_reg_cb_cr ;
    custom_uvm_reg_cbs flash_reg_cb_key ;
    custom_uvm_reg_cbs flash_reg_cb_superkey ;
    custom_uvm_reg_cbs flash_reg_cb_dpdkey ;
    custom_uvm_reg_cbs flash_reg_cb_optkey ;

    rgp_agent rgp_agt ;
    reg2rgp_adapter reg2rgp ;
    

    extern function new (string name = "flashctrl_env",uvm_component parent = null) ;
    extern virtual function void build_phase(uvm_phase phase) ;
    extern virtual function void connect_phase(uvm_phase phase) ;
    extern task main_phase(uvm_phase phase) ;
endclass : flashctrl_env

function flashctrl_env::new(string name = "flashctrl_env", uvm_component parent = null) ;
    super.new(name,parent) ;
    uvm_default_printer.knobs.dec_radix = "" ;
endfunction : new

function void flashctrl_env::build_phase(uvm_phase phase) ;
    super.build_phase(phase) ;

    if( !uvm_config_db#(flashctrl_env_config)::get(null,"","flashctrl_env_config",m_cfg) ) begin
        `uvm_fatal(get_name,"failed to get m_cfg")
    end

    if (m_cfg.has_scoreboard) begin
        m_scoreboard = flashctrl_scoreboard::type_id::create("m_scoreboard",this) ;
    end

    if (m_cfg.has_virtual_sequencer) begin
        m_vsqr = flashctrl_virtual_sequencer::type_id::create("m_vsqr",this) ;
    end

    if (m_cfg.has_ahb_env) begin
        uvm_config_db#(svt_ahb_system_configuration)::set(this,"m_ahb_system_env","cfg", m_cfg.m_ahb_system_env_cfg) ;
        m_ahb_system_env = svt_ahb_system_env::type_id::create("m_ahb_system_env",this) ;
        m_ahb_system_env.set_report_verbosity_level_hier(UVM_NONE) ;
    end

    if( !uvm_config_db#(virtual rgp_if)::get(null,"","rgp_if_inst0",m_cfg.rgp_if) ) begin
        `uvm_fatal(get_name,"failed to get m_cfg.rgp_if")
    end
    rgp_agt = rgp_agent::type_id::create("flashctrl_rgp_agt",this) ;
    
endfunction : build_phase

function void flashctrl_env::connect_phase(uvm_phase phase) ;
    super.connect_phase(phase) ;

    if (m_cfg.has_scoreboard) begin
        m_scoreboard.m_cfg = m_cfg ;
    end

    `ifdef RUN_ST
    if (m_cfg.fc_rm.get_parent() = null) begin
        reg2rgp = new ;
        m_cfg.fc_rm.default_map.set_sequencer(rgp_agt.sequencer, reg2rgp) ;
        m_cfg.fc_rm.default_map.set_auto_predict(1) ;
    end
    `else
    if (m_cfg.has_virtual_sequencer && m_cfg.has_ahb_env) begin
        m_vsqr.ahb_master = m_ahb_system_env.master[0].sequencer ;
    end
    if (m_cfg.fc_rm.get_parent() = null) begin
        if (m_cfg.has_ahb_env) begin
            svt_ahb_reg_adapter reg2ahb_adapter = new ("reg2ahb_adapter") ;
            reg2ahb_adapter.p_cfg= m_cfg.m_ahb_system_env_cfg.master_cfg[1] ;
            m_cfg.fc_rm.default_map.set_sequencer(m_ahb_system_env.master[1].sequencer, reg2ahb_adapter) ;
            m_cfg.fc_rm.default_map.set_auto_predict(1) ;
        end
    end
    `endif

    flash_reg_cb_cr = custom_uvm_reg_cbs::type_id::create("flash_reg_cb_cr",this) ;
    flash_reg_cb_key = custom_uvm_reg_cbs::type_id::create("flash_reg_cb_key",this) ;
    flash_reg_cb_optkey = custom_uvm_reg_cbs::type_id::create("flash_reg_cb_optkey",this) ;
    flash_reg_cb_superkey = custom_uvm_reg_cbs::type_id::create("flash_reg_cb_superkey",this) ;

    uvm_reg_cb::add( m_cfg.fc_rm.flash_cr, flash_reg_cb_cr) ;
    uvm_reg_cb::add( m_cfg.fc_rm.flash_bypass, flash_reg_cb_key) ;
    uvm_reg_cb::add( m_cfg.fc_rm.flash_superkey, flash_reg_cb_superkey) ;
    uvm_reg_cb::add( m_cfg.fc_rm.flash_dpdkey, flash_reg_cb_dpdkey) ;

    if (m_cfg.has_ahb_env && m_cfg.has_scoreboard) begin
        m_ahb_system_env.slave[0].monitor.item_observed_port.connect(m_scoreboard.main_fifo.analysis_export) ;
        m_ahb_system_env.slave[1].monitor.item_observed_port.connect(m_scoreboard.info_fifo.analysis_export) ;
    end
endfunction : connect_phase

task flashctrl_env::main_phase(uvm_phase phase) ;
    super.main_phase(phase) ;
endtask : main_phase

`endif

// vim: et:ts=4:sw=4:ft=sverilog
