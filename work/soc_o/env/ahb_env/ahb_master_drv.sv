/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_drv.sv
 * Author : dongj
 * Create : 2022-12-26
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/26 19:31:11
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_DRV_SV__
`define __AHB_MASTER_DRV_SV__

// COMPARE to 1, must's set end_addr > all data nums
class ahb_master_drv #(type T=ahb_master_trans) ;
// data or class properties
    T TR ;
    mailbox u_mbx ;
    mailbox u_drv2mon_mbx ;
    ahb_xact_trans sub_trans_q[int][$] ;
    int            sub_trans_q_max_size[int] ;
    ahb_xact_trans all_trans_q[$] ;
    virtual ahb_xact_intf u_xact_intf ;
    virtual ctrl_intf u_ctrl_intf ;
    bit stall ;
    int outstanding_num ;

    parameter COMPARE=1 ;

// initialization
    function new(mailbox u_mbx, mailbox u_drv2mon_mbx, virtual ahb_xact_intf u_xact_intf, virtual ctrl_intf u_ctrl_intf);
        this.u_mbx = u_mbx ;
        this.u_drv2mon_mbx = u_drv2mon_mbx ;
        this.u_xact_intf = u_xact_intf ;
        this.u_ctrl_intf = u_ctrl_intf ;
    endfunction : new

    function  ahb_xact_trans create_xact_trans( int t_addr,
                                                int t_type,
                                                int t_len,
                                                int t_id,
                                                int t_burst,
                                                int t_size) ;
        begin
            create_xact_trans = new () ;
            assert( create_xact_trans.randomize() with
            {
                op_addr == t_addr  ;
                op_type == t_type  ;
                op_len  == t_len   ;
                op_id   == t_id    ;
                op_burst== t_burst ;
                op_size == t_size  ;
            }) ;
        end
        
    endfunction: create_xact_trans

    extern task body() ;
    extern virtual task get_tr() ;
    extern virtual task check_tr() ;
    extern virtual task extract_tr() ;
    extern virtual task gen_cmd_buf(input bit[7:0] bus_id,bit[7:0] master_id,bit[7:0] sub_master_id, 
                        bit[31:0] base_addr, bit[31:0] end_addr, op_type_e sub_op_type, 
                        bit[7:0] burst_id, bit[2:0] burst_type, bit[3:0] burst_size,
                        bit[7:0] burst_len, int start_point, int left_len, 
                        int burst_interval, int burst_wait_num, int burst_nums, 
                        int burst_bundle_nums) ;
    extern virtual task arbit_tr() ;
    extern virtual task send_tr() ;
    extern virtual task transmit() ;
    extern function int addr_boundary_check(bit [31:0]base_addr, end_addr, bit[3:0] trans_size) ;


endclass : ahb_master_drv #

task ahb_master_drv::body () ;
    begin
        $display("%m: Drv Body Begin @%0t", , realtime) ;
        get_tr() ;
        check_tr() ;
        transmit() ;
    end
endtask : body 

task automatic ahb_master_drv::get_tr() ;
    begin
        u_mbx.get(TR) ;
        u_xact_intf.FREQ = TR.FREQ ;
        $display("%m: Get One TR @%0t",   realtime) ;
    end
endtask : get_tr

task automatic ahb_master_drv::check_tr() ;
    begin
        outstanding_num = 1 ;
    end
endtask : check_tr

task automatic ahb_master_drv::gen_cmd_buf( input bit[7:0] bus_id, bit[7:0] master_id, bit[7:0] sub_master_id, 
                                            bit[31:0] base_addr, bit[31:0] end_addr, op_type_e sub_op_type, 
                                            bit[7:0] burst_id, bit[2:0] burst_type, bit[3:0] burst_size,
                                            bit[7:0] burst_len, int start_point, int left_len, 
                                            int burst_interval, int burst_wait_num, int burst_nums, 
                                            int burst_bundle_nums) ;
    begin : GEN_CMD_REQ
        int record_len ;
        bit [63:0] local_addr ;
        bit        burst_type_tmp ;
        int trans_size ;
        ahb_xact_trans xact_tr ;
        trnas_size = (burst_len+1) * (2**burst_size) ;//byte
        local_addr = base_addr ;
        u_xact_intf.insert_delay(start_point) ;
        u_xact_intf.start_point = 1 ;
        $display("\n") ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] burst_nums           : %0d  @%0t", bus_id, master_id, sub_master_id, burst_nums, realtime) ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] burst_bundle_nums    : %0d  @%0t", bus_id, master_id, sub_master_id, burst_bundle_nums, realtime) ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] burst_wait_num       : %0d  @%0t", bus_id, master_id, sub_master_id, burst_wait_num, realtime) ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] burst_interval       : %0d  @%0t", bus_id, master_id, sub_master_id, burst_interval, realtime) ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] base_addr            : %0d  @%0t", bus_id, master_id, sub_master_id, base_addr, realtime) ;
        $display("\n") ;
        u_ctrl_intf.active_drv ++ ;
        for (int idx = 0; idx < burst_bundle_nums; idx ++) begin // one valid line 
            fork
                begin
                    for (int item = 0; item < burst_nums; item ++) begin
                        if ((11'(local_addr[9:0] + trans_size) > 'h400) && (burst_type%2>0) ) begin//cross 1K
                            int firs_len = 0 ;
                            int second_len = 0 ;
                            int first_trans_size ;
                            int second_trans_size ;

                            first_len = ('h400 - local_addr[9:0]) / (2**burst_size) ;
                            first_trans_size = first_len * (2**burst_size) ;
                            second_len = left_len - first_len ;
                            second_trans_size = second_len * (2**burst_size) ;
                            burst_type_tmp =1 ; 

                            //first trans
                            xact_tr = create_xact_trans(local_addr, sub_op_type, first_len, burst_id, burst_type_tmp, burst_size) ;
                            xact_tr.disp(0, "sub") ;
                            sub_trans_q[sub_master_id].push_back(xact_tr) ;
                            xact_tr = null ;

                            //loop back
                            local_addr = addr_boundary_check(base_addr, end_addr, first_trans_size) ;
                            record_len++ ;
                            // record max fifo size 
                            if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                            end
                            u_xact_intf.insert_delay(burst_wait_num) ;

                            // sec trans
                            xact_tr = create_xact_trans(local_addr, sub_op_type, second_len, burst_id, burst_type_tmp, burst_size) ;
                            xact_tr.disp(0, "sub") ;
                            sub_trans_q[sub_master_id].push_back(xact_tr) ;
                            xact_tr = null ;

                            //loop back
                            local_addr = addr_boundary_check(base_addr, end_addr, second_trans_size) ;
                            record_len++ ;
                            // record max fifo size 
                            if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                            end
                        end
                        else begin
                            xact_tr = create_xact_trans(local_addr, sub_op_type, burst_len, burst_id, burst_type, burst_size) ;
                            xact_tr.disp(0, "sub") ;
                            sub_trans_q[sub_master_id].push_back(xact_tr) ;
                            xact_tr = null ;

                            //loop back
                            local_addr = addr_boundary_check(base_addr, end_addr, trnas_size) ;
                            record_len++ ;
                            // record max fifo size 
                            if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                            end
                        end
                        u_xact_intf.insert_delay(burst_wait_num) ;
                    end
                    begin : LEFT
                        int left_trans_size ;
                        left_trans_size = left_len * (2**burst_size) ;
                        if (left_len != 'hDEAD) begin
                            // cross 4k boundary
                            if (local_addr[9:0] + left_trans_size > 'h400) begin
                                int firs_len = 0 ;
                                int second_len = 0 ;
                                int first_trans_size ;
                                int second_trans_size ;

                                first_len = ('h400 - local_addr[9:0]) / (2**burst_size) ;
                                first_trans_size = first_len * (2**burst_size) ;
                                second_len = left_len - first_len ;
                                second_trans_size = second_len * (2**burst_size) ;

                                //first trans
                                xact_tr = create_xact_trans(local_addr, sub_op_type, first_len, burst_id, burst_type, burst_size) ;
                                xact_tr.disp(0, "sub") ;
                                sub_trans_q[sub_master_id].push_back(xact_tr) ;
                                xact_tr = null ;

                                //loop back
                                local_addr = addr_boundary_check(base_addr, end_addr, first_trans_size) ;
                                record_len++ ;
                                // record max fifo size 
                                if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                    sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                                end
                                u_xact_intf.insert_delay(burst_wait_num) ;

                                // sec trans
                                xact_tr = create_xact_trans(local_addr, sub_op_type, second_len, burst_id, burst_type, burst_size) ;
                                xact_tr.disp(0, "sub") ;
                                sub_trans_q[sub_master_id].push_back(xact_tr) ;
                                xact_tr = null ;

                                //loop back
                                local_addr = addr_boundary_check(base_addr, end_addr, second_trans_size) ;
                                record_len++ ;
                                // record max fifo size 
                                if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                    sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                                end
                                u_xact_intf.insert_delay(burst_wait_num) ;
                            end
                            else begin
                                xact_tr = create_xact_trans(local_addr, sub_op_type, left_len, burst_id, burst_type, burst_size) ;
                                xact_tr.disp(0, "sub") ;
                                sub_trans_q[sub_master_id].push_back(xact_tr) ;
                                xact_tr = null ;

                                //loop back
                                local_addr = addr_boundary_check(base_addr, end_addr, second_trans_size) ;
                                record_len++ ;
                                // record max fifo size 
                                if (sub_trans_q_max_size[sub_master_id] < sub_trans_q.size()) begin
                                    sub_trans_q_max_size[sub_master_id] = sub_trans_q.size() ;
                                end
                                u_xact_intf.insert_delay(burst_wait_num) ;
                            end
                        end
                    end
                end
                begin
                    u_xact_intf.insert_delay(burst_interval) ;
                end
            join    
            if (record_len < burst_nums) begin
                $display("%m: Fatal, BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] not clear in valid line time, record_len < burst_nums @%0t", bus_id, master_id, sub_master_id, realtime) ;
                $display("%m:        BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] record_len : %0d, burst_nums : %0d @%0t"              , bus_id, master_id, sub_master_id, record_len, burst_nums, realtime) ;
            end
            $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] LINE %0d DONE @%0t", bus_id, master_id, sub_master_id, idx, realtime) ;
            record_len = 0 ;
            if (sub_trans_q[sub_master_id].size() > 0) begin
                $display("%m: Fatal, BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] remains %0d burst at line end @%0t", bus_id, master_id, sub_master_id, sub_trans_q[sub_master_id].size(), realtime) ;
            end
            u_xact_intf.trigger_line_end() ;
        end
    end

    begin : REPORT
        u_ctrl_intf.passive_drv ++ ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] RUN OVER ! @%0t", bus_id, master_id, sub_master_id, realtime) ;
        $display("%m: BUS[%0d] MASTER[%0d] SUB_MASTER[%0d] MAX_CAP : %0d @%0t", bus_id, master_id, sub_master_id, sub_trans_q_max_size[sub_master_id]*burst_len, realtime) ;
    end
endtask : gen_cmd_buf

function int axi_master_drv::addr_boundary_check(bit [31:0]base_addr, end_addr, bit[3:0] trans_size) ;
    int local_addr = 0 ;

    if (local_addr+trnas_size < end_addr) begin
        local_addr += trnas_size ;
    end
    else begin
        local_addr = base_addr ;
    end
    return local_addr ;
endfunction : addr_boundary_check

task automatic ahb_master_drv::extract_tr() ;
    begin
        if (TR.master_en) begin
            $display("\n") ;
            $display("**********************************") ;
            $display("%m: BUS[%0d] MASTER[%0d] Have %0d SUB_MASTER Running @%0t", TR.bus_id. TR.master_id, TR.sub_master_present, realtime) ;
            $display("**********************************") ;
            $display("\n") ;
            for (int idx = 0; idx < TR.sub_master_present; idx ++) begin
                fork
                    begin
                        u_xact_intf.insert_delay(1) ;
                    end
                    if (TR.sub_trans[idx].sub_master_en) begin
                        gen_cmd_buf(TR.sub_trans[idx].bus_id        , TR.sub_trans[idx].master_id       , TR.sub_trans[idx].sub_master_id   ,
                                    TR.sub_trans[idx].sub_base_addr , TR.sub_trans[idx].sub_end_addr    , TR.sub_trans[idx].sub_op_type     ,
                                    TR.sub_trans[idx].sub_burst_id  , TR.sub_trans[idx].sub_burst_type  , TR.sub_trans[idx].sub_burst_size  ,
                                    TR.sub_trans[idx].sub_burst_len , TR.sub_trans[idx].sub_start_point , TR.sub_trans[idx].sub_left_len    ,
                                    TR.sub_trans[idx].burst_interval, TR.sub_trans[idx].burst_wait_num  , TR.sub_trans[idx].burst_nums      ,
                                    TR.sub_trans[idx].burst_bundle_nums
                                ) ;
                    end
                join_any
            end
        end
        else begin
            $display("\n") ;
            $display("**********************************") ;
            $display("%m: BUS[%0d] MASTER[%0d] Disabled @%0t", TR.bus_id. TR.master_id, realtime) ;
            $display("**********************************") ;
            $display("\n") ;
        end
    end
endtask : extract_tr

task automatic ahb_master_drv::send_tr() ;
    forever begin
        for (int idx = 0; idx < TR.sub_master_present ; idx ++) begin
            ahb_xact_trans xact_tr ;
            if (sub_trans_q[idx].size() > 0) begin
                xact_tr = sub_trans_q[idx].pop_front() ;
                all_trans_q.push_back(xact_tr) ;
            end
        end
        u_xact_intf.insert_delay(1) ;
    end
endtask : send_tr

task automatic ahb_master_drv::arbit_tr() ;
    ahb_xact_trans xact_tr_send_q[$] ;
    fork
        forever begin
            ahb_xact_trans xact_tr ;
            if (COMPARE==1) begin
                wait(all_trans_q.size() > 0 && xact_tr_send_q.size() < 5) ;
            end
            else begin
                wait(all_trans_q.size() > 0) ;
            end

            xact_tr = all_trans_q.pop_front() ;
            xact_tr.disp(0,"all") ;

            if (xact_tr.op_type == OP_READ) begin
                bit [63:0] addr ;
                int trans_size ;
                trans_size = xact_tr.op_len * (2**xact_tr.op_size) ; 
                addr = xact_tr.op_addr ;
                for (int i = 0; i < xact_tr.op_len; i ++) begin
                    u_ctrl_intf.set_mem(xact_tr.op_size, addr, xact_tr.op_wdata[i] ;

                    addr += 2**xact_tr.op_size ;
                    if ( (xact_tr.op_burst==='d2 | xact_tr.op_burst==='d4 | xact_tr.op_burst==='d6) && (xact_tr.op_addr%trans_size!==0) ) begin
                        if (addr%trans_size===0) begin
                            addr -= trans_size ;
                        end
                    end
                end
                xact_tr.disp(0, "all:done") ;
            end
            xact_tr_send_q.push_back(xact_tr) ;
            xact_tr = null ;
        end
        
        forever begin
            if (xact_tr_send_q.size() > 0) begin
                ahb_xact_trans xact_tr_send ;
                xact_tr_send = xact_tr_send_q.pop_front() ;
                u_xact_intf.queue_size = xact_tr_send_q.size() ;
                xact_tr_send.disp(0,"all") ;
                
                if (xact_tr.op_type == OP_WRITE) begin
                    u_xact_intf.ahb_write(xact_tr_send.op_addr, xact_tr_send.op_size, xact_tr_send.op_len, xact_tr_send.op_burst, xact_tr_send.op_wdata) ;
                end
                else if (xact_tr.op_type == OP_READ) begin
                    u_xact_intf.ahb_read(xact_tr_send.op_addr, xact_tr_send.op_size, xact_tr_send.op_len, xact_tr_send.op_burst, xact_tr_send.op_rdata) ;
                end
                u_drv2mon_mbx.put(xact_tr_send) ;
                xact_tr_send = null ;
            end
            else begin
                u_xact_intf.insert_delay(1) ;
            end
        end
    join    
endtask : arbit_tr

task automatic ahb_master_drv::transmit() ;
    begin
        fork
            extract_tr() ;
            send_tr() ;
            arbit_tr() ;
        join    
    end
endtask : transmit

`endif

// vim: et:ts=4:sw=4:ft=sverilog
