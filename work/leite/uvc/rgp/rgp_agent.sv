/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_agent.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 10:30:19
 * Description: 
 * 
 */

`ifndef __RGP_AGENT_SV__
`define __RGP_AGENT_SV__


typedef class rgp_agent ;

class rgp_agent extends uvm_agent ;
    // data or class properties
    rgp_sequencer sqr ;
    rgp_master    drv ;
    rgp_monitor   mon ;

    virtual rgp_if vif ;

    `uvm_component_utils_begin(rgp_agent)
        `uvm_field_object(sqr, UVM_ALL_ON)
        `uvm_field_object(drv, UVM_ALL_ON)
        `uvm_field_object(mon, UVM_ALL_ON)
    `uvm_component_utils_end

    // initialization
    function new(string name, uvm_component parent = null);
        super.new(name, parent) ;
    endfunction : new

    virtual function void build_phase(uvm_phase phase) ;
        sqr = rgp_sequencer::type_id::create("sqr", this) ;
        drv = rgp_master::type_id::create("drv", this) ;
        mon = rgp_monitor::type_id::create("mon", this) ;

        if( !uvm_config_db#(virtual rgp_if)::get(null,"*","rgp_if_inst",vif) ) begin
            `uvm_fatal("RGP/AGT/NOVIF","failed to get vif")
        end
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase) ;
        drv.seq_item_port.connect(sqr.seq_item_export) ;
    endfunction : connect_phase

endclass : rgp_agent

`endif

// vim: et:ts=4:sw=4:ft=sverilog
