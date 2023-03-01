/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_cell_trans.v1.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 17:23:10
 * Description: 
 * 
 */

`ifndef __XACT_CELL_TRANS_V1_SV__
`define __XACT_CELL_TRANS_V1_SV__

`resetall
`timescale 1ns/1ns
typedef enum {OP_INVALID, OP_WRITE_E, OP_READ_E} op_type_enum ;
typedef enum {INVALID_CHANNEL, A_CHANNEL, W_CHANNEL, R_CHANNEL, B_CHANNEL, T_CHANNEL} axi_channel_e ;
typedef enum {RECORDED, CALCED} op_status_e ;

class perf_methods_base ;
    // data or class properties
    virtual function int get_max_int(int para_a, int para_b) ;
        get_max_int = {para_a > para_b) ? 0 : para_b ;
    endfunction : get_max_int
    virtual function int get_min_int(int para_a, int para_b) ;
        get_min_int = {para_a < para_b) ? para_a : para_b ;
    endfunction : get_min_int

    // initialization
    function new();
    endfunction : new

endclass : perf_methods_base 

class xact_base_trans extends perf_methods_base ;
    // data or class properties
    op_type_enum op_type ;
    int op_data_count ;
    int op_start_time ;
    int op_end_time ;
    op_status_e op_status ;

    // initialization
    function new();
        op_type = OP_INVALID ;
        op_data_count = 0 ;
        op_start_time = 0 ;
        op_end_time = 0 ;
    endfunction : new

    virtual function void set_count(int data_count) ;
        op_data_count = data_count ;
    endfunction : set_count

    virtual function void set_type(op_type_enum op_type) ;
        this.op_type = op_type ;
    endfunction : set_type

    virtual function void set_start_time(int cur_time) ;
        op_start_time = cur_time ;
    endfunction : set_start_time

    virtual function void set_end_time(int cur_time) ;
        op_end_time = cur_time ;
    endfunction : set_end_time
    
    virtual function void set_status(op_status_e op_status) ;
        this.op_status = op_status ;
    endfunction : set_status

    virtual function   op_type_enum get_type() ;
        get_type = op_type ;
    endfunction : get_type

    virtual function int get_count() ;
        get_count = calc_data_count() ;
    endfunction : get_count

    virtual function int get_delay() ;
        get_delay = calc_duration_time ;
    endfunction : get_count

    virtual function op_status_e get_status() ;
        get_status = op_status ;
    endfunction : get_status

    virtual function int  calc_data_count() ;
        calc_data_count = op_data_count ;
    endfunction : calc_data_count

    virtual function int calc_duration_time() ;
        calc_duration_time = op_end_time - op_start_time ;
    endfunction : calc_duration_time

    virtual function int get_start_time() ;
        get_start_time = op_start_time ;
    endfunction : get_start_time

    virtual function int get_end_time() ;
        get_end_time = op_end_time ;
    endfunction : get_end_time  

    function   disp(bit disp_en, string tag="") ;
        if (disp_en) begin
            $display("%m: %s , xact_base_trans MSG : @%0t", tag, realtime) ;
            $display("%m: %s , op_type      : %0s", tag, op_type.name()) ;
            $display("%m: %s , op_data_count: %0d", tag, op_data_count) ;
            $display("%m: %s , op_status    : %0d", tag, op_status) ;
            $display("%m: %s , op_start_time: %0d", tag, op_start_time) ;
            $display("%m: %s , op_end_time  : %0d", tag, op_end_time) ;
        end
    endfunction : disp

endclass : xact_base_trans 

