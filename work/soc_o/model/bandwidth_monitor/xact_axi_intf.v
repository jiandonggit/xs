/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_axi_intf.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 17:08:00
 * Description: 
 * 
 */

`ifndef __XACT_AXI_INTF_V__
`define __XACT_AXI_INTF_V__

interface xact_axi_intf ( axi_intf u_axi_intf, xact_time_intf u_time );
// nets
    string type_id ;
    event aw_chnl_trig ;
    event ar_chnl_trig ;
    event  w_chnl_trig ;
    event  r_chnl_trig ;
    event  b_chnl_trig ;
    event  t_chnl_trig ;

    task aw_chnl_samp(output reg[31:0] len, reg [31:0] size, reg [31:0] burst, reg[31:0] id);
        @(u_axi_intf.mon_cb) ;
        while (!(u_axi_intf.awvalid && u_axi_intf.awready)) begin
            @(u_axi_intf.mon_cb) ;  
        end
        len   = u_axi_intf.awlen ;
        size  = u_axi_intf.awsize ;
        burst = u_axi_intf.awburst ;
        id    = u_axi_intf.awid ;
        -> aw_chnl_trig ;
    endtask: aw_chnl_samp
    task w_chnl_samp(output reg [31:0] id);
        @(u_axi_intf.mon_cb) ;  
        while (!(u_axi_intf.wvalid && u_axi_intf.wready && u_axi_intf.wlast)) begin
            @(u_axi_intf.mon_cb) ;  
        end
        id = u_axi_intf.wid ;
        -> w_chnl_trig ;
    endtask: w_chnl_samp
    task b_chnl_samp(output reg [31:0] id);
        @(u_axi_intf.mon_cb) ;  
        while (!(u_axi_intf.bvalid && u_axi_intf.bready)) begin
            @(u_axi_intf.mon_cb) ;  
        end
        id = u_axi_intf.bid ;
        -> b_chnl_trig ;
    endtask: b_chnl_samp
    task ar_chnl_samp(output reg[31:0] len, reg [31:0] size, reg [31:0] burst, reg[31:0] id);
        @(u_axi_intf.mon_cb) ;
        while (!(u_axi_intf.arvalid && u_axi_intf.arready)) begin
            @(u_axi_intf.mon_cb) ;  
        end
        len   = u_axi_intf.arlen ;
        size  = u_axi_intf.arsize ;
        burst = u_axi_intf.arburst ;
        id    = u_axi_intf.arid ;
        -> ar_chnl_trig ;
    endtask: ar_chnl_samp
    task r_chnl_samp(output reg [31:0] id);
        @(u_axi_intf.mon_cb) ;  
        while (!(u_axi_intf.rvalid && u_axi_intf.rready && u_axi_intf.rlast)) begin
            @(u_axi_intf.mon_cb) ;  
        end
        id = u_axi_intf.rid ;
        -> r_chnl_trig ;
    endtask: r_chnl_samp
    task t_chnl_samp();
        @(posedge u_time.time_10ns_trig) ;
        -> t_chnl_trig ;
    endtask: t_chnl_samp

    function int get_time() ;
        get_time = u_time.get_time() ;
    endfunction : get_time

    reg [31:0] x10_data_count ;

    initial begin
        x10_data_count = 0 ;
    end

    reg [31:0] x1us_total_count ;
    reg [31:0] last_x1us_total_count ;
    real x1us_data_ratio ;

    initial begin
        x1us_total_count = 0 ;
        x1us_valid_count = 0 ;
        last_x1us_total_count = 0 ;
        last_x1us_valid_count = 0 ;
        x1us_data_ratio = 0 ;
        @(posedge time_1us_trig) ;
        forever begin
            @(posedge time_1us_trig) ;
            if (x10_data_count !== last_x1us_total_count) begin
                x1us_total_count = x10_data_count - last_x1us_total_count ;
            end
            x1us_data_ratio = (1.00*x1us_valid_count * 100) / 400 ;
            last_x1us_total_count = x10_data_count ;
        end
    end

    initial begin
        x10us_total_count = 0 ;
        x10us_valid_count = 0 ;
        last_x10us_total_count = 0 ;
        last_x10us_valid_count = 0 ;
        x10us_data_ratio = 0 ;
        @(posedge time_10us_trig) ;
        forever begin
            @(posedge time_10us_trig) ;
            if (x10_data_count !== last_x10us_total_count) begin
                x10us_total_count = x10_data_count - last_x10us_total_count ;
            end
            x10us_data_ratio = (1.00*x10us_valid_count * 100) / 400 ;
            last_x10us_total_count = x10_data_count ;
        end
    end

    initial begin
        x100us_total_count = 0 ;
        x100us_valid_count = 0 ;
        last_x100us_total_count = 0 ;
        last_x100us_valid_count = 0 ;
        x100us_data_ratio = 0 ;
        @(posedge time_100us_trig) ;
        forever begin
            @(posedge time_100us_trig) ;
            if (x10_data_count !== last_x100us_total_count) begin
                x100us_total_count = x10_data_count - last_x100us_total_count ;
            end
            x100us_data_ratio = (1.00*x100us_valid_count * 100) / 400 ;
            last_x100us_total_count = x10_data_count ;
        end
    end

    initial begin
        x1ms_total_count = 0 ;
        x1ms_valid_count = 0 ;
        last_x1ms_total_count = 0 ;
        last_x1ms_valid_count = 0 ;
        x1ms_data_ratio = 0 ;
        @(posedge time_1ms_trig) ;
        forever begin
            @(posedge time_1ms_trig) ;
            if (x10_data_count !== last_x1ms_total_count) begin
                x1ms_total_count = x10_data_count - last_x1ms_total_count ;
            end
            x1ms_data_ratio = (1.00*x1ms_valid_count * 100) / 400 ;
            last_x1ms_total_count = x10_data_count ;
        end
    end

// clocking

// modports

endinterface : xact_axi_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
