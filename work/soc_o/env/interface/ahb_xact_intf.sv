/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_xact_intf.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 14:27:34
 * Description: 
 * 
 */

`ifndef __AHB_XACT_INTF_SV__
`define __AHB_XACT_INTF_SV__

interface ahb_xact_intf ( 
        input clock,
        input reset_n,
        logic           hgrant ,
        logic [31:0]    hrdata ,
        logic           hready ,
        logic [ 1:0]    hresp ,
        logic [31:0]    haddr ,
        logic [ 2:0]    hburst ,
        logic           hbusreq ,
        logic           hlock ,
        logic [ 3:0]    hprot ,
        logic [ 2:0]    hsize ,
        logic [ 1:0]    htrans ,
        logic [31:0]    hwdata ,
        logic           hwrite ) ;

// nets

    parameter B_ID = 0 ;
    parameter M_ID = 0 ;

    int master_id = M_ID ;
    event line_end ;
    bit stall ;
    bit [31:0] all_queue_size ;
    bit start_point ;
    bit run_over ;
    int FREQ ;
    int queue_size ;

    task automatic ahb_write(
        bit [31:0] burst_addr ,
        bit [31:0] burst_width,
        bit [31:0] burst_len,
        bit [31:0] burst_type,
        bit [31:0] wdata[]);
        
        `ARCH_XACT_TOP.ahb_write(M_ID, burst_addr, burst_width, burst_len, burst_type, wdata) ;
        
    endtask: ahb_write

    task automatic ahb_read(
        bit [31:0] burst_addr ,
        bit [31:0] burst_width,
        bit [31:0] burst_len,
        bit [31:0] burst_type,
        output bit [31:0] rdata[]);
        
        `ARCH_XACT_TOP.ahb_read(M_ID, burst_addr, burst_width, burst_len, burst_type, rdata) ;
        
    endtask: ahb_write

    function reg [31:0]  get_slice(bit [31:0] size, reg[31:0] indata) ;
        case (size)
            8 : get_slice = indata [ 7:0] ;
            16: get_slice = indata [15:0] ;
            32: get_slice = indata        ;
            default: get_slice = indata ;
        endcase
    endfunction : get_slice

    task automatic watch_for (
        output bit [31:0] addr,
        output bit [ 7:0] len,
        output bit [ 3:0] size,
        output bit [ 3:0] burst,
        output bit        is_wr,
        output bit [10:0] id,
        output bit [63:0] data[] );

        `ARCH_XACT_TOP.watch_for(B_ID, M_ID, addr, len, size, burst, is_wr, id, data) ;
        
    endtask:  watch_for 

    task automatic insert_delay(bit [31:0] count);
        repeat(count) @(posedge clock) ;
    endtask: insert_delay

    task automatic wait_init_done();
        begin
            @(posedge clock) ;
            wait(reset_n) ;
            @(posedge clock) ;
        end
    endtask: wait_init_done

    task trigger_line_end() ;
        begin
            ->line_end ;
        end
    endtask : trigger_line_end

// clocking

// modports

endinterface : ahb_xact_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