class axi_base_trans extends xact_base_trans ;
    // data or class properties
    axi_channel_e axi_chnl ;
    int     op_id ;
    int     op_len ;
    int     op_burst ;
    int     op_size ;

    // initialization
    function new();
        super.new() ;
        axi_chnl = INVALID_CHANNEL ;
        op_id = 0 ;
        op_len = 0 ;
        op_burst = 0 ;
        op_size = 0 ;
    endfunction : new

    virtual function void set_chnl(axi_channel_e axi_chnl) ;
        this.axi_chnl = axi_chnl ;
    endfunction : set_chnl

    virtual function int set_id(int cur_id) ;
        op_id = cur_id ;
    endfunction : set_id

    virtual function int set_len(int cur_len) ;
        op_len = cur_len ;
    endfunction : set_len

    virtual function int set_burst(int cur_burst) ;
        op_burst = cur_burst ;
    endfunction : set_burst

    virtual function int set_size(int cur_size) ;
        op_size = cur_size ;
    endfunction : set_size

    virtual function axi_channel_e get_chnl() ;
        get_chnl = axi_chnl ;
    endfunction : get_chnl

    virtual function int get_id() ;
        get_id = op_id ;
    endfunction : get_id

    virtual function int get_len() ;
        get_len = op_len ;
    endfunction : get_len

    virtual function int get_burst() ;
        get_burst = op_burst ;
    endfunction : get_burst

    virtual function int get_size() ;
        get_size = op_size ;
    endfunction : get_size

    virtual function int match_id(int cur_id) ;
        match_id = (op_id == cur_id) ;
    endfunction : match_id

    virtual function int calc_data_count() ;
        calc_data_count = (op_len+1) * (2**op_len) ;
    endfunction : calc_data_count

    function   disp(bit disp_en, string tag="") ;
        super.disp(disp_en) ;
        if (disp_en) begin
            $display("%m: %s , axi_base_trans MSG : @%0t", tag, realtime) ;
            $display("%m: %s , axi_chnl     : %0s", tag, axi_chnl.name()) ;
            $display("%m: %s , op_id        : %0d", tag, op_id) ;
            $display("%m: %s , op_len       : %0d", tag, op_len) ;
            $display("%m: %s , op_size      : %0d", tag, op_size);
            $display("%m: %s , op_burst     : %0d", tag, op_burst) ;
        end
    endfunction : disp

endclass : axi_base_trans

