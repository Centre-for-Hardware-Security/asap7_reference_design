
# the script is slightly different for different versions of innovus. please set this variable wit the version number
#set VERSION 17
#set VERSION 18
#set VERSION 19
#set VERSION 20
set VERSION 21

set init_design_uniquify 1

set init_verilog {../run/netlist.v}

set init_design_netlisttype {Verilog}
set init_design_settop {1}
set init_top_cell {sha256}

set DB_PATH "../db/"					
set LEF_PATH "../lef/scaled/"
set TLEF_PATH "../techlef/"

set CELL_LEF "$LEF_PATH/asap7sc7p5t_28_L_4x_220121a.lef $LEF_PATH/asap7sc7p5t_28_SL_4x_220121a.lef"
set TECH_LEF $TLEF_PATH/asap7_tech_4x_201209.lef

#tech lef first, cell lef later
set init_lef_file "$TECH_LEF $CELL_LEF"

set fp_core_cntl {aspect}
set fp_aspect_ratio {1.0000}
set extract_shrink_factor {1.0}
set init_assign_buffer {0}
set init_pwr_net {VDD}
set init_gnd_net {VSS}

# here starts the timing libraries
set init_cpf_file {}
set init_mmmc_file {../scripts/sha256.mmmc}

init_design 

# settings begin here
# defines tech node
if {$VERSION <= 19} {
	setDesignMode -process 7 
} else {
	setDesignMode -process 7 -node N7
}

setMultiCpuUsage -localCpu 8

if {$VERSION <= 20} {
	setNanoRouteMode -routeBottomRoutingLayer 2
	setNanoRouteMode -routeTopRoutingLayer 7
} else {
	setDesignMode -bottomRoutingLayer 2
	setDesignMode -topRoutingLayer 7
}

#this is the VDD for the std cells
globalNetConnect VDD -type pgpin -pin VDD -inst * 

# and the VSS
globalNetConnect VSS -type pgpin -pin VSS -inst * 

set FP_RING_OFFSET 0.384
set FP_RING_WIDTH 2.176
set FP_RING_SPACE 0.384
set FP_RING_SIZE [expr {$FP_RING_SPACE + 2*$FP_RING_WIDTH + $FP_RING_OFFSET + 0.1}]
#set FP_RING_SIZE [expr {$FP_RING_SPACE + 2*$FP_RING_WIDTH + $FP_RING_OFFSET}]
set FP_TARGET 170
set FP_MUL 5
# important: these numbers cannot be chosen arbitrarily, otherwise all VDD/VSS stripes are offgrid or there are no valid vias that can drop on them 
# FP_TARGET is the only variable you can freely modify. this one determines the number of standard cell rows in your design
# FP_MUL controls the aspect ratio. FP_MUL = 5 gives you a perfectly square design
# the additional 0.1 is to account for situations where innovus snaps the fplan and the space becomes too narrow to fit the rings 

set cellheight [expr 0.270 * 4 ]
set cellhgrid  0.216

set fpxdim [expr $cellhgrid * $FP_TARGET*$FP_MUL]
set fpydim [expr $cellheight * $FP_TARGET ]

# this command prints the snapping rules, it is useful for debugging
fpiGetSnapRule

floorPlan -site asap7sc7p5t -s $fpxdim $fpydim $FP_RING_SIZE $FP_RING_SIZE $FP_RING_SIZE $FP_RING_SIZE -noSnap
# this is likely not perfect because some snapping is done by innovus. the commands below came with the reference script by ASU. 
#changeFloorplan -coreToBottom [expr $FP_RING_SIZE] 
#add_tracks -honor_pitch

# the interval setting matches the M3 stripes for saving some resources. 
addWellTap -cell TAPCELL_ASAP7_75t_L -cellInterval 12.960 -inRowOffset 1.296

if {$VERSION >= 21} {
	# this series of commands makes innovus 21 happy :)
	add_tracks -snap_m1_track_to_cell_pins
	add_tracks -mode replace -offsets {M5 vertical 0}
	deleteAllFPObjects
	addWellTap -cell TAPCELL_ASAP7_75t_L -cellInterval 12.960 -inRowOffset 1.296
}

