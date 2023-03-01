/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_if.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 11:04:22
 * Description: 
 * 
 */

`ifndef __RGP_IF_SV__
`define __RGP_IF_SV__

interface rgp_if ( input clk,
                   input rst_n );

    parameter setup_time = 0.2ns ;
    parameter hold_time = 0.2ns ;

    semaphore key = new(1) ;
// nets

// clocking
    clocking mck @(posedge clk) ;
        default input #setup_time output #hold_time ;
    endclocking : mck

    clocking sck @(posedge clk) ;
    endclocking : sck

    clocking pck @(posedge clk) ;
        default input #setup_time output #hold_time ;
    endclocking : pck

    modport master (clocking mck) ;
    modport slave  (clocking sck) ;
    modport passive(clocking pck) ;


// modports

    task RGP_WRITE(reg [31:0] x, reg [31:0] y, int size = 2);
        key.get ;
        `ifdef RGP_WRITE_WRAPPER
            `RGP_WRITE_WRAPPER(addr,data,size) ;
        `else
            $display("function not defined!") ;
        `endif
        key.put ;
    endtask: RGP_WRITE

    task RGP_READ(reg [31:0] x, output reg [31:0] y, input int size = 2);
        key.get ;
        `ifdef RGP_READ_WRAPPER
            `RGP_READ_WRAPPER(addr,data,size) ;
        `else
            $display("function not defined!") ;
        `endif
        key.put ;
    endtask: RGP_WRITE

endinterface : rgp_if


`endif

// vim: et:ts=4:sw=4:ft=sverilog
