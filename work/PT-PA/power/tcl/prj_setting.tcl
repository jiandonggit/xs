set name "xxx_asic_top"

set DESIGN_NAME xxx_asic_top
set DESIGN_FILE   # netlist_path

# inst hierachy in wave
set STRIP_PATH hdl/u_chip_top

# spef files
if { ! [info exists SPEF_EN ] } {
    set SPEF_EN 0 
    set SPEF_FILE ""
    #wire load if spef_en == 0 , Zero or Small
    set WIRE_LOAD Zero
}

# sdc file
set SDF_FILE  xxx

# for harden session 
# set harden_session xxx

# wave file 
if {$WAVE_FORM == "fsdb"} {
    set FSDB_FILE ""
} elseif {$WAVE_FORM == "saif"} {
    set SAIF_FILE ""
} else {
    set VCD_FILE ""
}

if { [info exists WAVE_FILE ] } {
    if {$WAVE_FORM == "fsdb"} {
        set FSDB_FILE $WAVE_FILE
    } elseif {$WAVE_FORM == "saif"} {
        set SAIF_FILE $WAVE_FILE
    } else {
        set VCD_FILE $WAVE_FILE
    }
}

set WAVE_BT 188194 ; #wave begin
set WAVE_ET 197848 ; #wave end

# if sdb no sdf, set this 1
set NOTIMING 0 

set HS 9t
set LIB_TYPE fsh0l_ers_generic_core

# clock domain
# set BASE_CLOCK ""

# case coner
# set corner tc

# set POWER_MODE time_based

puts "prj_setting.tcl done"

