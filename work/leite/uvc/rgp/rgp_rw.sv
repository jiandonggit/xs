/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : rgp_rw.sv
 * Author : dongj
 * Create : 2023-02-21
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/21 11:19:30
 * Description: 
 * 
 */

`ifndef __RGP_RW_SV__
`define __RGP_RW_SV__

class rgp_rw extends uvm_sequence_item;
    // data or class properties
    typedef enum {READ, WRITE} kind_e ;
    rand bit   [31:0] addr ;
    rand logic [31:0] data ;
    rand kind_e kind ;

    `uvm_component_utils_begin(rgp_rw)
        `uvm_field_int(addr,UVM_ALL_ON|UVM_NOPACK) ;
        `uvm_field_int(data,UVM_ALL_ON|UVM_NOPACK) ;
        `uvm_field_enum(kind_e,kind, UVM_ALL_ON | UVM_NOPACK) ;
    `uvm_component_utils_end

    // initialization
    function new(string namej = "rgp_rw");
        super.new(name) ;
    endfunction : new

    function string convert2string() ;
        return $sformatf("kind=%s addr=%0h data=%0h",kind,addr,data);
    endfunction : convert2string

endclass : rgp_rw

class reg2rgp_adapter extends uvm_reg_adapter ;
    // data or class properties
    `uvm_object_utils(reg2rgp_adapter)
    
    // initialization
    function new(string name = "reg2rgp_adapter");
        super.new(name) ;
    endfunction : new

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw) ;
        rgp_rw rgp = rgp_rw::type_id::create("rgp_rw") ;
        `uvm_info("reg2rgp_adapter",$psprintf("rw.kind = %s\nrw.addr = %0x\nrw.data = %0x",rw.kind,rw.addr,rw.data),UVM_DEBUG) ;
        rgp.kind = (rw.kind == UVM_READ) ? rgp_rw::READ : rgp_rw::WRITE ;
        rgp.addr = rw.addr ;
        rgp.data = rw.data ;
        return rgp ;
    endfunction : reg2bus

    virtual function void bus2reg(uvm_sequence_item bus_item,
                                  ref uvm_reg_bus_op rw) ;
        rgp_rw rgp ;
        if( !$cast(rgp,bus_item)) begin
            `uvm_fatal("NOT_RGP_TYPE","Provided bus_item is not of the correct type")
            return ; 
        end
        rw.kind = rgp.kind == rgp_rw::READ ? UVM_READ : UVM_WRITE ;
        rw.addr = rgp.addr ;
        rw.data = rgp.data ;
        rw.status = UVM_IS_OK ;
    endfunction : bus2reg

endclass : reg2rgp_adapter 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
