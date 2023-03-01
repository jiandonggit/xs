/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor_top.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 11:11:18
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_TOP_SV__
`define __AXI_MONITOR_TOP_SV__

module axi_monitor_top ();
    input ref_clk ,
    input rst_n 
) ;
    `include "axi_monitor_config.svh"

    string init_mode_sel = "sanity" ;
    
    reg         addr_range_check_en ;
    reg [31:0]  m1_addr_rang_min ;
    reg [31:0]  m1_addr_rang_max ;
    reg [31:0]  m2_addr_rang_min ;
    reg [31:0]  m2_addr_rang_max ;

    reg [31:0]  ref_clock_int_10ns ;
    reg [31:0]  ref_clock_int_100ns; 
    reg [31:0]  ref_clock_int_500ns ;
    reg [31:0]  ref_clock_int_1000ns ;
    reg [31:0]  ref_clock_int_10000ns; 

    reg sample_sync_ns_10ns ;
    reg sample_sync_ns_100ns ;
    reg sample_sync_ns_500ns ;
    reg sample_sync_ns_1000ns ;
    reg sample_sync_ns_10000ns ;

    reg sample_sync_ns_10ns_d ;
    reg sample_sync_ns_100ns_d ;
    reg sample_sync_ns_500ns_d ;
    reg sample_sync_ns_1000ns_d ;
    reg sample_sync_ns_10000ns_d ;

    reg sample_sync_ns_10ns_edge ;
    reg sample_sync_ns_100ns_edge ;
    reg sample_sync_ns_500ns_edge ;
    reg sample_sync_ns_1000ns_edge ;
    reg sample_sync_ns_10000ns_edge ;

    reg [2:0] ref_clk_sync_sys_rst_n ;

    wire ref_clk_rst_n ;

    wire ref_clock_cnt_clr_10ns ;
    wire ref_clock_cnt_clr_100ns ;
    wire ref_clock_cnt_clr_500ns ;
    wire ref_clock_cnt_clr_1000ns ;
    wire ref_clock_cnt_clr_10000ns ;

    assign ref_clk_rst_n = ref_clk_sync_sys_rst_n[2] ;

    wire ref_clock_cnt_clr_10ns    = (SAMPLE_CNT_NS_10     - 1 <= ref_clock_cnt_10ns     ) ? 1'b1 : 1'b0 ;
    wire ref_clock_cnt_clr_100ns   = (SAMPLE_CNT_NS_100    - 1 <= ref_clock_cnt_100ns    ) ? 1'b1 : 1'b0 ;
    wire ref_clock_cnt_clr_500ns   = (SAMPLE_CNT_NS_500    - 1 <= ref_clock_cnt_500ns    ) ? 1'b1 : 1'b0 ;
    wire ref_clock_cnt_clr_1000ns  = (SAMPLE_CNT_NS_1000   - 1 <= ref_clock_cnt_1000ns   ) ? 1'b1 : 1'b0 ;
    wire ref_clock_cnt_clr_10000ns = (SAMPLE_CNT_NS_10000  - 1 <= ref_clock_cnt_10000ns  ) ? 1'b1 : 1'b0 ;

    always @(posedge ref_clk or negedge rst_n) begin
        if (!rst_n) begin
            ref_clk_sync_sys_rst_n <= 3'b0 ;
        end
        else begin
            ref_clk_sync_sys_rst_n <= {ref_clk_sync_sys_rst_n[1:0],1'b1} ;
        end
    end

    always @(posedge ref_clk or negedge ref_clk_rst_n) begin
        if (!ref_clk_rst_n) begin
            ref_clock_int_10ns    <= 32'h0 ;
            ref_clock_int_100ns   <= 32'h0 ;
            ref_clock_int_500ns   <= 32'h0 ;
            ref_clock_int_1000ns  <= 32'h0 ;
            ref_clock_int_10000ns <= 32'h0 ;
        end
        else begin
            if (ref_clock_cnt_clr_10ns) begin
                ref_clock_int_10ns <= 32'h0 ;
            end
            else begin
                ref_clock_int_10ns <= ref_clock_int_10ns + 32'h1 ;
            end
            if (ref_clock_cnt_clr_100ns) begin
                ref_clock_int_100ns <= 32'h0 ;
            end
            else begin
                ref_clock_int_100ns <= ref_clock_int_100ns + 32'h1 ;
            end
            if (ref_clock_cnt_clr_500ns) begin
                ref_clock_int_500ns <= 32'h0 ;
            end
            else begin
                ref_clock_int_500ns <= ref_clock_int_500ns + 32'h1 ;
            end
            if (ref_clock_cnt_clr_1000ns) begin
                ref_clock_int_1000ns <= 32'h0 ;
            end
            else begin
                ref_clock_int_1000ns <= ref_clock_int_1000ns + 32'h1 ;
            end
            if (ref_clock_cnt_clr_10000ns) begin
                ref_clock_int_10000ns <= 32'h0 ;
            end
            else begin
                ref_clock_int_10000ns <= ref_clock_int_10000ns + 32'h1 ;
            end
        end
    end

    always @(posedge ref_clk or negedge ref_clk_rst_n) begin
        if(!ref_clk_rst_n) begin
            sample_sync_ns_10ns    <= 1'b0 ;
            sample_sync_ns_100ns   <= 1'b0 ;
            sample_sync_ns_500ns   <= 1'b0 ;
            sample_sync_ns_1000ns  <= 1'b0 ;
            sample_sync_ns_10000ns <= 1'b0 ;
        end
        else begin
            if(ref_clock_cnt_clr_10ns) 
                sample_sync_ns_10ns <= ~sample_sync_ns_10ns ;
            if(ref_clock_cnt_clr_100ns) 
                sample_sync_ns_100ns <= ~sample_sync_ns_100ns ;
            if(ref_clock_cnt_clr_500ns) 
                sample_sync_ns_500ns <= ~sample_sync_ns_500ns ;
            if(ref_clock_cnt_clr_1000ns) 
                sample_sync_ns_1000ns <= ~sample_sync_ns_1000ns ;
            if(ref_clock_cnt_clr_10000ns) 
                sample_sync_ns_10000ns <= ~sample_sync_ns_10000ns ;
        end
    end

    always @(posedge ref_clk or negedge ref_clk_rst_n) begin
        if (!ref_clk_rst_n) begin
            sample_sync_ns_10ns  <= 1'b0 ;
            sample_sync_ns_100ns   <= 1'b0 ;
            sample_sync_ns_500ns   <= 1'b0 ;
            sample_sync_ns_1000ns  <= 1'b0 ;
            sample_sync_ns_10000ns <= 1'b0 ;
        end
        else begin
            sample_sync_ns_10ns_d    <= sample_sync_ns_10ns     ;
            sample_sync_ns_100ns_d   <= sample_sync_ns_100ns    ;
            sample_sync_ns_500ns_d   <= sample_sync_ns_500ns    ;
            sample_sync_ns_1000ns_d  <= sample_sync_ns_1000ns   ;
            sample_sync_ns_10000ns_d <= sample_sync_ns_10000ns  ;
        end
    end

    assign sample_sync_ns_10ns_edge = sample_sync_ns_10ns ^ sample_sync_ns_10ns_d ;
    assign sample_sync_ns_100ns_edge = sample_sync_ns_100ns ^ sample_sync_ns_100ns_d ;
    assign sample_sync_ns_500ns_edge = sample_sync_ns_500ns ^ sample_sync_ns_500ns_d ;
    assign sample_sync_ns_1000ns_edge = sample_sync_ns_1000ns ^ sample_sync_ns_1000ns_d ;
    assign sample_sync_ns_100000ns_edge = sample_sync_ns_10000ns ^ sample_sync_ns_10000ns_d ;

    initial begin
        if($value$plusargs("INIT_MODE_SEL=%s",init_mode_sel)) begin
            $display("INIT_MODE_SEL = %s", init_mode_sel) ;
        end

        #10;

        case(init_mode_sel)
            "sanity" : begin
                addr_range_check_en = 1'b1 ;
                m1_addr_rang_min = 32'h12E_E000 ;
                m1_addr_rang_max = 32'h133_E000 ;
                m2_addr_rang_min = 32'h133_E000 ;
                m2_addr_rang_max = 32'h167_C000 ;
            end
        endcase
    end

    `include "axi_monitor_master_instance.svh"
    `include "axi_monitor_slave_instance.svh"



    
endmodule



`endif

// vim: et:ts=4:sw=4:ft=sverilog
