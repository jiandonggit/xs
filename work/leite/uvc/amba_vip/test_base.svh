/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : test_base.svh
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 16:47:34
 * Description: 
 * 
 */

`ifndef __TEST_BASE_SVH__
`define __TEST_BASE_SVH__

class base_test extends uvm_test ;
    
virtual task default_axi_slave_response(bit[8:0] delay_mode = 9'b1) ;
    axi_slave_zero_delay_sequence    zero_delay_seq ;
    axi_slave_write_delay_sequence   wr_delay_seq ;

    if(delay_mode[0])  zero_delay_seq = axi_slave_zero_delay_sequence::type_id::create("zero_delay_seq",this) ;
    if(delay_mode[1])  wr_delay_seq = axi_slave_write_delay_sequence::type_id::create("wr_delay_seq",this) ;

    env.axi_system_env.slave[0].sequencer.set_arbitration(SEQ_ARB_RANDOM) ;

    fork
        if(delay_mode[0]) zero_delay_seq.start(env.axi_system_env.slave[0].sequencer) ;
    join_any
    
endtask : default_axi_slave_response

virtual task main_phase(uvm_phase phase) ;
    super.main_phase(phase) ;
    phase.phase_done.set_drain_time(this,2000) ;
    default_axi_slave_response(9'b1) ;
endtask

endclass : base_test 



`endif

// vim: et:ts=4:sw=4:ft=sverilog
