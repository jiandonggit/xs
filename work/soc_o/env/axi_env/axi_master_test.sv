/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_master_test.sv
 * Author : dongj
 * Create : 2022-12-26
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/26 19:13:19
 * Description: 
 * 
 */

`ifndef __AXI_MASTER_TEST_SV__
`define __AXI_MASTER_TEST_SV__

program automatic axi_master_test #(type T=axi_master_base_gen, parameter B_ID=0, parameter M_ID=0, parameter AXI_LENGTH_WM_IDTH=8) (ctrl_intf u_ctrl_intf, axi_xact_intf u_xact_intf, ddr_intf u_mem_intf) ;
    T u_xact_gen ;
    axi_master_drv #( .B_ID(B_ID), .M_ID(M_ID), .AXI_LENGTH_WM_IDTH(AXI_LENGTH_WM_IDTH) ) u_xact_drv ;
    axi_master_mon #( .B_ID(B_ID), .M_ID(M_ID), .AXI_LENGTH_WM_IDTH(AXI_LENGTH_WM_IDTH) ) u_xact_mon ;
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
