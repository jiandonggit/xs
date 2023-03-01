/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_axi_test.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 19:56:09
 * Description: 
 * 
 */

`ifndef __XACT_AXI_TEST_SV__
`define __XACT_AXI_TEST_SV__


program automatic xact_axi_test #(type T=perf_axi_trans, type T0=axi_base_trans) (xact_axi_intf u_xact_intf) ;
    string file_name = "perf_msg" ;
    integer file_handle ;

    xact_axi_mon #(T0) u_xact_mon ;
    xact_axi_main#(T, T0) u_xact_main ;
    mailbox u_mbx_trans ;
    mailbox u_mbx_time ;

    initial begin
        u_mbx_trans = new(0) ;
        u_xact_mon = new(u_mbx_trans, u_xact_intf) ;
        u_xact_main= new(u_mbx_trans, u_xact_intf) ;

        $display("%m: ALL CONFIG DONE, START TO RUN TB @%0t", realtime) ;

        fork
            u_xact_mon.body() ;
            u_xact_main.body() ;
        join    

        wait(0) ;
    end

    final begin
        string msg ;
        file_handle = $fopen($sformatf("%s_perf_msg.txt", u_xact_intf.type_id), "w") ;
        msg = u_xact_main.get().disp_attr("xact_axi_test") ;
        $fwrite(file_handle, "%s\n", msg) ;
    end

endprogram : xact_axi_test

`endif

// vim: et:ts=4:sw=4:ft=sverilog
