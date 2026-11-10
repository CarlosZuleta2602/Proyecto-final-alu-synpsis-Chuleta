# =====================================================
# ALU+ - OPTIMIZACION POST-CTS
# Synopsys ICC2 / GF150 / M31
# Parte 2 - Punto 3
# =====================================================

set ROOT [pwd]

open_lib "$ROOT/icc2/ALU_Plus_GF150.nlib"
open_block alu_plus_sync_cts

set_host_options -max_cores 4

puts "===== OPTIMIZACION POST-CTS ====="

clock_opt -from final_opto

puts "===== REPORTES POST-CTS ====="

redirect -file "$ROOT/reports/icc2_post_cts_qor.rpt" {
    report_qor
}

redirect -file "$ROOT/reports/icc2_post_cts_setup.rpt" {
    report_timing -delay_type max -max_paths 10
}

redirect -file "$ROOT/reports/icc2_post_cts_hold.rpt" {
    report_timing -delay_type min -max_paths 10
}

redirect -file "$ROOT/reports/icc2_post_cts_legality.rpt" {
    check_legality
}

redirect -file "$ROOT/reports/icc2_post_cts_pg.rpt" {
    check_pg_connectivity
}

puts "===== GUARDANDO BLOQUE POST-CTS ====="

save_block -as alu_plus_sync_post_cts
save_lib

puts "===== POST-CTS FINALIZADO ====="

exit
