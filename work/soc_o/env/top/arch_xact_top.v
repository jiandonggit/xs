/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : arch_xact_top.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 16:17:52
 * Description: 
 * 
 */

`ifndef __ARCH_XACT_TOP_V__
`define __ARCH_XACT_TOP_V__


module arch_xact_top ();
    parameter ADDR_WIDTH = 32 ;
    parameter DATA_WIDTH = 64 ;
    parameter LEN_WIDTH = 6 ;
    parameter ID_WIDTH = 16 ;

    event xact_done ;
    `include "mem_task_wrap.v"
    `include "xact_instance.v"
    `include "arch_binds.svh"
    `include "arch_common_rw_task.svh"
    `include "ddr_init.sv"

    initial begin
        bit [31:0] rd_data ;
        `ifndef INTEGERATE_TO_OTHERS
            u_ctrl_intf.insert_delay(1000) ;
            ddr_init("3", "1600") ;
        `else
            wait(`INIT_DONE) ;//other tb init
        `endif

        u_ctrl_intf.insert_delay(100) ;

        u_ctrl_intf.init_done = 1 ;
    end

    `ifndef INTEGERATE_TO_OTHERS
        initial begin
            u_ctrl_intf.wait_init_done() ;
            u_ctrl_intf.wait_run_start() ;
            u_ctrl_intf.wait_run_done() ;
            u_ctrl_intf.insert_delay(500000) ;
            $finish ;
        end

        `ifdef DUMP_WAVE
            initial begin
                $fsdbAutoSwitchDumpfile(1024,"soc_arch.fsdb", 20, "fsdbdump.log") ;
                $fsdbDumpvarsByFile("./wave_dump.h") ;
            end
        `endif
    `endif
    
endmodule

`endif

// vim: et:ts=4:sw=4:ft=sverilog
