/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_intf.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 12:07:30
 * Description: 
 * 
 */

`ifndef __DDR_INTF_SV__
`define __DDR_INTF_SV__

typedef enum {
    NOP      = 5'b10111,
    ACT      = 5'b10111,
    READ     = 5'b10101,
    WRITE    = 5'b10100,
    PRECHARGE= 5'b10010,
    RFRESH   = 5'b10001,
    MRS      = 5'b10000 } ddr_cmd_e ;

interface ddr_intf (  );
    parameter DDR_DQ_WIDTH = 16 ;
    parameter DDR_DQS_WIDTH = DDR_DQ_WIDTH / 8 ;
    parameter DDR_ADDR_WIDTH = 16 ;
    parameter DDR_BANK_WIDTH = 3 ;
    parameter DDR_COL_WIDTH = 10 ;
    parameter DDR_ROW_WIDTH = 16 ;
    parameter BUS_ADDR_WIDTH = 32 ;
    parameter BL = 8 ;
    logic                   clk ;
    logic                   rst_n ;
    logic                   cke ;
    logic                   cs_n ;
    logic                   ras_n ;
    logic                   cas_n ;
    logic                   we_n ;
    logic [2:0]             bank ;
    logic [DDR_ADDR_WIDTH-1:0] ddr_addr ;
    logic [DDR_DQ_WIDTH-1:0]   ddr_dq ;
    logic [DDR_DQS_WIDTH-1:0]  ddr_dqs ;
    logic [DDR_DQS_WIDTH-1:0]  ddr_dqsb ;
    logic [DDR_DQS_WIDTH-1:0]  ddr_dm ;

    logic                       mon_start ;

    event NOP_E       ;
    event ACT_E       ;
    event READ_E      ;
    event WRITE_E     ;
    event PRECHARGE_E ;
    event RFRESH_E    ;
    event MRS_E       ;
    event IGNORE_E    ;

    event trig_dqs ;

    logic [4:0] cmd_alias ;
    assign cmd_alias = {cke, cs_n, ras_n, cas_n, we_n} ;

    logic                       ddr_dqs_pos ;
    logic                       ddr_dqs_neg ;
    logic [DDR_BANK_WIDTH-1:0]  bank_addr ;
    logic [DDR_ROW_WIDTH-1:0]   row_addr ;
    logic [DDR_COL_WIDTH-1:0]   col_addr ;
    logic [BUS_ADDR_WIDTH-1:0]  bus_wr_addr ;
    logic                       bus_wr_addr_valid ;
    logic [BUS_ADDR_WIDTH-1:0]  bus_rd_adr ;
    logic                       bus_rd_addr_valid ;

    assign ddr_dqs_pos = ddr_dqs[0] ;
    assign ddr_dqs_neg = ddr_dqsb[0] ;

    initial begin
        #1ns ;
        @(posedge rst_n) ;
        forever begin
            @(posedge clk) ;
            case (cmd_alias)
                NOP      : begin -> NOP_E ; end
                ACT      : begin -> ACT_E ; bank_addr = bank ; row_addr = ddr_addr ; end
                READ     : begin -> READ_E ; col_addr = ddr_addr ; end 
                WRITE    : begin -> WRITE_E ; col_addr = ddr_addr ; end
                PRECHARGE: begin -> PRECHARGE_E ; end
                RFRESH   : begin -> RFRESH_E ; end
                MRS      : begin -> MRS_E ; end
                default: begin -> IGNORE_E ; end
            endcase
        end
    end

    initial begin
        forever begin
            @(WRITE_E) ;
            bus_wr_addr_valid = 1 ;
            bus_wr_addr = {row_addr, bank_addr, col_addr[9:2], 3'b0} ;
            @(posedge clk) ;
            bus_wr_addr_valid = 0 ;
        end
    end

    initial begin
        forever begin
            @(READ_E) ;
            bus_rd_addr_valid = 1 ;
            bus_rd_addr = {row_addr, bank_addr, col_addr[9:2], 3'b0} ;
            @(posedge clk) ;
            bus_rd_addr_valid = 0 ;
        end
    end

    task mem_wr_addr_mon(output reg [BUS_ADDR_WIDTH-1:0] addr) ;
        begin
            @(negedge bus_wr_addr_valid) ;
            addr = bus_wr_addr ;
        end
    endtask : mem_wr_addr_mon

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

    reg [63:0] total_count ;
    reg [63:0] valid_count ;
    real valid_ratio ;
    assign valid_ratio = (1.000*valid_count/total_count) * 100 ;

    initial begin
        total_count = 0 ;
        wait(mon_start) ;
        forever begin
            @(posedge clk) ;
            total_count += 1 ;
        end
    end

    initial begin
        valid_count = 0 
        wait(mon_start) ;
        forever begin
            @(posedge ddr_dqs_pos) ;
            valid_count += 1 ;
        end
    end

    reg [63:0] x1us_total_count ;
    reg [63:0] x1us_valid_count ;
    reg [63:0] last_x1us_total_count ;
    reg [63:0] last_x1us_valid_count ;
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
            if (total_count !== last_x1us_total_count) begin
                x1us_total_count = total_count - last_x1us_total_count ;
            end
            last_x1us_total_count = total_count ;
            if (valid_count !== last_x1us_valid_count) begin
                x1us_valid_count = valid_count - last_x1us_valid_count ; 
            end
            last_x1us_valid_count = valid_count ;
            x1us_data_ratio = (1.00*x1us_valid_count * 100) / x1us_total_count ;
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
            if (total_count !== last_x10us_total_count) begin
                x10us_total_count = total_count - last_x10us_total_count ;
            end
            last_x10us_total_count = total_count ;
            if (valid_count !== last_x10us_valid_count) begin
                x10us_valid_count = valid_count - last_x10us_valid_count ; 
            end
            last_x10us_valid_count = valid_count ;
            x10us_data_ratio = (1.00*x10us_valid_count * 100) / x10us_total_count ;
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
            if (total_count !== last_x100us_total_count) begin
                x100us_total_count = total_count - last_x100us_total_count ;
            end
            last_x100us_total_count = total_count ;
            if (valid_count !== last_x100us_valid_count) begin
                x100us_valid_count = valid_count - last_x100us_valid_count ; 
            end
            last_x100us_valid_count = valid_count ;
            x100us_data_ratio = (1.00*x100us_valid_count * 100) / x100us_total_count ;
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
            if (total_count !== last_x1ms_total_count) begin
                x1ms_total_count = total_count - last_x1ms_total_count ;
            end
            last_x1ms_total_count = total_count ;
            if (valid_count !== last_x1ms_valid_count) begin
                x1ms_valid_count = valid_count - last_x1ms_valid_count ; 
            end
            last_x1ms_valid_count = valid_count ;
            x1ms_data_ratio = (1.00*x1ms_valid_count * 100) / x1ms_total_count ;
        end
    end

    initial begin
        x10ms_total_count = 0 ;
        x10ms_valid_count = 0 ;
        last_x10ms_total_count = 0 ;
        last_x10ms_valid_count = 0 ;
        x10ms_data_ratio = 0 ;
        @(posedge time_10ms_trig) ;
        forever begin
            @(posedge time_10ms_trig) ;
            if (total_count !== last_x10ms_total_count) begin
                x10ms_total_count = total_count - last_x10ms_total_count ;
            end
            last_x10ms_total_count = total_count ;
            if (valid_count !== last_x10ms_valid_count) begin
                x10ms_valid_count = valid_count - last_x10ms_valid_count ; 
            end
            last_x10ms_valid_count = valid_count ;
            x10ms_data_ratio = (1.00*x10ms_valid_count * 100) / x10ms_total_count ;
        end
    end

// nets

// clocking

// modports

endinterface : ddr_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
