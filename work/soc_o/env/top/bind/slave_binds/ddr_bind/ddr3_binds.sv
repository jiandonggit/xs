/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr3_binds.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 17:58:15
 * Description: 
 * 
 */

`ifndef __DDR3_BINDS_SV__
`define __DDR3_BINDS_SV__

bind u_ddr_top ddr3 u0_ddr3 (
    
    .rst_n         (ddr_rst_n    ) ,
    .ck            (ddr_ck       ) ,
    .ckn           (ddr_ckn      ) ,
    .cke           (ddr_cke      ) ,
    .cs_n          (ddr_cs_n     ) ,
    .ras_n         (ddr_ras_n    ) ,
    .cas_n         (ddr_address[17]) ,
    .we_n          (ddr_address[16]) ,
    .addr          (ddr_address[15:0]) ,
    .dm_tdqs       (ddr_ddr_dm   ) ,
    .ba            (ddr_bank     ) ,
    .dq            (ddr_dq       ) ,
    .dqs           (ddr_dqs      ) ,
    .dqs_n         (ddr_dqsb     ) ,
    .odt           (ddr_odt      ) ,
    .tdqs_n        ()
    ) ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
