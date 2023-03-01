/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_connect_intf.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 14:24:20
 * Description: 
 * 
 */

`ifndef __AHB_CONNECT_INTF_SV__
`define __AHB_CONNECT_INTF_SV__

interface ahb_intf ( input bit clock, input bit reset_n );
// nets
    logic           hgrant ;
    logic [31:0]    hrdata ;
    logic           hready ;
    logic [ 1:0]    hresp ;
    logic [31:0]    haddr ;
    logic [ 2:0]    hburst ;
    logic           hbusreq ;
    logic           hlock ;
    logic [ 3:0]    hprot ;
    logic [ 2:0]    hsize ;
    logic [ 1:0]    htrans ;
    logic [31:0]    hwdata ;
    logic           hwrite ;
// clocking

// modports

endinterface : ahb_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
