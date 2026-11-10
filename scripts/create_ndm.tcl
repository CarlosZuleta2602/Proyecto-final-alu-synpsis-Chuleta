# ALU+ - Biblioteca fisica NDM GF150/M31
# Synopsys Library Manager

set ROOT [pwd]

set TECH "$ROOT/pdk/gf150/extracted/PlaceRoute/ICC2/Techfiles/1p4m_1tm_11k_sp_sm_OPTA/gf150mcu_1p4m_1tm_11k_sp_sm_OPTA_7t_M31_ndm.tf"

set LIB "$ROOT/pdk/m31/M31LLSC733GL150MS_25CTT3P3_ctyp_nldm.db"

set LEF "$ROOT/pdk/m31/extracted/M31LLSC733GL150MS.00.03.000/lef/M31LLSC733GL150MS.lef"

set OUT "$ROOT/ndm/M31LLSC733_GF150.ndm"

foreach f [list $TECH $LIB $LEF] {
    if {![file exists $f]} {
        error "Archivo requerido no encontrado: $f"
    }
}

puts "===== CREANDO WORKSPACE M31 ====="

create_workspace -technology $TECH -flow normal M31LLSC733_GF150

puts "===== IMPORTANDO BIBLIOTECA LOGICA ====="
read_db $LIB

puts "===== IMPORTANDO GEOMETRIA LEF ====="
read_lef $LEF

puts "===== VALIDANDO WORKSPACE ====="
check_workspace

puts "===== GUARDANDO BIBLIOTECA NDM ====="
commit_workspace -output $OUT

puts "===== NDM GENERADA: $OUT ====="

exit
