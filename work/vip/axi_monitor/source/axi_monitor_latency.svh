/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_monitor_latency.svh
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 16:11:06
 * Description: 
 * 
 */

`ifndef __AXI_MONITOR_LATENCY_SVH__
`define __AXI_MONITOR_LATENCY_SVH__

id_timestamp q_wr_start_timestamp[$] ;
id_timestamp q_wr_end_timestamp[$] ;
id_timestamp q_rd_start_timestamp[$] ;
id_timestamp q_rd_end_timestamp[$] ;

id_timestamp wr_start_timestamp[$] ;
id_timestamp wr_end_timestamp[$] ;
id_timestamp rd_start_timestamp[$] ;
id_timestamp rd_end_timestamp[$] ;

latency_item wr_burst_latency ;
latency_item rd_burst_latency ;

task automatic detect_wr_starttime();
    forever begin
        @(aclk) ;
        if(dat_traffic_statistic_en_d[1])begin
            if(awready&awvalid) begin
                wr_start_timestamp = new() ;
                wr_start_timestamp.id = awid ;
                wr_start_timestamp.burst_len = awlen ;
                wr_start_timestamp.timestamp = $time ;
                q_wr_end_timestamp.push_back(wr_start_timestamp.copy()) ;
            end
        end
    end
endtask: detect_wr_starttime

task automatic detect_wr_endtime();
    forever begin
        @(aclk) ;
        if(dat_traffic_statistic_en_d[1])begin
            if(awready&awvalid) begin
                wr_end_timestamp = new() ;
                wr_end_timestamp.id = awid ;
                wr_end_timestamp.burst_len = awlen ;
                wr_end_timestamp.timestamp = $time ;
                q_wr_end_timestamp.push_back(wr_end_timestamp.copy()) ;
            end
        end
    end
endtask: detect_wr_endtime

task automatic detect_rd_starttime();
    forever begin
        @(aclk) ;
        if(dat_traffic_statistic_en_d[1])begin
            if(ardeady&awvalid) begin
                rd_start_timestamp = new() ;
                rd_start_timestamp.id = awid ;
                rd_start_timestamp.burst_len = awlen ;
                rd_start_timestamp.timestamp = $time ;
                q_rd_end_timestamp.push_back(rd_start_timestamp.copy()) ;
            end
        end
    end
endtask: detect_rd_starttime

task automatic detect_rd_endtime();
    forever begin
        @(aclk) ;
        if(dat_traffic_statistic_en_d[1])begin
            if(ardeady&awvalid) begin
                rd_end_timestamp = new() ;
                rd_end_timestamp.id = awid ;
                rd_end_timestamp.burst_len = awlen ;
                rd_end_timestamp.timestamp = $time ;
                q_rd_end_timestamp.push_back(rd_end_timestamp.copy()) ;
            end
        end
    end
endtask: detect_rd_endtime

task automatic detect_wr_burst_latency();
    id_timestamp end_time ;
    id_timestamp start_time ;
    realtime temp_latency ;
    forever begin
        wait(q_wr_end_timestamp.size() > 0) ;
        end_time = q_wr_end_timestamp.pop_front() ;

        foreach (q_wr_end_timestamp[i]) begin
            if(q_wr_end_timestamp[i].id === end_time.id) begin
                start_time = q_wr_start_timestamp[i] ;
                if(wr_burst_latency = null) begin
                    wr_burst_latency = new() ;

                    temp_latency = end_time.timestamp - start_time.timestamp ;
                    wr_burst_latency.last_latency = temp_latency ;
                    wr_burst_latency.max_latency = temp_latency ;
                    wr_burst_latency.min_latency = temp_latency ;
                    wr_burst_latency.avg_latency = temp_latency ;
                    // max
                    wr_burst_latency.max_latency_burst_id = start_time.id ;
                    wr_burst_latency.max_latency_burst_length = start_time.burst_len ;
                    wr_burst_latency.max_latency_burst_start_time = start_time.timestamp ;
                    wr_burst_latency.max_latency_burst_end_time = end_time.timestamp ;
                    // min
                    wr_burst_latency.min_latency_burst_id = start_time.id ;
                    wr_burst_latency.min_latency_burst_length = start_time.burst_len ;
                    wr_burst_latency.min_latency_burst_start_time = start_time.timestamp ;
                    wr_burst_latency.min_latency_burst_end_time = end_time.timestamp ;
                end
                else begin
                    temp_latency = end_time.timestamp - start_time.timestamp ;
                    wr_burst_latency.last_latency = temp_latency ;
                    if( wr_burst_latency.min_latency > temp_latency ) begin
                        wr_burst_latency.min_latency = temp_latency ; 
                        wr_burst_latency.min_latency_burst_id = start_time.id ;
                        wr_burst_latency.min_latency_burst_length = start_time.burst_len ;
                        wr_burst_latency.min_latency_burst_start_time = start_time.timestamp ;
                        wr_burst_latency.min_latency_burst_end_time = end_time.timestamp ;
                    end
                    else if( wr_burst_latency.max_latency < temp_latency ) begin
                        wr_burst_latency.max_latency = temp_latency ; 
                        wr_burst_latency.max_latency_burst_id = start_time.id ;
                        wr_burst_latency.max_latency_burst_length = start_time.burst_len ;
                        wr_burst_latency.max_latency_burst_start_time = start_time.timestamp ;
                        wr_burst_latency.max_latency_burst_end_time = end_time.timestamp ;
                    end
                    wr_burst_latency.avg_latency = (wr_burst_latency.avg_latency + temp_latency)/2.0 ;
                end
                q_wr_start_timestamp.delete(i) ;
                break ;
            end
        end
