/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_test.sv
 * Author : dongj
 * Create : 2022-12-26
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/26 19:13:19
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_TEST_SV__
`define __AHB_MASTER_TEST_SV__

program automatic ahb_master_test #(type T=ahb_master_base_gen) (ctrl_intf u_ctrl_intf, ahb_xact_intf u_xact_intf, ddr_intf u_mem_intf) ;
    T u_xact_gen ;
    ahb_master_drv u_xact_drv ;
    ahb_master_mon u_xact_mon ;
    mailbox u_mbx ;
    mailbox u_drv2mon_mbx ;

    initial begin
        u_mbx = new(1) ;
        u_drv2mon_mbx =new(1) ;
        u_xact_drv = new(u_mbx, u_drv2mon_mbx, u_xact_intf, u_ctrl_intf) ;
        u_xact_mon = new(u_drv2mon_mbx, u_xact_intf, u_ctrl_intf, u_mem_intf) ;

        u_ctrl_intf.wait_init_done() ;
        u_xact_intf.wait_init_done() ;

        $display("%m: ALL CONFIG DONE, START TO RUN TB @%0t\n", realtime) ;

       
        fork
            u_xact_gen.body() ;
            u_xact_drv.body() ;
            u_xact_mon.body() ;
        join    
        wait(0) ;
    end

    final begin
        u_xact_mon.write_compare() ;
    end

endprogram : program_name


`endif

// vim: et:ts=4:sw=4:ft=sverilog
