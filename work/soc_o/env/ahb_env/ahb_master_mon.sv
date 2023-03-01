/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_mon.sv
 * Author : dongj
 * Create : 2022-12-27
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/27 14:32:23
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_MON_SV__
`define __AHB_MASTER_MON_SV__

class ahb_master_mon ; //#(parameter B_ID=0, parameter M_ID=0) ;
    // data or class properties
    ahb_xact_trans exp_tr ;
    ahb_xact_trans act_tr ;
    mailbox u_drv2mon_mbx ;
    ahb_xact_trans exp_write_hash[$] ;
    ahb_xact_trans exp_read_hash[$] ;

    byte data_cam[int] ;

    virtual ahb_xact_intf u_xact_intf ;
    virtual ctrl_intf u_ctrl_intf ;
    virtual ddr_intf u_mem_intf ;

    bit [31:0] op_addr ;
    bit        op_type ;
    bit [ 7:0] op_len ;
    bit [ 3:0] op_size ;
    bit [ 3:0] op_burst ;
    bit [31:0] op_data[] ;
    bit [11:0] op_id ;
    event trig_watch ;
    event trig_wr_done ;
    event trig_rd_done ;

    int comp_cnt ;

    parameter COMPARE = 1 ;
    parameter DISP_EN = 0 ;
    parameter TIMEOUT = 200 ;

    parameter SPLIT_BOUNDARY = 16 ;

    // initialization
    function new(mailbox u_drv2mon_mbx, virtual ahb_xact_intf u_xact_intf, virtual ctrl_intf u_ctrl_intf, virtual ddr_intf u_mem_intf);
        begin
            this.u_drv2mon_mbx = u_drv2mon_mbx ;
            this.u_xact_intf = u_xact_intf ;
            this.u_ctrl_intf = u_ctrl_intf ;
            this.u_mem_intf  = u_mem_intf ;
        end
    endfunction : new

    function int addr_align_16(int addr) ;
        addr_align_16 = (addr >>4) << 4 ;
        if (DISP_EN) begin
            $display("%m: addr : %0x @%0t", addr, realtime) ;
        end
    endfunction : addr_align_16

    extern task body() ;
    extern virtual task get_tr() ;
    extern virtual task read_compare() ;
    extern virtual task wr_cam_fill() ;
    extern virtual function proto_analyze(ahb_xact_trans TR) ;
    extern virtual function write_compare() ;
endclass : ahb_master_mon

task ahb_master_mon::body() ;
    begin
        $display("%m: Mon Body Begin @%0t",   realtime) ;
        fork
            get_tr() ;
            read_compare() ;
            wr_cam_fill() ;
            //ddr_mon() ;
        join    
    end
endtask : body

task ahb_master_mon::get_tr() ;
    forever  begin
        u_xact_intf.insert_delay(1) ;
        u_drv2mon_mbx.get(exp_tr) ;
        exp_tr.cur_time = $realtime ;
        if (exp_tr.op_type == OP_WRITE) begin
            exp_write_hash.push_back(exp_tr) ; 
        end
        else if (exp_tr.op_type == OP_READ) begin
            exp_read_hash.push_back(exp_tr) ;
        end
        exp_tr.disp(DISP_EN,"mon") ;
    end
endtask : get_tr

task ahb_master_mon::wr_cam_fill() ;
    forever begin
        ahb_xact_trans tmp_tr ;
        wait(exp_write_hash.size() !== 0) ;
        tmp_tr = exp_write_hash.pop_front() ;
        proto_analyze(tmp_tr) ;
    end
endtask : wr_cam_fill

function   ahb_master_mon::proto_analyze(ahb_xact_trans TR) ;
    int start_addr ;
    int number_bytes ;
    int data_bus_tytes = 4 ;
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
    burst_len       = TR.op_len ;
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
        else if ( (|TR.op_burst && !TR.op_burst[0]) && (byte_address[i-1]+1) == (wrap_boundary+proto_bytes) ) begin
            byte_address[i] = wrap_boundary ;
        end begin
            byte_address[i] = byte_address[i-1]+1 ;
        end
    end

    for (int i = 0; i < burst_len; i ++) begin
        if (i==0) begin
            proto_address[i] = start_addr ;
        end
        else if ( (|TR.op_burst && !TR.op_burst[0]) && (byte_address[i-1]+number_bytes) == (wrap_boundary+proto_bytes) ) begin
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
    bit [31:0] rdata[] ;
    ahb_xact_trans tmp_tr ;
    forever begin
        wait(exp_read_hash.size()) ;
        tmp_tr = exp_read_hash.pop_front() ;

        int tmp_addr[$] ;
        axi_xact_trans tmp_tr ;
        wait(act_rd_trans_hash.size() !== 0) ;
        tmp_tr = act_rd_trans_hash.pop_front() ;

        if (tmp_tr.op_type == OP_READ) begin
            foreach ( tmp_tr.op_rdata[i] ) begin
                bit err ;
                case (tmp_tr.op_size)
                    0: if(tmp_tr.op_rdata[i][ 7:0]  !== tmp_tr.op_wdata[i][ 7:0])  err = 1 ;
                    1: if(tmp_tr.op_rdata[i][15:0]  !== tmp_tr.op_wdata[i][15:0])  err = 1 ;
                    2: if(tmp_tr.op_rdata[i][31:0]  !== tmp_tr.op_wdata[i][31:0])  err = 1 ;
                end
                endcase

                if (err && COMPARE) begin
                    $display("%m: Compare ERROR for addr : %0x, beat : %0d exp : %0x act : %0x @%0t", tmp_tr.op_addr, i , tmp_tr.op_wdata[i], tmp_tr.op_rdata[i] ) ; 
                end
                if (!err && COMPARE && DISP_EN) begin
                    $display("%m: Compare Pass for addr : %0x, beat : %0d exp : %0x act : %0x @%0t", tmp_tr.op_addr, i , tmp_tr.op_wdata[i], tmp_tr.op_rdata[i] ) ;
                end
            end
            comp_cnt++ ;
            tmp_tr = null ;
        end
        else begin
            $display("%m: data ERROR @%0t", realtime) ;
        end
    end
endtask : read_compare


`endif

// vim: et:ts=4:sw=4:ft=sverilog
