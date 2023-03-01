/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_sub_trans.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 10:49:16
 * Description: 
 * 
 */

`ifndef __AHB_SUB_TRANS_SV__
`define __AHB_SUB_TRANS_SV__

class ahb_sub_trans ;
    // data or class properties
    string                  name = ""  ;
    rand bit [2:0]          bus_id ;
    rand bit [3:0]          master_id ;
    rand bit                sub_master_en ; 
    rand bit [7:0]          sub_master_id ;
    rand bit [31:0]         sub_base_addr ;
    rand bit [31:0]         sub_end_addr ;
    rand xact_mode_e        sub_xact_mode ;
    rand op_type_e          sub_op_type ;
    rand bit [15:0]         sub_burst_id ;
    rand bit [2:0]          sub_burst_type ;
    rand bit [3:0]          sub_burst_size ;
    rand bit [7:0]          sub_burst_len ;
    rand bit [31:0]         sub_burst_wait_num ;
    rand bit [31:0]         sub_start_point ;

    rand bit [31:0]         sub_fps ;
    rand bit [31:0]         sub_width ;
    rand bit [31:0]         sub_height ;
    rand bit [31:0]         sub_dummy_h ;
    rand bit [31:0]         sub_dummy_v ;
    rand bit [31:0]         sub_mb_width ;
    rand bit [31:0]         sub_mb_height ;
    rand bit [31:0]         sub_data_amount ;
    rand bit [31:0]         sub_data_ratio ;
    rand                    real_sub_data_ratio ;

    rand int FREQ ;
    rand int sub_random_en ;

    rand bit [31:0] rand_burst_interval ;
    rand bit [31:0] rand_burst_wait_num ;

    real one_line_time ;
    bit [31:0] one_line_cycles ;
    bit [31:0] one_line_transfers ;
    bit [31:0] one_line_bursts ;

    bit [31:0] burst_interval ;
    bit [31:0] burst_wait_num ;
    bit [31:0] burst_nums ;
    bit [31:0] burst_boundle_nums ;

    int sub_left_len ;
    rand int local_burst_len ;

    int loc_width_amount ;

    constraint base_cst {
        sub_start_point inside {[0:100000000]}

        sub_burst_len inside {[1:16]) ;
        if (sub_random_en) {
            rand_burst_wait_num inside {[0:100]} ; 
        }
        local_burst_len == sub_burst_len ;
    }

    // initialization
    function new();
    endfunction : new

    function void post_randomize() ;
        begin
            sub_end_addr = sub_end_addr - 'h100 ;
            real_sub_data_ratio = sub_data_ratio / 1000.0 ;
            loc_width_amount = sub_width * real_sub_data_ratio ;
            if (sub_xact_mode == LINE) begin
                one_line_time = 1.00*10**9/sub_fps/(sub_height+sub_dummy_v) ;
                one_line_cycles = one_line_time*FREQ/1000 ;
                one_line_transfers = loc_width_amount/(2**sub_burst_size) ;
                one_line_bursts = one_line_transfers / local_burst_len ;

                burst_interval      = one_line_cycles ;
                burst_wait_num      = sub_burst_wait_num ;
                burst_nums          = one_line_bursts ;
                burst_boundle_nums  = sub_height ;

                if (loc_width_amount != burst_nums*local_burst_len*(2**sub_burst_size)) begin
                    sub_left_len = (loc_width_amount - burst_nums*local_burst_len*(2**sub_burst_size))/(2**sub_burst_size) ;
                end
                else begin
                    sub_left_len = 'hDEAD ;
                end
            end
            else if (sub_xact_mode = MACRO) begin
                one_line_time = 1.00*10**9/sub_fps/(loc_width_amount*sub_height/(sub_mb_width*sub_mb_height)) ;
                one_line_cycles = one_line_time*FREQ/1000;
                one_line_transfers = sub_mb_width*sub_mb_height/(2**sub_burst_size) ;
                one_line_bursts = one_line_transfers / local_burst_len ;

                burst_interval  = one_line_cycles ;
                burst_nums      = one_line_bursts ;
                burst_wait_num  = sub_burst_wait_num ;
                burst_boundle_nums = loc_width_amount * sub_height / (sub_mb_width*sub_mb_height) ;
                if (sub_mb_width*sub_mb_height != burst_nums*local_burst_len*(2**sub_burst_size)) begin
                    sub_left_len = (sub_mb_width*sub_mb_height - burst_nums*local_burst_len*(2**sub_burst_size)) / (2**sub_burst_size) ;
                end
                else begin
                    sub_left_len = 'hDEAD ;
                end
            end
            else if (sub_xact_mode == STREAM) begin
                one_line_time = 1.00*10**9/sub_fps ;
                one_line_cycles = one_line_time*FREQ/1000 ;
                one_line_transfers = sub_data_amount*real_sub_data_ratio/(2**sub_burst_size) ;
                one_line_bursts = one_line_transfers/local_burst_len ;
                
                burst_interval = one_line_cycles ;
                burst_nums     = one_line_bursts ;
                burst_wait_num = one_line_cycles/one_line_bursts ;
                burst_boundle_nums = 1 ;
                if (sub_data_amount*real_sub_data_ratio != burst_nums*local_burst_len*(2**sub_burst_size)) begin
                    sub_left_len = (sub_data_amount*real_sub_data_ratio - burst_nums*local_burst_len*(2**sub_burst_size)) / (2**sub_burst_size) ;
                end
                else begin
                    sub_left_len = 'hDEAD ;
                end
            end
            else begin
                $display("%m: FAIL UNKNOWN XACT MODE @%0t", , realtime) ;
            end

            if (sub_random_en) begin
                one_line_time = 1.00*10**9/sub_fps/(sub_height+sub_dummy_v) ;
                one_line_cycles = one_line_time*FREQ/1000 ;

                burst_interval      = one_line_cycles ;
                burst_nums          = sub_width ;
                burst_wait_num      = rand_burst_wait_num ;
                burst_boundle_nums  = sub_height ;
                sub_left_len = 'hDEAD ;
            end

            disp(0) ;
        end
        
    endfunction : post_randomize

    function disp (bit disp_en) ;
        if (disp_en) begin
            $display("%m: ahb_sub_master_trans MSG : @%0t", , realtime) ;
            $display("%m: sub_random_en     : %0d", sub_master_en) ;
            $display("%m: bus_id            : %0d", bus_id) ;
            $display("%m: master_id         : %0d", master_id) ;
            $display("%m: sub_master_id     : %0d", sub_master_id) ;
            $display("%m: sub_base_addr     : %0d", sub_base_addr) ;
            $display("%m: sub_end_addr      : %0d", sub_end_addr) ;
            $display("%m: sub_xact_mode     : %0d", sub_xact_mode) ;
            $display("%m: sub_op_type       : %0d", sub_op_type) ;
            $display("%m: sub_burst_id      : %0d", sub_burst_id) ;
            $display("%m: sub_burst_len     : %0d", sub_burst_len) ;
            $display("%m: sub_left_len      : %0d", sub_left_len) ;
            $display("%m: sub_burst_wait_num: %0d", sub_burst_wait_num) ;
            $display("%m: sub_start_point   : %0d", sub_start_point) ;
            $display("%m: sub_fps           : %0d", sub_fps) ;
            $display("%m: sub_width         : %0d", sub_width) ;
            $display("%m: sub_height        : %0d", sub_height) ;
            $display("%m: sub_dummy_h       : %0d", sub_dummy_h) ;
            $display("%m: sub_dummy_v       : %0d", sub_dummy_v) ;
            $display("%m: sub_mb_width      : %0d", sub_mb_width) ;
            $display("%m: sub_mb_height     : %0d", sub_mb_height) ;
            $display("%m: sub_data_amount   : %0d", sub_data_amount) ;
            $display("%m: sub_data_ratio    : %0d", sub_data_ratio) ;
            $display("%m: burst_interval    : %0d", burst_interval) ;
            $display("%m: burst_wait_num    : %0d", burst_wait_num) ;
            $display("%m: burst_nums        : %0d", burst_nums) ;
            $display("%m: burst_boundle_nums: %0d", burst_boundle_nums) ;
            $display("\n") ;
        end
        
    endfunction : disp
endclass : ahb_sub_trans 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
