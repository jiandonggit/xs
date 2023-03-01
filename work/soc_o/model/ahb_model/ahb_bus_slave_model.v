/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_bus_slave_model.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 10:55:42
 * Description: 
 * 
 */

`ifndef __AHB_BUS_SLAVE_MODEL_V__
`define __AHB_BUS_SLAVE_MODEL_V__

`include "VmtBaseDefines.inc"
`include "VmtDefines.inc"
`include "AmbaCommonDefines.inc"
`include "AmbaMessages.inc"
`include "AhbCommonDefines.inc"
`include "AhbSlaveDefines.inc"
`include "AhbSlaveMessages.inc"
`include "AhbBusDefines.inc"
`include "AhbBusMessages.inc"
`include "AhbMonitorDefines.inc"
`include "AhbMonitorMessages.inc"

`timescale 1ns/100ps

`include "ahb_bus_vmt.v"
`include "ahb_slave_vmt.v"
`include "ahb_monitor_vmt.v"

module ahb_bus_slave_model (
    hclk,
    hresetn,

    //bus_signal_m1 ,
    hbusreq_m1 ,
    hgrant_m1 ,
    haddr_m1,
    hburst_m1,
    hlock_m1,
    hprot_m1,
    hsize_m1,
    htrans_m1,
    hwdata_m1,
    hwrite_m1,

    //bus_signal_m2 ,
    //bus_signal_m3 ,
    //bus_signal_m4 ,
    //bus_signal_m5 ,
    //bus_signal_m6 ,

    hrdata,
    hready,
    hresp
) ;

parameter ADDR_WIDTH = 32 ;
parameter DATA_WIDTH = 32 ;

`define DECLARE_IO_M(STR) \
    input                       hbusreq_``STR ,\
    input  [ADDR_WIDTH-1:0]     haddr_``STR,\
    input  [2:0]                hburst_``STR,\
    input                       hlock_``STR,\
    input  [3:0]                hprot_``STR,\
    input  [2:0]                hsize_``STR,\
    input  [1:0]                htrans_``STR,\
    input  [DATA_WIDTH-1:0]     hwdata_``STR,\
    input                       hwrite_``STR,\
    output                      hgrant_``STR ,\

`define DECLARE_SIG_M(STR) \
    wire                      hbusreq_``STR ,\
    wire [ADDR_WIDTH-1:0]     haddr_``STR,\
    wire [2:0]                hburst_``STR,\
    wire                      hlock_``STR,\
    wire [3:0]                hprot_``STR,\
    wire [2:0]                hsize_``STR,\
    wire [1:0]                htrans_``STR,\
    wire [DATA_WIDTH-1:0]     hwdata_``STR,\
    wire                      hwrite_``STR,\
    wire                      hgrant_``STR ,\

`define DECLARE_SIG_S(STR) \
    wire                      hsel_``STR ,\
    wire                      hready_resp_``STR,\
    wire [1:0]                hresp_``STR,\
    wire [15:0]               hsplit_``STR,\
    wire [DATA_WIDTH-1:0]     hrdata_``STR,\

`define CONNECT_SIG_M(STR) \
    .hbusreq_``STR (hbusreq_``STR ) ,\
    .haddr_``STR   (haddr_``STR   ) ,\
    .hburst_``STR  (hburst_``STR  ) ,\
    .hlock_``STR   (hlock_``STR   ) ,\
    .hprot_``STR   (hprot_``STR   ) ,\
    .hsize_``STR   (hsize_``STR   ) ,\
    .htrans_``STR  (htrans_``STR  ) ,\
    .hwdata_``STR  (hwdata_``STR  ) ,\
    .hwrite_``STR  (hwrite_``STR  ) ,\
    .hgrant_``STR  (hgrant_``STR  ) ,\

`define CONNECT_SIG_S(STR) \
    .hsel_``STR        (hsel_``STR       ) ,\
    .hready_resp_``STR (hready_resp_``STR) ,\
    .hresp_``STR       (hresp_``STR      ) ,\
    .hsplit_``STR      (hsplit_``STR     ) ,\
    .hrdata_``STR      (hrdata_``STR     ) ,\

