/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : fork_timer_define.svh
 * Author : dongj
 * Create : 2023-01-03
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/03 19:34:30
 * Description: 
 * 
 */

`ifndef __FORK_TIMER_DEFINE_SVH__
`define __FORK_TIMER_DEFINE_SVH__

// trigger timeout when expr done
// level verbosity UVM_LOW ...
// id custom report id 
// msg curstom report msg
// hdlr post callback hdlr
//
`define uvm_timer_begin(expr,level=UVM_LOW,id="uvm_timer_default_id",msg="timeout!",hdlr=) \
fork begin\
    `uvm_info("uvm_timer_begin",id,UVM_DEBUG) \
    fork begin \
        expr ; \
        if (`"level`" != "UVM_NONE") begin\
            if (level >= UVM_LOW && uvm_report_enabled(level,UVM_INFO,id)) begin\
                uvm_report_info(id,msg,level,`uvm_file,`uvm_line);\
            end \
            else if (level <= UVM_FATAL) begin
                uvm_report(level,id,msg,UVM_NONE,`uvm_file,`uvm_line);\
            end\
        end\
        hdlr ;\ 
    end begin

`define uvm_timer_end \ 
    end join_any \
    disable fork ; \
    `uvm_info("uvm_timer_end","",UVM_DEBUG) \
end join    

//
`define fork_timer_begin(expr,msg="timeout!",hdlr=) \
fork begin \
`ifdef FORK_TIMER_DEBUG \
    $display("%m: fork_timer_begin @%0t", $realtime) ; \
`endif \
    fork begin \
        expr ; \
        $display("%m: %s @%0t", msg, $realtime) ; \
        hdlr ; \
    end begin 


`define fork_timer_end \
    end join_any \
    disable fork ; \
`ifdef FORK_TIMER_DEBUG \
    $display("%m: fork_timer_end @%0t", $realtime) ;
`endif\
end join

//Example :
//
/*
* task timeout_handler() ;
*   // do something here if timeout 
* endtask
*
* // invoke timeout_handler task if timeout
* `uvm_timer_begin(#1us,UVM_LOW,"test_id","timer detected", timeout_handler)
*     process_1 ;
* `uvm_timer_end
*
* // throw error if timeout
* `uvm_timer_begin(@Event,UVM_ERROR)
*     process_2 ;
* `uvm_timer_end
*
* // default, only UVM_INFO message if timeout
* `uvm_timer_begin(#1ms)
*     process_3 ;
* `uvm_timer_end
*


`endif

// vim: et:ts=4:sw=4:ft=sverilog
