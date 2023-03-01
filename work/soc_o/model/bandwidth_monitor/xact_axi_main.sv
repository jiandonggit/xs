/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : xact_axi_main.sv
 * Author : dongj
 * Create : 2022-12-29
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/29 19:50:26
 * Description: 
 * 
 */

`ifndef __XACT_AXI_MAIN_SV__
`define __XACT_AXI_MAIN_SV__

class xact_axi_main #(type T=perf_axi_trans, type T0=axi_base_trans) ;
    // data or class properties
    T total_trans ;
    virtual xact_axi_intf u_xact_intf ;
    mailbox u_mbx ;

    // initialization
    function T get();
        get = total_trans ;
    endfunction : get 

    function new(mailbox u_mbx, virtual xact_axi_intf u_xact_intf);
        this.u_mbx = u_mbx ;
        this.u_xact_intf = u_xact_intf ;
        total_trans = new(u_xact_intf.type_id) ;
        total_trans.vif = u_xact_intf ;
    endfunction : new

    extern virtual task body() ;
    extern virtual task sample() ;


endclass : xact_axi_main 

task automatic xact_axi_mon::body() ;
    $display("%m: Drv Body Begin @%0t", realtime) ;
    sample() ;
endtask : body

task automatic xact_axi_mon::sample() ;
    forever begin
        T0 proto_trans ;
        u_mbx.get(proto_trans) ;
        total_trans.check_trans(proto_trans) ;
    end
endtask


`endif

// vim: et:ts=4:sw=4:ft=sverilog
