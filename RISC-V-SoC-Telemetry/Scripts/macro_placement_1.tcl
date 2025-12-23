
puts "==> [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}] : Starting SRAM placement (right side, bottom-anchored)"

# ---------------------------------------------------------
# 1) Get core box
# ---------------------------------------------------------
set coreBox [dbGet top.fplan.coreBox]

if {[llength $coreBox] == 0} {
    puts "ERROR: coreBox is empty. Floorplan might not be created yet. Skipping SRAM placement."
    return
}

set coreBox [lindex $coreBox 0]
if {[llength $coreBox] != 4} {
    puts "ERROR: coreBox has unexpected format ([llength $coreBox] elements): '$coreBox'"
    return
}

set xLo [lindex $coreBox 0]
set yLo [lindex $coreBox 1]
set xHi [lindex $coreBox 2]
set yHi [lindex $coreBox 3]

set coreW [expr {$xHi - $xLo}]
set coreH [expr {$yHi - $yLo}]

puts "    Core box: xLo=$xLo yLo=$yLo xHi=$xHi yHi=$yHi (W=$coreW H=$coreH)"

# ---------------------------------------------------------
# 2) Collect SRAM instances by master cell name
# ---------------------------------------------------------
set sram_cell_pattern "TS1N16ADFPCLLLVTA128X64M4SWSHOD*"
set sram_insts {}

foreach inst_name [dbGet top.insts.name] {
    set h [dbGet -p top.insts.name $inst_name]
    set cell_name [dbGet $h.cell.name]
    if {[string match $sram_cell_pattern $cell_name]} {
        lappend sram_insts $inst_name
    }
}

set nSrams [llength $sram_insts]
if {$nSrams == 0} {
    puts "WARNING: No SRAM instances found matching pattern '$sram_cell_pattern'. Nothing to place."
    return
}

puts "   Found $nSrams SRAM macro instance(s): $sram_insts"

# ---------------------------------------------------------
# 3) Helper procs
# ---------------------------------------------------------
proc get_macro_box {inst_name} {
    set h [dbGet -p top.insts.name $inst_name]
    set box [dbGet $h.box]
    return [lindex $box 0]
}

proc get_macro_size {inst_name} {
    set box [get_macro_box $inst_name]
    set w [expr {[lindex $box 2] - [lindex $box 0]}]
    set h [expr {[lindex $box 3] - [lindex $box 1]}]
    return [list $w $h]
}

proc shrink_box {box eps} {
    set x0 [lindex $box 0]
    set y0 [lindex $box 1]
    set x1 [lindex $box 2]
    set y1 [lindex $box 3]
    set nx0 [expr {$x0 + $eps}]
    set ny0 [expr {$y0 + $eps}]
    set nx1 [expr {$x1 - $eps}]
    set ny1 [expr {$y1 - $eps}]
    if {$nx1 <= $nx0 || $ny1 <= $ny0} {
        return {}
    }
    return [list $nx0 $ny0 $nx1 $ny1]
}

# ---------------------------------------------------------
# 4) Macro size (assume all SRAMs same)
# ---------------------------------------------------------
set first_inst [lindex $sram_insts 0]
lassign [get_macro_size $first_inst] macroW macroH
puts "    Using macro size from $first_inst: W=$macroW H=$macroH"

# ---------------------------------------------------------
# 5) Placement parameters – bottom-anchored grid
# ---------------------------------------------------------

# Max 4 rows vertically, columns as needed
set nRows 4
if {$nSrams < $nRows} {
    set nRows $nSrams
}
set nCols [expr {int(ceil(double($nSrams)/$nRows))}]

puts "    Placing SRAMs in grid: $nRows rows × $nCols columns on the RIGHT side (bottom anchored)."

# Bottom margin and fixed row spacing so rows start near bottom
set bottom_margin_y  0.0   ;# gap from bottom core edge to first row
set row_spacing      90.0   ;# vertical gap BETWEEN rows (edge-to-edge)

# Horizontal spacing from right edge inward
set right_offset     45.0   ;# distance from right core edge to nearest macro edge
set col_spacing      100.0   ;# horizontal gap BETWEEN columns (edge-to-edge)

# Check that the vertical stack fits in the core height
set totalH [expr {$bottom_margin_y + $nRows*$macroH + ($nRows-1)*$row_spacing}]
if {$totalH > $coreH} {
    puts "WARNING: SRAM stack (height [format %.2f $totalH]) exceeds core height [format %.2f $coreH]."
    puts "         Consider increasing core height or reducing bottom_margin_y / row_spacing."
}

# ---------------------------------------------------------
# 6) Place all SRAMs on the RIGHT, starting from bottom
# ---------------------------------------------------------
for {set i 0} {$i < $nSrams} {incr i} {
    set inst [lindex $sram_insts $i]

    # row: 0..nRows-1 (0 = bottom), col: 0..nCols-1
    set row [expr {$i % $nRows}]
    set col [expr {$i / $nRows}]

    # Y center: bottom + margin + row * (H + spacing) + H/2
    set y [expr {$yLo + $bottom_margin_y +
                 $row * ($macroH + $row_spacing) +
                 $macroH / 2.0}]

    # X center: from right edge inward with extra column spacing
    set x [expr {$xHi - $right_offset -
                 $macroW / 2.0 - $col * ($macroW + $col_spacing)}]

    placeInstance $inst $x $y R180
}

# ---------------------------------------------------------
# 7) Route blockages around each SRAM (manual "halo" on M1/M2)
#    This keeps signal routing away from macro edges and fixes
#    the M2 spacing DRCs near the debug/trace logic.
# ---------------------------------------------------------

set routeHalo 4.0

# Helper: expand a box on all four sides by routeHalo
proc grow_box {box halo} {
    set xLo [lindex $box 0]
    set yLo [lindex $box 1]
    set xHi [lindex $box 2]
    set yHi [lindex $box 3]

    set xLoH [expr {$xLo - $halo}]
    set yLoH [expr {$yLo - $halo}]
    set xHiH [expr {$xHi + $halo}]
    set yHiH [expr {$yHi + $halo}]

    return [list $xLoH $yLoH $xHiH $yHiH]
}

foreach inst $sram_insts {
    set box [get_macro_box $inst]
    if {[llength $box] != 4} {
        puts "WARNING: could not get .box for SRAM $inst (box='$box')"
        continue
    }

    # Expanded blockage box (manual routing halo)
    set haloBox [grow_box $box $routeHalo]

# Block SIGNAL routing only (do NOT block VDD/VSS / special-route PG)
createRouteBlk -box $haloBox -layer {M1 M2} -exceptpgnet



    puts "    Route blockage around $inst : $haloBox"
}

puts "==> SRAM placement on RIGHT side (bottom-anchored) completed."

