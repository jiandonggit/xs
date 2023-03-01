
set mem "yes"

if {[info exists mode]} {
} else {
    set mode ""
}

#if {[info exists power]} {
#} else {
#    set power "0"
#}

if {[info exists corner]} {
} else {
    set corner "tc"
}

if {$corner == "wc"} { 
    set std_c       ss0p99vm40c
    set io_c        ss0p99v2p97vm40c
    set poc_io_c    ss0p99v1p62vm40c
    set mem_c       ss0p99vm40c
    set pll_c       WCL
    set adc_c       099c-40_wc
    set dphy_c      ss_cmax_m40
    set afe_eq_c    typ
    set nmos_c      typ
} elseif {$corner == "bc"} {
    set std_c       ff1p21v125c
    set io_c        ff1p21v3p63v125c
    set poc_io_c    ff1p21v3p63v125c
    set mem_c       ff1p21v125c
    set pll_c       ML
    set adc_c       121c125_leakage
    set dphy_c      ff_cmin_125
    set afe_eq_c    typ
    set nmos_c      typ
}

echo $corner
set SYNOPSYS_PATH [getenv SYNOPSYS]
set DESIGNWARE_PATH [list ${SYNOPSYS_PATH}/libraries/syn]

# STD
if {![info exist HS} {
    set STD_LIB_PATH [list \
        /work/xs_nas/IC_Library/UMC40LP/STD/xxxx/xx_ehs/ccsn/\
    ]

    set STD_LIBS [list \
        fsh0l_bhs_generic_core_$std_c.ccsndb \
    ]
} else {
    set STD_LIB_PATH [list \
        /work/xs_nas/IC_Library/UMC40LP/STD/xxxx/xx_ehs/ccsn/\
        /work/xs_nas/IC_Library/UMC40LP/STD/xxxx/xx_ers/ccsn/\
        /work/xs_nas/IC_Library/UMC40LP/STD/xxxx/xx_els/ccsn/\
    ]

    set STD_LIBS [list \
        fsh0l_ehs_generic_core_$std_c.ccsndb \
        fsh0l_ers_generic_core_$std_c.ccsndb \
        fsh0l_els_generic_core_$std_c.ccsndb \
    ]
}

# IO
if {$hir == "top"} {
    set IO_LIB_PATH [list \
        /work/xs_nas/IC_Library/UMC40LP/IO/xxxx/ \
    ]

    set IO_LIBS [list \
        foh0l_qrs25_t33_osc_high_io_$io_c.db \
    ]
} else { 
    set IO_LIB_PATH [list \
    ]
    set IO_LIBS [list \
    ]

# IP
if {$hir == "top"} {
    set IP_LIB_PATH [list \
        /work/xs_nas/IP_summary/PLL/xxxx/ \
    ]

    set IP_LIBS [list \
        PLLUM40LPXFRAC_$pll_c.db \
    ]
} else {
    set IP_LIB_PATH [list \
    ]
    set IP_LIBS [list \
    ]
}

# mem 
if {$mem == "yes"} {
    set MEM_LIB_PATH [list \
        /work/xs_nas/IC_Library/UMC40LP/xxx/db \
    ]

    set MEM_LIBS [list \
        U40LP_FA_RFT976x64_$mem_c.db \
        U40LP_FA_RFT960x64_$mem_c.db \
    ]
} else {
    set MEM_LIB_PATH [list \
    ]
    set MEM_LIBS [list \
    ]
}

set DESIGN_PATH [list \
]

set STD_LIBS_POWER [list \
]





