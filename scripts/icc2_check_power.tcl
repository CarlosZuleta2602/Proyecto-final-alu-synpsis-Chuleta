# ALU+ - Diagnostico de alimentacion GF150/M31

set ROOT [pwd]

open_lib "$ROOT/icc2/ALU_Plus_GF150.nlib"
open_block alu_plus_sync_power_setup

puts "===== REDES DE ALIMENTACION ====="
foreach name {VCCK GNDK} {
    set nets [get_nets -quiet $name]
    puts "$name: [sizeof_collection $nets] red(es)"
}

puts "===== PINES PG ====="
foreach name {VCCK GNDK} {
    set pins [get_pins -quiet -physical_context */$name]
    puts "$name: [sizeof_collection $pins] pin(es) fisicos"
}

puts "===== CONECTIVIDAD FISICA ACTUAL ====="
redirect -file "$ROOT/reports/icc2_pg_before_rails.rpt" {
    check_pg_connectivity
}

puts "===== DIAGNOSTICO FINALIZADO ====="
exit
