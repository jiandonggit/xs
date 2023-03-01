/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : custom_uvm_reg_cbs.sv
 * Author : dongj
 * Create : 2023-01-06
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/06 17:27:38
 * Description: 
 * 
 */

`ifndef __CUSTOM_UVM_REG_CBS_SV__
`define __CUSTOM_UVM_REG_CBS_SV__

class custom_uvm_reg_cbs extends uvm_reg_cbs ;
    // data or class properties
    `uvm_object_utils(custom_uvm_reg_cbs)

    // initialization
    function new(string name = "custom_uvm_reg_cbs");
        super.new(name) ;
    endfunction : new

    virtual task pre_write( uvm_reg_item rw) ;
        uvm_event_pool::get_global("PRE_WRITE").trigger(rw) ;
    endtask

    virtual task post_write( uvm_reg_item rw) ;
        uvm_event_pool::get_global("POST_WRITE").trigger(rw) ;
    endtask

    virtual task pre_read( uvm_reg_item rw) ;
        uvm_event_pool::get_global("PRE_READ").trigger(rw) ;
    endtask

    virtual task post_read( uvm_reg_item rw) ;
        uvm_event_pool::get_global("POST_READ").trigger(rw) ;
    endtask

endclass : custom_uvm_reg_cbs



`endif

// vim: et:ts=4:sw=4:ft=sverilog
