/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ddr_vip_bind.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 18:04:20
 * Description: 
 * 
 */

`ifndef __DDR_VIP_BIND_SV__
`define __DDR_VIP_BIND_SV__

import svt_uvm_pkg::* ;
import svt_mem_uvm_pkg::*;
`include "svt_ddr3_catalog.svi"
`include "svt_ddr_defines.svi"

parameter DDR_PART_NUM = "jedec_ddr3_2G_x16_1866L_1_23"

bind u_ddr_top svt_ddr3_agent_hdl vip_ddr3(
    .CK            (ddr_ck       ) ,
    .CK_n          (ddr_ckn      ) ,
    .RESET         (ddr_rst_n    ) ,
    .CKE           (ddr_cke      ) ,
    .CS            (ddr_cs_n     ) ,
    .RAS           (ddr_ras_n    ) ,
    .CAS           (ddr_address[17]) ,
    .WE            (ddr_address[16]) ,
    .A             (ddr_address[15:0]) ,
    .DM            (ddr_ddr_dm   ) ,
    .BA            (ddr_bank     ) ,
    .DQ            (ddr_dq       ) ,
    .DQS           (ddr_dqs      ) ,
    .DQS_n         (ddr_dqsb     ) ,
    .ODT           (ddr_odt      ) );

    task init_vip_ddr ();
        string      ddr_part_number ;
        logic       is_valid ;
        string      prop_name ;
        integer     cfg_handle ;
        int         array_ix ;

        ddr_part_number = DDR_PART_NUM ;
        is_valid = 0 ;
        `DDR_TOP.vip_ddr3.get_data_prop(is_valid, `SVT_CMD_NULL_HANDLE, "cfg", cfg_handle, 0) ;
        if (!is_valid) begin
            $display("%m: SET PART_NUM FAIL @%0t", realtime) ;
        end

        is_valid = 0 ;
        `DDR_TOP.vip_ddr3.cmd_mem_load_part_cfg(is_valid, `SVT_DDR_CMD_CATALOG_DDR3, `SVT_DDR_CMD_CATALOG_PACKAGE_DRAM, `SVT_DDR_CMD_CATALOG_VENDOR_JEDEC, ddr_part_number) ;

        is_valid = 0 ;
        `DDR_TOP.vip_ddr3.get_data_prop(is_valid, `SVT_CMD_NULL_HANDLE, "cfg", cfg_handle, 0) ;

        is_valid = 0 ;
        `DDR_TOP.vip_ddr3.display_data(is_valid, cfg_handle, "------") ;
        `DDR_TOP.vip_ddr3.start() ;

        is_valid = 0 ;
        `DDR_TOP.vip_ddr3.cmd_mem_initialize(is_valid, `SVT_MEM_INIT_ZEROES, 0, 0, 'h1fff_ffff) ;
        
    endtask: init_vip_ddr 

    initial begin
        #1ns ;
        init_vip_ddr() ;
    end

`endif

// vim: et:ts=4:sw=4:ft=sverilog
