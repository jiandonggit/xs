/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_virtual_sequencer.svh
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 14:16:34
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_VIRTUAL_SEQUENCER_SVH__
`define __FLASHCTRL_VIRTUAL_SEQUENCER_SVH__

class flashctrl_virtual_sequencer extends uvm_sequencer;
    // data or class properties
    `uvm_component_utils(flashctrl_virtual_sequencer)

    svt_ahb_master_transaction_sequencer ahb_master ;

    // initialization
    function new(string name = "flashctrl_virtual_sequencer", uvm_component parent=null);
        super.new(name,parent) ;
    endfunction : new

endclass : flashctrl_virtual_sequencer


`endif

// vim: et:ts=4:sw=4:ft=sverilog
