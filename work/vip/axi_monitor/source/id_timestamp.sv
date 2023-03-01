/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : id_timestamp.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 14:09:02
 * Description: 
 * 
 */

`ifndef __ID_TIMESTAMP_SV__
`define __ID_TIMESTAMP_SV__

class id_timestamp;
    // data or class properties
    bit [8:0] id; 
    bit [5:0] burst_len ;
    realtime timestamp;

    // initialization
    function new();
    endfunction : new

    virtual function id_timestamp copy() ;
        copy = new() ;
        copy.id = id ;
        copy.burst_len = burst_len ;
        copy.timestamp = timestamp ;
    endfunction : copy

    virtual function void display() ;
        $display("id_timestamp:") ;
        $display("id        : 0x%x",id) ;
        $display("burst_len : 0x%x",burst_len) ; 
        $display("timestamp : %0t",timestamp) ;
    endfunction : display

endclass : id_timestamp


`endif

// vim: et:ts=4:sw=4:ft=sverilog
