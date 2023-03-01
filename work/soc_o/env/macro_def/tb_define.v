/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : tb_define.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 14:49:00
 * Description: 
 * 
 */

`ifndef __TB_DEFINE_V__
`define __TB_DEFINE_V__

`define AHB_MASTER_INSTANTION(BUS_ID, MASTER_ID) \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_clk ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_rst_n ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_hgrant ; \
    wire [31:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hrdata ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_hready ; \
    wire [ 1:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hresp ; \
    wire [31:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_haddr ; \
    wire [ 2:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hburst ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_hbusreq ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_hlock ; \
    wire [ 3:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hprot ; \
    wire [ 2:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hsize ; \
    wire [ 1:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_htrans ; \
    wire [31:0]    ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwdata ; \
    wire           ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwrite ; \
    ahb_master_model ahb_bus``BUS_ID``_master_m``MASTER_ID ( \
            .hclk       ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_clk ) , \
            .hresetn    ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_rst_n ) , \
            .hgrant     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hgrant ) , \
            .hrdata     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hrdata ) , \
            .hready     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hready ) , \
            .hresp      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hresp ) , \
            .haddr      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_haddr ) , \
            .hburst     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hburst ) , \
            .hbusreq    ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hbusreq ) , \
            .hlock      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hlock ) , \
            .hprot      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hprot ) , \
            .hsize      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hsize ) , \
            .htrans     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_htrans ) , \
            .hwdata     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwdata ) , \
            .hwrite     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwrite ) , \
            ) ;

`define AHB_XACT_INTF_INSTANTION(BUS_ID, MASTER_ID) \
    bind arch_xact_top ahb_xact_intf #(.M_ID(MASTER_ID)) ahb_bus``BUS_ID``_master_m``MASTER_ID``_intf( \
    .clock      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_clk ) , \
    .reset_n    ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_rst_n ) , \
    .hgrant     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hgrant ) , \
    .hrdata     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hrdata ) , \
    .hready     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hready ) , \
    .hresp      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hresp ) , \
    .haddr      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_haddr ) , \
    .hburst     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hburst ) , \
    .hbusreq    ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hbusreq ) , \
    .hlock      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hlock ) , \
    .hprot      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hprot ) , \
    .hsize      ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hsize ) , \
    .htrans     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_htrans ) , \
    .hwdata     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwdata ) , \
    .hwrite     ( ahb_bus``BUS_ID``_master_m``MASTER_ID``_hwrite ) , \