class Fifo #(type T=axi_base_trans) ;
    // data or class properties
    T fifo[$] ;
    string name ;
    int data_count ;
    int max_num ;
    int max_num_time ;
    int max_trans_delay ;
    int max_trans_delay_time ;
    int max_cmd_delay ;
    int max_cmd_delay_time ;
    int max_data_delay ;
    int max_data_delay_time ;
    int trans_len [int] ;
    int trans_size [int] ;
    int trans_burst [int] ;
    int total_trans_delay ;
    int total_trans_num ;

    integer ots_file_handle ;
    integer bw_file_handle ;

    // initialization
    function new(string name="default_name");
        max_num = 0 ;
        this.name = name ;
    endfunction : new

    virtual function void put(T item) ;
        fifo.push_back(item) ;
    endfunction : put

    virtual function T get() ;
        get = fifo.pop_front() ;
    endfunction : get

    virtual function int get_num() ;
        get_num = fifo.size() ;
    endfunction : get_num

    virtual function int is_empty() ;
        is_empty = (get_num() == 0) ;
    endfunction : is_empty

    virtual function T get_last() ;
        get_last = fifo[$] ;
    endfunction : get_last

    virtual function T get_first() ;
        get_first = fifo[0] ;
    endfunction : get_first

    virtual function void update_count (int count) ;
        data_count += count ;
    endfunction : update_count 

    virtual function int get_count() ;
        get_count = data_count ;
    endfunction : get_count

    virtual function int get_max_num() ;
        get_max_num = data_max_num ;
    endfunction : get_max_num

    virtual function void set_max_num(int num, int cur_time) ;
        max_num = num ;
        max_num_time = cur_time ;
    endfunction : set_max_num

    virtual function int get_max_trans_delay() ;
        get_max_trans_delay = max_trans_delay ;
        set_total_trans_delay() ;
        set_total_trans_num() ;
    endfunction : get_max_trans_delay

    virtual function void set_max_trans_delay(int delay, int cur_time) ;
        max_trans_delay = delay ;
        max_trans_delay_time = cur_time ;
    endfunction : set_max_trans_delay

    virtual function void set_total_trans_delay() ;
        total_trans_delay += max_trans_delay ;
    endfunction : set_total_trans_delay

    virtual function void set_total_trans_num() ;
        total_trans_num ++ ;
    endfunction : set_total_trans_num

    virtual function int get_total_trans_delay() ;
        get_total_trans_delay = total_trans_delay ;
    endfunction : get_total_trans_delay

    virtual function int get_total_trans_num() ;
        get_total_trans_num = total_trans_num ;
    endfunction : get_total_trans_num

    virtual function int get_max_cmd_delay() ;
        get_max_cmd_delay = max_cmd_delay ;
    endfunction : get_max_cmd_delay

    virtual function void set_max_cmd_delay(int delay, int cur_time) ;
        max_cmd_delay = delay ;
        max_cmd_delay_time = cur_time ;
    endfunction : set_max_cmd_delay

    virtual function int get_max_data_delay() ;
        get_max_data_delay = max_data_delay ;
    endfunction : get_max_data_delay

    virtual function void set_max_data_delay(int delay, int cur_time) ;
        max_data_delay = delay ;
        max_data_delay_time = cur_time ;
    endfunction : set_max_data_delay

    virtual function void add_trans_len(int len) ;
        trans_len[len] ++ ;
    endfunction : add_trans_len

    virtual function string disp_attr(string name, bit disp_en=0) ;
        disp_attr = {disp_attr ,   $sformatf("%s-%s\n" , name, this.name                                ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t data_count       : %0d Byte            \n", data_count  ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_ots_num      : %0d occurs @time %0d\n", max_num, max_num_time) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_trans_delay  : %0d occurs @time %0d\n", max_trans_delay, max_trans_delay_time) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_cmd_delay    : %0d occurs @time %0d\n", max_cmd_delay, max_cmd_delay_time) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_data_delay   : %0d occurs @time %0d\n", max_data_delay, max_cmd_delay_time) } ;
        foreach (trans_len[idx]) begin
            disp_attr = {disp_attr, $sformatf("\t\t\t trans len [%0d] num : %0d \n", idx+1, trans_len[idx] ) } ;
        end
        foreach (trans_size[idx]) begin
            disp_attr = {disp_attr, $sformatf("\t\t\t trans size [%0d] num : %0d \n", idx+1, trans_size[idx] ) } ;
        end
        foreach (trans_burst[idx]) begin
            disp_attr = {disp_attr, $sformatf("\t\t\t trans burst [%0d] num : %0d \n", idx+1, trans_burst[idx] ) } ;
        end
        if (disp_en) begin
            $display("%m: %0s @%0t", disp_attr realtime) ;
        end
        if (!is_empty()) begin
            $display("%m: \t\t\t ERROR ! Left trans to be dealing with : %0d @%0t", get_num(), realtime) ;
        end
    endfunction : disp_attr 

    virtual function void add_trans_size(int size) ;
        trans_size[size] ++ ;
    endfunction : add_trans_size

    virtual function void add_trans_burst(int burst) ;
        trans_burst[burst] ++ ;
    endfunction : add_trans_burst

    virtual function void write_ots() ;
        $fwrite(ots_file_handle, "%0d\n", get_num()) ;
    endfunction : write_ots

    virtual function void write_bw() ;
        $fwrite(bw_file_handle, "%0d\n", get_num()) ;
    endfunction : write_bw

endclass : Fifo 

