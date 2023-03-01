/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : example.sv
 * Author : dongj
 * Create : 2023-01-10
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/10 19:39:04
 * Description: 
 * 
 */

`ifndef __EXAMPLE_SV__
`define __EXAMPLE_SV__

module example ();
    `include "data_skew_measure.sv"

    data_skew_measure psram_skew = new("DQ_RWDS", 0.5ns) ; // skew < 0.5ns , data valid window > 0.5ns

    final psram_skew.display() ;

    reg  [17:0] psram_pre ;
    wire [17:0] psram_curr = {`PSRAM_PHY.b_mem_pad_rwds, `PSRAM_PHY.b_mem_pad_dq} ;

    // example 1 : include first stable data
    always @(psram_curr) begin
        if (~`PSRAM_PHY.o_mem_pad_csn && ! $isunknown(psram_curr) ) begin
            psram_skew.sample() ;
        end
    end

    // example 2 : ignore first stable data
    always @(psram_curr) begin
        if (~`PSRAM_PHY.o_mem_pad_csn && ! $isunknown({psram_pre,psram_curr})) begin
            psram_skew.sample() ;
        end
        psram_pre = psram_curr ;
    end

endmodule

module example_tsu() ;
    `include "data_skew_measure.sv"
    `include "tsu_thd_measure.sv"
    tsu_thd_measure vo_skew = new("VO_DATA", 1ns) ;
    always @(VO_HS or 
             VO_VS or 
             VO_D0 or
             VO_D1 ) begin
        if( ! $isunknown( { VS,HS,D0,D1 } ) begin
            vo_skew.sample() ;
        end
    end
    initial begin
        forever begin
            @(proj_top.vo_out_clk_through_dphy_ttl) ;
            vo_skew.calc_tsu_thd() ;
        end
    end


`endif

// vim: et:ts=4:sw=4:ft=sverilog
