/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_xact_intf.sv
 * Author : dongj
 * Create : 2022-12-28
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/28 11:03:22
 * Description: 
 * 
 */

`ifndef __AXI_XACT_INTF_SV__
`define __AXI_XACT_INTF_SV__

interface axi_xact_intf ( 
    clock,
    reset_n,
    if_uwr_addr ,
    if_uwr_req,
    if_uwr_strb,
    if_uwr_ack,
    if_uwr_done,
    if_uwr_id,
    if_uwr_len,
    if_fifo_rd_en,
    if_fifo_wr_data,
    if_uwr_resp_id,

    if_urd_addr ,
    if_urd_req,
    if_urd_ack,
    if_urd_done,
    if_urd_id,
    if_urd_len,
    if_fifo_wr_en,
    if_fifo_rd_data,
    if_urd_resp_id);

    parameter B_ID = 0 ;
    parameter M_ID = 0 ;

    parameter AXI_ADDR_WM_IDTH = 64 ;
    parameter AXI_LENGTH_WM_IDTH = 8 ;
    parameter AXI_SIZE_WM_IDTH = 3 ;
    parameter AXI_BURST_TYPE_WM_IDTH = 2 ;
    parameter AXI_M_ID_WM_IDTH = 11 ;
    parameter AXI_DATA_WM_IDTH = 64 ;

// nets
    input clock;
    input reset_n;
    inout [AXI_ADDR_WM_IDTH-1:0] if_uwr_addr ;
    inout if_uwr_req;
    inout [15:0] if_uwr_strb;
    inout if_uwr_ack;
    inout if_uwr_done;
    inout [10:0] if_uwr_id;
    inout [7:0] if_uwr_len;
    inout if_fifo_rd_en;
    inout [AXI_DATA_WM_IDTH-1:0] if_fifo_wr_data;
    inout [10:0] if_uwr_resp_id;

    inout [AXI_ADDR_WM_IDTH-1:0] if_urd_addr ;
    inout if_urd_req;
    inout if_urd_ack;
    inout if_urd_done;
    inout [10:0] if_urd_id;
    inout [7:0] if_urd_len;
    inout if_fifo_wr_en;
    inout [AXI_DATA_WM_IDTH-1:0] if_fifo_rd_data;
    inout [10:0] if_urd_resp_id);

