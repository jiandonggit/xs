/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : flashctrl_falsh_mirror.sv
 * Author : dongj
 * Create : 2023-01-03
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/01/03 19:53:39
 * Description: 
 * 
 */

`ifndef __FLASHCTRL_FALSH_MIRROR_SV__
`define __FLASHCTRL_FALSH_MIRROR_SV__

class flashctrl_flash_mirror ;

    // data or class properties
    class Memory #(parameter WIDTH=32, DEFVAL=0);
        // data or class properties
        string name ;
        int depth ;
        bit debug = 0 ;
        reg [WIDTH-1:0] mem[] ;
        // initialization
        function new(string name = "Memory", int depth);
            this.name = name ;
            this.depth = depth ;
            this.mem = new[depth] ;
            foreach (mem[i]) begin
                mem[i] = DEFVAL ;
            end
        endfunction : new

        function void set(int index, reg[WIDTH-1:0]data) ;
            int i = index & ( depth - 1 ) ;
            mem[i] = data ;
            if (debug) $display("%m: set %s[%x]: addr 'h%x - %x @%0t", name, i, index*(WIDTH/8), data, $realtime) ;
        endfunction : set
        function reg [WIDTH-1:0] get(int index) ;
            int i = index & ( depth - 1 ) ;
            get = mem[i]
            if (debug) $display("%m: get %s[%x]: addr 'h%x - %x @%0t", name, i, index*(WIDTH/8), get, $realtime) ;
        endfunction : get
        function void set_all(reg[WIDTH-1:0] val = DEFVAL) ;
            foreach (mem[i]) begin
                mem[i] = val ;
            end
        endfunction : set_all

    endclass : Memory 

    parameter MEM_WIDTH = `FLASH_MEM_WIDTH ;
    parameter PAGE_SIZE = `FLASH_PAGE_SIZE ;
    parameter SECT_SIZE = `FLASH_SECT_SIZE ;
    parameter BANK_SIZE = `FLASH_BANK_SIZE ;
    parameter reg[MEM_WIDTH-1:0] MEM_DEFVAL = `FLASH_MEM_DEFVAL ;

    typedef Memory#(MEM_WIDTH,MEM_DEFVAL) memmory_t ;

    local memmory_t mem[string] ;


    // initialization
    function new();
        mem["main"] = new("main",`FLASH_MAIN_DEPTH) ;
        mem["info"] = new("info",`FLASH_INFO_DEPTH) ;
    `ifdef FLASH_HAS_CFG
        mem["cfg"] = new("cfg", `FLASH_CFG_SIZE/(MEM_WIDTH/8)) ;
    `endif
    `ifdef FLASH_HAS_RR
        mem["rr0"] = new("rr0", `FLASH_RR_SIZE/(MEM_WIDTH/8)) ;
        mem["rr1"] = new("rr1", `FLASH_RR_SIZE/(MEM_WIDTH/8)) ;
    `endif
    endfunction : new

    function int addr2idx(int addr) ;
        addr2idx = addr >> $clog2(MEM_WIDTH/8) ;
    endfunction : addr2idx

    function reg[MEM_WIDTH-1:0] get_pattern(reg[MEM_WIDTH-1:0] pattern, bit random = 0) ;
        if (random) begin
            get_pattern = $urandom ;
            for (int i = 1; i < (WIDTH+31)/32; i ++) begin
                get_pattern |= $urandom << (32*i)
            end
        end
        else begin
            get_pattern = pattern ;
        end
    endfunction : get_pattern

    function Memory#(MEM_WIDTH,MEM_DEFVAL) find_mem(string name) ;
        if (mem.exists(name)) begin
            return mem[name] ;
        end
        foreach (mem[i]) begin
            if (mem[i].name == name) begin
                return mem[i] ;
            end
        end
        $display("%m: Error mem(%s) not found @%0t", name, $realtime) ;
    endfunction : find_mem

    function void erase_page(string name, int page) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < PAGE_SIZE/(MEM_WIDTH/8); i ++) begin
            m.set(page*PAGE_SIZE/(MEM_WIDTH/8)+i, MEM_DEFVAL) ;
        end
        $display("%m: %s: page=%0d @%0t", m.name, page, $realtime) ;
    endfunction : erase_page

    function void erase_sector(string name, int sect) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < SECT_SIZE/PAGE_SIZE; i ++) begin
            this.erase_page(name, sector*(SECT_SIZE/PAGE_SIZE)+i) ;
        end
        $display("%m: %s: sector=%0d @%0t", m.name, sect, $realtime) ;
    endfunction : erase_sector

    function void erase_bank(string name, int bank) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < BANK_SIZE/SECT_SIZE; i ++) begin
            this.erase_sector(name, bank*(BANK_SIZE/SECT_SIZE)+i) ;
        end
        $display("%m: %s: bank=%0d @%0t", m.name, bank, $realtime) ;
    endfunction : erase_bank

    function void erase_all(string name) ;
        memmory_t m = find_mem(name) ;
        m.set_all(MEM_DEFVAL) ;
        $display("%m: %s: @%0t", m.name, $realtime) ;
    endfunction : erase_bank

    function void fill_page(string name, int page, reg[MEM_WIDTH-1:0] pattern, bit random=0) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < PAGE_SIZE/(MEM_WIDTH/8) ; i ++) begin
            mem.set(page*PAGE_SIZE/(MEM_WIDTH/8)+i, get_pattern(pattern,random)) ;
        end
        $display("%m: %s: page=%0d, pattern='h%x, random=%0d @%0t", m.name, page, pattern, random, $realtime) ;
    endfunction : fill_page

    function void fill_sector(string name, int sect, reg[MEM_WIDTH-1:0] pattern, bit random=0) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < SECT_SIZE/PAGE_SIZE; i ++) begin
            this.fill_page(name, sect*(SECT_SIZE/PAGE_SIZE)+i, pattern, random) ;
        end
        $display("%m: %s: sect=%0d, pattern='h%x, random=%0d @%0t", m.name, sect, pattern, random, $realtime) ;
    endfunction : fill_sector

    function void fill_bank(string name, int bank, reg[MEM_WIDTH-1:0] pattern, bit random=0) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < BANK_SIZE/SECT_SIZE; i ++) begin
            this.fill_sector(name, sect*(BANK_SIZE/SECT_SIZE)+i, pattern, random) ;
        end
        $display("%m: %s: bank=%0d, pattern='h%x, random=%0d @%0t", m.name, bank, pattern, random, $realtime) ;
    endfunction : fill_bank

    function void fill_bank_oe(string name, bit oesel, int bank, reg[MEM_WIDTH-1:0] pattern, bit random=0) ;
        memmory_t m = find_mem(name) ;
        for (int i = 0; i < BANK_SIZE/SECT_SIZE; i ++) begin
            if (i%2 == oesel) begin
                this.fill_sector(name, sect*(BANK_SIZE/SECT_SIZE)+i, pattern, random) ;
            end
        end
        $display("%m: %s: bank=%0d, oe=%0d, pattern='h%x, random=%0d @%0t", m.name, bank, oesel, pattern, random, $realtime) ;
    endfunction : fill_bank_oe

    function void fill(string name, reg[MEM_WIDTH-1:0] pattern, bit random=0) ;
        memmory_t m = find_mem(name) ;
        m.set_all(get_pattern(pattern, random)) ;
        $display("%m: %s: pattern='h%x, random=%0d @%0t", m.name, pattern, random, $realtime) ;
    endfunction : fill

    function void write(string name, int addr, reg[MEM_WIDTH-1:0] data, int size=2) ;
        memmory_t m = find_mem(name) ;
        int index = addr2idx(addr) ;
        $display("%m: %x - %x, size=%0d @%0t", addr, data, size, $realtime) ;
        if ((2**size)*8 < MEM_WIDTH) begin
            reg[MEM_WIDTH-1:0] tmp = m.get(index) ;
            for (int i = 0; i < (2**size); i ++) begin
                tmp[(addr($clog2(MEM_WIDTH/8)-1:0]+i)*8+:8] = data[8*i+:8] ;
            end
            m.set(index, tmp) ;
        end
        else begin
            m.set(index, data) ;
        end
    endfunction : write

    function void prog(string name, reg[MEM_WIDTH-1:0] data, int size = 2) ;
        memmory_t m = find_mem(name) ;
        int index = addr2idx(addr) ;
        reg[MEM_WIDTH-1:0] tmp = m.get(index) ;
        $display("%m: %x - %x, size=%0d @%0t", addr, data, size, $realtime) ;
        if (tmp != MEM_DEFVAL) begin
            $display("%m: prog more than once, preview = %x @%0t", tmp, $realtime) ;
        end
        if ((2**size)*8 < MEM_WIDTH) begin
            for (int i = 0; i < (2**size); i ++) begin
                case (MEM_DEFVAL)
                    '0: begin tmp[(addr[$clog2(MEM_WIDTH/8)-1:0]+i)*8+:8] |= data[8*i+;8] end;//only prog 0->1
                    '1: begin tmp[(addr[$clog2(MEM_WIDTH/8)-1:0]+i)*8+:8] &= data[8*i+;8] end;//only prog 1->0
                    default: begin tmp[(addr[$clog2(MEM_WIDTH/8)-1:0]+i)*8+:8] = data[8*i+;8] end;//prog x->val
                endcase
            end
            m.set(index, tmp) ;
        end
        else begin
            case (MEM_DEFVAL)
                '0: begin m.set(index, tmp | data) end;//only prog 0->1
                '1: begin m.set(index, tmp & data) end;//only prog 1->0
                default : m.set(index, data) ;//prog x->val
            endcase
        end
    endfunction : prog

    function reg [MEM_WIDTH-1:0] read(string name, int addr, int size=2) ;
        memmory_t m = find_mem(name) ;
        int index = addr2idx(addr) ;
        reg[MEM_WIDTH-1:0] tmp = m.get(index) ;
        read = 0 ;
        for (int i = 0; i < (2**size); i ++) begin
            read[8*i+:8] = tmp[(addr[$clog2(MEM_WIDTH/8)-1:0]*8+:8] ;
        end
    endfunction : read

    function void set(string name, int index, reg[MEM_WIDTH-1:0] data) ;
        memmory_t m = find_mem(name) ;
        m.set(index,data) ;
    endfunction : set

    function reg[MEM_WIDTH-1:0] get(string name, int index) ;
        memmory_t m = find_mem(name) ;
        return m.get(index) ;
    endfunction : get

endclass : flashctrl_flash_mirror 


`endif

// vim: et:ts=4:sw=4:ft=sverilog
