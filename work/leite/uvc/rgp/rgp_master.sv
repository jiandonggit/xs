/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_master.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 10:41:07
 * Description: 
 * 
 */

`ifndef __RGP_MASTER_SV__
`define __RGP_MASTER_SV__

typedef class rgp_master ;

class rgp_master_cbs extends uvm_callback ;
    // data or class properties
    virtual task trans_received (rgp_master xactor, rgp_rw cycle); endtask
    virtual task trans_executed (rgp_master xactor, rgp_rw cycle); endtask
endclass : rgp_master_cbs

typedef uvm_callbacks #(rgp_master,rgp_master_cbs) rgp_master_cbs_t ;

//typedef class rgp_master_cbs ;
class rgp_master extends uvm_driver#(rgp_rw);
    // data or class properties
    `uvm_component_utils(rgp_master)
    `uvm_register_cb(rgp_master, rgp_master_cbs) ;

//valuable-------------------------------------------
    event trig ;
    virtual rgp_if rgp_vif ;
    bit DEBUG_FLAG ;

    // initialization
    function new(string name, uvm_component parent = null);
        super.new(name, parent) ;
    endfunction : new

    virtual function void build_phase(uvm_phase phase) ;
        rgp_agent agent ;
        super.build_phase(phase) ;

        if($cast(agent, get_parent()) && agent != null) begin
            rgp_vif = agent.vif ;
        end
        else begin
            if( !uvm_config_db#(virtual rgp_if)::get(null,"*","rgp_if_inst",rgp_vif) ) begin
                `uvm_fatal("RGP/DRV/NOVIF","failed to get rgp_vif")
            end
        end
    endfunction : build_phase   

    virtual protected task reset_phase(uvm_phase phase) ;
        super.reset_phase(phase) ;
    endtask : reset_phase

    virtual protected task main_phase(uvm_phase phase) ;
        super.main_phase(phase) ;

        forever begin
            rgp_rw tr ;
            
            seq_item_port.get_next_item(tr) ;

            this.trans_received(tr) ;
            `uvm_do_callbacks(rgp_master, rgp_master_cbs, trans_received(this,tr))

            case(tr.kind)
                rgp_rw::READ : this.read(tr.addr, tr.data) ;
                rgp_rw::WRITE: this.write(tr.addr, tr.data) ;
            endcase

            this.trans_executed(tr) ;
            `uvm_do_callbacks(rgp_master, rgp_master_cbs, trans_executed(this,tr))

            seq_item_port.item_done() ;

            `ifdef UVM_DISABLE_AUTO_ITEM_RECORDING
                tr.end_tr();
            `endif

            ->trig ;
            #1;
        end
    endtask : main_phase

    virtual protected task read(input bit [31:0] addr,
                                output logic [31:0] data) ;
        this.rgp_vif.RGP_READ(addr, data) ;
    endtask

    virtual protected task write(input bit [31:0] addr,
                                 input bit [31:0] data) ;
        `uvm_info("rgp_master",$psprintf("Addr :%0x write %0x",addr,data),UVM_HIGH); 
        this.rgp_vif.RGP_WRITE(addr, data) ;
    endtask

    virtual protected task trans_received(rgp_rw tr) ;
    endtask

    virtual protected task trans_executed(rgp_rw tr) ;
    endtask 

        

endclass : rgp_master


`endif

// vim: et:ts=4:sw=4:ft=sverilog
