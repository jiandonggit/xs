/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : arch_common_rw_task.svh
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 10:19:10
 * Description: 
 * 
 */

`ifndef __ARCH_COMMON_RW_TASK_SVH__
`define __ARCH_COMMON_RW_TASK_SVH__

    parameter AXI_ADDR_WIDTH        = 32 ;
    parameter AXI_LENGTH_WIDTH      = 8;
    parameter AXI_SIZE_WIDTH        = 3;
    parameter AXI_BURST_TYPE_WIDTH  = 2 ;
    parameter AXI_ID_WIDTH          = 16 ;
    parameter AXI_DATA_WIDTH        = 64 ;

    task automatic xact(
        bit [7:0] bus_id ,
        bit [7:0] master_id ,
        bit is_wr,
        bit [AXI_ADDR_WM_IDTH-1:0]        burst_addr, 
        bit [AXI_LENGTH_WM_IDTH-1:0]      burst_len,
        bit [AXI_SIZE_WM_IDTH-1:0]        burst_size,
        bit [AXI_M_ID_WM_IDTH-1:0]        burst_id,
        bit [AXI_BURST_TYPE_WM_IDTH-1:0]  burst_type,
        bit [AXI_DATA_WM_IDTH-1:0]        burst_wr_data[],
        output bit [AXI_DATA_WM_IDTH-1:0] burst_rd_data[],
        input bit wdata_pre_enable,
        input bit wstrb_all_zero
    ) ;
    case ({bus_id,master_id})
        'h0000: `ARCH_XACT_TOP.bus0_master_m0_inst.xact(is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        'h0001: `ARCH_XACT_TOP.bus0_master_m1_inst.xact(is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        'h0002: `ARCH_XACT_TOP.bus0_master_m2_inst.xact(is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        'h0003: `ARCH_XACT_TOP.bus0_master_m3_inst.xact(is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        'h0004: `ARCH_XACT_TOP.bus0_master_m4_inst.xact(is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        default: $display("%m: Master %0d Do not exists @%0t", {bus_id,master_id}, realtime) ;

    endcase
        
    endtask: xact

    task automatic watch_for(
        bit [7:0] bus_id ,
        bit [7:0] master_id ,
        output bit [AXI_ADDR_WM_IDTH-1:0]        addr, 
        output bit [AXI_LENGTH_WM_IDTH-1:0]      len,
        output bit [AXI_SIZE_WM_IDTH-1:0]        size,
        output bit [AXI_BURST_TYPE_WM_IDTH-1:0]  burst,
        output bit is_wr,
        output bit [AXI_M_ID_WM_IDTH-1:0]        id,
        output bit [AXI_DATA_WM_IDTH-1:0]        data[],
    ) ;

        case ({bus_id,master_id})
            'h0000: `ARCH_XACT_TOP.bus0_master_m0_inst.wait_xact_done_get_xact_attr(addr, len, size, burst, is_wr, id, data) ;
            'h0001: `ARCH_XACT_TOP.bus0_master_m1_inst.wait_xact_done_get_xact_attr(addr, len, size, burst, is_wr, id, data) ;
            'h0002: `ARCH_XACT_TOP.bus0_master_m2_inst.wait_xact_done_get_xact_attr(addr, len, size, burst, is_wr, id, data) ;
            'h0003: `ARCH_XACT_TOP.bus0_master_m3_inst.wait_xact_done_get_xact_attr(addr, len, size, burst, is_wr, id, data) ;
            'h0004: `ARCH_XACT_TOP.bus0_master_m4_inst.wait_xact_done_get_xact_attr(addr, len, size, burst, is_wr, id, data) ;
        default: $display("%m: Master %0d Do not exists @%0t", {bus_id,master_id}, realtime) ;
        endcase
        
    endtask: watch_for

    task automatic ahb_write(
        bit [7:0] master_id ,
        bit [31:0] burst_addr ,
        bit [31:0] burst_width,
        bit [31:0] burst_len,
        bit [31:0] burst_type
        bit [31:0] wdata[]
        );
        
        case (master_id)
            'd0001: `ARCH_XACT_TOP.ahb_bus0_master_m1.write(burst_addr, burst_width, burst_len, burst_type, wdata) ;
            default: $display("%m: Master %0d Do not exists @%0t", master_id, realtime) ;
        end
        endcase
        
    endtask: ahb_write

    task automatic ahb_read(
        bit [31:0] burst_addr ,
        bit [31:0] burst_width,
        bit [31:0] burst_len,
        bit [31:0] burst_type,
        output bit [31:0] rdata[]
    );
        case (master_id)
            'd0001: `ARCH_XACT_TOP.ahb_bus0_master_m1.read(burst_addr, burst_width, burst_len, burst_type, rdata) ;
            default: $display("%m: Master %0d Do not exists @%0t", master_id, realtime) ;
        endcase
    endtask: ahb_read




`endif

// vim: et:ts=4:sw=4:ft=sverilog