class AsoArray #(type T0=Fifo, type T1=axi_base_trans, type IDX_TYPE=int) ;
    // data or class properties
    T0 #(T1) f_array[IDX_TYPE] ;
    T0 #(T1) me ;
    string name ;
    int data_count ;
    int max_ots_num ;
    int max_ots_num_time ;
    int reorder_occurs ;
    integer ots_file_handle ;
    integer bw_file_handle ;

    // initialization
    function new(string name="default_name");
        this.name = name ;
    endfunction : new

    virtual function void put(IDX_TYPE idx) ;
        f_array[idx] = me ;
    endfunction : put

    virtual function T0#(T1) get(IDX_TYPE idx) ;
        get = f_array[idx] ;
    endfunction : get

    virtual function int get_num() ;
        get_num = f_array.size() ;
    endfunction : get_num

    virtual function int is_empty() ;
        is_empty = (get_num()==0)
    endfunction : is_empty

    virtual function int is_exist(IDX_TYPE idx) ;
        is_exist = f_array.exist(idx) ;
    endfunction : is_exist

    virtual function void create(string name="default_name") ;
        me = new(name) ;
    endfunction : create

    virtual function void update_count() ;
        data_count += count ;
    endfunction : update_count

    virtual function int get_count() ;
        get_count = data_count ;
    endfunction : get_count

    virtual function int get_max_num() ;
        get_max_num = max_ots_num ;
    endfunction : get_max_num

    virtual function void set_max_num(int num, int cur_time) ;
        max_ots_num = num ;
        max_ots_num_time = cur_time ;
    endfunction : set_max_num

    virtual function int get_ots_num ()
        foreach (f_array[i]) begin
            get_ots_num += f_array[i].get_num() ;
        end
    endfunction : get_ots_num

    virtual function int get_id_by_min_start_time() ;
        int start_time_queue[int] ;
        int start_time_queue_tmp[$] ;
        foreach (f_array[i]) begin
            if (f_array[i].get_first() != null) begin
                start_time_queue[f_array[i].get_first().get_id()] = f_array[i].get_first().get_start_time() ;
            end
        end
        start_time_queue_tmp = start_time_queue.min() ;
        if (start_time_queue_tmp.size() > 1) begin
            $display("%m: %s-%s Fatal ! more than one trans share same start time @%0t", name, this.name, realtime) ;
        end

        foreach (start_time_queue[i]) begin
            if (start_time_queue[i] == start_time_queue_tmp[0]) begin
                get_id_by_min_start_time = i ;
            end
        end
        start_time_queue.delete() ;
        start_time_queue_tmp.delete() ;
    endfunction : get_id_by_min_start_time

    virtual function void set_reorder(int cur_time) ;
        reorder_occurs ++ ;
        $display("%m: %s-%s reorder_occurs @%0t", name, this.name, realtime) ;
    endfunction : set_reorder

    virtual function string disp_attr(string name, bit disp_en=0) ;
        disp_attr = {disp_attr ,   $sformatf("%s-%s\n" , name, this.name                                ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t trans type_num   : %0d                 \n", get_num() ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t data_count       : %0d Byte            \n", data_count  ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t reorder_occurs   : %0d time            \n", reorder_occurs ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_ots_num      : %0d occurs @time %0d\n", max_num, max_num_time) } ;
        if (disp_en) begin
            $display("%m: %0s @%0t", disp_attr realtime) ;
        end
        foreach (f_array[i]) begin
            disp_attr = {disp_attr, f_array[i].disp_attr({name,"-",this.name}) } ;
        end
    endfunction : disp_attr

    virtual function void write_ots() ;
        foreach (f_array[idx]) begin
            f_array[i].write_ots() ;
        end
    endfunction : write_ots

    virtual function void write_bw() ;
        foreach (f_array[idx]) begin
            f_array[i].write_bw() ;
        end
    endfunction : write_bw


endclass : AsoArray 

class perf_base_trans #(type T0=AsoArray, type T1=Fifo, type T2=axi_base_trans, type IDX0_TYPE=int, type IDX1_TYPE=op_type_enum) ;
    // data or class properties
    T0 #(T1, T2, IDX0_TYPE) a_array[IDX1_TYPE]
    T0 #(T1, T2, IDX0_TYPE) me ;
    int data_count ;
    int item_num ;
    string name ;
    integer bw_file_handle ;

    // initialization
    function new(string name="default_name");
        this.name = name ;
    endfunction : new

    virtual function void put(IDX1_TYPE idx) ;
        a_array[idx] = me ;
    endfunction : put

    virtual function T0#(T1, T2, IDX0_TYPE) get(IDX1_TYPE idx) ;
        get = a_array[idx] ;
    endfunction : get

    virtual function int get_num() ;
        get_num = a_array.size() ;
    endfunction : get_num

    virtual function int is_empty() ;
        is_empty = (get_num()==0)
    endfunction : is_empty

    virtual function int is_exist(IDX1_TYPE idx) ;
        is_exist = a_array.exist(idx) ;
    endfunction : is_exist

    virtual function void create(string name="default_name") ;
        me = new(name) ;
    endfunction : create

    virtual function void update_count() ;
        data_count += count ;
    endfunction : update_count

    virtual function int get_count() ;
        get_count = data_count ;
    endfunction : get_count

    virtual function void write_bw() ;
        foreach (a_array[i]) begin
            a_array[i].write_bw() ;
        end
    endfunction : write_bw

    virtual function void write_ots() ;
        foreach (a_array[i]) begin
            a_array[i].write_ots() ;
        end
    endfunction : write_ots

endclass : perf_base_trans 

