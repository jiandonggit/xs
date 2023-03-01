/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 14:18:16
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_SV__
`define __AXI_MONITOR_SV__

module axi_monitor (
    input       aclk ,
    output      aresetn ,

    // axi bus 
    // aw
    // w
    // b
    // ar
    // r
    input i_addr_range_check_en ,
    input [31:0] i_addr_range_wr_min ,
    input [31:0] i_addr_range_wr_max ,
    input [31:0] i_addr_range_rd_min ,
    input [31:0] i_addr_range_rd_max ,

    input i_dat_traffic_statistic_en ,
    input i_dat_traffic_statistic_clr ,

    input i_sample_sync_ns_10ns_edge ,
    input i_sample_sync_ns_100ns_edge ,
    input i_sample_sync_ns_500ns_edge ,
    input i_sample_sync_ns_1000ns_edge ,
    input i_sample_sync_ns_100000ns_edge 
);

    `include "axi_monitor_config.svh"

    reg sample_sync_ns_10_cdc   ;
    reg sample_sync_ns_100_cdc  ;
    reg sample_sync_ns_500_cdc  ;
    reg sample_sync_ns_1000_cdc ;

    reg [1:0] sample_sync_ns_10_d   ;
    reg [1:0] sample_sync_ns_100_d  ;
    reg [1:0] sample_sync_ns_500_d  ;
    reg [1:0] sample_sync_ns_1000_d ;

    reg       dat_traffic_statistic_en_cdc ;
    reg [1:0] dat_traffic_statistic_en_d ;
    reg       dat_traffic_statistic_clr_cdc ;
    reg [1:0] dat_traffic_statistic_clr_d ;

    wire      dat_traffic_statistic_en_pos ;
    wire      dat_traffic_statistic_en_neg ;

    reg [39:0] total_dat_cnt_rd ;
    reg [39:0] total_dat_cnt_wr ;
    reg [39:0] total_dat_cnt_sum ;

    reg [39:0] dat_traffic_stat_cnt_rd ;
    reg [39:0] dat_traffic_stat_cnt_wr ;
    reg [39:0] dat_traffic_stat_cnt_sum ;
    reg [39:0] req_traffic_stat_cnt_rd ;
    reg [39:0] req_traffic_stat_cnt_wr ;
    reg [39:0] req_traffic_stat_cnt_sum ;

    reg [12:0] burst_dat_cnt_rd ;
    reg [12:0] burst_dat_cnt_wr ;

    reg [12:0] number_bytes_wr ;
    reg [12:0] number_bytes_rd ;

    wire [12:0] burst_length_wr ;
    wire [12:0] burst_length_rd ;

    reg [31:0] burst_boundary_addr_wr ;
    reg [31:0] burst_boundary_addr_rd ;

    wire       addr_out_range_wr ;
    wire       addr_out_range_rd ;
    reg        addr_out_range ;

    reg        resp_err_flag ;
    wire       resp_err_flag_r ;
    wire       resp_err_flag_b ;

    // osd
    reg [15:0] burst_cnt_aw ;
    reg [15:0] burst_cnt_b ;
    reg [15:0] burst_cnt_ar ;
    reg [15:0] burst_cnt_r ;
    reg [15:0] burst_cnt_sum ;
    reg [15:0] outstanding_cnt_wr ;
    reg [15:0] outstanding_cnt_rd ;
    reg [15:0] outstanding_cnt_sum ;

    // avg bw
    reg [39:0] sample_dat_cnt_ns_10_rd ;
    reg [39:0] sample_dat_cnt_ns_10_wr ;
    reg [39:0] sample_dat_cnt_ns_10_sum ;
    reg [39:0] sample_dat_cnt_ns_100_rd ;
    reg [39:0] sample_dat_cnt_ns_100_wr ;
    reg [39:0] sample_dat_cnt_ns_100_sum ;
    reg [39:0] sample_dat_cnt_ns_500_rd ;
    reg [39:0] sample_dat_cnt_ns_500_wr ;
    reg [39:0] sample_dat_cnt_ns_500_sum ;
    reg [39:0] sample_dat_cnt_ns_1000_rd ;
    reg [39:0] sample_dat_cnt_ns_1000_wr ;
    reg [39:0] sample_dat_cnt_ns_1000_sum ;
    reg [39:0] sample_dat_cnt_ns_10000_rd ;
    reg [39:0] sample_dat_cnt_ns_10000_wr ;
    reg [39:0] sample_dat_cnt_ns_10000_sum ;

    reg [39:0] avg_dat_cnt_ns_10_rd ;
    reg [39:0] avg_dat_cnt_ns_10_wr ;
    reg [39:0] avg_dat_cnt_ns_10_sum ;
    reg [39:0] avg_dat_cnt_ns_100_rd ;
    reg [39:0] avg_dat_cnt_ns_100_wr ;
    reg [39:0] avg_dat_cnt_ns_100_sum ;
    reg [39:0] avg_dat_cnt_ns_500_rd ;
    reg [39:0] avg_dat_cnt_ns_500_wr ;
    reg [39:0] avg_dat_cnt_ns_500_sum ;
    reg [39:0] avg_dat_cnt_ns_1000_rd ;
    reg [39:0] avg_dat_cnt_ns_1000_wr ;
    reg [39:0] avg_dat_cnt_ns_1000_sum ;
    reg [39:0] avg_dat_cnt_ns_10000_rd ;
    reg [39:0] avg_dat_cnt_ns_10000_wr ;
    reg [39:0] avg_dat_cnt_ns_10000_sum ;

    reg [19:0] burst_length_cnt_wr[21] ;
    reg [19:0] burst_length_cnt_rd[21] ;

    reg awready_d ;
    reg awvalid_d ;
    reg arready_d ;
    reg arvalid_d ;

    wire sample_sync_edge_ns_10_n ;
    wire sample_sync_edge_ns_100_n ;
    wire sample_sync_edge_ns_500_n ;
    wire sample_sync_edge_ns_1000_n ;
    wire sample_sync_edge_ns_100000_n ;

    assign sample_sync_ns_10_n      = !i_sample_sync_ns_10ns_edge ;
    assign sample_sync_ns_100_n     = !i_sample_sync_ns_100ns_edge ;
    assign sample_sync_ns_500_n     = !i_sample_sync_ns_500ns_edge ;
    assign sample_sync_ns_1000_n    = !i_sample_sync_ns_1000ns_edge ;
    assign sample_sync_ns_100000_n  = !i_sample_sync_ns_100000ns_edge ;

    assign dat_traffic_statistic_en_pos = (dat_traffic_statistic_en_d[0] & (~dat_traffic_statistic_en_d[1])) ;
    assign dat_traffic_statistic_en_neg = ((~dat_traffic_statistic_en_d[0]) & dat_traffic_statistic_en_d[1]) ;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            dat_traffic_statistic_en_cdc <= 1'b0 ;
            dat_traffic_statistic_en_d <= 2'b0 ;
            dat_traffic_statistic_clr_cdc <= 1'b0 ;
            dat_traffic_statistic_clr_d <= 2'b0 ;
        end
        else begin
            dat_traffic_statistic_en_cdc  <= i_dat_traffic_statistic_en ;
            dat_traffic_statistic_en_d    <= {dat_traffic_statistic_en_d[0],dat_traffic_statistic_en_cdc} ;
            dat_traffic_statistic_clr_cdc <= i_dat_traffic_statistic_clr ;
            dat_traffic_statistic_clr_d   <= {dat_traffic_statistic_clr_d[0],dat_traffic_statistic_clr_cdc} ;
        end
    end

    // osd

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            burst_cnt_aw = <=16'h0 ;
        end
        else if (awready & awvalid) begin
            burst_cnt_aw <= burst_cnt_aw + 16'h1 ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            burst_cnt_b = <=16'h0 ;
        end
        else if (bready & bvalid) begin
            burst_cnt_b <= burst_cnt_b + 16'h1 ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            burst_cnt_ar = <=16'h0 ;
        end
        else if (arready & arvalid) begin
            burst_cnt_ar <= burst_cnt_ar + 16'h1 ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            burst_cnt_r = <=16'h0 ;
        end
        else if (rready & rvalid) begin
            burst_cnt_r <= burst_cnt_r + 16'h1 ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            outstanding_cnt_wr <= 16'h0 ;
            outstanding_cnt_rd <= 16'h0 ;
        end
        else begin
            outstanding_cnt_wr <= burst_cnt_aw - burst_cnt_b ;
            outstanding_cnt_rd <= burst_cnt_ar - burst_cnt_r ;
        end
    end

    always @(*) begin
        case(awsize) 
            3'h0: number_bytes_wr = 13'd1 ;
            3'h1: number_bytes_wr = 13'd2 ;
            3'h2: number_bytes_wr = 13'd4 ;
            3'h3: number_bytes_wr = 13'd8 ;
            3'h4: number_bytes_wr = 13'd16 ;
            3'h5: number_bytes_wr = 13'd32 ;
            3'h6: number_bytes_wr = 13'd64 ;
            3'h7: number_bytes_wr = 13'd128 ;
            default:number_bytes_wr = 13'd0 ;
        endcase
    end

    always @(*) begin
        case(arsize) 
            3'h0: number_bytes_rd = 13'd1 ;
            3'h1: number_bytes_rd = 13'd2 ;
            3'h2: number_bytes_rd = 13'd4 ;
            3'h3: number_bytes_rd = 13'd8 ;
            3'h4: number_bytes_rd = 13'd16 ;
            3'h5: number_bytes_rd = 13'd32 ;
            3'h6: number_bytes_rd = 13'd64 ;
            3'h7: number_bytes_rd = 13'd128 ;
            default:number_bytes_rd = 13'd0 ;
        endcase
    end

    assign burst_length_wr = [7'b0,awlen} + 13'h1 ;
    assign burst_length_rd = [7'b0,arlen} + 13'h1 ;

    always @(*) begin
        burst_dat_cnt_wr = number_bytes_wr * burst_length_wr ;
        burst_dat_cnt_rd = number_bytes_rd * burst_length_rd ;
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            total_dat_cnt_wr <= 40'h0 ;
            total_dat_cnt_rd <= 40'h0 ;
        end
        else begin
            if (awready & awvalid) begin
                total_dat_cnt_wr <= total_dat_cnt_wr + burst_dat_cnt_wr ;
            end
            if (arready & arvalid) begin
                total_dat_cnt_rd <= total_dat_cnt_rd + burst_dat_cnt_rd ;
            end
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            dat_traffic_stat_cnt_wr <= 40'h0 ;
            dat_traffic_stat_cnt_rd <= 40'h0 ;
            req_traffic_stat_cnt_wr <= 16'h0 ;
            req_traffic_stat_cnt_rd <= 16'h0 ;
        end
        else if ( dat_traffic_statistic_clr_d[1] ) begin
            dat_traffic_stat_cnt_wr <= 40'h0 ;
            dat_traffic_stat_cnt_rd <= 40'h0 ;
            req_traffic_stat_cnt_wr <= 16'h0 ;
            req_traffic_stat_cnt_rd <= 16'h0 ;
        end
        else if (dat_traffic_statistic_en_d[1]) begin
            if(awready&awvalid) begin
                dat_traffic_stat_cnt_wr <= dat_traffic_stat_cnt_wr + burst_dat_cnt_wr ;
                req_traffic_stat_cnt_wr <= req_traffic_stat_cnt_wr + 16'h1 ;
            end
            if(arready&arvalid) begin
                dat_traffic_stat_cnt_rd <= dat_traffic_stat_cnt_rd + burst_dat_cnt_rd ;
                req_traffic_stat_cnt_rd <= req_traffic_stat_cnt_rd + 16'h1 ;
            end
        end
    end

    always @(posedge aclk or negedge sample_sync_edge_ns_100_n) begin
        if(!sample_sync_edge_ns_100_n) begin
            sample_dat_cnt_ns_100_wr <= 40'h0 ;
            sample_dat_cnt_ns_100_rd <= 40'h0 ;
        end
        else begin
            if(awvalid&awready) begin
                sample_dat_cnt_ns_100_wr <= sample_dat_cnt_ns_100_wr + burst_dat_cnt_wr ;
            end
            if(arvalid&arready) begin
                sample_dat_cnt_ns_100_rd <= sample_dat_cnt_ns_100_rd + burst_dat_cnt_rd ;
            end
        end
    end

    always @(posedge aclk or negedge sample_sync_edge_ns_500_n) begin
        if(!sample_sync_edge_ns_500_n) begin
            sample_dat_cnt_ns_500_wr <= 40'h0 ;
            sample_dat_cnt_ns_500_rd <= 40'h0 ;
        end
        else begin
            if(awvalid&awready) begin
                sample_dat_cnt_ns_500_wr <= sample_dat_cnt_ns_500_wr + burst_dat_cnt_wr ;
            end
            if(arvalid&arready) begin
                sample_dat_cnt_ns_500_rd <= sample_dat_cnt_ns_500_rd + burst_dat_cnt_rd ;
            end
        end
    end

    always @(posedge aclk or negedge sample_sync_edge_ns_1000_n) begin
        if(!sample_sync_edge_ns_1000_n) begin
            sample_dat_cnt_ns_1000_wr <= 40'h0 ;
            sample_dat_cnt_ns_1000_rd <= 40'h0 ;
        end
        else begin
            if(awvalid&awready) begin
                sample_dat_cnt_ns_1000_wr <= sample_dat_cnt_ns_1000_wr + burst_dat_cnt_wr ;
            end
            if(arvalid&arready) begin
                sample_dat_cnt_ns_1000_rd <= sample_dat_cnt_ns_1000_rd + burst_dat_cnt_rd ;
            end
        end
    end

    always @(posedge aclk or negedge sample_sync_edge_ns_10000_n) begin
        if(!sample_sync_edge_ns_10000_n) begin
            sample_dat_cnt_ns_10000_wr <= 40'h0 ;
            sample_dat_cnt_ns_10000_rd <= 40'h0 ;
        end
        else begin
            if(awvalid&awready) begin
                sample_dat_cnt_ns_10000_wr <= sample_dat_cnt_ns_10000_wr + burst_dat_cnt_wr ;
            end
            if(arvalid&arready) begin
                sample_dat_cnt_ns_10000_rd <= sample_dat_cnt_ns_10000_rd + burst_dat_cnt_rd ;
            end
        end
    end

    always @(*) begin
        total_dat_cnt_sum = total_dat_cnt_wr + total_dat_cnt_rd ;
        dat_traffic_stat_cnt_sum = dat_traffic_stat_cnt_wr + dat_traffic_stat_cnt_rd ;
        sample_dat_cnt_ns_10_sum = sample_dat_cnt_ns_10_wr + sample_dat_cnt_ns_10_rd ;
        sample_dat_cnt_ns_100_sum = sample_dat_cnt_ns_100_wr + sample_dat_cnt_ns_100_rd ;
        sample_dat_cnt_ns_500_sum = sample_dat_cnt_ns_500_wr + sample_dat_cnt_ns_500_rd ;
        sample_dat_cnt_ns_1000_sum = sample_dat_cnt_ns_1000_wr + sample_dat_cnt_ns_1000_rd ;
        sample_dat_cnt_ns_10000_sum = sample_dat_cnt_ns_10000_wr + sample_dat_cnt_ns_10000_rd ;
        burst_cnt_sum = burst_cnt_aw + burst_cnt_ar ;
        outstanding_cnt_sum = outstanding_cnt_wr + outstanding_cnt_rd ;
        req_traffic_stat_cnt_sum = req_traffic_stat_cnt_wr + req_traffic_stat_cnt_rd ;
    end

    always @(posedge i_sample_sync_ns_10ns_edge) begin
        if(i_sample_sync_ns_10ns_edge) begin
            avg_dat_cnt_ns_10_wr <= sample_dat_cnt_ns_10_wr ;
            avg_dat_cnt_ns_10_rd <= sample_dat_cnt_ns_10_rd ;
            avg_dat_cnt_ns_10_sum<= sample_dat_cnt_ns_10_sum ;
        end
    end

    always @(posedge i_sample_sync_ns_100ns_edge) begin
        if(i_sample_sync_ns_100ns_edge) begin
            avg_dat_cnt_ns_100_wr <= sample_dat_cnt_ns_100_wr ;
            avg_dat_cnt_ns_100_rd <= sample_dat_cnt_ns_100_rd ;
            avg_dat_cnt_ns_100_sum<= sample_dat_cnt_ns_100_sum ;
        end
    end

    always @(posedge i_sample_sync_ns_500ns_edge) begin
        if(i_sample_sync_ns_500ns_edge) begin
            avg_dat_cnt_ns_500_wr <= sample_dat_cnt_ns_500_wr ;
            avg_dat_cnt_ns_500_rd <= sample_dat_cnt_ns_500_rd ;
            avg_dat_cnt_ns_500_sum<= sample_dat_cnt_ns_500_sum ;
        end
    end

    always @(posedge i_sample_sync_ns_1000ns_edge) begin
        if(i_sample_sync_ns_1000ns_edge) begin
            avg_dat_cnt_ns_1000_wr <= sample_dat_cnt_ns_1000_wr ;
            avg_dat_cnt_ns_1000_rd <= sample_dat_cnt_ns_1000_rd ;
            avg_dat_cnt_ns_1000_sum<= sample_dat_cnt_ns_1000_sum ;
        end
    end

    always @(posedge i_sample_sync_ns_10000ns_edge) begin
        if(i_sample_sync_ns_10000ns_edge) begin
            avg_dat_cnt_ns_10000_wr <= sample_dat_cnt_ns_10000_wr ;
            avg_dat_cnt_ns_10000_rd <= sample_dat_cnt_ns_10000_rd ;
            avg_dat_cnt_ns_10000_sum<= sample_dat_cnt_ns_10000_sum ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            awready_d <= 1'b0 ;
            awvalid_d <= 1'b0 ;
            arready_d <= 1'b0 ;
            arvalid_d <= 1'b0 ;
        end
        else begin
            awready_d <= awready ;
            awvalid_d <= awvalid ;
            arready_d <= arready ;
            arvalid_d <= arvalid ;
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            burst_boundary_addr_wr <= 32'h0 ;
        end
        else begin
            if(awvalid&awready) begin
                burst_boundary_addr_wr <= awaddr + burst_dat_cnt_wr - 32'h1 ;
            end
            if(arvalid&arready) begin
                burst_boundary_addr_rd <= awaddr + burst_dat_cnt_rd - 32'h1 ;
            end
        end
    end

    assign addr_out_range_wr = (awready_d&awvalid_d& ((burst_boundary_addr_wr<i_addr_range_wr_min)||(burst_boundary_addr_wr>=i_addr_range_wr_max))) ;
    assign addr_out_range_rd = (arready_d&arvalid_d& ((burst_boundary_addr_rd<i_addr_range_rd_min)||(burst_boundary_addr_rd>=i_addr_range_rd_max))) ;

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            addr_out_range <= 1'b0 ;
        end
        else if (i_addr_range_check_en) begin
            if (addr_out_range_wr|addr_out_range_rd) begin
                addr_out_range <= 1'b1 ;
            end
            else begin
                addr_out_range <= 1'b0 ;
            end
        end
    end

    assign resp_err_flag_b = (bvalid&bready&bresp[1]) ;
    assign resp_err_flag_r = (rvalid&rready&rresp[1]) ;

    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            resp_err_flag <= 1'b0 ;
        end
        else if (resp_err_flag_b||resp_err_flag_r) begin
            resp_err_flag <= 1'b1 ;
        end
        else begin
            resp_err_flag <= 1'b0 ;
        end
    end

    // bl statistic
    genvar gen_len_i ;
    generate
        for (int gen_len_i = 0; gen_len_i < 21; gen_len_i ++) begin:GEN_BURST_LENGTH_CNT
            always @(posedge aclk or negedge aresetn) begin
                if(!aresetn) begin
                    burst_length_cnt_wr[gen_len_i] <= 20'h0 ;
                    burst_length_cnt_rd[gen_len_i] <= 20'h0 ;
                end
                else if(dat_traffic_statistic_clr_d[1]) begin
                    burst_length_cnt_wr[gen_len_i] <= 20'h0 ;
                    burst_length_cnt_rd[gen_len_i] <= 20'h0 ;
                end
                else if (dat_traffic_statistic_en_d[1]) begin
                    if(gen_len_i<16) begin
                        if(awready&awvalid)&&(awlen == gen_len_i)) begin
                            burst_length_cnt_wr[gen_len_i] <= burst_length_cnt_wr[gen_len_i] + 20'h1 ;
                        end
                        if(arready&arvalid)&&(arlen == gen_len_i)) begin
                            burst_length_cnt_rd[gen_len_i] <= burst_length_cnt_rd[gen_len_i] + 20'h1 ;
                        end
                    end
                    else begin
                        //write
                        if((awready&awvalid)&&(awlen > 15)&&(awlen<31)) begin
                            burst_length_cnt_wr[16] <= burst_length_cnt_wr[16] + 20'h1 ;
                        end
                        if((awready&awvalid)&&(awlen == 31)) begin
                            burst_length_cnt_wr[17] <= burst_length_cnt_wr[17] + 20'h1 ;
                        end
                        if((awready&awvalid)&&(awlen > 31)) begin
                            burst_length_cnt_wr[18] <= burst_length_cnt_wr[18] + 20'h1 ;
                        end
                        if((awready&awvalid)&&(awlen == 63)) begin
                            burst_length_cnt_wr[19] <= burst_length_cnt_wr[19] + 20'h1 ;
                        end
                        if((awready&awvalid)&&(awlen > 63)) begin
                            burst_length_cnt_wr[20] <= burst_length_cnt_wr[20] + 20'h1 ;
                        end
                        //read
                        if((arready&arvalid)&&(arlen > 15)&&(arlen<31)) begin
                            burst_length_cnt_rd[16] <= burst_length_cnt_rd[16] + 20'h1 ;
                        end
                        if((arready&arvalid)&&(arlen == 31)) begin
                            burst_length_cnt_rd[17] <= burst_length_cnt_rd[17] + 20'h1 ;
                        end
                        if((arready&arvalid)&&(arlen > 31)) begin
                            burst_length_cnt_rd[18] <= burst_length_cnt_rd[18] + 20'h1 ;
                        end
                        if((arready&arvalid)&&(arlen == 63)) begin
                            burst_length_cnt_rd[19] <= burst_length_cnt_rd[19] + 20'h1 ;
                        end
                        if((arready&arvalid)&&(arlen > 63)) begin
                            burst_length_cnt_rd[20] <= burst_length_cnt_rd[20] + 20'h1 ;
                        end
                    end
                end
            end
        end
    endgenerate

    // addr range Error 
    generate
        if(VIP_SIM) begin : ADDR_RANGE_MSG
            always @(addr_out_range) begin
                if(addr_out_range_wr) begin
                    $display("axi_monitor Error: Write addr out range occurred (%0t), burst_boundary_addr  [0x%h:0x%h], burst_length_cnt_wr = 0x%h of %m",$time, i_addr_range_wr_min,i_addr_range_wr_max,burst_boundary_addr_wr) ;
                end
                if(addr_out_range_rd) begin
                    $display("axi_monitor Error: Read addr out range occurred (%0t), burst_boundary_addr  [0x%h:0x%h], burst_length_cnt_rd = 0x%h of %m",$time, i_addr_range_rd_min,i_addr_range_rd_max,burst_boundary_addr_rd) ;
                end
                
            end
        end
    endgenerate

    // resp Error
    generate 
        if(VIP_SIM) begin : RESP_MSG
            always @(posedge resp_err_flag_b or posedge resp_err_flag_r) begin
                if(resp_err_flag_b) begin
                    $display(" axi_monitor Error : Write resp channel error occurred (%0t), bresp = 2'b%b of %m ", $time, bresp) ;
                end
                if(resp_err_flag_r) begin
                    $display(" axi_monitor Error : Read resp channel error occurred (%0t), rresp = 2'b%b of %m ", $time, rresp) ;
                end
                
            end
        end
    endgenerate

    // display

    generate
        if(VIP_SIM) begin : STATISTIC_MSG
            realtime traffic_statistic_begin_time ;
            realtime traffic_statistic_end_time ;
            realtime traffic_statistic_time ;
            real     traffic_statistic_bandwidth_wr ;
            real     traffic_statistic_bandwidth_rd ;
            real     traffic_statistic_total_bandwidth_ratio ;

            real     bus_bandwidth_ratio_ns_10_rd ;
            real     bus_bandwidth_ratio_ns_10_wr ;
            real     bus_bandwidth_ratio_ns_10_sum ;
            real     bus_bandwidth_ratio_ns_100_rd ;
            real     bus_bandwidth_ratio_ns_100_wr ;
            real     bus_bandwidth_ratio_ns_100_sum ;
            real     bus_bandwidth_ratio_ns_500_rd ;
            real     bus_bandwidth_ratio_ns_500_wr ;
            real     bus_bandwidth_ratio_ns_500_sum ;
            real     bus_bandwidth_ratio_ns_1000_rd ;
            real     bus_bandwidth_ratio_ns_1000_wr ;
            real     bus_bandwidth_ratio_ns_1000_sum ;
            real     bus_bandwidth_ratio_ns_10000_rd ;
            real     bus_bandwidth_ratio_ns_10000_wr ;
            real     bus_bandwidth_ratio_ns_10000_sum ;

            int display_cnt_i ;

            always @(posedge dat_traffic_statistic_en_neg or posedge dat_traffic_statistic_en_pos) begin
                if(dat_traffic_statistic_en_pos) begin
                    traffic_statistic_begin_time = $realtime ;
                end
                else if (dat_traffic_statistic_en_neg) begin
                    traffic_statistic_end_time = $realtime ;

                    traffic_statistic_time = traffic_statistic_end_time - traffic_statistic_begin_time ;
                    traffic_statistic_bandwidth_rd = ((dat_traffic_stat_cnt_rd*1000000000.0/1024.0)/1024.0)/traffic_statistic_time ;
                    traffic_statistic_bandwidth_wr = ((dat_traffic_stat_cnt_wr*1000000000.0/1024.0)/1024.0)/traffic_statistic_time ;
                    traffic_statistic_total_bandwidth_ratio = 100.0*(traffic_statistic_bandwidth_wr + traffic_statistic_bandwidth_rd)/((DDR_TOTAL_BW*1000000.0/1024.0)/1024.0);

                    $display("\n-------------------------------------------------------------");
                    $display("axi_monitor report for TRAFFIC STATISTIC.\nStart time : %0t,\nEnd time : %0t,\nInstance: %m.",traffic_statistic_begin_time,traffic_statistic_end_time) ;
                    $display("traffic_statistic_read_bus_bandwidth = %.2f MB/s.",traffic_statistic_bandwidth_rd) ;
                    $display("traffic_statistic_read_byte_count    = %0d byte.", dat_traffic_stat_cnt_rd) ;
                    $display("traffic_statistic_read_request_count = %0d.", req_traffic_stat_cnt_rd) ;

                    $display("traffic_statistic_write_bus_bandwidth = %.2f MB/s.",traffic_statistic_bandwidth_wr) ;
                    $display("traffic_statistic_write_byte_count    = %0d byte.", dat_traffic_stat_cnt_wr) ;
                    $display("traffic_statistic_write_request_count = %0d.", req_traffic_stat_cnt_wr) ;

                    //read 
                    $display("axi_monitor report for BURST_LENGTH_STATISTIC.\nStart time: %0t,\nEnd time : %0t,\nInstance: %m.",traffic_statistic_begin_time,traffic_statistic_end_time);
                    for (int display_cnt_i = 0; display_cnt_i < 21; display_cnt_i ++) begin
                        if(display_cnt_i==16) begin
                            $display("ARLEN = [0x10:0x1e], count = %0d/%0d, ratio = %0d%%", burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                        else if(display_cnt_i==17) begin
                            $display("ARLEN = 0x1f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                        else if(display_cnt_i==18) begin
                            $display("ARLEN = [0x20:0x3e], count = %0d/%0d, ratio = %0d%%", burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                        else if(display_cnt_i==19) begin
                            $display("ARLEN = 0x3f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                        else if(display_cnt_i==20) begin
                            $display("ARLEN > 0x3f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                        else begin
                            $display("ARLEN = 0x%2h, count = %0d/%0d, ratio = %0d%%",display_cnt_i, burst_length_cnt_rd[display_cnt_i],req_traffic_stat_cnt_rd,burst_length_cnt_rd[display_cnt_i]*100.0/req_traffic_stat_cnt_rd) ;
                        end
                    end

                    // write
                    for (int display_cnt_i = 0; display_cnt_i < 21; display_cnt_i ++) begin
                        if(display_cnt_i==16) begin
                            $display("AWLEN = [0x10:0x1e], count = %0d/%0d, ratio = %0d%%", burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                        else if(display_cnt_i==17) begin
                            $display("AWLEN = 0x1f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                        else if(display_cnt_i==18) begin
                            $display("AWLEN = [0x20:0x3e], count = %0d/%0d, ratio = %0d%%", burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                        else if(display_cnt_i==19) begin
                            $display("AWLEN = 0x3f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                        else if(display_cnt_i==20) begin
                            $display("AWLEN > 0x3f, count = %0d/%0d, ratio = %0d%%", burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                        else begin
                            $display("AWLEN = 0x%2h, count = %0d/%0d, ratio = %0d%%",display_cnt_i, burst_length_cnt_wr[display_cnt_i],req_traffic_stat_cnt_wr,burst_length_cnt_wr[display_cnt_i]*100.0/req_traffic_stat_cnt_wr) ;
                        end
                    end

                    $display("\n-------------------------------------------------------------");
                end
            end

            always @(*) begin
                bus_bandwidth_ratio_ns_10_rd = (1000.0*avg_dat_cnt_ns_10_rd / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_10_wr = (1000.0*avg_dat_cnt_ns_10_wr / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_10_sum = (1000.0*avg_dat_cnt_ns_10_sum / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_100_rd = (1000.0*avg_dat_cnt_ns_100_rd / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_100_wr = (1000.0*avg_dat_cnt_ns_100_wr / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_100_sum = (1000.0*avg_dat_cnt_ns_100_sum / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_500_rd = (1000.0*avg_dat_cnt_ns_500_rd / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_500_wr = (1000.0*avg_dat_cnt_ns_500_wr / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_500_sum = (1000.0*avg_dat_cnt_ns_500_sum / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_1000_rd = (1000.0*avg_dat_cnt_ns_1000_rd / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_1000_wr = (1000.0*avg_dat_cnt_ns_1000_wr / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_1000_sum = (1000.0*avg_dat_cnt_ns_1000_sum / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_10000_rd = (1000.0*avg_dat_cnt_ns_10000_rd / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_10000_wr = (1000.0*avg_dat_cnt_ns_10000_wr / 10.0 )*100.0/DDR_TOTAL_BW ;
                bus_bandwidth_ratio_ns_10000_sum = (1000.0*avg_dat_cnt_ns_10000_sum / 10.0 )*100.0/DDR_TOTAL_BW ;
            end
        end
    endgenerate

    `include "axi_monitor_latency.svh"
    
endmodule



`endif

// vim: et:ts=4:sw=4:ft=sverilog
