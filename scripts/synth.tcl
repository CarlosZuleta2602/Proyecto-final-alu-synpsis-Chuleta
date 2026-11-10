# =========================================================
# ALU+ 16 BITS - SINTESIS SYNOPSYS DESIGN COMPILER
# Tecnologia: GF150 / Biblioteca M31LLSC733
# =========================================================

set ROOT [pwd]
set TOP alu_plus_sync

set LIB "$ROOT/pdk/m31/M31LLSC733GL150MS_25CTT3P3_ctyp_nldm.db"

set_app_var search_path [concat [get_app_var search_path] \
    [list "$ROOT/rtl" "$ROOT/pdk/m31"]]

set_app_var target_library [list $LIB]
set_app_var link_library [list "*" $LIB]

define_design_lib WORK -path "$ROOT/work"

# ---------------------------------------------------------
# 1. Lectura del RTL
# ---------------------------------------------------------

analyze -format sverilog [list \
    "$ROOT/rtl/prefix_adder.sv" \
    "$ROOT/rtl/multiplicador.sv" \
    "$ROOT/rtl/bus_triestado.sv" \
    "$ROOT/rtl/alu_plus.sv" \
    "$ROOT/rtl/alu_plus_sync.sv" \
]

elaborate $TOP
current_design $TOP
link
uniquify

redirect -file "$ROOT/reports/01_check_design.rpt" {
    check_design
}

# ---------------------------------------------------------
# 2. Restricciones temporales
# ---------------------------------------------------------

create_clock -name core_clock -period 50 [get_ports clk]

set_input_delay 5 -clock core_clock \
    [get_ports {A* B* ALUControl*}]

set_output_delay 5 -clock core_clock [all_outputs]

# Reset asincrono:
# Se excluye de la evaluacion convencional de caminos de datos.
set_false_path -from [get_ports rst_n]

# ---------------------------------------------------------
# 3. Sintesis y optimizacion
# ---------------------------------------------------------

compile_ultra

# ---------------------------------------------------------
# 4. Comprobaciones y reportes
# ---------------------------------------------------------

redirect -file "$ROOT/reports/02_area.rpt" {
    report_area -hierarchy
}

redirect -file "$ROOT/reports/03_timing.rpt" {
    report_timing -delay_type max -max_paths 10
}

redirect -file "$ROOT/reports/04_cells.rpt" {
    report_reference -hierarchy
}

redirect -file "$ROOT/reports/05_constraints.rpt" {
    report_constraint -all_violators
}

redirect -file "$ROOT/reports/06_power.rpt" {
    report_power
}

redirect -file "$ROOT/reports/07_check_timing.rpt" {
    check_timing
}

# ---------------------------------------------------------
# 5. Guardar resultados
# ---------------------------------------------------------

change_names -rules verilog -hierarchy

write_file -format verilog -hierarchy \
    -output "$ROOT/results/alu_plus_sync_synth.v"

write_file -format ddc -hierarchy \
    -output "$ROOT/results/alu_plus_sync_synth.ddc"

write_sdc "$ROOT/results/alu_plus_sync.sdc"

puts "============================================="
puts "SINTESIS FINALIZADA"
puts "Reportes: $ROOT/reports"
puts "Netlist:  $ROOT/results/alu_plus_sync_synth.v"
puts "DDC:      $ROOT/results/alu_plus_sync_synth.ddc"
puts "============================================="

exit
