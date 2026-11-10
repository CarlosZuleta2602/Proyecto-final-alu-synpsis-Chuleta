# ALU+ - Comprobacion de comandos de exportacion y DRC

set ROOT [pwd]

open_lib "$ROOT/icc2/ALU_Plus_GF150.nlib"
open_block alu_plus_sync_drc_repair

puts "===== COMANDO WRITE_GDS ====="
help write_gds

puts "===== COMANDO WRITE_STREAM ====="
help write_stream

puts "===== COMANDOS DE DRC ====="
help get_drc_errors
help report_drc

puts "===== COMPROBACION TERMINADA ====="
exit
