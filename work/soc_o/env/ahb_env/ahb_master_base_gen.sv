/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : ahb_master_base_gen.sv
 * Author : dongj
 * Create : 2022-12-26
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2022/12/26 19:28:28
 * Description: 
 * 
 */

`ifndef __AHB_MASTER_BASE_GEN_SV__
`define __AHB_MASTER_BASE_GEN_SV__

class ahb_master_base_gen ;
// data or class properties
    ahb_master_trans TR ;
    mailbox u_mbx ;
    int sub_master_present ;


// initialization
function new();
begin
    
end
endfunction : new

virtual task body() ;
begin
    
end
endtask : body 

endclass : ahb_master_base_gen 



`endif

// vim: et:ts=4:sw=4:ft=sverilog
