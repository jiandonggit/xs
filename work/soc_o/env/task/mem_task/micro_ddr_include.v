/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : micro_ddr_include.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 09:32:14
 * Description: 
 * 
 */

`ifndef __MICRO_DDR_INCLUDE_V__
`define __MICRO_DDR_INCLUDE_V__

`ifdef ASIC_DDR
`ifdef DDR4
    `ifndef DDR_HBW
        `ifdef DDR_TOTAL_4GB
            `define ROW addr[31:15]
        `else
            `define ROW addr[30:15]
        `endif
        `define BG addr[5]
        `define BA addr[14:13]
        `define COL {addr[12:6],addr[4:2]}
        `define MEM_RD0 `DDR_MEM0.memory_read
        `define MEM_WR0 `DDR_MEM0.memory_write
        `define MEM_RD1 `DDR_MEM1.memory_read
        `define MEM_WR1 `DDR_MEM1.memory_write
        `define DDR_RD0(rdata) `MEM_RD0(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(rdata))
        `define DDR_WR0(wdata) `MEM_WR0(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(wdata))
        `define DDR_RD1(rdata) `MEM_RD1(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(rdata))
        `define DDR_WR1(wdata) `MEM_WR1(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(wdata))
    `else
        `define ROW addr[29:14]
        `define BG addr[4]
        `define BA addr[13:12]
        `define COL {addr[11:5],addr[3:1]}
        `define MEM_RD0 `DDR_MEM0.memory_read
        `define MEM_WR0 `DDR_MEM0.memory_write
        `define DDR_RD0(rdata) `MEM_RD0(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(rdata))
        `define DDR_WR0(wdata) `MEM_WR0(.bg(`BG),.ba(`BA),.row(`ROW),.col(`COL),.data(wdata))
    `endif
`endif