# classic setting: all inputs on the left, all outputs on the right.
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Left -layer 3 -spreadType center -spacing 2.016 -pin {reset_n clk {address[0]} {address[1]} {address[2]} {address[3]} {address[4]} {address[5]} {address[6]} {address[7]} cs we {write_data[0]} {write_data[1]} {write_data[2]} {write_data[3]} {write_data[4]} {write_data[5]} {write_data[6]} {write_data[7]} {write_data[8]} {write_data[9]} {write_data[10]} {write_data[11]} {write_data[12]} {write_data[13]} {write_data[14]} {write_data[15]} {write_data[16]} {write_data[17]} {write_data[18]} {write_data[19]} {write_data[20]} {write_data[21]} {write_data[22]} {write_data[23]} {write_data[24]} {write_data[25]} {write_data[26]} {write_data[27]} {write_data[28]} {write_data[29]} {write_data[30]} {write_data[31]}}
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Right -layer 3 -spreadType center -spacing 2 -pin {error {read_data[0]} {read_data[1]} {read_data[2]} {read_data[3]} {read_data[4]} {read_data[5]} {read_data[6]} {read_data[7]} {read_data[8]} {read_data[9]} {read_data[10]} {read_data[11]} {read_data[12]} {read_data[13]} {read_data[14]} {read_data[15]} {read_data[16]} {read_data[17]} {read_data[18]} {read_data[19]} {read_data[20]} {read_data[21]} {read_data[22]} {read_data[23]} {read_data[24]} {read_data[25]} {read_data[26]} {read_data[27]} {read_data[28]} {read_data[29]} {read_data[30]} {read_data[31]}}
editPin -snap TRACK -pin *
setPinAssignMode -pinEditInBatch false
legalizePin

# now we are going to add the core ring using M6/M7
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Pad -stacked_via_bottom_layer M1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top M7 bottom M7 left M6 right M6} -width $FP_RING_WIDTH -spacing $FP_RING_SPACE -offset $FP_RING_OFFSET -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# now we are going to add M2 follow rails. on top of every standard cell row. we need to add VSS and VDD separately because the number of rows is not always odd. it is possible you need one extra stripe of VDD, but not VSS.
addStripe  -skip_via_on_wire_shape blockring \
    -direction horizontal \
    -set_to_set_distance [expr 2*$cellheight] \
    -skip_via_on_pin Standardcell \
    -stacked_via_top_layer  M1 \
    -layer M2 \
    -width 0.072 \
    -nets {VDD} \
    -stacked_via_bottom_layer M1 \
    -start_from bottom \
    -snap_wire_center_to_grid None \
    -start_offset -0.044 \
    -stop_offset -0.044

addStripe  -skip_via_on_wire_shape blockring \
    -direction horizontal \
    -set_to_set_distance [expr 2*$cellheight] \
    -skip_via_on_pin Standardcell \
    -stacked_via_top_layer  M1 \
    -layer M2 \
    -width 0.072 \
    -nets {VSS} \
    -stacked_via_bottom_layer M1 \
    -start_from bottom \
    -snap_wire_center_to_grid None \
    -start_offset [expr $cellheight -0.044] \
    -stop_offset -0.044

# now we are going to add vertical M3 stripes. the metal stack is very restrictive, it is not easy to use other metals because of assumptions made with respect to V2 and V1. 
set m3pwrwidth 0.936
set m3pwrspacing 0.360
set m3pwrset2setdist    12.960

# looks like this   |0.936|0.360|0.936|long space... repeat pattern 
# if the last vertical M3 stripe is too close to the edge of the core, it can create a DRC violation. this stripe can be deleted manually.

addStripe  -skip_via_on_wire_shape Noshape \
    -set_to_set_distance $m3pwrset2setdist \
    -skip_via_on_pin Standardcell \
    -stacked_via_top_layer Pad \
    -spacing $m3pwrspacing \
    -xleft_offset 0.360 \
    -layer M3 \
    -width $m3pwrwidth \
    -nets {VDD VSS} \
    -stacked_via_bottom_layer M2 \
    -start_from left

# innovus 17 does some unusual large via selection for the power grid and generates violations
# the commands below fix that
if {$VERSION == 17} {
	editPowerVia -delete_vias 1 -top_layer 4 -bottom_layer 3
	editPowerVia -add_vias 1
}

# now we are going to add horizontal M4 stripes. the metal stack is very restrictive, it is not easy to use other metals because of assumptions made with respect to V2 and V1. 
set m4pwrwidth 0.864
set m4pwrspacing 0.864
set m4pwrset2setdist 21.6

