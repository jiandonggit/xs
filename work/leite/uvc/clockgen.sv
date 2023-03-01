/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : clockgen.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 16:37:30
 * Description: 
 * 
 */

`ifndef __CLOCKGEN_SV__
`define __CLOCKGEN_SV__

`timescale 100fs/1fs

module clockgen ( output reg clk, rstn);
    parameter FREQ = 24 ;
    parameter RSTN = 100 ;

    reg [15:0] cnt ;
    reg [24:0] half ;

    initial begin
        clk = 1'b0 ;
        rstn = 1'b0 ;
        cnt = 16'd0 ;
    end

    initial begin
        half = 10000000.00/FREQ/2.00 ;
        forever #(half) clk <= ~clk ;
    end

    always @(posedge clk) begin
        if (cnt < RSTN) begin
            cnt <= cnt + 16'd1 ;
            rstn <= 1'b0 ;
        end
        else begin
            rstn <= 1'b1 ;
        end
    end
    
endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
