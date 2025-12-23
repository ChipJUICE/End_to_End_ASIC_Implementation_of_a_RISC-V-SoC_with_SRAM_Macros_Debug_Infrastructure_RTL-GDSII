# =========================================================
# place.tcl – placement
# =========================================================

file mkdir ./results

# Make placement more congestion-aware
setPlaceMode -congEffort high
setPlaceMode -timingDriven true

# Check the design before placement
checkDesign -all > ./results/check_design_pre_place.rpt

# Place standard cells and macros
place_opt_design

# Save a snapshot after placement
saveDesign ./results/riscv_tcm_placed.enc

# Basic reports
report_timing -max_paths 20 > ./results/timing_post_place.rpt

# Congestion report (note: no -outfile option in newer Innovus)
redirect ./results/congestion_post_place.rpt {
    reportCongestion -hotSpot -overflow
}

