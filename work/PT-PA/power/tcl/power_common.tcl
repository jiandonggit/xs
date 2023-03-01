
set_host_options -max_cores 16
set hir "top"
set DESIGN TOP

if { ! [info exists HARDEN] } { 
    set HARDEN 0 
}

if {$HARDEN == 0} { 
    source -e -v ../../setup/common_setup.power.tcl
    source -e -v ../../setup/pt_setup.tcl
} else {
    source -echo -verbose ../rm_setup/common_setup1.tcl
    restore_session $harden_session
}

set power_enable_analysis true
set power_enable_multi_rail_analysis true
set power_analysis_mode $POWER_MODE
#set power_enable_merged_fsdb true

set report_default_significant_digits 3 ;
set sh_source_uses_search_path true ;
set power_clock_network_include_clock_gating_network true 

if {$HARDEN == 0} {
    read_verilog $DESIGN_FILE
}

current_desig $DESIGN_NAME

if {$HARDEN == 0} {
    #link_design --keep_sub
    #link_design --keep_sub_designs
    link_design
}

if {$SPEF_EN == 1} {
    read_parasitics -format spef $SPEF_FILE
}

if {$HARDEN ==0} {
    source -e -v $SDC_FILE
}
#set_case_analysis 0 TEST_MODE
#set_propagated_clock [all_clocks]
#set_operating_conditions $std_c -library $LIB_TYPE\_$std_c -analysis_type on_chip_variation
#set auto_wire_load_selection false
#set_wire_load_model -lib $LIB_TYPE\_$std_c -name $WIRE_LOAD
#set_clock_transition 0.2 [all_clocks]

update_timing -full

check_timing -verbose > ../rpt/check_timing.$TARGET\.report

#report_global_timing > ../rpt/report_global_timing.$TARGET\.report
#report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -sign 4 > ../rpt/report_timing.$TARGET\.report
#report_constraints -all_violators -verbose > ../rpt/report_constraints.$TARGET\.report
#report_design > ../rpt/report_design.$TARGET\.report
#report_net > ../rpt/report_net.$TARGET\.report
#report_clock -skew -attribute > ../rpt/report_clock.$TARGET\.report
#report_analysis_coverage > ../rpt/report_analysis_coverage.$TARGET\.report

if {$WAVE_FORM = "fsdb"} {
    if {$NOTIMING == 1} {
        read_fsdb $FSDB_FILE -strip_path $STRIP_PATH -time [list $WAVE_BT $WAVE_ET] -zero_delay
    } else {
        read_fsdb $FSDB_FILE -strip_path $STRIP_PATH -time [list $WAVE_BT $WAVE_ET]
    }
} elseif {$WAVE_FORM = "saif"} {
    if {$NOTIMING == 1} {
        read_saif $SAIF_FILE -strip_path $STRIP_PATH  -zero_delay
    } else {
        read_saif $SAIF_FILE -strip_path $STRIP_PATH 
    }
} else {
    if {$NOTIMING == 1} {
        read_vcd $VCD_FILE -strip_path $STRIP_PATH  -zero_delay
    } else {
        read_vcd $VCD_FILE -strip_path $STRIP_PATH 
    }
}
report_switching_activity -list_not_annotated

# no vcd 
# set_switching_activity -type registers -hier -static_probability 0.5 -toggle_rate 0.1 -clock_domains [all_clocks]
# set_switching_activity -type memory -hier -static_probability 0.5 -toggle_rate 0.1 -clock_domains [all_clocks]
# set_switching_activity -type black_boxes -hier -static_probability 0.5 -toggle_rate 0.1 -clock_domains [all_clocks]
# set_switching_activity -type clock_gating_cells -hier -static_probability 0.5 -toggle_rate 0.5 -clock_domains [all_clocks]

check_power > ../rpt/check_power.$TARGET\.report
if {$POWER_MODE == "time_based"} {
    set_power_analysis_options -waveform_format fsdb -waveform_output $TARGET -waveform_interval 1
}
update_power

#set 10% toggle rate on clock gates -- no vcd
#set_switching_activity -clock_derate 0.4/6 -clock_domains [all_clocks] -type clock_gating_cells

# report power
#estimate_clock_network_power scc55nll_hd_rvt_$$std_c\_basic/CLKNHDV16 -max_fanout 20 -input_transition 0.2

report_power -v > ../rpt/report_power.$TARGET\.$POWER_MODE\.report
#report_power -include_estimated_clock_network -v > ../rpt/report_power.$TARGET\.report_pre

if {$HARDEN == 0} {
    report_clock_gate_savings
}

if {$HARDEN == 0} {
    foreach_in_collection l [get_libs] {
        if {[get_attribute [get_lib $l] default_threshold_voltage_group] = ""} {
            set lname [get_object_name [get_lib $l]]
            set_user_attribute [get_lib $l] default_threshold_voltage_group $lname -class lib
        }
    }
    report_power -threshold_voltage_group > ../rpt/pwr.$TARGET\.per_lib_leakage
    report_threshold_voltage_group > ../rpt/pwr.$TARGET\.per_volt_threshold_group
}

save_session ../session/power_session.$TARGET\.$POWER_MODE

#exit










