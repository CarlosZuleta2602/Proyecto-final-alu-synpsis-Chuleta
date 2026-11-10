# Parte 2 — Design Compiler e ICC2: flujo ASIC preliminar

[Volver al README](../README.md)

Los scripts Tcl, la netlist, las capturas y los reportes citados se recuperaron de la entrega original. Su presencia documenta un flujo ejecutado en otro entorno; **no se ejecutó nuevamente** al preparar este repositorio. La reproducción requiere licencias de Synopsys y acceso propio autorizado a GF150 y M31. El repositorio no incluye bibliotecas de celdas, PDK ni bases de datos físicas.

## 1. Sintetizar con Design Compiler

Archivo: [`scripts/synth.tcl`](../scripts/synth.tcl).

El script lee los cinco archivos de `rtl/`, elabora `alu_plus_sync`, enlaza la biblioteca M31, comprueba el diseño, crea un reloj `core_clock` de 50 ns, fija 5 ns de retardo de entrada y salida, declara false path desde `rst_n` y ejecuta `compile_ultra`. Escribe la [netlist mapeada](../results/alu_plus_sync_synth.v), el [SDC](../results/alu_plus_sync.sdc) y reportes de área, timing, celdas, restricciones, potencia y `check_timing`.

Desde la raíz del proyecto en el entorno autorizado:

```sh
dc_shell -f scripts/synth.tcl
```

El [área de síntesis reportada](../reports/02_area.rpt) es 36 154.137622 µm². [`01_check_design.rpt`](../reports/01_check_design.rpt) contiene avisos de dos celdas sin carga y una salida conectada directamente a `N`; conviene revisarlos antes de considerar el diseño cerrado. Los reportes incluidos son la evidencia de la ejecución recuperada. La netlist es una salida del diseño y referencia nombres de celdas M31; no contiene las definiciones de esa biblioteca.

## 2. Preparar biblioteca e importar en ICC2

1. [`create_ndm.tcl`](../scripts/create_ndm.tcl) crea una biblioteca de referencia NDM local a partir de archivos autorizados `.tf`, `.db` y `.lef`. Ejecútelo en **Library Manager**; esos insumos y el NDM producido quedan fuera de GitHub.
2. [`icc2_import.tcl`](../scripts/icc2_import.tcl) crea la biblioteca de diseño local, importa la netlist y el SDC, enlaza celdas y guarda el bloque `alu_plus_sync`. Su [reporte de bibliotecas](../reports/icc2_reference_libs.rpt) registra las referencias usadas.

Los scripts usan `set ROOT [pwd]`; deben lanzarse desde la raíz y con la estructura local `pdk/` que describen. Las rutas `pdk/gf150` y `pdk/m31` son referencias **locales** a material que debe obtenerse mediante la licencia correspondiente.

## 3. Floorplan y placement

[`icc2_floorplan.tcl`](../scripts/icc2_floorplan.tcl) lee tecnología parasítica TLUplus, establece parámetros de extracción e inicializa un floorplan rectangular con utilización objetivo 0.40 y desplazamiento del núcleo de 20 unidades de diseño. Guarda `alu_plus_sync_floorplan`.

[`icc2_placement.tcl`](../scripts/icc2_placement.tcl) abre ese bloque, ejecuta `place_opt`, comprueba legalidad y guarda `alu_plus_sync_placement`. Consulte [legalidad](../reports/icc2_placement_legality.rpt), [timing](../reports/icc2_placement_timing.rpt) y [QoR](../reports/icc2_placement_qor.rpt). Capturas reales recuperadas: [floorplan](../evidencias/icc2/01_Floorplan_FINAL.png) y [placement](../evidencias/icc2/02_Placement_FINAL.png).

## 4. Red de alimentación VCCK/GNDK

[`icc2_power_setup.tcl`](../scripts/icc2_power_setup.tcl) crea las redes `VCCK` y `GNDK`, conecta pines de celdas y guarda `alu_plus_sync_power_setup`. [`icc2_check_power.tcl`](../scripts/icc2_check_power.tcl) aporta un diagnóstico de conectividad previo. [`icc2_power_grid.tcl`](../scripts/icc2_power_grid.tcl) configura rieles en `METAL1`, malla vertical en `METAL2`, ejecuta `compile_pg`, comprueba PG y guarda `alu_plus_sync_power_grid`.

Consulte [conectividad PG](../reports/icc2_pg_connectivity.rpt), [PG DRC](../reports/icc2_pg_drc.rpt) y la [captura de la red](../evidencias/icc2/03_Power_Grid_FINAL.png). La presencia de redes y de un reporte de conectividad **no demuestra** por sí sola verificación eléctrica o signoff de alimentación.

## 5. CTS y optimización posterior

