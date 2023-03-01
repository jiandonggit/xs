/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_svt_ahb_system_configuration.sv
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 13:53:58
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_SVT_AHB_SYSTEM_CONFIGURATION_SV__
`define __FLASHCTRL_SVT_AHB_SYSTEM_CONFIGURATION_SV__

class flashctrl_svt_ahb_system_configuration extends svt_ahb_system_configuration ;
    // data or class properties
    `uvm_object_utils(flashctrl_svt_ahb_system_configuration)

    int range_base[] = { `FLASH_BASE, `FLASH_INFO_BASE, `FLASH_CTRL_BASE } ;
    int range_size[] = { `FLASH_SIZE, `FLASH_INFO_SIZE, `FLASH_CTRL_SIZE } ;

    // initialization
    function new(string name = "flashctrl_svt_ahb_system_configuration");
        super.new(name) ;

        this.num_masters = 2 ;
        this.num_slaves = 3 ;
        this.system_monitor_enable = 0 ;
        this.system_coverage_enable = 0 ;

        this.create_sub_cfgs(num_master,num_slaves) ;

        for (int i = 0; i < num_masters; i ++) begin
            this.master_cfg[i].transaction_coverage_enable = 0 ;
            this.master_cfg[i].is_active = 1 ;
            this.master_cfg[i].data_width = 32 ;
            this.master_cfg[i].addr_width = 32 ;
            this.master_cfg[i].enable_xml_gen = 1 ;
            this.master_cfg[i].pa_format_type = svt_xml_write::FSDB ;
        end

        for (int i = 0; i < num_slaves; i ++) begin
            this.slave_cfg[i].transaction_coverage_enable = 0 ;
            this.slave_cfg[i].is_active = 0 ;
            this.slave_cfg[i].protocol_checks_enable = 1 ;
            this.slave_cfg[i].data_width = 32 ;
            this.slave_cfg[i].addr_width = 32 ;
            this.slave_cfg[i].enable_xml_gen = 0 ;
            this.slave_cfg[i].pa_format_type = svt_xml_write::FSDB ;
            this.set_addr_range(i, range_base[i], range_base[i]+range_size[i]-1) ;
        end

        this.ahb_lite = 1 ;
        this.ahb_lite_multilayer = 1 ;

    endfunction : new

endclass : flashctrl_svt_ahb_system_configuration


`endif

// vim: et:ts=4:sw=4:ft=sverilog
