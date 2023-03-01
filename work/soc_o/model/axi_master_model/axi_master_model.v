/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_master_model.v
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 13:56:33
 * Description: 
 * 
 */

`ifndef __AXI_MASTER_MODEL_V__
`define __AXI_MASTER_MODEL_V__

`resetall

`timescale 10ps/10ps

`include "VmtDefines.inc"
`include "AmbaCommonDefines.inc"
`include "AxiCommonDefines.inc"
`include "AxiMasterDefines.inc"
`include "AmbaMessages.inc"
`include "axi_master_vmt.v"

module axi_master_model (
        aclk ,
        areset_n ,
        awvalid ,
        awaddr ,
        awlen ,
        awsize ,
        awburst ,
        awlock ,
        awcache ,
        awprot ,
        awid ,
        awsideband ,
        awready ,

        wvalid ,
        wdata ,
        wstrb ,
        wid ,
        wsideband ,
        wready ,
        wlast ,

        bvalid ,
        bresp ,
        bid ,
        bsideband ,
        bready ,

        arvalid ,
        araddr ,
        arlen ,
        arsize ,
        arburst ,
        arlock ,
        arcache ,
        arprot ,
        arid ,
        arsideband ,
        arready ,

        rvalid ,
        rdata ,
        rstrb ,
        rid ,
        rsideband ,
        rready ,
        rlast 

);

    parameter AXI_TYPE4 = 0 ;
    parameter READ_EXPECT = 0 ;

    parameter AXI_ADDR_WIDTH        = 32 ;
    parameter AXI_LENGTH_WIDTH      = 8;
    parameter AXI_SIZE_WIDTH        = 3;
    parameter AXI_BURST_TYPE_WIDTH  = 2 ;
    parameter AXI_LOCK_WIDTH        = 2;
    parameter AXI_CACHE_WIDTH       = 4;
    parameter AXI_PROT_WIDTH        = 3;
    parameter AXI_ID_WIDTH          = 16 ;
    parameter AXI_RESP_WIDTH        = 2 ;
    parameter AXI_DATA_WIDTH        = 64 ;
    parameter AXI_QOS_WIDTH         = 4 ;

    parameter AXI_OTS_NUM = 16 ;
    parameter AXI_MAX_BURST_LEN = 256 ;

    parameter ARQOS = 0 ;
    parameter AWQOS = 0 ;

    parameter AXI_LOG_EN = 0 ;
    parameter AXI_XACT_TIMEOUT = 2000 ;
    parameter AXI_BLOCK_TIMEOUT = 0 ;
    parameter AXI_BLOCK = 0 ;
    parameter AXI_COMPARE = 0 ;
    parameter DISP_EN = 1 ;

    parameter MAX_LEN = 63 ;

    output                           awvalid ;
    output [AXI_ADDR_WIDTH-1:0]     awaddr ;
    output [AXI_LENGTH_WIDTH-1:0]   awlen ;
    output [AXI_SIZE_WIDTH-1:0]     awsize ;
    output [AXI_BURST_WIDTH-1:0]    awburst ;
    output [AXI_LOCK_WIDTH-1:0]     awlock ;
    output [AXI_CACHE_WIDTH-1:0]    awcache ;
    output [AXI_PROT_WIDTH-1:0]     awprot ;
    output [AXI_ID_WIDTH-1:0]       awid ;
    input                           awready ;

    output                        wvalid ;
    output [AXI_DATA_WIDTH-1:0]   wdata ;
    output [AXI_DATA_WIDTH/8-1:0] wstrb ;
    output [AXI_ID_WIDTH-1:0]     wid ;
    input                         wready ;
    output                        wlast ;

    input                       bvalid ;
    input  [AXI_RESP_WIDTH-1:0] bresp ;
    input  [AXI_ID_WIDTH-1:0]   bid ;
    output                      bready ;

    output                          arvalid ;
    output [AXI_ADDR_WIDTH-1:0]     araddr ;
    output [AXI_LENGTH_WIDTH-1:0]   arlen ;
    output [AXI_SIZE_WIDTH-1:0]     arsize ;
    output [AXI_BURST_WIDTH-1:0]    arburst ;
    output [AXI_LOCK_WIDTH-1:0]     arlock ;
    output [AXI_CACHE_WIDTH-1:0]    arcache ;
    output [AXI_PROT_WIDTH-1:0]     arprot ;
    output [AXI_ID_WIDTH-1:0]       arid ;
    input                           arready ;

    input                       rvalid ;
    input  [AXI_DATA_WIDTH-1:0] rdata ;
    input  [AXI_ID_WIDTH-1:0]   rid ;
    output                      rready ;
    input                       rlast ;

    pulldown (awvalid) ;
    pulldown (arvalid) ;
    pulldown (rready) ;
    pulldown (wvalid) ;
    pulldown (wlast) ;
    pulldown (bready) ;

    wire csysreq ;
    wire csysack ;
    wire cactive ;
    wire [AXI_SIDEBAND_WIDTH-1:0] awsideband ;
    wire [AXI_SIDEBAND_WIDTH-1:0] wsideband ;
    wire [AXI_SIDEBAND_WIDTH-1:0] bsideband ;
    wire [AXI_SIDEBAND_WIDTH-1:0] arsideband ;
    wire [AXI_SIDEBAND_WIDTH-1:0] rsideband ;

    assign csysreq = 0 ;
    assign rsideband = 0 ;
    assign bsideband = 0 ;
    assign arqos = ARQOS ;
    assign awqos = AWQOS ;

    initial begin
        if(AXI_TYPE4) begin
            force wid = 'hz ;
        end
    end

    axi_master_vmt master(
        //connect ...
    ) ;

    task init_model();
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_DATA_WIDTH_PARAM, AXI_DATA_WIDTH) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_ADDR_WIDTH_PARAM, AXI_ADDR_WIDTH) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_ID_WIDTH_PARAM, AXI_ID_WIDTH) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_NUM_OUTSTANDING_XACT_PARAM, AXI_OTS_NUM) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_WRITE_STRB_IDLE_PARAM, `DW_VIP_AXI_WSTRB_INACTIVE_LOW) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_MAX_BURST_LENGTH_PARAM, AXI_MAX_BURST_LEN) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AMBA_ENFORCE_COMPLIANT_PARAM, 0) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_SIDEBAND_ENABLE_PARAM, `VMT_OFF) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_DEFAULT_RREADY_PARAM, 1) ;
        master.set_config_param(`VMT_DEFAULT_STREAM_ID, `DW_VIP_AXI_DEFAULT_BREADY_PARAM, 1) ;
        if (!AXI_LOG_EN) begin
            integer log_handle ;
            master.open_msg_log(`VMT_DEFAULT_STREAM_ID, "logs/axi_master.log", `VMT_MSG_LOG_MODE_OVR, log_handle) ;
            master.disable_msg_type(`VMT_DEFAULT_STREAM_ID, `VMT_MSG_ALL, `VMT_MSG_ROUTE_ALL) ;
            master.enable_msg_type   (`VMT_DEFAULT_STREAM_ID, `VMT_MSG_ERROR, `VMT_MSG_ROUTE_ALL) ;
            master.enable_msg_feature(`VMT_DEFAULT_STREAM_ID, `VMT_MSG_SCOPE_ALL, `VMT_MSG_FEATURES_ALL, `VMT_MSG_ROUTE_ALL) ;
        end
        master.start ;
        
    endtask: init_model

    typedef enum {S_8, S_16, S_32, S_64, S_128} e_burst_size ;
    typedef enum {FIXED, INCR, WRAP} e_burst_type ;
    typedef enum {READ, WRITE} e_xact_type ;

    task automatic xact(
        bit is_wr,
        bit [AXI_ADDR_WIDTH-1:0]        burst_addr, 
        bit [AXI_LENGTH_WIDTH-1:0]      burst_len,
        bit [AXI_SIZE_WIDTH-1:0]        burst_size,
        bit [AXI_M_ID_WIDTH-1:0]        burst_id,
        bit [AXI_BURST_TYPE_WIDTH-1:0]  burst_type,
        bit [AXI_DATA_WIDTH-1:0]        burst_wr_data[],
        output bit [AXI_DATA_WIDTH-1:0] burst_rd_data[],
        input bit wdata_pre_enable,
        input bit wstrb_all_zero
    );
        integer status ;
        integer resp_buf ;
        integer cmd_buf ;
        integer xact_buf ;
        bit [1:0] lock ;
        bit [2:0] prot ;
        bit [3:0] cache ;
        integer avalid_wvalid_delay_pre ;
        integer avalid_wvalid_delay_post ;
        integer avalid_wvalid_delay ;
        @(posedge aclk) ;
        
        begin
            lock = 0 ;
            prot = 0 ;
            cache = 15 ;
            avalid_wvalid_delay_pre = $urandom_range(0, 15) ;
            avalid_wvalid_delay_post = $urandom_range(0, 15) ;
            avalid_wvalid_delay = avalid_wvalid_delay_pre - avalid_wvalid_delay_post ;
        end
        master.new_buffer(xact_buf) ;
        master.set_buffer_attr_int(xact_buf, `DW_VIP_AXI_WRITE, 0, is_wr) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ALEN, 0, burst_len) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ASIZE, 0, burst_size) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ABURST, 0, burst_type ) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ALOCK, 0, lock) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ACACHE, 0, cach) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_APROT, 0, prot) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_AID, 0, burst_i) ;
        master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_ADDR, 0, burst_add) ;
        if(wdata_pre_enable) begin
            master.set_buffer_attr_int(xact_buf, `DW_VIP_AXI_AVALID_WVALID_DELAY, 0, avalid_wvalid_delay) ;
        end
        else begin
            master.set_buffer_attr_int(xact_buf, `DW_VIP_AXI_AVALID_WVALID_DELAY, 0, avalid_wvalid_delay_pre) ;
        end
        if(READ_EXPECT) begin
            master.set_buffer_attr_int(xact_buf, `DW_VIP_AXI_READ_EXPECT, 0, `VMT_TRUE) ;
        end
        for (int nIndex = 0; nIndex <= burst_len; nIndex ++) begin
            master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_DATA, nIndex, burst_wr_data[nIndex]) ;
            if (wstrb_all_zero) begin
                master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_WSTRB, nIndex, 'h0) ;
            end
            master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_RESP, nIndex, `DW_VIP_AXI_RESP_OKAY) ;
            if (READ_EXPECT) begin
                master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_READ_EXPECT_DATA, nIndex, burst_wr_data[nIndex]) ;
                master.set_buffer_attr_bitvec(xact_buf, `DW_VIP_AXI_READ_EXPECT_RESP, nIndex, `DW_VIP_AXI_RESP_OKAY) ;
            end
        end
        master.send_xact(`VMT_DEFAULT_STREAM_ID, xact_buf, cmd_buf) ;
        if (AXI_BLOCK) begin
            master.block_stream(`VMT_DEFAULT_STREAM_ID, AXI_BLOCK_TIMEOUT, status) ;
            if (status !== 0) begin
                $display("%m: ERROR Master Timeout for block_stream @%0t", , realtime) ;
            end
        end
        if (AXI_COMPARE) begin
            if (!is_wr) begin
                burst_rd_data = new[burst_len+1] ;
                master.get_result(`VMT_DEFAULT_STREAM_ID, cmd_buf, resp_buf) ;
                for (int nIndex = 0; nIndex <= burst_len; nIndex ++) begin
                    master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_DATA, nIndex, burst_rd_data[nIndex]) ;
                end
            end
        end
        master.delete_buffer(xact_buf) ;
        
    endtask: xact

    task automatic wait_xact_done_get_xact_attr(
            output bit [AXI_ADDR_WIDTH-1:0]        addr, 
            output bit [AXI_LENGTH_WIDTH-1:0]      len,
            output bit [AXI_SIZE_WIDTH-1:0]        size,
            output bit [AXI_BURST_TYPE_WIDTH-1:0]  burst,
            output bit                             is_wr,
            output bit [AXI_M_ID_WIDTH-1:0]        id,
            output bit [AXI_DATA_WIDTH-1:0]        data[]
        ) ;
        integer info ;
        integer status ;
        integer resp_buf ;
        integer wp ;
        master.create_watchpoint(`VMT_MESSAGE_ID, `AXI_MSGID_MASTER_SEND_XACT_COMPLETE, wp) ;
        master.watch_for(wp, info) ;
        master.get_watchpoint_data_int(info, `AXI_MSGID_MASTER_SEND_XACT_COMPLETE_ARG_RESULT_BUF_HANDLE, resp_buf, status) ;
        master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_ADDR, 0, addr) ;
        master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_ALEN, 0, len) ;
        master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_ASIZE, 0, size) ;
        master.get_buffer_attr_int(resp_buf, `DW_VIP_AXI_WRITE, 0, is_wr) ;
        master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_ID, 0, id) ;
        master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_ABURST, 0, burst) ;
        if (data.size() != 0) begin
            data.delete() ;
        end
        data = new[len+1] ;
        for (int i = 0; i <= len; i ++) begin
            master.get_buffer_attr_bitvec(resp_buf, `DW_VIP_AXI_DATA, i, data[i]) ;
        end
        resp_buf = null ;
        info = null ;
        master.destroy_watchpoint(`VMT_DEFAULT_STREAM_ID, wp) ;
    endtask

    task automatic reg_write(input bit [AXI_ADDR_WIDTH-1:0] addr, bit [AXI_DATA_WIDTH-1:0] data);
        bit [AXI_DATA_WIDTH-1:0] beat_wr_data[] ;
        bit [AXI_DATA_WIDTH-1:0] beat_rd_data[] ;

        beat_wr_data = new[1] ;
        beat_rd_data = new[1]
        beat_wr_data[0] = data ;
        xact(WRITE, addr, 0, S_32, WR_RD_ID, INCR, beat_wr_data, beat_rd_data) ;
        if (DISP_EN) begin
            $display("%m: write addr done : %0x, data : %0x @%0t", addr, data, realtime) ;
        end
        
    endtask: reg_write

    task automatic reg_read(input bit [AXI_ADDR_WIDTH-1:0] addr, output bit [AXI_DATA_WIDTH-1:0] data);
        bit [AXI_DATA_WIDTH-1:0] beat_wr_data[] ;
        bit [AXI_DATA_WIDTH-1:0] beat_rd_data[] ;

        beat_wr_data = new[1] ;
        beat_rd_data = new[1]
        xact(READ, addr, 0, S_32, WR_RD_ID, INCR, beat_wr_data, beat_rd_data) ;
        data = beat_wr_data[0][31:0] ;
        if (DISP_EN) begin
            $display("%m: write addr done : %0x, data : %0x @%0t", addr, data, realtime) ;
        end
        
    endtask: reg_read

    event all_init_done ;

    initial begin
        wait(areset_n) ;
        init_model() ;
        repeat(10) @(posedge aclk) ;
        -> all_init_done ;
        $display("%m: ALL INIT DONE @%0t", , realtime) ;
    end

    task wait_init();
        wait(all_init_done.triggered) ;
    endtask: wait_init

    
endmodule

`resetall

`endif

// vim: et:ts=4:sw=4:ft=sverilog
