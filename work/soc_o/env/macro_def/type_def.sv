/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : type_def.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 15:09:37
 * Description: 
 * 
 */

`ifndef __TYPE_DEF_SV__
`define __TYPE_DEF_SV__

    typedef enum {OP_READ, OP_WRITE} op_type_e ;
    typedef enum {LINE, MACRO, STREAM, FREE} xact_mode_e ;
    typedef enum { int count ;
                   real cur_time ;
                 } addr_mon_s ;


`endif

// vim: et:ts=4:sw=4:ft=sverilog
