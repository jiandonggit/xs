/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : data_skew_measure.sv
 * Author : dongj
 * Create : 2023-01-10
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/10 19:11:38
 * Description: 
 * 
 */

`ifndef __DATA_SKEW_MEASURE_SV__
`define __DATA_SKEW_MEASURE_SV__


class data_skew_measure ;
    // data or class properties
    string name ;
    realtime window ;
    int top ;
    bit debug ;

    typedef struct {
        realtime skew ;
        realtime stamp ;
        int cnt ;
    } data_skew_s ;

    realtime record[$] ;
    data_skew_s max_skew[$] ;

    // initialization
    function new(string name = "data_skew_measure", realtime window=1ns, int top=10, bit debug=0);
        this.name = name ;
        this.window = window ;
        this.top = top ;
        this.debug = debug ;
    endfunction : new

    function string sformat_item(data_skew_s s) ;
        if (s.cnt) begin
            return $sformatf("%.3t @%.3t (%0d)", s.skew, s.stamp, s.cnt+1) ;
        end
        else begin
            return $sformatf("%.3t @%.3t", s.skew, s.stamp) ;
        end
    endfunction : sformat_item
    
    function string psdisplay(string prefix="") ;
        psdisplay = "" ;
        if (max_skew.size > 1) begin
            psdisplay = {psdisplay,prefix, "==============================================\n"} ;
            psdisplay = {psdisplay,prefix, $sformatf(" %s: Top%0d max_skew\n", name, max_skew.size)} ;
            psdisplay = {psdisplay,prefix, "----------------------------------------------\n"} ;
            foreach ( max_skew[i] ) begin
                psdisplay = {psdisplay,prefix, $sformatf(" %2d  %s\n", i, sformat_item(max_skew[i])) } ;
            end
            psdisplay = {psdisplay,prefix, "==============================================\n"} ;
        end
        else if (max_skew.size == 1) begin
            psdisplay = {psdisplay,prefix,name,$sformatf(" max_skew: %s", sformat_item(max_skew[0]))} ;
        end
        else begin
            psdisplay = {psdisplay,prefix,name," max_skew: no record"} ;
        end
    endfunction : psdisplay

    function void display(string prefix="") ;
        $display(psdisplay(prefix)) ;
    endfunction : display

    task sample() ;
        data_skew_s tmp ;
        realtime curr_time = $realtime ;
        int find[$] ;

        if (record.size && (curr_time - record[$]) > window) begin

            tmp.skew = realtime'(time'((record[$] - record[0])*1000))/1000 ; // keep 3 precision
            tmp.stamp = record[$] ;

            find = max_skew.find_first_index with ( item.skew == tmp.skew ) ;

            if (tmp.skew > max_skew[$].skew || max_skew.size < top) begin
                if (find.size) begin
                    max_skew[find[0]].cnt++ ;
                end
                else begin
                    max_skew.push_back(tmp) ;
                    max_skew.rsort with ( item.skew ) ;
                    max_skew = max_skew[0:top-1] ;
                    if ( this.debug ) this.display() ;
                end
            end

            if (this.debug) begin
                $display("%s: flush record (%0d) @%0t",name, record.size, $realtime) ;
            end
            record.delete() ;
        end

        record.push_back(curr_time) ;

    endtask : sample

endclass : data_skew_measure 




`endif

// vim: et:ts=4:sw=4:ft=sverilog
