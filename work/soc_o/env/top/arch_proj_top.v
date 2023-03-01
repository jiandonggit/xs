/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : arch_proj_top.v
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 16:15:12
 * Description: 
 * 
 */

`ifndef __ARCH_PROJ_TOP_V__
`define __ARCH_PROJ_TOP_V__

module arch_proj_top ();

    wire osc_clk ;
    wire sys_rstn ;

    reg osc_clk_reg ;
    reg ext_rst_n_reg ;

    assign osc_clk = osc_clk_reg ;
    assign sys_rstn = ext_rst_n_reg ;

    initial begin
        osc_clk_reg = 0 ;
        ext_rst_n_reg = 0 ;
        #500ns ;
        ext_rst_n_reg = 1 ;
    end

    always #20.833 osc_clk_reg = ~osc_clk_reg ; 

    `include "rtl_instance.v"
    `include "ddr_bind.v"
    
endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
