/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_axi_mon.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 19:37:53
 * Description: 
 * 
 */

`ifndef __XACT_AXI_MON_SV__
`define __XACT_AXI_MON_SV__

class xact_axi_mon #(type T=int) ;
    // data or class properties
    virtual xact_axi_intf u_xact_intf ;
    mailbox u_mbx ;

    // initialization
    function new(mailbox u_mbx, virtual xact_axi_intf u_xact_intf);
        this.u_mbx = u_mbx ;
        this.u_xact_intf = u_xact_intf ;
    endfunction : new

    extern virtual task body() ;
    extern virtual task sample() ;
    extern virtual task sample_aw() ;
    extern virtual task sample_w() ;
    extern virtual task sample_b() ;
    extern virtual task sample_t() ;
    extern virtual task sample_ar() ;
    extern virtual task sample_r() ;

endclass : xact_axi_mon 

task automatic xact_axi_mon::body() ;
    $display("%m: Drv Body Begin @%0t", realtime) ;
    sample() ;
endtask : body

task automatic xact_axi_mon::sample() ;
    fork
        sample_aw() ;
        sample_w() ;
        sample_b() ;
        sample_t() ;
        sample_ar() ;
        sample_r() ;
    join    
endtask : sample

task automatic xact_axi_mon::sample_aw() ;
    T TR ;
    int len ;
    int size ;
    int burst ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.aw_chnl_samp(len, size, burst, id) ;
        TR.set_type(OP_WRITE_E) ;
        TR.set_chnl(A_CHANNEL) ;
        TR.set_id(id) ;
        TR.set_size(size) ;
        TR.set_burst(burst) ;
        TR.set_start_time(u_xact_intf.get_time()) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_aw

task automatic xact_axi_mon::sample_ar() ;
    T TR ;
    int len ;
    int size ;
    int burst ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.ar_chnl_samp(len, size, burst, id) ;
        TR.set_type(OP_READ_E) ;
        TR.set_chnl(A_CHANNEL) ;
        TR.set_id(id) ;
        TR.set_size(size) ;
        TR.set_burst(burst) ;
        TR.set_start_time(u_xact_intf.get_time()) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_ar

task automatic xact_axi_mon::sample_w() ;
    T TR ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.w_chnl_samp(id) ;
        TR.set_type(OP_WRITE_E) ;
        TR.set_chnl(W_CHANNEL) ;
        TR.set_id(id) ;
        TR.set_start_time(u_xact_intf.get_time()) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_w

task automatic xact_axi_mon::sample_r() ;
    T TR ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.r_chnl_samp(id) ;
        TR.set_type(OP_READ_E) ;
        TR.set_chnl(R_CHANNEL) ;
        TR.set_id(id) ;
        TR.set_start_time(u_xact_intf.get_time()) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_r

task automatic xact_axi_mon::sample_b() ;
    T TR ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.b_chnl_samp(id) ;
        TR.set_type(OP_WRITE_E) ;
        TR.set_chnl(B_CHANNEL) ;
        TR.set_id(id) ;
        TR.set_start_time(u_xact_intf.get_time()) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_b

task automatic xact_axi_mon::sample_t() ;
    T TR ;
    int id ;
    forever begin
        TR = new() ;
        u_xact_intf.t_chnl_samp(id) ;
        TR.set_type(OP_INVALID) ;
        TR.set_chnl(T_CHANNEL) ;
        u_mbx.put(TR) ;
        TR = null  ;
    end
endtask : sample_t



`endif

// vim: et:ts=4:sw=4:ft=sverilog
