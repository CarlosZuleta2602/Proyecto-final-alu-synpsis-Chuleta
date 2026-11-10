# =====================================================
# ALU+ 16 BITS - IMPORTACION A SYNOPSYS ICC2
# Tecnologia: GF150 - M31LLSC733
# =====================================================

set ROOT [pwd]
set TOP alu_plus_sync

set TECH "$ROOT/pdk/gf150/extracted/PlaceRoute/ICC2/Techfiles/1p4m_1tm_11k_sp_sm_OPTA/gf150mcu_1p4m_1tm_11k_sp_sm_OPTA_7t_M31_ndm.tf"

set REF "$ROOT/ndm/M31LLSC733_GF150.ndm"

set NETLIST "$ROOT/results/alu_plus_sync_synth.v"
set SDC "$ROOT/results/alu_plus_sync.sdc"

set DESIGN_LIB "$ROOT/icc2/ALU_Plus_GF150.nlib"

foreach f [list $TECH $REF $NETLIST $SDC] {
    if {![file exists $f]} {
        error "Falta archivo requerido: $f"
    }
}

if {[file exists $DESIGN_LIB]} {
    error "La biblioteca de diseno ya existe. No se sobrescribira."
}

puts "===== CREANDO BIBLIOTECA ICC2 ====="

create_lib $DESIGN_LIB \
    -technology $TECH \
    -ref_libs [list $REF]

puts "===== IMPORTANDO NETLIST ====="

read_verilog -top $TOP $NETLIST

puts "===== ENLAZANDO CELDAS ====="

link_block

puts "===== LEYENDO RESTRICCIONES ====="

read_sdc $SDC

puts "===== BIBLIOTECAS DE REFERENCIA ====="

redirect -file "$ROOT/reports/icc2_reference_libs.rpt" {
    report_ref_libs
}

puts "===== GUARDANDO DISENO ====="

save_block
save_lib

puts "============================================"
puts "IMPORTACION ICC2 COMPLETADA"
puts "============================================"

exit