// clocking
    logic [AXI_ADDR_WM_IDTH-1:0] uwr_addr ;
    logic uwr_req;
    logic [15:0] uwr_strb;
    logic uwr_ack;
    logic uwr_done;
    logic [10:0] uwr_id;
    logic [7:0] uwr_len;
    logic fifo_rd_en;
    logic [AXI_DATA_WM_IDTH-1:0] fifo_wr_data;
    logic [10:0] uwr_resp_id;

    logic [AXI_ADDR_WM_IDTH-1:0] urd_addr ;
    logic urd_req;
    logic urd_ack;
    logic urd_done;
    logic [10:0] urd_id;
    logic [7:0] urd_len;
    logic fifo_wr_en;
    logic [AXI_DATA_WM_IDTH-1:0] fifo_rd_data;
    logic [10:0] urd_resp_id);

    assign if_uwr_addr         = uwr_addr    ;
    assign if_uwr_req          = uwr_req     ;
    assign if_uwr_strb         = uwr_strb    ;
    assign if_uwr_id           = uwr_id      ;
    assign if_uwr_len          = uwr_len     ;
    assign if_fifo_wr_data     = fifo_wr_data;

    assign if_urd_addr         = urd_addr     ;
    assign if_urd_req          = urd_req      ;
    assign if_urd_id           = urd_id       ;
    assign if_urd_len          = urd_len      ;

    assign uwr_ack         = if_uwr_ack     ;
    assign uwr_done        = if_uwr_done    ;
    assign uwr_resp_id     = if_uwr_resp_id ;
    assign fifo_rd_en      = if_fifo_rd_en  ;

    assign urd_ack         = if_urd_ack      ;
    assign urd_done        = if_urd_done     ;
    assign urd_resp_id     = if_urd_resp_id  ;
    assign fifo_wr_en      = if_fifo_wr_en   ;
    assign fifo_rd_data    = if_fifo_rd_data ;

    event line_end ;

    logic [63:0] ended_xact = 0 ;
    logic [63:0] recorded_xact = 0 ;
    logic [31:0] outstanding_num = 0 ;

    bit stall ;
    bit [31:0] all_queue_size ;

    initial begin
        uwr_addr    = 0 ;
        uwr_req     = 0 ;
        uwr_strb    = 0 ;
        uwr_id      = 0 ;
        uwr_len     = 0 ;
        fifo_wr_data= 0 ;

        urd_addr    = 0 ;
        urd_req     = 0 ;
        urd_id      = 0 ;
        urd_len     = 0 ;
    end

    task automatic xact(
        bit is_wr ,
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
    begin
        bit [AXI_DATA_WM_IDTH-1:0]        burst_wdata[] ;
        bit [AXI_DATA_WM_IDTH-1:0]        burst_rd_data[] ;
        bit [31:0] beat_data[4] ;
        bit [AXI_DATA_WM_IDTH-1:0]        beat_data_qword ; 
        burst_rd_data = new[burst_len+1] ;
        `ifndef INTERNAL_COMPARE
        `ARCH_XACT_TOP.xact(B_ID, M_ID, is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        `else
        burst_wdata = new[burst_len+1] ;
        for (int idx = 0; idx <= burst_len; idx ++) begin
            begin
                beat_data[0] = burst_addr+idx*(2**burst_size) ;
                beat_data[1] = burst_addr+idx*(2**burst_size) ;
                beat_data[2] = burst_addr+idx*(2**burst_size) ;
                beat_data[3] = burst_addr+idx*(2**burst_size) ;
                beat_data_qword = {beat_data[3], beat_data[2], beat_data[1], beat_data[0]} ;
            end
        end
        `ARCH_XACT_TOP.xact(B_ID, M_ID, is_wr, burst_addr, burst_len, burst_size, burst_id, burst_type, burst_wr_data, burst_rd_data, wdata_pre_enable, wstrb_all_zero) ;
        if (!is_wr) begin
            for (int idx = 0; idx <= burst_len; idx ++) begin
                if (get_slice_data(burst_size, burst_wdata[idx]) !== burst_rd_data[idx]) begin
                     $display("%m:bus%0d_m%0d addr[%0x] len[%0x] size[%0x] id[%0x] burst[%0x] idx[%0x] compare ERROR. (%0x, %0x) @%0t", B_ID, M_ID, burst_addr, burst_len, burst_size, burst_id, burst_type, idx, get_slice_data(burst_size, burst_wdata[idx]), burst_rd_data[idx], realtime) ;
                end
            end
        end
        burst_wdata.delete() ;
        `endif
    end
        
    endtask : xact

    task automatic watch_for(
        output bit [AXI_ADDR_WM_IDTH-1:0]        addr, 
        output bit [AXI_LENGTH_WM_IDTH-1:0]      len,
        output bit [AXI_SIZE_WM_IDTH-1:0]        size,
        output bit [AXI_BURST_TYPE_WM_IDTH-1:0]  burst,
        output bit is_wr,
        output bit [AXI_M_ID_WM_IDTH-1:0]        id,
        output bit [AXI_DATA_WM_IDTH-1:0]        data[],
    ) ;
        `ARCH_XACT_TOP.watch_for(B_ID, M_ID, addr, len, size, burst, is_wr, id, data) ;
        
    endtask : watch_for 

    function bit [AXI_DATA_WM_IDTH-1:0] get_slice_data(bit [2:0] size, bit [AXI_DATA_WM_IDTH-1:0] ori_data) ;
        begin
            case (size)
                0: get_slice_data = ori_data[  7:0] ;
                1: get_slice_data = ori_data[ 15:0] ;
                2: get_slice_data = ori_data[ 31:0] ;
                3: get_slice_data = ori_data[ 63:0] ;
                4: get_slice_data = ori_data[127:0] ;
            default: get_slice_data = ori_data[127:0] ;
            endcase
        end
    endfunction : get_slice_data

    task automatic insert_delay(bit [31:0] count) ;
        begin
            repeat(count+1) @(posedge clock) ;
        end
    endtask : insert_delay

    task automatic insert_1ps_delay() ;
        begin
            #1ps ;
        end
    endtask : insert_1ps_delay

    task automatic wait_init_done() ;
        begin
            @(posedge clock) ;
            wait(reset_n) ;
            @(posedge clock) ;
        end
    endtask : wait_init_done 

    task trigger_line_end() ;
        begin
            ->line_end ;
        end
    endtask : trigger_line_end

// modports

endinterface : axi_xact_intf


`endif

// vim: et:ts=4:sw=4:ft=sverilog
