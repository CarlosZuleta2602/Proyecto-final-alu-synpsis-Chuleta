# =====================================================
# ALU+ 16 BITS - EXPORTACION GDSII
# Synopsys ICC2 - GF150 / M31
# Parte 2 - Punto 4
# =====================================================

set ROOT [pwd]

set DESIGN_LIB "$ROOT/icc2/ALU_Plus_GF150.nlib"

set MAP "$ROOT/pdk/gf150/extracted/PlaceRoute/ICC2/Techfiles/1p4m_1tm_11k_sp_sm_OPTA/gf150mcu_1p4m_1tm_11k_sp_sm_OPTA_gds2OutLayer.map"

set GDS "$ROOT/gds/alu_plus_sync_GF150_preliminary.gds"

if {![file exists $MAP]} {
    error "No se encontro el mapa GDS: $MAP"
}

puts "===== ABRIENDO DISENO ENRUTADO ====="

open_lib $DESIGN_LIB
open_block alu_plus_sync_drc_repair

puts "===== EXPORTANDO GDSII ====="

write_gds \
    -hierarchy all \
    -layer_map $MAP \
    -lib_cell_view frame \
    $GDS

puts "===== COMPROBANDO ARCHIVO ====="

if {![file exists $GDS]} {
    error "No se genero el archivo GDS"
}

puts "Archivo generado: $GDS"
puts "Tamano: [file size $GDS] bytes"

puts "===== EXPORTACION GDSII FINALIZADA ====="

exit
