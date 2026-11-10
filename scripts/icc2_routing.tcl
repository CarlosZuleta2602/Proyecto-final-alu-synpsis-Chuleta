# =====================================================
# ALU+ 16 BITS - ROUTING
# Synopsys ICC2 - GF150/M31
# Parte 2 - Punto 3
# =====================================================

set ROOT [pwd]
set DESIGN_LIB "$ROOT/icc2/ALU_Plus_GF150.nlib"

open_lib $DESIGN_LIB
open_block alu_plus_sync_post_cts

set_host_options -max_cores 4

puts "===== INICIANDO ROUTING DE SENALES ====="

route_auto

puts "===== GUARDANDO ROUTING INICIAL ====="

save_block -as alu_plus_sync_route_initial
save_lib

puts "===== OPTIMIZANDO ROUTING ====="

route_opt

puts "===== VERIFICANDO RUTAS ====="

redirect -file "$ROOT/reports/icc2_routing_check.rpt" {
    check_routes
}

puts "===== VERIFICANDO LEGALIDAD ====="

redirect -file "$ROOT/reports/icc2_routing_legality.rpt" {
    check_legality
}

puts "===== VERIFICANDO ALIMENTACION ====="

redirect -file "$ROOT/reports/icc2_routing_pg.rpt" {
    check_pg_connectivity
}

puts "===== REPORTE DE SETUP ====="

redirect -file "$ROOT/reports/icc2_routing_setup.rpt" {
    report_timing -delay_type max -max_paths 10
}

puts "===== REPORTE DE HOLD ====="

redirect -file "$ROOT/reports/icc2_routing_hold.rpt" {
    report_timing -delay_type min -max_paths 10
}

puts "===== REPORTE GENERAL QOR ====="

redirect -file "$ROOT/reports/icc2_routing_qor.rpt" {
    report_qor
}

puts "===== GUARDANDO ROUTING FINAL ====="

save_block -as alu_plus_sync_routed
save_lib

puts "===== ROUTING FINALIZADO ====="

exit