endtask: detect_wr_burst_latency

task automatic detect_rd_burst_latency();
    id_timestamp end_time ;
    id_timestamp start_time ;
    realtime temp_latency ;
    forever begin
        wait(q_rd_end_timestamp.size() > 0) ;
        end_time = q_rd_end_timestamp.pop_front() ;

        foreach (q_rd_end_timestamp[i]) begin
            if(q_rd_end_timestamp[i].id === end_time.id) begin
                start_time = q_rd_start_timestamp[i] ;
                if(rd_burst_latency = null) begin
                    rd_burst_latency = new() ;

                    temp_latency = end_time.timestamp - start_time.timestamp ;
                    rd_burst_latency.last_latency = temp_latency ;
                    rd_burst_latency.max_latency = temp_latency ;
                    rd_burst_latency.min_latency = temp_latency ;
                    rd_burst_latency.avg_latency = temp_latency ;
                    // max
                    rd_burst_latency.max_latency_burst_id = start_time.id ;
                    rd_burst_latency.max_latency_burst_length = start_time.burst_len ;
                    rd_burst_latency.max_latency_burst_start_time = start_time.timestamp ;
                    rd_burst_latency.max_latency_burst_end_time = end_time.timestamp ;
                    // min
                    rd_burst_latency.min_latency_burst_id = start_time.id ;
                    rd_burst_latency.min_latency_burst_length = start_time.burst_len ;
                    rd_burst_latency.min_latency_burst_start_time = start_time.timestamp ;
                    rd_burst_latency.min_latency_burst_end_time = end_time.timestamp ;
                end
                else begin
                    temp_latency = end_time.timestamp - start_time.timestamp ;
                    rd_burst_latency.last_latency = temp_latency ;
                    if( rd_burst_latency.min_latency > temp_latency ) begin
                        rd_burst_latency.min_latency = temp_latency ; 
                        rd_burst_latency.min_latency_burst_id = start_time.id ;
                        rd_burst_latency.min_latency_burst_length = start_time.burst_len ;
                        rd_burst_latency.min_latency_burst_start_time = start_time.timestamp ;
                        rd_burst_latency.min_latency_burst_end_time = end_time.timestamp ;
                    end
                    else if( rd_burst_latency.max_latency < temp_latency ) begin
                        rd_burst_latency.max_latency = temp_latency ; 
                        rd_burst_latency.max_latency_burst_id = start_time.id ;
                        rd_burst_latency.max_latency_burst_length = start_time.burst_len ;
                        rd_burst_latency.max_latency_burst_start_time = start_time.timestamp ;
                        rd_burst_latency.max_latency_burst_end_time = end_time.timestamp ;
                    end
                    rd_burst_latency.avg_latency = (rd_burst_latency.avg_latency + temp_latency)/2.0 ;
                end
                q_rd_start_timestamp.delete(i) ;
                break ;
            end
        end
endtask: detect_rd_burst_latency

task automatic latency_report();
    realtime latency_traffic_statistic_begin_time ;
    realtime latency_traffic_statistic_end_time ;
    realtime latency_traffic_statistic_time ;

    forever begin
        @(posedge dat_traffic_statistic_en_neg or posedge dat_traffic_statistic_en_pos) ;
        if(dat_traffic_statistic_en_pos) begin
            latency_traffic_statistic_begin_time = $realtime ;
        end
        else if (dat_traffic_statistic_en_neg) begin
            latency_traffic_statistic_end_time = $realtime ;

            latency_traffic_statistic_time = latency_traffic_statistic_end_time - latency_traffic_statistic_begin_time ;

            $display("\n--------------------------------------------------") ;
            $display("axi_monitor report for Latency.\nStart time : %-t,\nEnd time : %0t,\nInstance : %m.", latency_traffic_statistic_begin_time,latency_traffic_statistic_end_time);
            if(rd_burst_latency=null) begin
                $display("No Read Transfer occurred within the specified time.") ;
            end
            else begin
                $display("rd_burst_latency:") ;
                rd_burst_latency.display() ;
            end

            if(wr_burst_latency=null) begin
                $display("No Read Transfer occurred within the specified time.") ;
            end
            else begin
                $display("wr_burst_latency:") ;
                wr_burst_latency.display() ;
            end

            q_wr_start_timestamp.delete() ;
            q_wr_end_timestamp.delete() ;
            q_rd_start_timestamp.delete() ;
            q_rd_end_timestamp.delete() ;
            wr_burst_latency = null ;
            rd_burst_latency = null ;
        end
    end
endtask: latency_report

initial begin
    fork
        detect_wr_starttime() ;
        detect_wr_endtime() ;
        detect_wr_burst_latency() ;
        detect_rd_starttime() ;
        detect_rd_endtime() ;
        detect_rd_burst_latency() ;
        latency_report() ;
    join
end



`endif

// vim: et:ts=4:sw=4:ft=sverilog