`ifdef DDR3
    `ifndef DDR_HBW
        `define ROW addr[30:15]
        `define BA addr[14:12]
        `define COL addr[11:2]
        `define MEM_RD0 `DDR_MEM0.memory_read
        `define MEM_WR0 `DDR_MEM0.memory_write
        `define MEM_RD1 `DDR_MEM1.memory_read
        `define MEM_WR1 `DDR_MEM1.memory_write
        `define DDR_RD0(rdata) `MEM_RD0(`BA,`ROW,`COL,rdata)
        `define DDR_WR0(wdata) `MEM_WR0(`BA,`ROW,`COL,wdata)
        `define DDR_RD1(rdata) `MEM_RD1(`BA,`ROW,`COL,rdata)
        `define DDR_WR1(wdata) `MEM_WR1(`BA,`ROW,`COL,wdata)
    `else
        `define ROW addr[30:14]
        `define BA addr[13:11]
        `define COL addr[10:1]
        `define MEM_RD0 `DDR_MEM0.memory_read
        `define MEM_WR0 `DDR_MEM0.memory_write
        `define MEM_RD1 `DDR_MEM1.memory_read
        `define MEM_WR1 `DDR_MEM1.memory_write
        `define DDR_RD0(rdata) `MEM_RD0(`BA,`ROW,`COL,rdata)
        `define DDR_WR0(wdata) `MEM_WR0(`BA,`ROW,`COL,wdata)
        `define DDR_RD1(rdata) `MEM_RD1(`BA,`ROW,`COL,rdata)
        `define DDR_WR1(wdata) `MEM_WR1(`BA,`ROW,`COL,wdata)
    `endif
`endif

`ifdef DDR2
    `ifndef DDR_HBW

    `else
        `ifdef DDR_TOTAL_256MB
            `define ROW addr[27:14]
            `define BA addr[13:11]
            `define COL addr[10:1]
        `else//64MB
            `define ROW addr[25:13]
            `define BA addr[12:11]
            `define COL addr[10:1]
        `endif
        `define MEM_RD0 `DDR_MEM0.memory_read
        `define MEM_WR0 `DDR_MEM0.memory_write
        `define DDR_RD0(rdata) `MEM_RD0(`BA,`ROW,`COL,rdata)
        `define DDR_WR0(wdata) `MEM_WR0(`BA,`ROW,`COL,wdata)
    `endif
`endif

`ifndef DDR_HBW
    task mem_wr_byte(input reg [31:0] addr, input reg [7:0] data);
        parameter DISP_EN = 0 ;
        bit addr_error_flg ;
        reg [127:0] read_data ;
        byte read_data_q[$] ;
        byte rd_data_q[$] ;
        bit [15:0] rd_data_q_2byte[$] ;
        bit [15:0] mem_data[bit [6:0]] ;
        int data_size ;
        reg [127:0] wr_data_0 ;
        reg [127:0] wr_data_1 ;

        `DDR_RD0(read_data) ;
        wr_data_0 = read_data ;
        if (DISP_EN) begin
            $display("%m: RD0 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end
        for (int i = 0; i < 8; i ++) begin
            mem_data[2*i] = read[i*16 +: 16] ;
        end

        `DDR_RD1(read_data) ;
        wr_data_1 = read_data ;
        if (DISP_EN) begin
            $display("%m: RD1 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end
        for (int i = 0; i < 8; i ++) begin
            mem_data[2*i] = read[i*16 +: 16] ;
        end

        foreach (mem_data[i]) begin
            if (DISP_EN) begin
                $display("%m: mem_data[%0d] : %0x @%0t", i, mem_data[i], realtime) ;
            end
        end

        foreach (mem_data[i]) begin
            for (int idx = 0; idx < 2; idx ++) begin
                rd_data_q.push_back(mem_data[i][idx*8 +: 8]) ;
            end  
        end

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        rd_data_q[addr[4:0] = data ;

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: changed rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        data_size = rd_data_q.size() / 2 ;

        for (int i = 0; i < data_size; i ++) begin
            bit [15:0] tmp ;
            tmp = {rd_data_q[2*i+1], rd_data_q[2*i]} ;
            rd_data_q_2byte.push_back(tmp) ;
        end

        foreach (rd_data_q_2byte[i]) begin
            if (DISP_EN) begin
                $display("%m: rd_data_q_2byte[%0d] : %0x @%0t", i, rd_data_q_2byte[i], realtime) ;
            end
        end

        foreach (rd_data_q_2byte[i]) begin
            if (i%2 == 0) begin
                wr_data_0[(i/2)*16 +: 16] = rd_data_q_2byte[i] ; 
            end
        end

        foreach (rd_data_q_2byte[i]) begin
            if (i%2 != 0) begin
                wr_data_1[(i/2)*16 +: 16] = rd_data_q_2byte[i] ; 
            end
        end

        `DDR_WR0(wr_data_0) ;
        `DDR_WR1(wr_data_1) ;

        if (DISP_EN) begin
            $display("%m: wr_data_0 : %x @%0t", wr_data_0 realtime) ;
            $display("%m: wr_data_1 : %x @%0t", wr_data_1 realtime) ;
        end

        mem_data.delete() ;
        rd_data_q = {} ;
        rd_data_q_2byte = {} ;
        
    endtask: mem_wr_byte

    task mem_rd_byte(input reg [31:0] addr, output reg [7:0] data);
        parameter DISP_EN = 0 ;
        bit addr_error_flg ;
        reg [127:0] read_data ;
        bit [15:0] mem_data[bit [6:0]] ;
        byte read_data_q[$] ;

        `DDR_RD0(read_data) ;
        if (DISP_EN) begin
            $display("%m: RD0 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end
        for (int i = 0; i < 8; i ++) begin
            mem_data[2*i] = read[i*16 +: 16] ;
        end

        `DDR_RD1(read_data) ;
        if (DISP_EN) begin
            $display("%m: RD1 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end
        for (int i = 0; i < 8; i ++) begin
            mem_data[2*i] = read[i*16 +: 16] ;
        end

        foreach (mem_data[i]) begin
            if (DISP_EN) begin
                $display("%m: mem_data[%0d] : %0x @%0t", i, mem_data[i], realtime) ;
            end
        end

        foreach (mem_data[i]) begin
            for (int idx = 0; idx < 2; idx ++) begin
                rd_data_q.push_back(mem_data[i][idx*8 +: 8]) ;
            end  
        end

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        data = rd_data_q[addr[4:0] ;

        mem_data.delete() ;
        rd_data_q = {} ;
        
    endtask: mem_rd_byte

`else
    task mem_wr_byte(input reg [31:0] addr, input reg [7:0] data);
        parameter DISP_EN = 0 ;
        bit addr_error_flg ;
        reg [127:0] read_data ;
        byte rd_data_q[$] ;
        reg [127:0] wr_data_0 ;

        `DDR_RD0(read_data) ;
        wr_data_0 = read_data ;
        if (DISP_EN) begin
            $display("%m: RD0 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end

        for (int i = 0; i < 16; i ++) begin
            rd_data_q.push_back(read_data[i*8 +: 8]) ;
        end

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        rd_data_q[addr[3:0] = data ;

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: changed rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        foreach (rd_data_q[i]) begin
            wr_data_0[i*8 +: 8] = rd_data_q[i] ; 
        end

        `DDR_WR0(wr_data_0) ;

        if (DISP_EN) begin
            $display("%m: wr_data_0 : %x @%0t", wr_data_0 realtime) ;
        end

        rd_data_q = {} ;
        
    endtask: mem_wr_byte

    task mem_rd_byte(input reg [31:0] addr, output reg [7:0] data);
        parameter DISP_EN = 0 ;
        bit addr_error_flg ;
        reg [127:0] read_data ;
        byte rd_data_q[$] ;

        `DDR_RD0(read_data) ;
        if (DISP_EN) begin
            $display("%m: RD0 addr : %0x, read_data : %0x @%0t", addr, read_data, realtime) ;
        end

        for (int i = 0; i < 16; i ++) begin
            rd_data_q.push_back(read_data[i*8 +: 8]) ;
        end

        foreach (rd_data_q[i]) begin
            if (DISP_EN) begin
                $display("%m: rd_data_q[%0d] : %0x @%0t", i, rd_data_q[i], realtime) ;
            end
        end

        data = rd_data_q[addr[3:0] ;

        rd_data_q = {} ;
        
    endtask: mem_rd_byte


`endif

// vim: et:ts=4:sw=4:ft=sverilog
