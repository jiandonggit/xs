/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_trans.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 10:47:32
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_TRANS_SV__
`define __AHB_MASTER_TRANS_SV__

class ahb_master_trans ;
    // data or class properties
    rand ahb_sub_trans sub_trans[] ;
    rand bit [2:0] bus_id ;
    rand bit [3:0] master_id ;
    string name = "" ;
    rand bit master_en ;
    rand bit [31:0] outstanding_num ;
    rand bit [31:0] base_addr ;

    rand bit wdata_pre_enable ;
    rand bit wstrb_all_zero ;

    bit [31:0] sub_master_present ;

    // initialization
    function new(int sub_master_present, string name = "");
        begin
            this.sub_master_present = sub_master_present ;
            this.name = name ;
            $display("%m: sub_master_present : %0d @%0t", sub_master_present, realtime) ;
        end
    endfunction : new

    function void pre_randomize() ;
        begin
            $display("%m: PRE RANDOMIZE @%0t", , realtime) ;
            sub_trans = new[sub_master_present] ;
            foreach ( sub_trans[i] ) begin
                sub_trans[i] = new() ; 
            end
        end
    endfunction : pre_randomize

    function void post_randomize() ;
        begin
            disp(master_en) ;
        end
    endfunction : post_randomize

    function disp(bit disp_en) ;
        if (disp_en) begin
            $display("%m: axi_master_trans MSG : @%0t", realtime) ;
            $display("%m: bus_id    : %0d", bus_id) ;
            $display("%m: master_id : %0d", master_id) ;
            $display("%m: ots_num   : %0d", outstanding_num) ;
            $display("%m: wdata_pre : %0d", wdata_pre_enable) ;
            $display("%m: wstrb     : %0d", wstrb_all_zero) ;
            $display("%m: sub_num   : %0d", sub_master_present) ;
            $display("    \n") ;
        end
    endfunction : disp 

endclass : axi_master_trans 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
