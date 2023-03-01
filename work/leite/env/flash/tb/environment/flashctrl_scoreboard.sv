/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_scoreboard.sv
 * Author : dongj
 * Create : 2023-01-04
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/04 16:16:05
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_SCOREBOARD_SV__
`define __FLASHCTRL_SCOREBOARD_SV__

class flashctrl_scoreboard extends uvm_scoreboard ;
    `uvm_component_utils(flashctrl_scoreboard)

    local int no_transfers ;
    local int no_pass ;
    local int no_errors ;
    int last_read_data ;
    int perfetch_data ;
    bit [4:0] disable_checker ;

    bit flash_pre_program ;
    bit flash_mass_erase ;
    bit unlock ;
    bit supermode_unlock ;
    bit opt_unlock ;
    bit dpd ;
    flashctrl_item::mode_e mode ;
    bit rr_valid[2] ;
    int rr[2] ;
    
    struct packed {
        bit [7:0] rdp_reg ;
        bit [7:0] user ;
        bit [7:0] data0 ;
        bit [7:0] data1 ;
        bit [31:0] wrpr ;
        bit half ;
        bit swdp ;
        bit isp_con ;
        bit rdp ;
        bit oblerr ;
        bit hd_rst ;
        bit wdg_sw ;
        bit boot0_sel ;
        bit boot1 ;
        bit boot0 ;
    } opt ;

    flashctrl_env_config m_cfg ;
    uvm_status_e status ;

    custom_uvm_reg_by_name reg_by_name ;
    custom_uvm_reg_field_by_name field_by_name ;

    uvm_tlm_analysis_fifo#(svt_ahb_transaction) main_fifo ;
    uvm_tlm_analysis_fifo#(svt_ahb_transaction) info_fifo ;

    extern function new (string name = "flashctrl_scoreboard",uvm_component parent = null) ;
    extern virtual function void build_phase(uvm_phase phase) ;
    extern virtual function void connect_phase(uvm_phase phase) ;
    extern task main_phase(uvm_phase phase) ;
    extern task post_main_phase(uvm_phase phase) ;
    extern task post_write_cr(int data) ;
    extern task compare_mirror(string name = "") ;
endclass : flashctrl_scoreboard

function flashctrl_scoreboard::new(string name = "flashctrl_scoreboard", uvm_component parent = null) ;
    super.new(name,parent) ;
endfunction : new

function void flashctrl_scoreboard::build_phase(uvm_phase phase) ;
    super.build_phase(phase) ;
    main_fifo = new("main_fifo",this) ;
    info_fifo = new("info_fifo",this) ;
    reg_by_name = new("reg_by_name") ;
    field_by_name = new("field_by_name") ;
endfunction : build_phase

function void flashctrl_scoreboard::connect_phase(uvm_phase phase) ;
    super.connect_phase(phase) ;
endfunction : connect_phase

task flashctrl_scoreboard::main_phase(uvm_phase phase) ;
    super.main_phase(phase) ;
    reg_by_name.default_rm = m_cfg.fc_rm ;
    field_by_name.default_rm = m_cfg.fc_rm ;

    fork
        forever begin
            uvm_config_db#(int)::wait_modified(this,"*","disable_checker") ;
            uvm_config_db#(int)::get(this,"*","disable_checker", disable_checker) ;
            `uvm_info(get_name,$psprintf("get disable_checker = 'b%0b",disable_checker),UVM_LOW)
        end
    join_none

    fork
        predictor_main() ;
        predictor_info() ;
        predictor_load() ;
        predictor_reset() ;
        predictor_page() ;

        forever begin
            uvm_object tdata ;
            flashctrl_item tmp ;
            uvm_event_poll::get_global("CMD_RESP".wait_trigger_data(tdata) ;
            $cast(tmp, tdata) ;
            if (tmp.resp == flashctrl_item::RESP_OK) begin
                m_cfg.fc_if.advanceClock(1) ;
                $display("%m: compare_mirror @ CMD_RESP @%0t",   $realtime) ;
                compare_mirror() ;
            end
        end

        forever begin
            uvm_object tdata ;
            uvm_reg_item rw ;
            uvm_event_poll::get_global("POST_WRITE").wait_trigger_data(tdata) ;
            $cast(rw, tdata) ;
            $display("%m: POST_WRITE : %s @%0t", rw.element.get_name, $realtime) ;
            case (rw.element.get_name)
                "flash_cr"      : post_write_cr(rw.value[0]) ;
                "flash_bypass"  : post_write_byass(rw.value[0]) ;
                "flash_superkey": post_write_superkey(rw.value[0]) ;
                "flash_dpdkey"  : post_write_dpdkey(rw.value[0]) ;
            endcase
        end
    join    
endtask : main_phase

task flashctrl_scoreboard::post_main_phase(uvm_phase phase) ;
    super.post_main_phase(phase) ;
    phase.raise_objection(this) ;
    `ifndef UPF
    compare_mirror() ;
    `endif
    phase.drop_objection(this) ;
endtask : post_main_phase

task automatic flashctrl_scoreboard::post_write_cr(int data) ;
    if (this.unlock == 0) begin
        `uvm_info(get_name,"ignore write cr without unlock",UVM_LOW)
        return ;
    end

    if (!data[m_cfg.fc_rm.flash_cr.SUPERMODE.get_lsb_pos]) begin
        this.supermode_unlock = 0 ;
        `uvm_info(get_name,"supermode=0",UVM_LOW)
    end

    if (!data[m_cfg.fc_rm.flash_cr.UNLOCK.get_lsb_pos]) begin
        this.unlock = 0 ;
        `uvm_info(get_name,"unlock=0",UVM_LOW)
    end

    if (!data[m_cfg.fc_rm.flash_cr.DPD.get_lsb_pos]) begin
        this.dpd = 0 ;
        `uvm_info(get_name,"dpd=0",UVM_LOW)
    end
    this.mode = field_by_name.get("OP") ;
endtask : post_write_cr

task automatic flashctrl_scoreboard::compare_mirror(string name = "") ;
    int err = 0 ,num ;
    reg [`FLASH_MEM_WIDTH-1:0] dut,mrr ;

    if (name =="") begin
        err = compare_mirror("main") + compare_mirror("info") ;
        return err ;
    end

    case (name)
        "main" : num =  `FLASH_MAIN_DEPTH ;
        "info" : num =  `FLASH_INFO_DEPTH ;
        default: num =  `FLASH_SECT_DEPTH ;
    endcase

    for (int i = 0; i < num; i ++) begin
        mrr = m_cfg.flash_mirror.get(name,i) ;
        dut = m_cfg.flash_if.get_mem(name,i) ;
        if (dut !== mrr) begin
            err ++ ;
            if (err <= 10) begin
                `uvm_error(get_name,$psprintf("compare_mirror: %s [%0d] mismatch: addr=%x dut=%x  mrr=%x",name, i, i*4, dut, mrr))
            end
        end

        if (err == 0) begin
            `uvm_info(get_name,$psprintf("compare_mirror: %s OK",name),UVM_LOW)
        end
        else begin
            `uvm_info(get_name,$psprintf("compare_mirror: %s total mismatch : %d", name, err),UVM_LOW)
        end
    end
endtask : compare_mirror


`endif

// vim: et:ts=4:sw=4:ft=sverilog