# looks like this   |0.864|0.864|0.864|long space... repeat pattern 
addStripe  -skip_via_on_wire_shape Noshape \
    -direction horizontal \
    -set_to_set_distance $m4pwrset2setdist \
    -skip_via_on_pin Standardcell \
    -stacked_via_top_layer M7 \
    -spacing $m4pwrspacing \
    -layer M4 \
    -width $m4pwrwidth \
    -nets {VDD VSS} \
    -stacked_via_bottom_layer M3 \
    -start_from bottom

setSrouteMode -reset
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { M1(1) M7(1) } -blockPinTarget { nearestTarget } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -deleteExistingRoutes -allowJogging 0 -crossoverViaLayerRange { M1(1) Pad(10) } -nets { VDD VSS } -allowLayerChange 0 -targetViaLayerRange { M1(1) Pad(10) }

editPowerVia -add_vias 1 -orthogonal_only 0

verify_drc

setOptMode -holdTargetSlack  0.020
setOptMode -setupTargetSlack 0.020

#setPlaceMode -place_detail_preroute_as_obs 3

# this helps verify_drc realize that some metals are colored. 
colorizePowerMesh

# for some versions of innovus, silly mistakes are made when assigning colors to vias on the power rings. these lines fix it.
if {$VERSION == 19} {
	editPowerVia -delete_vias 1 -top_layer 6 -bottom_layer 5
	editPowerVia -delete_vias 1 -top_layer 7 -bottom_layer 6
	editPowerVia -add_vias 1
}

# for v20, these commands might have to be executed later as well once the layout is finalized
if {$VERSION == 20} {
	#colorizePowerMesh -reverse_with_nondefault_width 1
	editPowerVia -delete_vias 1 -top_layer 6 -bottom_layer 5
	editPowerVia -add_vias 1
}

if {$VERSION == 21} {
	colorizePowerMesh -reverse_with_nondefault_width 1
	editPowerVia -delete_vias 1 -top_layer 6 -bottom_layer 5
	editPowerVia -delete_vias 1 -top_layer 7 -bottom_layer 6
	editPowerVia -add_vias 1
}

place_opt_design

# add tie hi lo at this point. could have been handled in genus too.
setTieHiLoMode -maxFanout 5
addTieHiLo -prefix TIE -cell {TIELOx1_ASAP7_75t_SL TIEHIx1_ASAP7_75t_SL}

# CTS
ccopt_design

set_interactive_constraint_modes [all_constraint_modes -active]
reset_propagated_clock [all_clocks]
if {$VERSION == 21} {
	set_propagated_clock [all_clocks]
	#update_io_latency -source -verbose
} else {
	set_propagated_clock [all_clocks]
}


routeDesign

setAnalysisMode -analysisType onChipVariation
setSIMode -enable_glitch_report true
setSIMode -enable_glitch_propagation true
setSIMode -enable_delay_report true
optDesign -postRoute
optDesign -postRoute -hold

report_noise -threshold 0.2 
report_noise -bumpy_waveform 

# Writing out the def file and the netlist
defOut -netlist -routing -allLayers ${DB_PATH}${init_top_cell}_v${VERSION}.def
saveNetlist ${DB_PATH}${init_top_cell}_v${VERSION}.v													

# setStreamOutMode -reset

# streamOut ./sha256_v${VERSION}.gds.gz \
    # -mapFile {../gds/gds2.map} \
    # -libName DesignLib \
    # -uniquifyCellNames \
    # -outputMacros \
    # -stripes 1 \
    # -mode ALL \
    # -units 4000 \
    # -reportFile ../report/top/gds_stream_out_final.rpt \
    # -merge { ../gds/asap7sc7p5t_28_L_220121a_scaled4x.gds  ../gds/asap7sc7p5t_28_SL_220121a_scaled4x.gds }
    ## -merge { ../gds/asap7sc7p5t_28_L_220121a_scaled4x.gds  ../gds/asap7sc7p5t_28_R_220121a_scaled4x.gds  ../gds/asap7sc7p5t_28_SL_220121a_scaled4x.gds  ../gds/asap7sc7p5t_28_SRAM_220121a_scaled4x.gds}




# final notes
# there is a lot more that this script could do to become more industry-like. 
# - The SDC should be more realistic. The in/out constraints are picked almost arbitrarily.
# - It should handle path groups. 
# - It could have better setup/hold targets
# - It should handle DFT/scan. 
# - It should/could have more OPT runs to help with convergence at the end. 
# - It should do signoff-quality checks at the end, but this requires external quantus and licenses. Some users might not have it, so the commands are not provided