`define AXI_MASTER_VIP_INSTANTION(BUS_ID, MASTER_ID) \
    wire                       bus``BUS_ID``_master``MASTER_ID``_clk        ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_rst_n      ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_awvalid    ; \
    wire [`ADDR_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_awaddr     ; \
    wire [`LEN_WIDTH-1:0]      bus``BUS_ID``_master``MASTER_ID``_awlen      ; \
    wire [`SIZE_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_awsize     ; \
    wire [`BURST_WIDTH-1:0]    bus``BUS_ID``_master``MASTER_ID``_awburst    ; \
    wire [`LOCK_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_awlock     ; \
    wire [`CACHE_WIDTH-1:0]    bus``BUS_ID``_master``MASTER_ID``_awcache    ; \
    wire [`PROT_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_awprot     ; \
    wire [`M_ID_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_awid       ; \
    wire [`SIDEBAND_WIDTH-1:0] bus``BUS_ID``_master``MASTER_ID``_awsideband ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_awready    ; \
                                                                              \
    wire                       bus``BUS_ID``_master``MASTER_ID``_wvalid     ; \
    wire [`DATA_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_wdata      ; \
    wire [`DATA_WIDTH/8-1:0]   bus``BUS_ID``_master``MASTER_ID``_wstrb      ; \
    wire [`M_ID_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_wid        ; \
    wire [`SIDEBAND_WIDTH-1:0] bus``BUS_ID``_master``MASTER_ID``_wsideband  ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_wready     ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_wlast      ; \
                                                                              \
    wire                       bus``BUS_ID``_master``MASTER_ID``_bvalid     ; \
    wire [`RESP_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_bresp      ; \
    wire [`M_ID_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_bid        ; \
    wire [`SIDEBAND_WIDTH-1:0] bus``BUS_ID``_master``MASTER_ID``_bsideband  ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_bready     ; \
                                                                              \
    wire                       bus``BUS_ID``_master``MASTER_ID``_arvalid    ; \
    wire [`ADDR_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_araddr     ; \
    wire [`LEN_WIDTH-1:0]      bus``BUS_ID``_master``MASTER_ID``_arlen      ; \
    wire [`SIZE_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_arsize     ; \
    wire [`BURST_WIDTH-1:0]    bus``BUS_ID``_master``MASTER_ID``_arburst    ; \
    wire [`LOCK_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_arlock     ; \
    wire [`CACHE_WIDTH-1:0]    bus``BUS_ID``_master``MASTER_ID``_arcache    ; \
    wire [`PROT_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_arprot     ; \
    wire [`M_ID_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_arid       ; \
    wire [`SIDEBAND_WIDTH-1:0] bus``BUS_ID``_master``MASTER_ID``_arsideband ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_arready    ; \
                                                                              \
    wire                       bus``BUS_ID``_master``MASTER_ID``_rvalid     ; \
    wire [`DATA_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_rdata      ; \
    wire [`DATA_WIDTH/8-1:0]   bus``BUS_ID``_master``MASTER_ID``_rstrb      ; \
    wire [`M_ID_WIDTH-1:0]     bus``BUS_ID``_master``MASTER_ID``_rid        ; \
    wire [`SIDEBAND_WIDTH-1:0] bus``BUS_ID``_master``MASTER_ID``_rsideband  ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_rready     ; \
    wire                       bus``BUS_ID``_master``MASTER_ID``_rlast      ; \
    wire [`QOS_WIDTH-1:0]      bus``BUS_ID``_master``MASTER_ID``_arqos      ; \
    wire [`QOS_WIDTH-1:0]      bus``BUS_ID``_master``MASTER_ID``_awqos      ; \
    axi_master_model #(.AXI_COMPARE(0)) bus``BUS_ID``_master``MASTER_ID``_inst ( \
        .clk        (bus``BUS_ID``_master``MASTER_ID``_clk        ) , \
        .areset_n   (bus``BUS_ID``_master``MASTER_ID``_rst_n      ) , \
        .awvalid    (bus``BUS_ID``_master``MASTER_ID``_awvalid    ) , \
        .awaddr     (bus``BUS_ID``_master``MASTER_ID``_awaddr     ) , \
        .awlen      (bus``BUS_ID``_master``MASTER_ID``_awlen      ) , \
        .awsize     (bus``BUS_ID``_master``MASTER_ID``_awsize     ) , \
        .awburst    (bus``BUS_ID``_master``MASTER_ID``_awburst    ) , \
        .awlock     (bus``BUS_ID``_master``MASTER_ID``_awlock     ) , \
        .awcache    (bus``BUS_ID``_master``MASTER_ID``_awcache    ) , \
        .awprot     (bus``BUS_ID``_master``MASTER_ID``_awprot     ) , \
        .awid       (bus``BUS_ID``_master``MASTER_ID``_awid       ) , \
        .awready    (bus``BUS_ID``_master``MASTER_ID``_awready    ) , \
        \
        .wvalid     (bus``BUS_ID``_master``MASTER_ID``_wvalid     ) , \
        .wdata      (bus``BUS_ID``_master``MASTER_ID``_wdata      ) , \
        .wstrb      (bus``BUS_ID``_master``MASTER_ID``_wstrb      ) , \
        .wid        (bus``BUS_ID``_master``MASTER_ID``_wid        ) , \
        .wready     (bus``BUS_ID``_master``MASTER_ID``_wready     ) , \
        .wlast      (bus``BUS_ID``_master``MASTER_ID``_wlast      ) , \
        \
        .bvalid     (bus``BUS_ID``_master``MASTER_ID``_bvalid     ) , \
        .bresp      (bus``BUS_ID``_master``MASTER_ID``_bresp      ) , \
        .bid        (bus``BUS_ID``_master``MASTER_ID``_bid        ) , \
        .bready     (bus``BUS_ID``_master``MASTER_ID``_bready     ) , \
        \
        .arvalid    (bus``BUS_ID``_master``MASTER_ID``_arvalid    ) , \
        .araddr     (bus``BUS_ID``_master``MASTER_ID``_araddr     ) , \
        .arlen      (bus``BUS_ID``_master``MASTER_ID``_arlen      ) , \
        .arsize     (bus``BUS_ID``_master``MASTER_ID``_arsize     ) , \
        .arburst    (bus``BUS_ID``_master``MASTER_ID``_arburst    ) , \
        .arlock     (bus``BUS_ID``_master``MASTER_ID``_arlock     ) , \
        .arcache    (bus``BUS_ID``_master``MASTER_ID``_arcache    ) , \
        .arprot     (bus``BUS_ID``_master``MASTER_ID``_arprot     ) , \
        .arid       (bus``BUS_ID``_master``MASTER_ID``_arid       ) , \
        .arready    (bus``BUS_ID``_master``MASTER_ID``_arready    ) , \
        \
        .rvalid     (bus``BUS_ID``_master``MASTER_ID``_rvalid     ) , \
        .rdata      (bus``BUS_ID``_master``MASTER_ID``_rdata      ) , \
        .rstrb      (bus``BUS_ID``_master``MASTER_ID``_rstrb      ) , \
        .rid        (bus``BUS_ID``_master``MASTER_ID``_rid        ) , \
        .rready     (bus``BUS_ID``_master``MASTER_ID``_rready     ) , \
        .rlast      (bus``BUS_ID``_master``MASTER_ID``_rlast      ) , \
        .arqos      (bus``BUS_ID``_master``MASTER_ID``_arqos      ) , \
        .awqos      (bus``BUS_ID``_master``MASTER_ID``_awqos      )   \
        ) ;

`define AXI_XACT_INTF_INSTANTION(BUS_ID, MASTER_ID, ID) \
    bind arch_xact_top axi_xact_intf #(.B_ID(BUS_ID), .M_ID(ID) bus``BUS_ID``_master``MASTER_ID``_if ( \
        .clock   ( bus``BUS_ID``_master``MASTER_ID``_clk ) , \
        .reset_n ( bus``BUS_ID``_master``MASTER_ID``_rst_n )   \
        ) ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
