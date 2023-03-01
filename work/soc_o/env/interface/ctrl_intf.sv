/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ctrl_intf.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 11:55:01
 * Description: 
 * 
 */

`ifndef __CTRL_INTF_SV__
`define __CTRL_INTF_SV__

interface ctrl_intf ( input clock, input reset_n );
// nets
    bit init_done ;

    bit [31:0] active_drv ;
    bit [31:0] passive_drv ;

    task wait_run_start() ;
        while(active_drv ==0) begin
            @(posedge clock) ;
        end
    endtask : wait_run_start

    task wait_run_done() ;
        while (active_drv !== passive_drv) begin
            @(posedge clock) ;
        end
    endtask : wait_run_done

    task wait_reset() ;
        @(posedge clock) ;
        while (!reset_n) begin
            @(posedge clock) ;
        end
        repeat(100) @(posedge clock) ;
    endtask : wait_reset

    task wait_init_done() ;
        @(posedge clock) ;
        while (!init_done) begin
            @(posedge clock) ;
        end
        $display("%m: wait init_done @%0t", realtime) ;
    endtask : wait_init_done

    task insert_delay(bit [31:0] count) ;
        repeat(count) @(posedge clock) ;
    endtask : insert_delay

    `ifndef USE_VIP_SLAVE
    task automatic  set_mem(bit [15:0] size, bit [31:0] addr, bit [127:0] data) ;
        `SET_MEM(8*(2**size), addr, data) ;
    endtask : set_mem

    task automatic  get_mem(bit [15:0] size, bit [31:0] addr, output bit [127:0] data) ;
        `GET_MEM(8*(2**size), addr, data) ;
    endtask : get_mem
    `endif

    `ifdef USE_VIP_SLAVE
    task automatic  set_mem(bit [15:0] size, bit [31:0] addr, bit [127:0] data) ;
        if (addr<=32'h0000_ffff & addr>=32'h0) begin
            `ROM_VIP.ahb_slave.set_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
        else if (addr<=32'h0001_ffff & addr>=32'h0001_0000) begin
            `SRAM_VIP.ahb_slave.set_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
        else if (addr<=32'h0cff_ffff & addr>=32'h0500_0000) begin
            `PSRAM_VIP.axi_slave.set_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
    endtask

    task automatic  get_mem(bit [15:0] size, bit [31:0] addr, output bit [127:0] data) ;
        if (addr<=32'h0000_ffff & addr>=32'h0) begin
            `ROM_VIP.ahb_slave.get_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
        else if (addr<=32'h0001_ffff & addr>=32'h0001_0000) begin
            `SRAM_VIP.ahb_slave.get_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
        else if (addr<=32'h0cff_ffff & addr>=32'h0500_0000) begin
            `PSRAM_VIP.axi_slave.get_mem(0, addr, 8*(2**size),data[31:0]) ;
        end
    endtask

// clocking

// modports

endinterface : ctrl_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
