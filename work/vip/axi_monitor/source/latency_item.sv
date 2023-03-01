/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : latency_item.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 14:12:39
 * Description: 
 * 
 */

`ifndef __LATENCY_ITEM_SV__
`define __LATENCY_ITEM_SV__

class latency_item;
    // data or class properties
    realtime last_latency ;
    realtime max_latency ;
    realtime min_latency ;
    realtime avg_latency ;
    bit [8:0] max_latency_burst_id ;
    int       max_latency_burst_length ;
    realtime  max_latency_burst_start_time ;
    realtime  max_latency_burst_end_time ;
    bit [8:0] min_latency_burst_id ;
    int       min_latency_burst_length ;
    realtime  min_latency_burst_start_time ;
    realtime  min_latency_burst_end_time ;


    // initialization
    function new();
    endfunction : new

    virtual function latency_item copy() ;
        copy = new() ;
        copy.last_latency                  = last_latency                 ;
        copy.max_latency                   = max_latency                  ;
        copy.min_latency                   = min_latency                  ;
        copy.avg_latency                   = avg_latency                  ;
        copy.max_latency_burst_id          = max_latency_burst_id         ;
        copy.max_latency_burst_length      = max_latency_burst_length     ;
        copy.max_latency_burst_start_time  = max_latency_burst_start_time ;
        copy.max_latency_burst_end_time    = max_latency_burst_end_time   ;
        copy.min_latency_burst_id          = min_latency_burst_id         ;
        copy.min_latency_burst_length      = min_latency_burst_length     ;
        copy.min_latency_burst_start_time  = min_latency_burst_start_time ;
        copy.min_latency_burst_end_time    = min_latency_burst_end_time   ;
    endfunction : copy

    virtual function void display() ;
        $display("latency_item:") ;
        $display("last_latency                  = %0t", last_latency                 ) ;
        $display("max_latency                   = %0t", max_latency                  ) ;
        $display("min_latency                   = %0t", min_latency                  ) ;
        $display("avg_latency                   = %0t", avg_latency                  ) ;
        $display("max_latency_burst_id          = 0x%0x", max_latency_burst_id         ) ;
        $display("max_latency_burst_length      = 0x%0x", max_latency_burst_length     ) ;
        $display("max_latency_burst_start_time  = %0t", max_latency_burst_start_time ) ;
        $display("max_latency_burst_end_time    = %0t", max_latency_burst_end_time   ) ;
        $display("min_latency_burst_id          = 0x%0x", min_latency_burst_id         ) ;
        $display("min_latency_burst_length      = 0x%0x", min_latency_burst_length     ) ;
        $display("min_latency_burst_start_time  = %0t", min_latency_burst_start_time ) ;
        $display("min_latency_burst_end_time    = %0t", min_latency_burst_end_time   ) ;
    endfunction : display

endclass : latency_item


`endif

// vim: et:ts=4:sw=4:ft=sverilog