`define CLEAR_SIG_M(STR) \
    assign hbusreq_``STR = 0 ;\
    assign haddr_``STR   = 0 ;\
    assign hburst_``STR  = 0 ;\
    assign hlock_``STR   = 0 ;\
    assign hprot_``STR   = 0 ;\
    assign hsize_``STR   = 0 ;\
    assign htrans_``STR  = 0 ;\
    assign hwdata_``STR  = 0 ;\
    assign hwrite_``STR  = 0 ;\
    assign hgrant_``STR  = 0 ;\

`define CLEAR_SIG_S(STR) \
    assign hsel_``STR        = 0 ;\
    assign hready_resp_``STR = 0 ;\
    assign hresp_``STR       = 0 ;\
    assign hsplit_``STR      = 0 ;\
    assign hrdata_``STR      = 0 ;\


    // IO 
    input hclk ;
    input hresetn ;
    `DECLARE_IO_M(m1)

    output [DATA_WIDTH-1:0] hrdata ;
    output                  hready ;
    output [1:0]            hresp ;

    wire   xxx_slv ;

    `DECLARE_SIG_M(m7) ;
    // ...

    `DECLARE_SIG_S(s1) ;
    // ...
    
    `CLEAR_SIG_M(m0) ;
    // ...

    `CLEAR_SIG_S(s0) ;
    // ...

    ahb_bus_vmt ahb_bus(
        .hresetn(hresetn) ,
        .hclk(hclk),
        `CONNECT_SIG_M(m1)
        // ...
        `CONNECT_SIG_S(s1)
        // ...
        // common slv
        .haddr( xxx_slv ) ,
        // ...
        .hrdata ( hrdata ),
        .hready ( hready ) ,
        .hresp  ( hresp ) 
    ) ;

    ahb_slave_vmt ahb_slave(
        .hclk (hclk) ,
        .hresetn (hresetn) ,
        // common slv
        .haddr( xxx_slv ) ,
        .hrdata( hrdata_s1 ) ,
        //...
    ) ;

    wire [15:0] hsel_2mon ;
    assign hsel_2mon = { hsel_s15, hsel_s14 .... hsel_s0 } ;
    wire [15:0] hbusreq_2mon ;
    assign hbusreq_2mon = { hbusreq_s15, hbusreq_s14 .... hbusreq_s0 } ;
    wire [15:0] hgrant_2mon ;
    assign hgrant_2mon = { hgrant_s15, hgrant_s14 .... hgrant_s0 } ;

    ahb_monitor_vmt ahb_monitor(
        .hclk   (hclk) ,
        .hresetn(hresetn) ,
        .haddr  ( xxx_slv ) ,
        // ...
        .hsel   (hsel_2mon),
        .hsplit_s0 (16'b0),
        .hsplit_s1 (hsplit_s1) ,
        // ...
    ) ;

    initial begin
        integer slaveLogId ;
        integer monLogId ;

        wait(hresetn == 1) ;
        //AHB_SLAVE_SET_PARAM
        ahb_slave.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HDATA_WIDTH_PARAM, DATA_WIDTH) ;
        ahb_slave.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HADDR_WIDTH_PARAM, ADDR_WIDTH) ;
        ahb_slave.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_NOTSELECTED_HREADY_RESP_PARAM, 0) ;
        ahb_slave.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HSPLIT_DELAY_CLOCKS_PARAM, $urandom_range(0,16)) ;

        ahb_slave.open_msg_log      (`VMT_DEFAULT_STREAM_ID, "logs/ahb_slave.log", `VMT_MSG_LOG_MODE_OVR, slaveLogId) ;
        ahb_slave.disable_msg_type  (`VMT_DEFAULT_STREAM_ID, `VMT_MSG_ALL, `VMT_MSG_ROUTE_ALL) ;
        ahb_slave.enable_msg_type   (`VMT_DEFAULT_STREAM_ID, `VMT_MSG_PROTO_CYCLE|`VMT_MSG_PROTO_ERROR, `VMT_MSG_ROUTE_ALL) ;
        ahb_slave.enable_msg_feature(`VMT_DEFAULT_STREAM_ID, `VMT_MSG_SCOPE_ALL, `VMT_MSG_FEATURES_DEFAULT, slaveLogId) ;

        //AHB_BUS_SET_PARAM
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HDATA_WIDTH_PARAM, DATA_WIDTH) ;
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HADDR_WIDTH_PARAM, ADDR_WIDTH) ;
        ahb_bus.configure_memmap(`DW_VIP_AMBA_ALL_SLAVES, 0, 0) ;
        ahb_bus.configure_memmap(1, 0, 64'h1_0000_0000/4) ;
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_MASTER_PRESENT_PARAM, 16'h7f) ;
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_DEFAULT_MASTER_PARAM, 0) ;
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_SLAVE_PRESENT_PARAM, 16'h3) ;

        //AHB_MONITOR_SET_PARAM
        ahb_monitor.open_msg_log    (`VMT_DEFAULT_STREAM_ID, "logs/ahb_monitor.log", `VMT_MSG_LOG_MODE_OVR, monLogId) ;
        ahb_monitor.disable_msg_type  (`VMT_DEFAULT_STREAM_ID, `VMT_MSG_ALL, `VMT_MSG_ROUTE_SIM) ;
        ahb_monitor.enable_msg_type   (`VMT_DEFAULT_STREAM_ID, `VMT_MSG_PROTO_CYCLE|`VMT_MSG_PROTO_ERROR, `VMT_MSG_ROUTE_SIM) ;
        ahb_monitor.enable_msg_feature(`VMT_DEFAULT_STREAM_ID, `VMT_MSG_SCOPE_ALL, `VMT_MSG_FEATURES_DEFAULT, monLogId) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_MASTER_PRESENT_PARAM, 16'h7f) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_SLAVE_PRESENT_PARAM, 16'h3) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HDATA_WIDTH_PARAM, DATA_WIDTH) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_DEFAULT_MASTER_PARAM, 0) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_DUMMY_MASTER_PARAM, 0) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_LOG_TRANSACTIONS_PARAM, 1);
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_SPLIT_CAPABLE_PARAM, 16'h3) ;

        $display("%m: vip start @%0t", realtime) ;
        ahb_slave.start ;
        ahb_bus.start ;
        ahb_monitor.start ;

    end

    task set_ebt(bit [15:0] master_id, bit [31:0] own_cycle, bit [31:0] valid_cycle);
        ahb_bus.set_ebt (master_id, own_cycle, `DW_VIP_AMBA_INFINITE_NUM_TIMES_ON_EBT, valid_cycle) ;
    endtask: set_ebt

    task clear_ebt(bit [15:0] master_id);
        ahb_bus.clear_ebt (master_id) ;
    endtask: clear_ebt

    task set_delay(bit [31:0] addr, [1:0] size, int delay);
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, {32'h0,addr}, 2**size, 1, `DW_VIP_AMBA_RESPONSE_OKAY, delay) ;
    endtask: set_delay

    task set_split(bit [31:0] addr, [1:0] size);
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, 64'h0, `DW_VIP_AMBA_MEM_ALL, `DW_VIP_AMBA_RESPONSE_RESET, `DW_VIP_AMBA_RESPONSE_OKAY, 0) ;
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, {32'h0,addr}, 2**size, 1, `DW_VIP_AMBA_RESPONSE_SPLIT, $urandom_range(0,16)) ;
    endtask: set_split

    task set_retry(bit [31:0] addr, [1:0] size);
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, 64'h0, `DW_VIP_AMBA_MEM_ALL, `DW_VIP_AMBA_RESPONSE_RESET, `DW_VIP_AMBA_RESPONSE_OKAY, 0) ;
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, {32'h0,addr}, 2**size, 1, `DW_VIP_AMBA_RESPONSE_RETRY, $urandom_range(0,16)) ;
    endtask: set_retry

    task set_error(bit [31:0] addr, [1:0] size);
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, 64'h0, `DW_VIP_AMBA_MEM_ALL, `DW_VIP_AMBA_RESPONSE_RESET, `DW_VIP_AMBA_RESPONSE_OKAY, 0) ;
        ahb_slave.set_mem_response(`VMT_DEFAULT_STREAM_ID, {32'h0,addr}, 2**size, 1, `DW_VIP_AMBA_RESPONSE_ERROR, $urandom_range(0,16)) ;
    endtask: set_error

    task get_mem_byte(bit [31:0] addr, output bit [7:0] data);
        ahb_slave.get_mem(`VMT_DEFAULT_STREAM_ID, addr, 8, data) ;
    endtask: get_mem_byte 
    task get_mem_hword(bit [31:0] addr, output bit [15:0] data);
        ahb_slave.get_mem(`VMT_DEFAULT_STREAM_ID, addr, 16, data) ;
    endtask: get_mem_hword
    task get_mem_word(bit [31:0] addr, output bit [31:0] data);
        ahb_slave.get_mem(`VMT_DEFAULT_STREAM_ID, addr, 32, data) ;
    endtask: get_mem_word

    task set_mem_byte(bit [31:0] addr,  bit [7:0] data);
        ahb_slave.set_mem(`VMT_DEFAULT_STREAM_ID, addr, 8, data) ;
    endtask: set_mem_byte 
    task set_mem_hword(bit [31:0] addr,  bit [15:0] data);
        ahb_slave.set_mem(`VMT_DEFAULT_STREAM_ID, addr, 16, data) ;
    endtask: set_mem_hword
    task set_mem_word(bit [31:0] addr,  bit [31:0] data);
        ahb_slave.set_mem(`VMT_DEFAULT_STREAM_ID, addr, 32, data) ;
    endtask: set_mem_word

    task set_default_master(bit [31:0] mstr_id);
        ahb_bus.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_DEFAULT_MASTER_PARAM, mstr_id) ;
        ahb_monitor.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_DEFAULT_MASTER_PARAM, mstr_id) ;
    endtask: set_default_master



endmodule

`undef DECLARE_IO_M
`undef DECLARE_SIG_M
`undef DECLARE_SIG_S
`undef CONNECT_SIG_M
`undef CONNECT_SIG_S
`undef CLEAR_SIG_M
`undef CLEAR_SIG_S



`endif

// vim: et:ts=4:sw=4:ft=sverilog
