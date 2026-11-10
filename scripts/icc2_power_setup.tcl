# =====================================================
# ALU+ 16 BITS - PREPARACION DE ALIMENTACION GF150/M31
# Parte 2 - Punto 3
# =====================================================

set ROOT [pwd]
set DESIGN_LIB "$ROOT/icc2/ALU_Plus_GF150.nlib"

open_lib $DESIGN_LIB
open_block alu_plus_sync_placement

puts "===== CREANDO REDES DE ALIMENTACION ====="

create_net -power VCCK
create_net -ground GNDK

puts "===== CONECTANDO PINES DE CELDAS ====="

connect_pg_net -net VCCK \
    [get_pins -physical_context */VCCK]

connect_pg_net -net GNDK \
    [get_pins -physical_context */GNDK]

puts "===== COLOCANDO PINES EXTERIORES ====="

place_pins -self

puts "===== GUARDANDO PREPARACION ====="

save_block -as alu_plus_sync_power_setup
save_lib

puts "===== CONEXIONES LOGICAS PG PREPARADAS ====="

exit
