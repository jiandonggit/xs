/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor_config.svh
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 13:55:45
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_CONFIG_SVH__
`define __AXI_MONITOR_CONFIG_SVH__

`ifndef PSRAM_CLK_FREQ
`define PSRAM_CLK_FREQ 250
`endif

parameter REF_CLOCK_FREQ = 1000_000_000 ; //1000MHz
parameter SAMPLE_CNT_NS_10   = REF_CLOCK_FREQ/1000_000_00 ; //10ns
parameter SAMPLE_CNT_NS_100  = REF_CLOCK_FREQ/1000_000_0 ;//100ns
parameter SAMPLE_CNT_NS_500  = REF_CLOCK_FREQ/2000_000 ; //500ns
parameter SAMPLE_CNT_NS_1000 = REF_CLOCK_FREQ/1000_000 ; //1000ns
parameter SAMPLE_CNT_NS_10000= REF_CLOCK_FREQ/1000_00 ; // 10000ns

parameter DDR_DQS_WIDTH = 16 ;
parameter DDR_CLK_FREQ = `PSRAM_CLK_FREQ ;
parameter DDR_TOTAL_BW = DDR_CLK_FREQ*DDR_DQS_WIDTH*2/8 ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
