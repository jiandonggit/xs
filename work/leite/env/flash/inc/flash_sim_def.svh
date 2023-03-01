/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flash_sim_def.svh
 * Author : dongj
 * Create : 2023-01-03
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/03 19:11:18
 * Description: 
 * 
 */

`ifndef __FLASH_SIM_DEF_SVH__
`define __FLASH_SIM_DEF_SVH__

`define FLASH_BASE          32'h0800_0000
`define FLASH_MAIN_BASE     32'h0800_0000
`define FLASH_INFO_BASE     32'h1FFF_F000
`define FLASH_TRM_BASE      32'h1FFF_F000
`define FLASH_OPT_BASE      32'h1FFF_FE00
`define FLASH_WRP_BASE      32'h1FFF_FE08
`define FLASH_RDP_BASE      32'h1FFF_FE00
`define FLASH_FSF_BASE      32'h1FFF_FC00

`define FLASH_SECT_PAGES    2
`define FLASH_BANK_PAGES    256
`define FLASH_MAIN_PAGES    256
`define FLASH_INFO_PAGES    16

`define FLASH_PAGE_SIZE     256 // byte
`define FLASH_SECT_SIZE     (`FLASH_PAGE_SIZE*`FLASH_SECT_PAGES)
`define FLASH_BANK_SIZE     (`FLASH_PAGE_SIZE*`FLASH_BANK_PAGES)
`define FLASH_MAIN_SIZE     (`FLASH_PAGE_SIZE*`FLASH_MAIN_PAGES)
`define FLASH_INFO_SIZE     (`FLASH_PAGE_SIZE*`FLASH_INFO_PAGES)
`define FLASH_SIZE          `FLASH_MAIN_SIZE

`define FLASH_PAGE_MASK     (`FLASH_PAGE_SIZE-1) 
`define FLASH_SECT_MASK     (`FLASH_SECT_SIZE-1)
`define FLASH_BANK_MASK     (`FLASH_BANK_SIZE-1)
`define FLASH_MAIN_MASK     (`FLASH_MAIN_SIZE-1)
`define FLASH_INFO_MASK     (`FLASH_INFO_SIZE-1)

`define FLASH_BANK_SECTORS  (`FLASH_BANK_SIZE/`FLASH_SECT_SIZE) 
`define FLASH_MAIN_SECTORS  (`FLASH_MAIN_SIZE/`FLASH_SECT_SIZE) 
`define FLASH_INFO_SECTORS  (`FLASH_INFO_SIZE/`FLASH_SECT_SIZE) 

`define FLASH_OPT_PAGE      ((`FLASH_OPT_BASE&`FLASH_INFO_MASK)/`FLASH_PAGE_SIZE)
`define FLASH_TRM_PAGE      ((`FLASH_TRM_BASE&`FLASH_INFO_MASK)/`FLASH_PAGE_SIZE)
`define FLASH_RDP_PAGE      ((`FLASH_RDP_BASE&`FLASH_INFO_MASK)/`FLASH_PAGE_SIZE)
`define FLASH_FSF_PAGE      ((`FLASH_FSF_BASE&`FLASH_INFO_MASK)/`FLASH_PAGE_SIZE)
`define FLASH_OPT_SECTOR    (`FLASH_OPT_PAGE/`FLASH_SECT_PAGES)
`define FLASH_TRM_SECTOR    (`FLASH_TRM_PAGE/`FLASH_SECT_PAGES)
`define FLASH_RDP_SECTOR    (`FLASH_RDP_PAGE/`FLASH_SECT_PAGES)
`define FLASH_FSF_SECTOR    (`FLASH_FSF_PAGE/`FLASH_SECT_PAGES)

`define FLASH_MEM_WIDTH     32
`define FLASH_PAGE_DEPTH    (`FLASH_PAGE_SIZE/(`FLASH_MEM_WIDTH/8))
`define FLASH_SECT_DEPTH    (`FLASH_SECT_SIZE/(`FLASH_MEM_WIDTH/8))
`define FLASH_BANK_DEPTH    (`FLASH_BANK_SIZE/(`FLASH_MEM_WIDTH/8))
`define FLASH_MAIN_DEPTH    (`FLASH_MAIN_SIZE/(`FLASH_MEM_WIDTH/8))
`define FLASH_INFO_DEPTH    (`FLASH_INFO_SIZE/(`FLASH_MEM_WIDTH/8))
`define FLASH_MEM_AWIDTH    $clog2(`FLASH_MAIN_DEPTH) 
`define FLASH_ADDR_WIDTH    $clog2(`FLASH_MAIN_SIZE)

`define FLASH_CTRL_BASE     32'h4002_2000
`define FLASH_CTRL_SIZE     'h30

`define FLASH_OPT_NUM       5

`define FLASH_RDP_RET       1 //read value for rdp
`define FLASH_MEM_DEFVAL   '1 // init value
`define FLASH_HAS_CFG
`define FLASH_CFG_SIZE      `FLASH_SECT_SIZE

`define FLASH_PG_TIME       32'd42
`define FLASH_ONE_PG_MAX_TIME   32'd3000
`define FLASH_ONE_PG_MAX_CNT    `FLASH_ONE_PG_MAX_TIME/`FLASH_PG_TIME

`define SVT_AHB_INCLUDE_USER_DEFINES // svt_ahb_user_defines.svi will be included by svt_ahb_port_define.svi

`define STDCELL_FUNCTIONAL

`include "fork_timer_define.svh"




`endif

// vim: et:ts=4:sw=4:ft=sverilog
