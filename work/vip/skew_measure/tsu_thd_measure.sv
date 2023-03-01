/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : tsu_thd_measure.sv
 * Author : dongj
 * Create : 2023-01-10
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/10 19:44:47
 * Description: 
 * 
 */

`ifndef __TSU_THD_MEASURE_SV__
`define __TSU_THD_MEASURE_SV__


class tsu_thd_measure extends data_skew_measure ;
    // data or class properties
    typedef struct {
        realtime win ;
        realtime stamp ;
        int cnt ;
    } clk_sample_s ;

    realtime record_clk[$] ;
    clk_sample_s min_tsu[$] ;
    clk_sample_s min_thd[$] ;
    

    // initialization
    function new(string name = "tsu_thd_measure", realtime window=1ns, int top=10, bit debug=0);
        super.new(name, window, top, debug) ;
    endfunction : new

    function string sformat_win(clk_sample_s s) ;
        if (s.cnt) begin
            return $sformatf("%.3t @%.3t (%0d)", s.win, s.stamp, s.cnt+1) ;
        end
        else begin
            return $sformatf("%.3t @%.3t", s.win, s.stamp) ;
        end
    endfunction : sformat_win

    function string psdisplay_win(string prefix="", type_="", clk_sample_s s[$]) ;
        psdisplay_win = "" ;
        if (max_skew.size > 1) begin
            psdisplay_win = {psdisplay_win,prefix, "==============================================\n"} ;
            psdisplay_win = {psdisplay_win,prefix, $sformatf(" %s: Top%0d $s\n", name, s.size, type_)} ;
            psdisplay_win = {psdisplay_win,prefix, "----------------------------------------------\n"} ;
            foreach ( s[i] ) begin
                psdisplay_win = {psdisplay_win,prefix, $sformatf(" %2d  %s\n", i, sformat_item(s[i])) } ;
            end
            psdisplay_win = {psdisplay_win,prefix, "==============================================\n"} ;
        end
        else if (s.size == 1) begin
            psdisplay_win = {psdisplay_win,prefix,name,$sformatf(" %s: %s", type_, sformat_item(s[0]))} ;
        end
        else begin
            psdisplay_win = {psdisplay_win,prefix,name, $sformatf(" %s: no record", type_)} ;
        end
    endfunction : psdisplay_win

    function void display(string prefix="") ;
        $display(psdisplay(prefix)) ;
        $display(psdisplay_win(prefix, "min_tsu", min_tsu)) ;
        $display(psdisplay_win(prefix, "min_thd", min_thd)) ;
    endfunction : display

    /*
    *           ___________  _  _____________  _  ____________
    *    data              \/ \/             \/ \/
    *           ___________/\_/\_____________/\_/\____________
    *                      |   |
    *                  ____|__ |      ______        ______
    *    clk      ____|    | |_|____|      |______|      |______
    *                 |--->|   |--->|
    *                  Thd      Tsu
    */

   task calc_tsu_thd() ;
       clk_sample_s tmp_tsu ;
       clk_sample_s tmp_thd ;
       realtime curr_time = $realtime ;
       int find[$] ;

       if (record_clk.size && record.size) begin
           tmp_tsu.win = curr_time - record[$] ;       // data last --> current clk position
           tmp_thd.win = record[0] - record_clk[$] ;   // previous clk position --> data first change
           tmp_tsu.stamp = curr_time ;
           tmp_thd.stamp = curr_time ;

           find = min_tsu.find_first_index with ( item.win == tmp_tsu.win ) ;

           if (tmp_tsu.win < min_tsu[$].win || min_tsu.size < top) begin
               if (find.size) begin
                   min_tsu[find[0]].cnt++ ;
               end
               else begin
                   min_tsu.push_back(tmp_tsu) ;
                   min_tsu.sort with (item.win) ;
                   min_tsu = min_tsu[0:top-1] ;
                   if ( this.debug ) this.display() ;
               end
           end

           if (tmp_thd.win > 0) begin
               find = min_thd.find_first_index with (item.win == tmp_thd.win) ;

               if (tmp_thd.win < min_thd[$].win || min_thd.size < top) begin
                   if (find.size) begin
                       min_thd[find[0]].cnt++ ;
                   end
                   else begin
                       min_thd.push_back(tmp_thd) ;
                       min_thd.sort with (item.win) ;
                       min_thd = min_thd[0:top-1] ;
                       if ( this.debug ) this.display() ;
                   end
               end
           end

           if (record_clk.size >= 3) begin
               record_clk = record_clk[$-2:$] ;
           end
       end

       record_clk.push_back(curr_time) ;

   endtask : calc_tsu_thd

endclass : tsu_thd_measure 

`endif

// vim: et:ts=4:sw=4:ft=sverilog
