/*
 * Copyright (C) xxx Electronic Technology Co., Ltd 
 * 
 * File   : clock_if.sv
 * Author : dongj
 * Create : 2023-02-20
 * 
 * History:
 * ----------------------------------------------------------------
 * Revision: 1.0, dongj @2023/02/20 16:41:18
 * Description: 
 * 
 */

`ifndef __CLOCK_IF_SV__
`define __CLOCK_IF_SV__

interface clock_if #( parameter CLOCK_FREQUENCE = 250, parameter START_PHASE = 10 )();
// nets

    bit CLOCK ;
    real half_cycle ;
    int start_phase ;
    real clock_frequency_set ;
    bit gate_en = 1 ;

    event half_cycle_set_event ;
    event clock_frequency_set_event ;
    event restart_event ;

// clocking

// modports

    initial begin
        CLOCK = 0 ;
        half_cycle = 1000.000/CLOCK_FREQUENCE/2.000 ;
        $display("\nINFO----------CLOCK(%m) %0dMhz, half cycle is initial : %0f",CLOCK_FREQUENCE,half_cycle) ;
        if(START_PHASE == 0) //START_PHASE == 0 means random start_phase
            start_phase = $urandom_range(0,int'(half_cycle*2.00*1000.00));
        else
            start_phase = START_PHASE ;
        #(start_phase*1.0ps) ;

        //Generate clock
        CLOCK = ~CLOCK ;
        forever
        begin : CLOCK_LOOP
            if(restart_event.triggered)
            begin
                CLOCK = 0 ;
                CLOCK = ~CLOCK ;
            end
            #(half_cycle*1.0ns) ;
            CLOCK = ~ CLOCK ;
            CLOCK = CLOCK & gate_en ;
        end
    end

    initial begin
        forever begin
            @(half_cycle) ;
            ->half_cycle_set_event ;
            if(!clock_frequency_set_event.triggered)
            begin
                clock_frequency_set = 1000.000/half_cycle/2.000 ;
                $display("\nINFO----CLOCK(%m) %0fMhz, half cycle set by : %0f @%0t", clock_frequency_set, half_cycle,$time) ;
                -> restart_event ;
                disable CLOCK_LOOP ;
            end
        end
    end

    initial begin
        forever begin
            @(clock_frequency_set) ;
            -> clock_frequency_set_event ;
            if(!half_cycle_set_event.triggered) 
            begin
                half_cycle = 1000/clock_frequency_set/2.00;
                $display("\nINFO----CLOCK(%m) frequency set by %0fMhz, half cycle : %0f @%0t", clock_frequency_set, half_cycle, $time) ;
                -> restart_event ;
                disable CLOCK_LOOP ;
            end
        end
    end

    initial begin
        forever begin
            @(gate_en) ;
            if(gate_en) $display("\nINFO----CLOCK(%m) GATE is opend @%0d", $time) ;
            else        $display("\nINFO----CLOCK(%m) GATE is closed@%0d", $time) ;
        end
    end

endinterface : clock_if


`endif

// vim: et:ts=4:sw=4:ft=sverilog
