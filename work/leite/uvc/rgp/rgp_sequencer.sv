/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_sequencer.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 11:30:02
 * Description: 
 * 
 */

`ifndef __RGP_SEQUENCER_SV__
`define __RGP_SEQUENCER_SV__

class rgp_sequencer extends uvm_sequencer #(rgp_rw) ;
    // data or class properties
    `uvm_component_utils(rgp_sequencer) 

    // initialization
    function new(input string name, uvm_component parent=null);
        super.new(name,parent) ;
    endfunction : new

endclass : rgp_sequencer 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
