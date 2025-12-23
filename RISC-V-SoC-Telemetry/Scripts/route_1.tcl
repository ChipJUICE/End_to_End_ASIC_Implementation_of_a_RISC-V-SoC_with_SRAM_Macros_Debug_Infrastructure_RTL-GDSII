# =========================================================
# route.tcl – global + detail route and post-route opt
# =========================================================

# Make sure results directory exists
file mkdir ./results

# ---------------------------------------------------------
# 1) Set NanoRoute modes (only options supported in v23.14)
# ---------------------------------------------------------

# Timing-driven routing; SI-driven off (simpler)
setNanoRouteMode -route_with_timing_driven true
setNanoRouteMode -route_with_si_driven      false

# Turn ON detail-route search and repair (for DRC fixing)
setNanoRouteMode -route_detail_search_and_repair true

# Allow more detail-route clean-up iterations
setNanoRouteMode -route_detail_end_iteration 30

# Higher effort for signoff-style cleanup
setNanoRouteMode -route_detail_signoff_effort high

# ---------------------------------------------------------
# 2) Global + detail route
# ---------------------------------------------------------
routeDesign -globalDetail -viaOpt -wireOpt

# ---------------------------------------------------------
# 3) Post-route optimization
# ---------------------------------------------------------
# Timing / DRC cleanup after routing
optDesign -postRoute

# Optional: immediate DRC check + report
verify_drc -report ./results/verify_drc_post_route.rpt

# ---------------------------------------------------------
# 4) Save final routed database and reports
# ---------------------------------------------------------

# Save routed design database
saveDesign ./results/riscv_tcm_routed.enc

# Final timing & area reports
report_timing -max_paths 20 > ./results/timing_post_route.rpt
report_area                  > ./results/area_post_route.rpt

# Write final DEF and netlist (for LVS / signoff)
defOut    -floorplan -netlist -routing ./results/riscv_tcm_postroute.def
saveNetlist ./results/riscv_tcm_postroute.v

