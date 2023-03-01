/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_item.sv
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 11:39:22
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_ITEM_SV__
`define __FLASHCTRL_ITEM_SV__



class flashctrl_item;
    // data or class properties
    typedef struct packed {
        reg [7:0] B3 ;
        reg [7:0] B2 ;
        reg [7:0] B1 ;
        reg [7:0] B0 ;
    } opt_word_s ;

    typedef enum bit[63:0] {
        KEY1 = 64'hA5A5A5A5_5A5A5A5A,
        KEY2 = 64'h2 ,
        KEY3 = 64'h ,
        KEY4 = 64'h ,
        KEY5 = 64'h
    } key_e ;

    typedef enum int {
        NONE = 'b0000 ,
        MAIN = 'b0001 ,
        INFO = 'b0010 ,
        RR0  = 'b0100 ,
        RR0  = 'b1000 ,
        SRAM = 'b1001 ,
        ALL  = 'b1111 
    } block_e ;

    typedef enum bit[1:0] {
        SIZE_8BIT,
        SIZE_16BIT,
        SIZE_32BIT
    } size_e ;

    typedef enum int {
        RD = 'b00 ,
        PG = 'b01 ,
        PE = 'b101 ,
        ES = 'b10 ,
        EA = 'b11 
    } mode_e ;

    typedef enum bit[2:0] {
        RESP_OK,
        RESP_WRPERR,
        RESP_RESET,
        RESP_TIMEOUT,
        RESP_ERROR
    } RESP_e ;

    rand mode_e mode ;
    rand block_e block ;
    rand bit [7:0] rdp ;
    rand bit [7:0] user ;
    rand bit [7:0] data0 ;
    rand bit [7:0] data1 ;
    rand bit isp_con ;
    bit full_size = 1 ;
    rand bit [31:0] wrp ;
    rand bit [31:0] addr ;
    rand size_e size ;
    rand bit [31:0] data[] ;
    rand opt_word_s [`FLASH_OPT_NUM-1:0] opt ;
    rand int len ;
    rand bit hd_rst ;
    rand bit wdg_sw ;
    rand bit boot0_sel ;
    rand bit boot0 ;
    rand bit boot1 ;
    rand bit [5:0] pg_depth
    bit pre_pg = 1; 

    rand byte unsigned page ;
    rand byte unsigned sector ;
    rand byte unsigned bank ;

    rand RESP_e resp ;
    
    bit addr_in_wrp = 0 ;

    `uvm_object_utils_begin(flashctrl_item)
        `uvm_field_enum(mode_e,mode,UVM_ALL_ON)
        `uvm_field_enum(block_e,block,UVM_ALL_ON)
        `uvm_field_sarray_int(opt,UVM_ALL_ON)
        `uvm_field_int(rdp,UVM_ALL_ON)
        `uvm_field_int(user,UVM_ALL_ON)
        `uvm_field_int(data0,UVM_ALL_ON)
        `uvm_field_int(data1,UVM_ALL_ON)
        `uvm_field_int(wrp,UVM_ALL_ON)
        `uvm_field_array_int(data,UVM_ALL_ON)
        `uvm_field_int(len,UVM_ALL_ON|UVM_DEC)
        `uvm_field_int(addr,UVM_ALL_ON)
        `uvm_field_enum(size_e,size,UVM_ALL_ON|UVM_DEC)
        `uvm_field_int(page,UVM_ALL_ON|UVM_DEC)
        `uvm_field_int(sector,UVM_ALL_ON|UVM_DEC)
        `uvm_field_enum(RESP_e,resp,UVM_ALL_ON)
        `uvm_field_int(hd_rst,UVM_ALL_ON)
        `uvm_field_int(wdg_sw,UVM_ALL_ON)
        `uvm_field_int(boot0_sel,UVM_ALL_ON)
        `uvm_field_int(boot0,UVM_ALL_ON)
        `uvm_field_int(boot1,UVM_ALL_ON)
        `uvm_field_int(pg_depth,UVM_ALL_ON)
    `uvm_object_utils_end
    

    // initialization
    function new(string name = "flashctrl_item");
        super.new(name) ;
    endfunction : new

    
    constraint block_cst {
        block inside { MAIN, INFO, SRAM } ;
    }

    constraint addr_cst {
        solve size before addr ;
    }

endclass : flashctrl_item


`endif

// vim: et:ts=4:sw=4:ft=sverilog
