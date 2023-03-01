/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : sahb_vip_binds.svh
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:52:04
 * Description: 
 * 
 */

`ifndef __SAHB_VIP_BINDS_SVH__
`define __SAHB_VIP_BINDS_SVH__

`define BIND_M(M_NUM) \
    assign `SAHB_VIP_TOP.haddr  = `AHB_BUS.haddr``M_NUM ; \
    assign `SAHB_VIP_TOP.hwrite = `AHB_BUS.hwrite``M_NUM ; \
    assign `SAHB_VIP_TOP.hburst = `AHB_BUS.hburst``M_NUM ; \
    assign `SAHB_VIP_TOP.htrans = `AHB_BUS.htrans``M_NUM ; \
    assign `SAHB_VIP_TOP.hsize  = `AHB_BUS.hsize``M_NUM ; \
    assign `SAHB_VIP_TOP.hprot  = `AHB_BUS.hprot``M_NUM ; \
    assign `SAHB_VIP_TOP.hwdata = `AHB_BUS.hwdata``M_NUM ; \
    assign `SAHB_VIP_TOP.hready = `AHB_BUS.hready``M_NUM ; \
    initial begin \
        force `AHB_BUS.hgrant_``M_NUM = `SAHB_VIP_TOP.hgrant_m``M_NUM ;  \
        force `AHB_BUS.hrdata_``M_NUM = `SAHB_VIP_TOP.i_hrdata ; \
        force `AHB_BUS.hresp_``M_NUM  = `SAHB_VIP_TOP.i_hresp  ; \
        force `AHB_BUS.hlock_``M_NUM  = `SAHB_VIP_TOP.i_hlock  ; \
    end \


    `BIND_M(1) ;
    `BIND_M(2) ;
    `BIND_M(3) ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
