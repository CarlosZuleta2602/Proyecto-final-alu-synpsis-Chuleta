# =====================================================
# ALU+ 16 BITS - PLACEMENT SYNOPSYS ICC2
# Tecnologia GF150 / M31
# =====================================================

set ROOT [pwd]
set DESIGN_LIB "$ROOT/icc2/ALU_Plus_GF150.nlib"

open_lib $DESIGN_LIB
open_block alu_plus_sync_floorplan

set_host_options -max_cores 4

puts "===== REVISANDO BLOQUE ====="
puts "Bloque actual: [current_block]"

puts "===== PLACEMENT Y OPTIMIZACION ====="

place_opt

puts "===== VERIFICANDO LEGALIDAD ====="

redirect -file "$ROOT/reports/icc2_placement_legality.rpt" {
    check_legality
}

puts "===== REPORTE DE TIMING ====="

redirect -file "$ROOT/reports/icc2_placement_timing.rpt" {
    report_timing -delay_type max -max_paths 10
}

puts "===== REPORTE QOR ====="

redirect -file "$ROOT/reports/icc2_placement_qor.rpt" {
    report_qor
}

puts "===== GUARDANDO PLACEMENT ====="

save_block -as alu_plus_sync_placement
save_lib

puts "===== PLACEMENT COMPLETADO ====="

exit
