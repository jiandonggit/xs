/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_monitor.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 11:11:34
 * Description: 
 * 
 */

`ifndef __RGP_MONITOR_SV__
`define __RGP_MONITOR_SV__

typedef class rgp_monitor ;

class rgp_monitor_cbs extends uvm_callback ;
    // data or class properties
    virtual function void trans_observed(rgp_monitor xactor, rgp_rw cycle) ;
    endfunction : trans_observed
endclass : rgp_monitor_cbs

class rgp_monitor extends uvm_monitor ;
    // data or class properties
    virtual rgp_if sigs ;

    uvm_analysis_port#(rgp_rw)  ap ;

    `uvm_component_utils(rgp_monitor) 

    // initialization
    function new(string name, uvm_component parent = null);
        super.new(name, parent) ;
        ap = new("ap", this) ;
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        rgp_agent agent ;
        super.build_phase(phase) ;

        if($cast(agent, get_parent()) && agent != null) begin
            sigs = agent.vif ;
        end
        else begin
            virtual rgp_if tmp ;
            if( !uvm_config_db#(virtual rgp_if)::get(null,"*","vif",tmp) ) begin
                `uvm_fatal("RGP/MON/NOVIF","failed to get tmp")
            end
            sigs = tmp ;
        end
    endfunction: build_phase

    virtual protected task main_phase(uvm_phase phase) ;
        super.main_phase(phase) ;
    endtask : main_phase

    virtual protected task trans_observed(rgp_rw tr) ;
    endtask : trans_observed

endclass : rgp_monitor 



`endif

// vim: et:ts=4:sw=4:ft=sverilog
