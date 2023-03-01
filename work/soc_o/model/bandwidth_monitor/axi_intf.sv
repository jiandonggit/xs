/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_intf.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 17:04:14
 * Description: 
 * 
 */

`ifndef __AXI_INTF_SV__
`define __AXI_INTF_SV__

interface axi_intf ( input bit clock, input bit reset_n );
// nets
    logic                       awvalid ;
    logic [`ADDR_WIDTH-1:0]     awaddr ;
    logic [`LEN_WIDTH-1:0]      awlen ;
    logic [`SIZE_WIDTH-1:0]     awsize ;
    logic [`BURST_WIDTH-1:0]    awburst ;
    logic [`LOCK_WIDTH-1:0]     awlock ;
    logic [`CACHE_WIDTH-1:0]    awcache ;
    logic [`PROT_WIDTH-1:0]     awprot ;
    logic [`M_ID_WIDTH-1:0]     awid ;
    logic [`SIDEBAND_WIDTH-1:0] awsideband ;
    logic                       awready ;

    logic                       wvalid ;
    logic [`DATA_WIDTH-1:0]     wdata ;
    logic [`STRB_WIDTH-1:0]     wstrb ;
    logic [`M_ID_WIDTH-1:0]     wid ;
    logic [`SIDEBAND_WIDTH-1:0] wsideband ;
    logic                       wready ;
    logic                       wlast ;

    logic                       bvalid ;
    logic [`RESP_WIDTH-1:0]     bresp ;
    logic [`M_ID_WIDTH-1:0]     bid ;
    logic [`SIDEBAND_WIDTH-1:0] bsideband ;
    logic                       bready ;

    logic                       arvalid ;
    logic [`ADDR_WIDTH-1:0]     araddr ;
    logic [`LEN_WIDTH-1:0]      arlen ;
    logic [`SIZE_WIDTH-1:0]     arsize ;
    logic [`BURST_WIDTH-1:0]    arburst ;
    logic [`LOCK_WIDTH-1:0]     arlock ;
    logic [`CACHE_WIDTH-1:0]    arcache ;
    logic [`PROT_WIDTH-1:0]     arprot ;
    logic [`M_ID_WIDTH-1:0]     arid ;
    logic [`SIDEBAND_WIDTH-1:0] arsideband ;
    logic                       arready ;

    logic                       rvalid ;
    logic [`DATA_WIDTH-1:0]     rdata ;
    logic [`STRB_WIDTH-1:0]     rstrb ;
    logic [`M_ID_WIDTH-1:0]     rid ;
    logic [`SIDEBAND_WIDTH-1:0] rsideband ;
    logic                       rready ;
    logic                       rlast ;

    logic                       csysreq ;
    logic                       csysack ;
    logic                       cactive ;

// clocking
    clocking mon_cb @(negedge clock);
        #default input #1step ;
        input awvalid ;
        input awaddr ;
        input awlen ;
        input awsize ;
        input awburst ;
        input awlock ;
        input awcache ;
        input awprot ;
        input awid ;
        input awsideband ;
        input awready ;

        input wvalid ;
        input wdata ;
        input wstrb ;
        input wid ;
        input wsideband ;
        input wready ;
        input wlast ;

        input bvalid ;
        input bresp ;
        input bid ;
        input bsideband ;
        input bready ;

        input arvalid ;
        input araddr ;
        input arlen ;
        input arsize ;
        input arburst ;
        input arlock ;
        input arcache ;
        input arprot ;
        input arid ;
        input arsideband ;
        input arready ;

        input rvalid ;
        input rdata ;
        input rstrb ;
        input rid ;
        input rsideband ;
        input rready ;
        input rlast ;

        input csysreq ;
        input csysack ;
        input cactive ;
    
    endclocking : mon_cb

// modports

endinterface : axi_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