[`icc2_cts.tcl`](../scripts/icc2_cts.tcl) ejecuta `clock_opt -from build_clock -to route_clock` y guarda `alu_plus_sync_cts`. [`icc2_post_cts.tcl`](../scripts/icc2_post_cts.tcl) ejecuta optimización posterior y guarda `alu_plus_sync_post_cts`. Están disponibles [QoR de reloj](../reports/icc2_cts_clock_qor.rpt), [timing setup](../reports/icc2_cts_setup.rpt), [timing hold](../reports/icc2_cts_hold.rpt) y [captura CTS](../evidencias/icc2/04_CTS_FINAL.png).

## 6. Routing y DRC

[`icc2_routing.tcl`](../scripts/icc2_routing.tcl) ejecuta `route_auto`, guarda un bloque inicial, ejecuta `route_opt`, crea reportes de rutas, legalidad, alimentación y timing, y guarda `alu_plus_sync_routed`. [`icc2_drc_repair.tcl`](../scripts/icc2_drc_repair.tcl) intenta una reparación incremental y guarda `alu_plus_sync_drc_repair`.

La [revisión de rutas inicial](../reports/icc2_routing_check.rpt) muestra 429 DRC. La [revisión posterior](../reports/icc2_drc_repair_check.rpt) y la [revisión final](../reports/entrega_final/05_drc.rpt) muestran **415 DRC, 285 shorts y cero open nets**. La reducción de 429 a 415 no resuelve el diseño. El [reporte final de setup](../reports/entrega_final/01_timing_setup.rpt) lista peor slack de +0.03 ns y el [de hold](../reports/entrega_final/02_timing_hold.rpt) +0.55 ns en los caminos solicitados. La [captura del routing](../evidencias/icc2/05_Routing_Final_FINAL.png) es una imagen real del archivo de entrega, no una certificación DRC.

## 7. GDS preliminar y estado de cierre

[`icc2_export_gds.tcl`](../scripts/icc2_export_gds.tcl) abre el bloque `alu_plus_sync_drc_repair`, usa un mapa de capas local y exporta GDSII. La entrega privada contenía un archivo `gds/alu_plus_sync_GF150_preliminary.gds`, pero **no se distribuye** porque no se verificaron derechos sobre la información de proceso y celdas que pudiera incorporar. [`icc2_export_help.tcl`](../scripts/icc2_export_help.tcl) registra consultas de ayuda sobre comandos de exportación y DRC.

El nombre GDS **preliminar** es literal: permanecen 415 violaciones DRC, 285 shorts y avisos de reglas de antena ausentes. El flujo no acredita LVS, extracción y cierre signoff, verificación de integridad de potencia ni aprobación para tapeout. Se requiere corregir y volver a verificar con el PDK autorizado antes de cualquier fabricación.

## Secuencia de scripts recuperados

| Orden | Herramienta | Script | Bloque o salida principal |
| ---: | --- | --- | --- |
| 1 | Design Compiler | [`synth.tcl`](../scripts/synth.tcl) | Netlist y SDC |
| 2 | Library Manager | [`create_ndm.tcl`](../scripts/create_ndm.tcl) | Referencia NDM local |
| 3 | ICC2 | [`icc2_import.tcl`](../scripts/icc2_import.tcl) | `alu_plus_sync` |
| 4 | ICC2 | [`icc2_floorplan.tcl`](../scripts/icc2_floorplan.tcl) | `alu_plus_sync_floorplan` |
| 5 | ICC2 | [`icc2_placement.tcl`](../scripts/icc2_placement.tcl) | `alu_plus_sync_placement` |
| 6 | ICC2 | [`icc2_power_setup.tcl`](../scripts/icc2_power_setup.tcl) | `alu_plus_sync_power_setup` |
| 7 | ICC2 | [`icc2_check_power.tcl`](../scripts/icc2_check_power.tcl) | Diagnóstico previo |
| 8 | ICC2 | [`icc2_power_grid.tcl`](../scripts/icc2_power_grid.tcl) | `alu_plus_sync_power_grid` |
| 9 | ICC2 | [`icc2_cts.tcl`](../scripts/icc2_cts.tcl) | `alu_plus_sync_cts` |
| 10 | ICC2 | [`icc2_post_cts.tcl`](../scripts/icc2_post_cts.tcl) | `alu_plus_sync_post_cts` |
| 11 | ICC2 | [`icc2_routing.tcl`](../scripts/icc2_routing.tcl) | `alu_plus_sync_routed` |
| 12 | ICC2 | [`icc2_drc_repair.tcl`](../scripts/icc2_drc_repair.tcl) | `alu_plus_sync_drc_repair` |
| 13 | ICC2 | [`icc2_export_help.tcl`](../scripts/icc2_export_help.tcl) | Consulta de comandos |
| 14 | ICC2 | [`icc2_export_gds.tcl`](../scripts/icc2_export_gds.tcl) | GDS preliminar privado |

La secuencia es la dependencia de los scripts presentes, no una afirmación de que cada etapa haya pasado sin avisos. Revise los reportes de cada etapa antes de avanzar. Al repetir el flujo, registre versión, licencias, esquina, reglas y resultados propios.
