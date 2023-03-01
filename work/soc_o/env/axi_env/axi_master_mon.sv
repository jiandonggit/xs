/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : axi_master_mon.sv
 * Author : dongj
 * Create : 2022-12-27
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/27 14:32:23
 * Description: 
 * 
 */

`ifndef __AXI_MASTER_MON_SV__
`define __AXI_MASTER_MON_SV__

class axi_master_mon #(parameter B_ID=0, parameter M_ID=0, parameter AXI_LENGTH_WM_IDTH=8) ;
    // data or class properties
    axi_xact_trans exp_tr ;
    axi_xact_trans act_tr ;
    mailbox u_drv2mon_mbx ;
    axi_xact_trans exp_trans_hash[bit [63:0]] ;
    axi_xact_trans act_wr_trans_hash[$] ;
    axi_xact_trans act_rd_trans_hash[$] ;
    byte data_cam[int] ;

    virtual axi_xact_intf #(.B_ID(B_ID), .M_ID(M_ID), .AXI_LENGTH_WM_IDTH(AXI_LENGTH_WM_IDTH)) u_xact_intf ;
    virtual ctrl_intf u_ctrl_intf ;
    virtual ddr_intf u_mem_intf ;

    bit [63:0] op_addr ;
    op_type_e  op_type ;
    bit [ 7:0] op_len ;
    bit [ 3:0] op_size ;
    bit [ 3:0] op_burst ;
    bit [63:0] op_data[] ;
    bit [15:0] op_id ;
    event trig_watch ;

    int burst_nums ;

    int read_comp_cnt ;
    int read_comp_pass_cnt ;
    int read_comp_fail_cnt ;

    parameter COMPARE = 1 ;
    parameter DISP_EN = 0 ;
    parameter TIMEOUT = 200 ;

    parameter SPLIT_BOUNDARY = 16 ;

    // initialization
    function new(mailbox u_drv2mon_mbx, virtual axi_xact_intf #(.B_ID(B_ID), .M_ID(M_ID), .AXI_LENGTH_WM_IDTH(AXI_LENGTH_WM_IDTH) u_xact_intf, virtual ctrl_intf u_ctrl_intf, virtual ddr_intf u_mem_intf);
        begin
            this.u_drv2mon_mbx = u_drv2mon_mbx ;
            this.u_xact_intf = u_xact_intf ;
            this.u_ctrl_intf = u_ctrl_intf ;
            this.u_mem_intf  = u_mem_intf ;
        end
    endfunction : new

    extern task body() ;
    extern virtual task get_tr() ;
    extern virtual task watch_for() ;
    extern virtual task read_compare() ;
    extern virtual task compare() ;
    extern virtual task wr_cam_fill() ;
    extern virtual function proto_analyze(axi_xact_trans TR) ;
    extern virtual function write_compare() ;
endclass : axi_master_mon

task axi_master_mon::body() ;
    begin
        $display("%m: Mon Body Begin @%0t",   realtime) ;
        fork
            get_tr() ;
            watch_for() ;
            compare() ;
            //ddr_mon() ;
        join    
    end
endtask : body

task axi_master_mon::get_tr() ;
    forever  begin
        u_xact_intf.insert_delay(1) ;
        u_drv2mon_mbx.get(exp_tr) ;
        exp_tr.disp(DISP_EN,"mon") ;
        if (exp_tr.op_type == OP_READ) begin
            if (exp_trans_hash.exists({exp_tr.op_id, exp_tr.op_addr}) begin
                $display("%m: ERROR, Already exists TR for addr : %0x, id : %0x @%0t", exp_tr.op_addr, exp_tr.op_id, realtime) ;
            end
            else begin
                exp_trans_hash[{exp_tr.op_id, exp_tr.op_addr}] = exp_tr ;
            end
        end
    end
endtask : get_tr

task automatic axi_master_mon::watch_for() ;
    begin
        forever begin
            u_xact_intf.watch_for(op_addr, op_len, op_size, op_burst, op_type, op_id, op_data) ;
            act_tr = new() ;
            act_tr.op_addr  = op_addr ;
            act_tr.op_len   = op_len ;
            act_tr.op_size  = op_size ;
            act_tr.op_burst = op_burst ;
            act_tr.op_type  = op_type ;
            act_tr.op_id    = op_id ;
            act_tr.op_wdata = new[op_len] ;
            act_tr.op_rdata = new[op_len] ;
            act_tr.op_wdata = op_data ;
            act_tr.op_rdata = op_data ;
            act_tr.cur_time = $realtime ;
            if (act_tr.op_type == OP_WRITE) begin
                act_wr_trans_hash.push_back(act_tr) ;
            end
            else begin
                act_rd_trans_hash.push_back(act_tr) ;
            end
            act_tr = null ;
            if (DISP_EN) begin
                $display("%m: addr : %0x, id : %0x, op_type : %s, op_len : %0d @%0t", op_addr, op_id, op_type.name(), op_len, realtime) ;
            end
            u_xact_intf.ended_xact++ ;
            -> trig_watch ;
        end
    end
endtask : watch_for

task axi_master_mon::compare() ;
    fork
        read_compare() ;
        wr_cam_fill() ;
    join    
endtask : compare

function   axi_master_mon::proto_analyze(axi_xact_trans TR) ;
    int start_addr ;
    int number_bytes ;
    int data_bus_tytes = 8 ;
    int aligned_addr ;
    int burst_len ;
    int wrap_boundary ;
    int lower_byte_lane ;
    int byte_address[$] ;
    int proto_address[$] ;
    byte byte_wdata[$] ;

    int valid_bytes ;
    int proto_bytes ;

    TR.disp(DISP_EN, "proto_analyze") ;

    start_addr      = TR.op_addr ;
    number_bytes    = 2**TR.op_size ;
    burst_len       = TR.op_len + 1 ;
    aligned_addr    = (start_addr/number_bytes) * number_bytes ;
    wrap_boundary   = (start_addr/(number_bytes*burst_len)) * (number_bytes*burst_len) ;

    proto_bytes = burst_len * number_bytes ; 
    valid_bytes = proto_bytes - start_addr % number_bytes ;

    if (DISP_EN) begin
        $display("%m: wrap_boundary : %0x @%0t", wrap_boundary, realtime) ;
    end

    for (int i = 0; i < valid_bytes; i ++) begin
        if (i==0) begin
            byte_address[i] = wrap_boundary ;
        end
        else if ((TR.op_burst==2) & (byte_address[i-1]+1) == (wrap_boundary+proto_bytes)) begin
            byte_address[i] = wrap_boundary ;
        end begin
            byte_address[i] = byte_address[i-1]+1 ;
        end
    end

    for (int i = 0; i < burst_len; i ++) begin
        if (i==0) begin
            proto_address[i] = start_addr ;
        end
        else if ((TR.op_burst==2) && ((proto_address[i-1]+number_bytes) == (wrap_boundary+proto_bytes))) begin
            proto_address[i] = wrap_boundary ; 
        end
        else begin
            proto_address[i] = aligned_addr+i*number_bytes ;
        end
    end

    for (int i = 0; i < burst_len; i ++) begin
        if (i==0) begin
            lower_byte_lane = start_addr - (start_addr/data_bus_tytes) * data_bus_tytes ;    
            for (int j = lower_byte_lane; j < number_bytes; j ++) begin
                byte_wdata.push_back(TR.op_wdata[i][8*j+:8]) ;
            end
        end
        else begin
            lower_byte_lane = proto_address[i] - (proto_address[i]/data_bus_tytes) * data_bus_tytes ;
            for (int j = lower_byte_lane; j < number_bytes; j ++) begin
                byte_wdata.push_back(TR.op_wdata[i][8*j+:8]) ;
            end
        end
    end

    if (byte_address.size() == byte_wdata.size()) begin
        foreach ( byte_address[i] ) begin
            data_cam[byte_address[i]] = byte_wdata[i] ;
        end
    end

    byte_address = {} ;
    byte_wdata = {} ;
    proto_address = {} ;
    
endfunction : proto_analyze

task axi_master_mon::wr_cam_fill() ;
    forever begin
        axi_xact_trans tmp_tr ;
        wait(act_wr_trans_hash.size() !== 0) ;
        tmp_tr = act_wr_trans_hash.pop_front() ;
        proto_analyze(tmp_tr) ;
    end
endtask : wr_cam_fill

function axi_master_mon::write_compare() ;
    int pass_num ;
    int fail_num ;
    int total_num ;
    foreach ( data_cam[idx] ) begin
        byte data_comp ;
        u_ctrl_intf.get_mem(0, idx, data_comp) ;
        if(data_comp !== data_cam[idx]) begin
            $display("%m: Compare ERROR for addr : %0x exp : %0x, act : %0x @%0t", idx, data_cam[idx], data_comp, realtime) ;
            fail_num++ ;
        end
        else begin
            if (DISP_EN) begin
                $display("%m: Compare PASS for addr : %0x exp : %0x, act : %0x @%0t", idx, data_cam[idx], data_comp, realtime) ;
            end
            pass_num++ ;
        end
        total_num++ ;
    end
    $display("%m: COMPARE MSG : WRITE_TOTAL_NUM : %0d, PASS NUM : %0d, FAIL NUM : %0d @%0t", total_num, pass_num, fail_num, realtime) ;
    $display("%m: COMPARE MSG :  REAE_TOTAL_NUM : %0d, PASS NUM : %0d, FAIL NUM : %0d @%0t", read_comp_cnt, read_comp_pass_cnt, read_comp_fail_cnt, $realtime) ;
    
endfunction : write_compare 

task axi_master_mon::read_compare() ;
    forever begin
        bit [63:0] addr_comp ;
        bit [63:0] data_comp ;
        bit [ 2:0] addr_add ;

        int tmp_addr[$] ;
        axi_xact_trans tmp_tr ;
        wait(act_rd_trans_hash.size() !== 0) ;
        tmp_tr = act_rd_trans_hash.pop_front() ;

        addr_comp = tmp_tr.op_addr ;
        addr_add = tmp_tr.op_addr%(2**tmp_tr.op_size) ; //except the first 8bit
        begin
            if (exp_trans_hash.exists({tmp_tr.op_id, tmp_tr.op_addr}) begin
                if (addr_add !==0) begin
                    exp_trans_hash[{tmp_tr.op_id, tmp_tr.op_addr}].op_wdata[0] = exp_trans_hash[{tmp_tr.op_id, tmp_tr.op_addr}].op_wdata[0] << addr_add * 8 ;        
                end

                foreach ( tmp_tr.op_rdata[i] ) begin
                    bit err ;
                    for (int j = 0; j < tmp_tr.op_size ; j ++) begin
                        if (tmp_tr.op_rdata[i][j*8+:8] !== exp_trans_hash[{tmp_tr.op_id, tmp_tr.op_addr}].op_wdata[i][j*8+;8]) begin
                            err = 1 ;
                            read_comp_fail_cnt++ ; 
                        end
                        else begin
                            read_comp_pass_cnt++ ;
                        end
                        read_comp_cnt++ ;
                    end
                    if (err && COMPARE) begin
                        $display("%m: Compare ERROR for addr : %0x, beat : %0d exp : %0x act : %0x @%0t", tmp_tr.op_addr, i , exp_trans_hash[{tmp_tr.op_id, tmp_tr.op_addr}].op_wdata[i], tmp_tr.op_rdata[i], realtime) ;
                    end
                    if (!err && COMPARE && DISP_EN) begin
                        $display("%m: Compare Pass for addr : %0x, beat : %0d exp : %0x act : %0x @%0t", tmp_tr.op_addr, i , exp_trans_hash[{tmp_tr.op_id, tmp_tr.op_addr}].op_wdata[i], tmp_tr.op_rdata[i], realtime) ;
                    end
                end
                exp_trans_hash.delete({tmp_tr.op_id, tmp_tr.op_addr}) ;
                tmp_tr = null ;
            end
            else begin
                $display("%m: ERROR No hash for addr : %0x, id : %0x, op_type : %0x, Put it back @%0t", tmp_tr.op_addr, tmp_tr.op_id, tmp_tr.op_type, realtime) ;
            end
        end
    end
endtask : read_compare


`endif

// vim: et:ts=4:sw=4:ft=sverilog
