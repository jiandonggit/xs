/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_time_intf.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 17:00:57
 * Description: 
 * 
 */

`ifndef __XACT_TIME_INTF_SV__
`define __XACT_TIME_INTF_SV__

`resetall
`timescale 1ns/10ps

interface xact_time_intf (  );
// nets
    reg clk_1000m ;
    reg perf_rst_n ;
    bit [31:0] timer ;
    bit time_10ns_trig ;
    parameter time_10ns = 10 ;
    bit time_100ns_trig ;
    parameter time_100ns = 100 ;
    bit time_1us_trig ;
    parameter time_1us = 1000 ;
    bit time_10us_trig ;
    parameter time_10us = 10000 ;
    bit time_100us_trig ;
    parameter time_100us = 100000 ;
    bit time_1ms_trig ;
    parameter time_1ms = 1000000 ;
    bit time_10ms_trig ;
    parameter time_10ms = 10000000 ;
    bit time_100ms_trig ;
    parameter time_100ms = 100000000 ;
    bit time_1s_trig ;
    parameter time_1s = 1000000000 ;

    initial begin
        perf_rst_n = 0 ;
        repeat(5) @(posedge clk_1000m) ;
        perf_rst_n = 1 ;
    end

    initial begin
        clk_1000m = 0 ;
        forever begin
            #0.5ns clk_1000m = ~clk_1000m ;
        end
    end

    always @(posedge clk_1000m or negedge perf_rst_n) begin
        if (!perf_rst_n) begin
            timer <= 'h1 ;
            time_1us_trig <= 0 ;
            time_10us_trig <= 0 ;
            time_100us_trig <= 0 ;
            time_1ms_trig <= 0 ;
            time_10ms_trig <= 0 ;
            time_100ms_trig <= 0 ;
            time_1s_trig <= 0 ;
        end
        else begin
            timer <= timer + 1 ;
            if (!(timer % time_10ns) begin
                time_10ns_trig <= 1 ;
            end
            else begin
                time_10ns_trig <= 0 ;
            end
            if (!(timer % time_100ns) begin
                time_100ns_trig <= 1 ;
            end
            else begin
                time_100ns_trig <= 0 ;
            end
            if (!(timer % time_1us) begin
                time_1us_trig <= 1 ;
            end
            else begin
                time_1us_trig <= 0 ;
            end
            if (!(timer % time_10us) begin
                time_10us_trig <= 1 ;
            end
            else begin
                time_10us_trig <= 0 ;
            end
            if (!(timer % time_100us) begin
                time_100us_trig <= 1 ;
            end
            else begin
                time_100us_trig <= 0 ;
            end
            if (!(timer % time_1ms) begin
                time_1ms_trig <= 1 ;
            end
            else begin
                time_1ms_trig <= 0 ;
            end
            if (!(timer % time_10ms) begin
                time_10ms_trig <= 1 ;
            end
            else begin
                time_10ms_trig <= 0 ;
            end
            if (!(timer % time_100ms) begin
                time_100ms_trig <= 1 ;
            end
            else begin
                time_100ms_trig <= 0 ;
            end
            if (!(timer % time_1s) begin
                time_1s_trig <= 1 ;
            end
            else begin
                time_1s_trig <= 0 ;
            end
        end
    end
    function int get_time() ;
        get_time = timer ;
    endfunction : get_time

// clocking

// modports

endinterface : xact_time_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