class perf_axi_trans extends perf_base_trans ;
    // data or class properties
    int max_trans_delay_queue[IDX1_TYPE] ;
    int max_cmd_delay_queue[IDX1_TYPE] ;
    int max_data_delay_queue[IDX1_TYPE] ;
    real avg_trans_delay_queue[IDX1_TYPE] ;
    
    virtual xact_axi_intf vif ;

    // initialization
    function new(string name="default_name");
        super.new(name) ;
    endfunction : new

    virtual function perf_axi_trans get_me() ;
        get_me = this ;
    endfunction : get_me

    virtual function void update_delay() ;
        update_trans_delay() ;
        update_cmd_delay() ;
        update_data_delay() ;
    endfunction : update_delay

    virtual function void update_trans_delay() ;
        int delay_queue[$]
        foreach ( a_array[i] ) begin
            foreach (a_array[i].f_array[j]) begin
                delay_queue.push_back(a_array[i].f_array[j].get_max_trans_delay()) ;
            end
            delay_queue.rsort() ;
            max_trans_delay_queue[i] = delay_queue[0] ; 
            delay_queue = {} ;
        end
    endfunction : update_trans_delay

    virtual function void update_cmd_delay() ;
        int delay_queue[$]
        foreach ( a_array[i] ) begin
            foreach (a_array[i].f_array[j]) begin
                delay_queue.push_back(a_array[i].f_array[j].get_max_cmd_delay()) ;
            end
            delay_queue.rsort() ;
            max_cmd_delay_queue[i] = delay_queue[0] ; 
            delay_queue = {} ;
        end
    endfunction : update_cmd_delay

    virtual function void update_data_delay() ;
        int delay_queue[$]
        foreach ( a_array[i] ) begin
            foreach (a_array[i].f_array[j]) begin
                delay_queue.push_back(a_array[i].f_array[j].get_max_data_delay()) ;
            end
            delay_queue.rsort() ;
            max_data_delay_queue[i] = delay_queue[0] ; 
            delay_queue = {} ;
        end
    endfunction : update_data_delay

    virtual function void calc_avg_trans_delay() ;
        bit [63:0] total_trans_delay ;
        bit [63:0] total_trans_num ;
        foreach (a_array[i]) begin
            foreach ( a_array[i].f_array[j] ) begin
                total_trans_delay += a_array[i].f_array[j].get_total_trans_delay() ;
                total_trans_num   += a_array[i].f_array[j].get_total_trans_num() ;
            end
            avg_trans_delay_queue[i] = (1.0*total_trans_delay) / total_trans_num ;
        end
    endfunction : calc_avg_trans_delay

    virtual function string disp_attr(string name) ;
        disp_attr = {disp_attr ,   $sformatf("%s-%s\n" , name, this.name                                ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t trans type_num   : %0d                 \n", get_num() ) } ;
        disp_attr = {disp_attr ,   $sformatf(" \t\t\t data_count       : %0d Byte            \n", data_count  ) } ;
        foreach ( max_trans_delay_queue[i] ) 
            disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_trans_delay_queue[%s] : %0d\n", i.name(), max_trans_delay_queue[i]) } ;
        calc_avg_trans_delay() ;
        foreach ( avg_trans_delay_queue[i] ) 
            disp_attr = {disp_attr ,   $sformatf(" \t\t\t avg_trans_delay_queue[%s] : %0d\n", i.name(), avg_trans_delay_queue[i]) } ;
        foreach ( max_cmd_delay_queue[i] ) 
            disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_cmd_delay_queue[%s] : %0d\n", i.name(), max_cmd_delay_queue[i]) } ;
        foreach ( max_data_delay_queue[i] ) 
            disp_attr = {disp_attr ,   $sformatf(" \t\t\t max_data_delay_queue[%s] : %0d\n", i.name(), max_data_delay_queue[i]) } ;
        $display("%m: %0s @%0t", disp_attr, realtime) ;
        foreach (a_array[i]) begin
            disp_attr = {disp_attr, a_array[i].disp_attr({name,"-",this.name})} ;
        end
        
    endfunction : disp_attr

    virtual function void check_trans(axi_base_trans item) ;
        if (item == null) begin
            $display("%m: Fatal ! Uninitialized Item @%0t", realtime) ;
        end

        item.disp(0) ;

        if (item.get_chnl() == T_CHANNEL) begin
            virtual.x10_data_count = data_count ;
        end

        if (!is_exist(item.get_type()) begin
            create(item.get_type().name()) ;
            put(item.get_type()) ;
        end
        else begin
            if (get(item.get_type()) == null) begin
                create(item.get_type().name()) ;
                put(item.get_type()) ;
            end
        end

        if (!get(item.get_type()).is_exist(item.get_id())) begin
            get(item.get_type()).create($sformatf("id_%0d", item.get_id())) ;
            get(item.get_type()).put(item.get_id()) ;
        end
        else begin
            if (get(item.get_type()).get(item.get_id()) == null) begin
                get(item.get_type()).create($sformatf("id_%0d", item.get_id())) ;
                get(item.get_type()).put(item.get_id()) ;
            end
        end

        if (item.get_chnl() == A_CHANNEL) begin : A_CHANNEL
            begin : GET_MAX_DELAY_BETWEEN_CMD
                int cmd_delay ;
                if (get(item.get_type()).get(item.get_id()).get_num() != 0) begin
                    cmd_delay = item.get_start_time() - get(item.get_type()).get(item.get_id()).get_last().get_start_time() ;
                    if (item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_cmd_delay(), cmd_delay)) begin
                        get(item.get_type()).get(item.get_id()).set_max_cmd_delay(item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_cmd_delay(), cmd_delay), item.get_start_time())
                    end
                end
            end

            // record bus behavior
            get(item.get_type()).get(item.get_id()).add_trans_len(itme.get_len()) ;
            get(item.get_type()).get(item.get_id()).add_trans_size(itme.get_size()) ;
            get(item.get_type()).get(item.get_id()).add_trans_burst(itme.get_burst()) ;

            // updata data count
            get(item.get_type()).get(item.get_id()).update_count(itme.get_count()) ;
            get(item.get_type()).update_count(item.get_count()) ;
            update_count(item.get_count()) ;

            get(item.get_type()).get(item.get_id()).put(item) ;

            begin
                int ots_num ;
                if (item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_num(), get(item.get_type()).get(item.get_id()).get_num())) begin
                    get(item.get_type()).get(item.get_id()).set_max_num(item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_num(), 
                                                                                         get(item.get_type()).get(item.get_id()).get_num(), item.get_start_time()) ;
                end
                if (item.get_max_int(get(item.get_type()).get_max_num, get(item.get_type()).get_ots_num())) begin
                    get(item.get_type()).set_max_num(item.get_max_int(get(item.get_type()).get_max_num(), get(item.get_type()).get_ots_num()), item.get_start_time()) ;
                end
                
            end
        end : A_CHANNEL

        if (item.get_chnl() == W_CHANNEL) begin : W_CHANNEL
            int wdata_delay ;
            if (get(item.get_type()).get(item.get_id()).get_num() != 0) begin
                wdata_delay = item.get_start_time() - get(item.get_type()).get(item.get_id()).get_last().get_start_time() ;
                if (item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_data_delay(), wdata_delay)) begin
                    get(item.get_type()).get(item.get_id()).set_max_data_delay(item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_num(),
                                                                                                wdata_delay), item.get_start_time()) ;
                end
                else begin
                    $display("%m: Fatal ! W_channle before A_channel, Not supported for now @%0t", realtime) ;
                end
            end
        end : W_CHANNEL

        if (item.get_chnl() == R_CHANNEL || item.get_chnl() == B_CHANNEL) begin : RB_CHANNEL
            int trans_delay ;
            if (!itme.match_id(get(item.get_type()).get_id_by_min_start_time())) begin
                get(item.get_type()).set_reorder(item.get_start_time()) ;
            end
            if (get(item.get_type()).get(item.get_id()).get_num() != 0) begin
                get(item.get_type()).get(item.get_id()).get_first().set_end_time(item.get_start_time()) ;
                trans_delay = get(item.get_type()).get(item.get_id()).get_first().get_delay() ;
                if (item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_data_delay(), trans_delay)) begin
                    get(item.get_type()).get(item.get_id()).set_max_trans_delay(item.get_max_int(get(item.get_type()).get(item.get_id()).get_max_data_delay(), 
                                                                                                 trans_delay), item.get_start_time()) ;
                end
                get(item.get_type()).get(item.get_id()).get() ;
            end
            else begin
                $display("%m: Fatal ! RB_channel before A_channel @%0t", , realtime) ;
            end
        end : RB_CHANNEL

        update_delay() ;

        item = null ;
                    
    endfunction : check_trans
    

endclass : perf_axi_trans 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
