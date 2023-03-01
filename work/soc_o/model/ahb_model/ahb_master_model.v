/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_model.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 11:57:23
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_MODEL_V__
`define __AHB_MASTER_MODEL_V__


`resetall
`timescale 10ps/10ps

`include "VmtDefines.inc"
`include "AmbaCommonDefines.inc"
`include "AhbCommonDefines.inc"
`include "AhbMasterDefines.inc"
`include "AmbaMessages.inc"
`include "ahb_master_vmt.v"

module ahb_master_model #(
parameter ADDR_WIDTH = 32 ,
parameter DATA_WIDTH = 32 
)
        (
    input hclk,
    input hresetn,

    output                       hbusreq ,
    output  [ADDR_WIDTH-1:0]     haddr   ,
    output  [2:0]                hburst  ,
    output                       hlock   ,
    output  [3:0]                hprot   ,
    output  [2:0]                hsize   ,
    output  [1:0]                htrans  ,
    output  [DATA_WIDTH-1:0]     hwdata  ,
    output                       hwrite  ,
    input                        hgrant  
) ;

parameter AHB_BLOCK = 1 ;
bit init_done ;

ahb_master_vmt ahb_master(
    .hclk    (hclk    ) ,
    .hresetn (hresetn ) ,
    .hbusreq (hbusreq ) ,
    .haddr   (haddr   ) ,
    .hburst  (hburst  ) ,
    .hlock   (hlock   ) ,
    .hprot   (hprot   ) ,
    .hsize   (hsize   ) ,
    .htrans  (htrans  ) ,
    .hwdata  (hwdata  ) ,
    .hwrite  (hwrite  ) ,
    .hgrant  (hgrant  ) 

    event xact_done ;

    initial begin
        wait(hresetn==1) ;
        ahb_master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_HDATA_WIDTH_PARAM, DATA_WIDTH) ;
        ahb_master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_AHB_LITE_PARAM, 0) ;
        ahb_master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_ENFORCE_COMPIANT_PARAM, 0) ;
        ahb_master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_END_INCR_WITH_BUSY_PARAM, 0) ;
        ahb_master.disable_msg_type(`VMT_DEFAULT_STREAM_ID, `VMT_MSG_ALL, `VMT_MSG_ROUTE_ALL) ;
        ahb_master.start ;
        init_done = 1 ;
    end

    task write(bit [31:0] burst_addr, burst_width, burst_len, burst_type, wdata[],
               bit  set_busy_en, integer busy_beat, integer busy_cycles) ;
        integer buf_handle ;
        integer resp_handle ;
        integer xfer_size ;
        integer xfer_type ;
        integer xfer_attr ;
        integer status ;

        int burst_size ;

        bit [31:0] len ;

        case (burst_width)
            0: xfer_size = `DW_VIP_AMBA_XFER_SIZE_8 ;
            1: xfer_size = `DW_VIP_AMBA_XFER_SIZE_16 ;
            2: xfer_size = `DW_VIP_AMBA_XFER_SIZE_32 ;
            default: xfer_size = `DW_VIP_AMBA_XFER_SIZE_8 ;
        endcase

        case (burst_type)
            'd0: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_SINGLE ;    len= 1 ; end
            'd1: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR ;      len= burst_len ; end
            'd2: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP4 ;     len= 4 ; end
            'd3: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR4 ;     len= 4 ; end
            'd4: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP8 ;     len= 8 ; end
            'd5: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR8 ;     len= 8 ; end
            'd6: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP16 ;    len= 16 ; end
            'd7: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR16 ;    len= 16 ; end
            default : begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR ; len= burst_len ; end
        endcase

        xfer_attr = `DW_VIP_AMBA_XFER_REQUEST | `DW_VIP_AMBA_XFER_DATA_ACCESS | xfer_size | xfer_type ;

        if (burst_type !== 0) begin
            ahb_master.new_burst_buffer(burst_width, `VMT_MEM_PATTERN_ZERO, 0, len, buf_handle) ;
            if (set_busy_en) begin
                ahb_master.set_burst_buffer_busy(buf_handle, busy_beat, busy_cycles) ;
            end
            ahb_master.set_burst_buffer_xfer_attr(buf_handle, 1, xfer_attr) ;
            for (int i = 0; i < burst_len; i ++) begin
                ahb_master.set_burst_buffer_data(buf_handle, i+1, wdata[i]) ;
            end
            ahb_master.write_burst(`VMT_DEFAULT_STREAM_ID, burst_addr, len, buf_handle, resp_handle) ;
            if (AHB_BLOCK) begin
                ahb_master.block_stream(`VMT_DEFAULT_STREAM_ID, 0, status) ;
            end
            if (burst_type === 1) begin
                ahb_master.idle(`VMT_DEFAULT_STREAM_ID, xfer_attr, 1) ;
            end
            ahb_master.delete_buffer(buf_handle) ;
        end
        else begin
            ahb_master.write_burst(`VMT_DEFAULT_STREAM_ID, burst_addr, wdata[0], xfer_attr, buf_handle) ;
            if (set_busy_en) begin
                ahb_master.set_burst_buffer_busy(buf_handle, busy_beat, busy_cycles) ;
            end
            if (AHB_BLOCK) begin
                ahb_master.block_stream(`VMT_DEFAULT_STREAM_ID, 0, status) ;
            end
        end
        
    endtask: write

    task read(bit [31:0] burst_addr, burst_width, burst_len, burst_type, rdata[],
               bit  set_busy_en, integer busy_beat, integer busy_cycles) ;
        integer buf_handle ;
        integer resp_handle ;
        integer result_handle ;
        integer xfer_size ;
        integer xfer_type ;
        integer xfer_attr ;
        integer status ;

        int burst_size ;

        bit [31:0] len ;
        bit [31:0] rd_data ;

        case (burst_width)
            0: xfer_size = `DW_VIP_AMBA_XFER_SIZE_8 ;
            1: xfer_size = `DW_VIP_AMBA_XFER_SIZE_16 ;
            2: xfer_size = `DW_VIP_AMBA_XFER_SIZE_32 ;
            default: xfer_size = `DW_VIP_AMBA_XFER_SIZE_8 ;
        endcase

        case (burst_type)
            'd0: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_SINGLE ;    len= 1 ; end
            'd1: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR ;      len= burst_len ; end
            'd2: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP4 ;     len= 4 ; end
            'd3: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR4 ;     len= 4 ; end
            'd4: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP8 ;     len= 8 ; end
            'd5: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR8 ;     len= 8 ; end
            'd6: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_WRAP16 ;    len= 16 ; end
            'd7: begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR16 ;    len= 16 ; end
            default : begin xfer_type = `DW_VIP_AMBA_XFER_BURST_INCR ; len= burst_len ; end
        endcase

        xfer_attr = `DW_VIP_AMBA_XFER_REQUEST | `DW_VIP_AMBA_XFER_DATA_ACCESS | xfer_size | xfer_type ;

        if (burst_type !== 0) begin
            ahb_master.new_burst_buffer(burst_width, `VMT_MEM_PATTERN_ZERO, 0, len, buf_handle) ;
            if (set_busy_en) begin
                ahb_master.set_burst_buffer_busy(buf_handle, busy_beat, busy_cycles) ;
            end
            ahb_master.set_burst_buffer_xfer_attr(buf_handle, 1, xfer_attr) ;
            ahb_master.read_burst(`VMT_DEFAULT_STREAM_ID, burst_addr, len, buf_handle, resp_handle) ;
            if (AHB_BLOCK) begin
                ahb_master.block_stream(`VMT_DEFAULT_STREAM_ID, 0, status) ;
            end
            if (burst_type === 1) begin
                ahb_master.idle(`VMT_DEFAULT_STREAM_ID, xfer_attr, 1) ;
            end
            ahb_master.delete_buffer(buf_handle) ;
            ahb_master.get_burst_result(`VMT_DEFAULT_STREAM_ID, resp_handle, result_handle) ;
            rdata = new[burst_len] ;
            for (int i = 0; i < burst_len; i ++) begin
                ahb_master.get_burst_buffer_data(result_handle, i, rdata[i-1]) ;
            end
        end
        else begin
            ahb_master.read(`VMT_DEFAULT_STREAM_ID, burst_addr, xfer_attr, buf_handle) ;
            if (set_busy_en) begin
                ahb_master.set_burst_buffer_busy(buf_handle, busy_beat, busy_cycles) ;
            end
            if (AHB_BLOCK) begin
                ahb_master.block_stream(`VMT_DEFAULT_STREAM_ID, 0, status) ;
            end
            ahb_master.idle(`VMT_DEFAULT_STREAM_ID, xfer_attr, 1) ;
            ahb_master.get_result(`VMT_DEFAULT_STREAM_ID, resp_handle, result_handle) ;
            rdata = new[1] ;
            ahb_master.get_buffer_data(result_handle, rd_data) ;
            rdata[0] = rd_data ;
        end
        
    endtask: write

    
endmodule


`endif

// vim: et:ts=4:sw=4:ft=sverilog
