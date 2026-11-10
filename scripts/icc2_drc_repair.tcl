# =====================================================
# ALU+ - REPARACION INCREMENTAL DE DRC
# Synopsys ICC2 - GF150/M31
# Parte 2 - Punto 3
# =====================================================

set ROOT [pwd]

open_lib "$ROOT/icc2/ALU_Plus_GF150.nlib"
open_block alu_plus_sync_routed

set_host_options -max_cores 4

puts "===== CONFIGURANDO REPARACION ====="

set_app_options \
    -name route.detail.force_max_number_iterations \
    -value true

puts "===== EJECUTANDO ROUTING INCREMENTAL ====="

route_detail -incremental true

puts "===== COMPROBANDO ROUTING ====="

redirect -file "$ROOT/reports/icc2_drc_repair_check.rpt" {
    check_routes
}

puts "===== TIMING SETUP ====="

redirect -file "$ROOT/reports/icc2_drc_repair_setup.rpt" {
    report_timing -delay_type max -max_paths 5
}

puts "===== TIMING HOLD ====="

redirect -file "$ROOT/reports/icc2_drc_repair_hold.rpt" {
    report_timing -delay_type min -max_paths 5
}

puts "===== COMPROBANDO ALIMENTACION ====="

redirect -file "$ROOT/reports/icc2_drc_repair_pg.rpt" {
    check_pg_connectivity
}

puts "===== GUARDANDO NUEVA VERSION ====="

save_block -as alu_plus_sync_drc_repair
save_lib

puts "===== REPARACION INCREMENTAL TERMINADA ====="

exit
