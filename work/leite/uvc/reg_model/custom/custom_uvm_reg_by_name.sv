/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : custom_uvm_reg_by_name.sv
 * Author : dongj
 * Create : 2023-01-06
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/06 17:34:24
 * Description: 
 * 
 */

`ifndef __CUSTOM_UVM_REG_BY_NAME_SV__
`define __CUSTOM_UVM_REG_BY_NAME_SV__

class custom_uvm_reg_field_by_name extends uvm_object ;
    `uvm_object_utils(custom_uvm_reg_field_by_name)

    uvm_path_e default_path = UVM_FRONTDOOR ;
    uvm_object default_rm ;
    uvm_status_e status ;
    int default_timeout = 10000 ;

    function new(string name="custom_uvm_reg_field_by_name", uvm_object rm = null, uvm_path_e path = UVM_FRONTDOOR) ;
        super.new(name) ;
        if (rw != null) begin
            this.default_rm = rm ;
        end
        this.default_path = path ;
    endfunction : new

    function uvm_reg_field get_field(string name, uvm_object rm = default_rm, bit rpterr=1) ;
        uvm_reg _reg ;
        uvm_reg_block _block ;

        if (rm == null) begin
            `uvm_fatal(get_name,"Null object")
        end

        if (name.len == 0) begin
            `uvm_error(get_name,"Null name")
            return null ;
        end

        if (name[0] == ".") begin
            name = name.substr(1,name.len-1) ;
        end

        /* type: uvm_reg */
        if ($cast(_reg,rm) begin
            uvm_reg_field fields[$] ;

            _reg.get_fields(fields) ;
            foreach (fields[i]) begin
                string re = uvm_glob_to_re(name) ;
                string f = fields[i].get_full_name() ;
                int p = f.len-name.len ;
                if (name = f || (p>0 && f.substr(p-1,f.len-1) == {".",name})) begin
                    return fields[i] ;
                end
                else if (uvm_re_match(re,f) == 0) begin
                    return fields[i] ;
                end
                else if (uvm_re_match({"/\\.",re.substr(2,re.len-1)},f) == 0) begin
                    return fields[i] ;
                end
            end
        end

        /* type: uvm_reg_block */
        else if ($cast(_block,rm)) begin
            uvm_reg_field ret ;
            uvm_reg subregs[$] ;
            uvm_reg_block blocks[$] ;

            _block.get_registers(subregs) ;
            foreach (subregs[i]) begin
                ret = this.get_field(name, subregs[i], 0) ;
                if ( ret ) return ret ;
            end

            _block.get_blocks(blocks) ;
            foreach ( blocks[i] ) begin
                ret = this.get_field(name, blocks[i], 0) ;
                if ( ret ) return ret ;
            end
        end

        /* type: unknown */ 
        else `uvm_fatal(get_name,"Invalid type: should be uvm_reg or uvm_reg_block")

        if (rpterr) begin
            `uvm_error(get_name,{"get_field:",name," failed"})
        end

        return null ;
    endfunction : get_field

    task update(string name, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            uvm_reg parent = field.get_parent ;
            parent.update(status,path) ;
            $display("[%08x]%s.update: %s='h%0x @%0t", parent.get_address, get_name, parent.get_full_name, parent.get, $realtime) ;
        end
    endtask : update

    task set(string name, int value, bit update=0, uvm_object rm = default_rm, uvm_path_e path=default_path) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            uvm_reg parent = field.get_parent ;
            field.set(value) ;
            $display("[%08x]%s.set: %s='h%0x @%0t", parent.get_address, get_name, parent.get_full_name, parent.get, $realtime) ;
            if ( update ) this.update(name,rm,path) ;
        end
    endtask : set

    task get(string name, uvm_object rm = default_rm) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            get = field.get ;
        end
        else begin
            get = 0 ;
        end
    endtask : get

    task read(string name, output int value, input uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            uvm_reg parent = field.get_parent ;
            parent.read(status,UVM_NO_CHECK,path) ;
            value = this.get(name,rm) ;
        end
        else begin
            value = 0 ;
        end
    endtask : read

    task write(string name, int value, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            uvm_reg parent = field.get_parent ;
            int mask = ((2**field.get_n_bits)-1) << field.get_lsb_pos ;
            int wdata = (parent.get & ~mask)|((value << field.get_lsb_pos)&mask) ;
            parent.write(status, wdata, path) ;
            $display("[%08x]%s.write: %s='h%0x %s='h%0x @%0t", parent.get_address, get_name, parent.get_full_name, wdata, name, value, $realtime) ;
        end
    endtask : write

    task poll(string name, int value, mask='1, to=default_timeout, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        int counter = 0 ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            int tmp ;
            uvm_reg parent = field.get_parent ;
            $display("[%08x]%s.poll: %s='h%0x, mask='h%x, start @%0t", parent.get_address, get_name, field.get_full_name, value, mask, $realtime) ;
            do begin
                read(name,tmp,rm,path) ;
                if (((++counter) %100) == 0) begin
                    $display("[%08x]%s.poll: %s counter=%0d @%0t", parent.get_address, get_name, name, counter, $realtime) ;
                end
            end
            while( (tmp&mask) !== (value&mask) && ((counter<to) || !to)) ;
            if ((counter<to) || !to) begin
                $display("[%08x]%s.poll: %s='h%0x done @%0t", parent.get_address, get_name, field.get_full_name, tmp, $realtime) ;
            end
        end
    endtask : poll

    task mirror(string name, uvm_check_e check=UVM_NO_CHECK, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg_field field = get_field(name,rm) ;
        if (field) begin
            uvm_reg parent = field.get_parent ;
            parent.mirror(status, check, path) ;
        end
    endtask : mirror

    virtual task body() ;
    endtask : body
endclass : custom_uvm_reg_field_by_name


class custom_uvm_reg_by_name extends uvm_object ;
    `uvm_object_utils(custom_uvm_reg_by_name)

    uvm_path_e default_path = UVM_FRONTDOOR ;
    uvm_object default_rm ;
    uvm_status_e status ;
    int default_timeout = 10000 ;

    function new(string name="custom_uvm_reg_by_name", uvm_object rm = null, uvm_path_e path = UVM_FRONTDOOR) ;
        super.new(name) ;
        if (rw != null) begin
            this.default_rm = rm ;
        end
        this.default_path = path ;
    endfunction : new

    function uvm_reg_field get_reg(string name, uvm_object rm = default_rm, bit rpterr=1) ;
        uvm_reg _reg ;
        uvm_reg_block _block ;

        if (rm == null) begin
            `uvm_fatal(get_name,"Null object")
        end

        if (name.len == 0) begin
            `uvm_error(get_name,"Null name")
            return null ;
        end

        if (name[0] == ".") begin
            name = name.substr(1,name.len-1) ;
        end

        /* type: uvm_reg */
        if ($cast(_reg,rm) begin
            string re = uvm_glob_to_re(name) ;
            string f = _reg.get_full_name() ;
            int p = f.len-name.len ;
            if (name = f || (p>0 && f.substr(p-1,f.len-1) == {".",name})) begin
                return _reg ;
            end
            else if (uvm_re_match(re,f) == 0) begin
                return _reg ;
            end
            else if (uvm_re_match({"/\\.",re.substr(2,re.len-1)},f) == 0) begin
                return _reg ;
            end
        end

        /* type: uvm_reg_block */
        else if ($cast(_block,rm)) begin
            uvm_reg_field ret ;
            uvm_reg subregs[$] ;
            uvm_reg_block blocks[$] ;

            _block.get_registers(subregs) ;
            foreach (subregs[i]) begin
                ret = this.get_field(name, subregs[i], 0) ;
                if ( ret ) return ret ;
            end

            _block.get_blocks(blocks) ;
            foreach ( blocks[i] ) begin
                ret = this.get_field(name, blocks[i], 0) ;
                if ( ret ) return ret ;
            end
        end

        /* type: unknown */ 
        else `uvm_fatal(get_name,"Invalid type: should be uvm_reg or uvm_reg_block")

        if (rpterr) begin
            `uvm_error(get_name,{"get_reg:",name," failed"})
        end

        return null ;
    endfunction : get_reg

    task update(string name, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (re) begin
            rg.update(status,path) ;
            $display("[%08x]%s.update: %s='h%0x @%0t", parent.get_address, get_name, parent.get_full_name, parent.get, $realtime) ;
        end
    endtask : update

    task set(string name, int value, bit update=0, uvm_object rm = default_rm, uvm_path_e path=default_path) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            rg.set(value) ;
            $display("[%08x]%s.set: %s='h%0x @%0t", rg.get_address, get_name, rg.get_full_name, value, $realtime) ;
            if ( update ) this.update(name,rm,path) ;
        end
    endtask : set

    task get(string name, uvm_object rm = default_rm) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            get = rg.get ;
        end
        else begin
            get = 0 ;
        end
    endtask : get

    task read(string name, output int value, input uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            rg.read(status,value,path) ;
        end
        else begin
            value = 0 ;
        end
    endtask : read

    task write(string name, int value, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            uvm_reg_block parent = rg.get_parent ;
            rg.write(status, value, path) ;
            $display("[%08x]%s.write: %s='h%0x @%0t", rg.get_address, get_name, rg.get_full_name, value, $realtime) ;
        end
    endtask : write

    task poll(string name, int value, mask='1, to=default_timeout, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        int counter = 0 ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            int tmp ;
            $display("[%08x]%s.poll: %s='h%0x, mask='h%x, start @%0t", rg.get_address, get_name, rg.get_full_name, value, mask, $realtime) ;
            do begin
                read(name,tmp,rm,path) ;
                if (((++counter) %100) == 0) begin
                    $display("[%08x]%s.poll: %s counter=%0d @%0t", rg.get_address, get_name, name, counter, $realtime) ;
                end
            end
            while( (tmp&mask) !== (value&mask) && ((counter<to) || !to)) ;
            if ((counter<to) || !to) begin
                $display("[%08x]%s.poll: %s='h%0x done @%0t", rg.get_address, get_name, rg.get_full_name, tmp, $realtime) ;
            end
            else
                `uvm_error(get_name,{rg.get_full_name,": Timeout !"})
        end
    endtask : poll

    task mirror(string name, uvm_check_e check=UVM_NO_CHECK, uvm_object rm = default_rm, uvm_path_e path = default_path) ;
        uvm_reg rg = get_reg(name,rm) ;
        if (rg) begin
            rg.mirror(status, check, path) ;
        end
    endtask : mirror

    virtual task body() ;
    endtask : body
endclass : custom_uvm_reg_by_name



`endif

// vim: et:ts=4:sw=4:ft=sverilog
