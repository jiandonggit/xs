/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_xact_trans.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 10:52:10
 * Description: 
 * 
 */

`ifndef __AHB_XACT_TRANS_SV__
`define __AHB_XACT_TRANS_SV__

class ahb_xact_trans ;
    // data or class properties
    rand bit [31:0] op_addr ;
    rand op_type_e  op_type ;
    rand bit [7:0]  op_len ;
    rand bit [15:0] op_id ;
    rand bit [7:0]  op_burst ;
    rand bit [3:0]  op_size ;
    rand bit [63:0] op_wdata[] ;
    rand bit [63:0] op_rdata[] ;
    real cur_time ;

    constraint size_cst {
        op_rdata.size() == op_len ;
        op_wdata.size() == op_len ;
    }

    // initialization
    function new();
    endfunction : new

    //function void post_randomize() ;
    //    foreach ( op_wdata[i] ) begin
    //        op_wdata[i] = {op_addr+i*(2**op_size), op_addr+i*(2**op_size)} ;
    //    end
    //    foreach ( op_rdata[i] ) begin
    //        op_rdata[i] = 0 ;
    //    end
    //endfunction : post_randomize

    function disp(bit disp_en, string tag="") ;
        if (disp_en) begin
            $display("%m: %s , ahb_xact_trans MSG : @%0t", tag, realtime) ;
            $display("%m: %s , op_addr  : %0x", tag, op_addr) ;
            $display("%m: %s , op_type  : %0x", tag, op_type.name()) ;
            $display("%m: %s , op_len   : %0x", tag, op_len) ;
            $display("%m: %s , op_id    : %0x", tag, op_id) ;
            $display("%m: %s , op_burst : %0x", tag, op_burst) ;
            $display("%m: %s , op_size  : %0x", tag, op_size) ;
            foreach (op_wdata[i]) begin
                $display("%m: %s , op_wdata[%0d] : %0x ", tag, i, op_wdata[i]) ;
            end
            $display("\n") ;
        end
        
    endfunction : disp

endclass : ahb_xact_trans 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
