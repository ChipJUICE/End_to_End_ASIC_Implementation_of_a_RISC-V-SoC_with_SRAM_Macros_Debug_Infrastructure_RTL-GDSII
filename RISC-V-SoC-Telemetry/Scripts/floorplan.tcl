# =========================================================
# floorplan.tcl – simple core floorplan for riscv_tcm_top
# =========================================================

set CORE_W   1000.0   ;# core width  (micron)   ;# was 600
set CORE_H   1000.0   ;# core height (micron)   ;# was 450

# Slightly larger keep-out from die edge for routing/power
set MARGIN_L 20.0    ;# was 10
set MARGIN_B 20.0    ;# was 10
set MARGIN_R 20.0    ;# was 10
set MARGIN_T 20.0    ;# was 10

set SITE_NAME "core"

# Make sure the default technical site also matches the stdcell site
setFPlanMode -defaultTechSite $SITE_NAME

# ---- Create floorplan ----
# -s <coreW> <coreH> <left> <bottom> <right> <top>
floorPlan \
    -site $SITE_NAME \
    -s $CORE_W $CORE_H $MARGIN_L $MARGIN_B $MARGIN_R $MARGIN_T

# Optional: report floorplan for sanity check
file mkdir ./results
#reportFloorplan > ./results/floorplan.rpt

