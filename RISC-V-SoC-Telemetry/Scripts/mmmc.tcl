# scripts/mmmc.tcl – single-mode, single-corner setup

# Use explicit paths so MMMC can find the libs
create_library_set -name lib_typical -timing {
    ./lib/N16ADFP_StdCelltt0p8v25c.lib
    ./lib/N16ADFP_SRAM_tt0p8v0p8v25c_100a.lib
}

create_rc_corner -name rc_typical

create_delay_corner -name delay_typical \
    -library_set lib_typical \
    -rc_corner    rc_typical

# SDC path is from the Innovus working directory (innovus_run)
create_constraint_mode -name mode_typical \
    -sdc_files { ./constraints/top.sdc }

create_analysis_view -name view_typical \
    -constraint_mode mode_typical \
    -delay_corner    delay_typical

set_analysis_view -setup view_typical -hold view_typical

# ---------------------------------------------------------
# Keep analysis simple (no OCV, no SI-aware delay)
# ---------------------------------------------------------
#set_db timing_analysis_mode default
setDelayCalMode -SIAware false


