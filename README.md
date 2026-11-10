# ALU+ de 16 bits: RTL, síntesis y diseño físico preliminar

Proyecto académico de Carlos Zuleta. Esta publicación reúne los archivos **auténticos** recuperados de `ALU_Plus_Entrega_Definitiva.tar.gz`: código SystemVerilog, banco de pruebas, scripts de Synopsys, netlist generada, restricciones, reportes y capturas de ICC2. Las rutas locales de los reportes se sustituyeron por `<ROOT_LOCAL>`; las mediciones no se modificaron. El archivo original tiene SHA-256 `8F9F858532BAC8BAA8216618CBAB04E1A931A233D72FF1C47BBC2FA7FB23000D`.

> **Estado:** la simulación y el flujo físico tienen archivos de apoyo reales, pero no se ejecutaron de nuevo al preparar este repositorio. No se recuperaron proyecto ni reportes de Vivado; un informe PDF local contiene dos capturas de una variante `alu_plus` de 8 bits, que no se publican porque muestran una ruta privada y no prueban la versión sincronizada de 16 bits. El diseño físico **no está listo para fabricación**: el reporte final muestra **415 DRC**, incluidos **285 shorts**, aunque registra **0 open nets**. El GDS preliminar existe en la entrega privada, pero no se publica porque no se verificaron sus permisos de redistribución.

## Contenido

1. [Arquitectura y operaciones](#arquitectura-y-operaciones)
2. [Parte 1: Vivado](#parte-1-vivado)
3. [Parte 2: Design Compiler e ICC2](#parte-2-design-compiler-e-icc2)
4. [Resultados medidos y límites](#resultados-medidos-y-límites)
5. [Cómo reproducir](#cómo-reproducir)
6. [Inventario y procedencia](#inventario-y-procedencia)
7. [Videos](#videos)

## Arquitectura y operaciones

El módulo superior [`alu_plus_sync`](rtl/alu_plus_sync.sv) instancia la [`alu_plus`](rtl/alu_plus.sv) combinacional con `WIDTH=16`. Registra entradas, control y salidas en flancos positivos; después de presentar entradas antes de un flanco, el resultado correspondiente queda registrado en el **segundo flanco**. `rst_n` es asíncrono y activo en bajo. `ProductFull` tiene 32 bits y contiene `A*B` sin signo en todos los códigos de operación; `Result` contiene 16 bits. `N`, `Z`, `C` y `V` son indicadores del resultado.

| `ALUControl` | `Result` | Detalle |
| --- | --- | --- |
| `000` | `A & B` | AND bit a bit |
| `001` | `A \| B` | OR bit a bit |
| `010` | `A + B` | Suma; `C` es acarreo y `V` indica desbordamiento con signo |
| `011` | `A < B` | Comparación menor que **con signo**; `Result` vale 0 o 1. El sumador calcula `A-B` para `C` y `V`; **no entrega la resta como resultado** |
| `100` | `A * B` | 16 bits bajos; producto completo en `ProductFull` |
| `101` | `A / B` | División sin signo; si `B=0`, resultado 0 |
| `110` | `A % B` | Módulo sin signo; si `B=0`, resultado 0 |
| `111` | 0 | Operación por defecto |

[`prefix_adder.sv`](rtl/prefix_adder.sv) implementa el sumador prefijo y [`multiplicador.sv`](rtl/multiplicador.sv) el producto combinacional. [`bus_triestado.sv`](rtl/bus_triestado.sv) es un módulo auxiliar incluido en la entrega, pero **no está instanciado** por el módulo superior. La versión combinacional tiene `WIDTH=8` por defecto; la instancia del diseño superior usa 16 bits.

## Parte 1: Vivado

La guía [Parte 1: Vivado, paso por paso](docs/parte-1-vivado.md) identifica cada módulo, las pruebas, la simulación, la síntesis y exactamente qué evidencias de Vivado faltan. El [testbench](tb/tb_alu_plus_sync.sv) contiene 13 vectores dirigidos y 100 aleatorios. Se conserva la [traza VCD](results/alu_plus_sync.vcd) incluida en la entrega. Una traza no sustituye un log de aprobación del testbench; no se afirma que se haya repetido aquí una corrida de Vivado.

## Parte 2: Design Compiler e ICC2

La guía [Parte 2: síntesis y diseño físico](docs/parte-2-synopsys.md) recorre los scripts **en el orden de ejecución**: síntesis, biblioteca de referencia local, importación de netlist, floorplan, placement, alimentación VCCK/GNDK, CTS, optimización posterior, routing, revisión DRC y exportación preliminar de GDS. El repositorio incluye la [netlist sintetizada](results/alu_plus_sync_synth.v), [SDC](results/alu_plus_sync.sdc), [reportes](reports/) y [capturas finales](evidencias/icc2/). La netlist usa nombres de celdas M31 y necesita la biblioteca autorizada para enlazarse.

**Evidencia visual del layout enrutado:** imagen original de la entrega, sin retoques. La imagen documenta el estado alcanzado; el reporte DRC determina sus limitaciones.

![Layout enrutado preliminar de la ALU+](evidencias/icc2/05_Routing_Final_FINAL.png)

## Resultados medidos y límites

| Medida | Valor | Evidencia |
| --- | ---: | --- |
| Período de reloj configurado | 50 ns | [`synth.tcl`](scripts/synth.tcl), [`SDC`](results/alu_plus_sync.sdc) |
| Área total de celdas tras síntesis | 36 154.137622 µm² | [`02_area.rpt`](reports/02_area.rpt) |
| Área física total de celdas al final | 35 207.424 µm² | [`03_area.rpt`](reports/entrega_final/03_area.rpt) |
| Peor slack setup en los caminos listados del reporte final | +0.03 ns | [`01_timing_setup.rpt`](reports/entrega_final/01_timing_setup.rpt) |
| Peor slack hold en los caminos listados del reporte final | +0.55 ns | [`02_timing_hold.rpt`](reports/entrega_final/02_timing_hold.rpt) |
| DRC final | 415 | [`05_drc.rpt`](reports/entrega_final/05_drc.rpt) |
| Shorts incluidos en DRC | 285 | [`05_drc.rpt`](reports/entrega_final/05_drc.rpt) |
| Redes abiertas | 0 | [`05_drc.rpt`](reports/entrega_final/05_drc.rpt) |

Estas cifras son de los reportes recuperados. Los slacks citados corresponden a los caminos que listan esos archivos, no a una certificación signoff. El `check_design` de síntesis también contiene avisos de dos celdas sin carga y una salida conectada directamente a otra salida; se conservan en [`01_check_design.rpt`](reports/01_check_design.rpt). Además, el reporte DRC advierte que no había reglas de antena definidas. El diseño requiere corrección de shorts y DRC, verificación de alimentación, reglas de fabricación y validación completa antes de considerarse apto para tapeout.

## Cómo reproducir

**Requisitos:** una herramienta compatible con SystemVerilog para la parte lógica; Vivado para repetir la parte 1; licencias válidas de Synopsys y acceso autorizado al PDK GF150 y a M31 para la parte 2. Las versiones registradas por los reportes son DC `X-2025.06-SP5-5` e ICC2 `Y-2026.03-SP2`; otras versiones pueden necesitar ajustes. Los scripts de la entrega suponen ejecutar desde la raíz del proyecto (`set ROOT [pwd]`) y que las bibliotecas privadas estén bajo `pdk/`.

1. Lea [la guía de Vivado](docs/parte-1-vivado.md), agregue los cinco archivos de `rtl/` y `tb/tb_alu_plus_sync.sv`, seleccione `alu_plus_sync` como top de diseño y `tb_alu_plus_sync` como top de simulación, y ejecute la simulación. Registre el conteo de pruebas y errores de la consola.
2. Para síntesis ASIC, en un entorno autorizado ejecute `dc_shell -f scripts/synth.tcl` desde la raíz. Inspeccione `reports/` y `results/` generados **localmente**. El script original fija el período a 50 ns, entrada y salida a 5 ns y excluye el reset asíncrono de caminos convencionales.
3. Siga la [secuencia ICC2](docs/parte-2-synopsys.md). `create_ndm.tcl` se ejecuta con Library Manager; los demás scripts ICC2 necesitan las bibliotecas y bloques creados por el paso anterior. No descargue ni redistribuya el PDK desde este repositorio.
4. Compare los reportes nuevos con los incluidos; no interprete un GDS creado con DRC pendiente como entrega de fabricación.

## Inventario y procedencia

| Carpeta | Qué contiene |
| --- | --- |
| [`rtl/`](rtl/) | Cinco archivos SystemVerilog originales |
| [`tb/`](tb/) | Testbench y monitor VCD originales |
| [`scripts/`](scripts/) | Catorce scripts Tcl originales; rutas de PDK relativas a la raíz |
| [`results/`](results/) | Netlist, SDC y VCD recuperados; sin DDC, FSDB ni bases de simulación |
| [`reports/`](reports/) | Reportes `.rpt` reales, con solo la ruta absoluta de trabajo reemplazada por `<ROOT_LOCAL>` |
| [`evidencias/icc2/`](evidencias/icc2/) | Cinco PNG distintos de etapas finales, extraídos de la entrega |

No se publican los directorios `pdk/`, `ndm/`, `icc2/*.nlib`, ejecutables y bases temporales, DDC, FSDB, GDS, ni el `.tar.gz` completo. Los PNG anteriores a la serie `*_FINAL.png` repetían imágenes bajo nombres de etapas distintas; se omitieron para evitar atribuirles una evidencia que no muestran. Tampoco se encontraron fuentes específicas de Vivado (`.xpr` o reportes). Las dos capturas de Vivado incrustadas en un informe PDF local muestran la variante combinacional de 8 bits y una ruta privada visible, por lo que no se publican. La parte 1 es una guía de reproducción apoyada en el RTL y el testbench, no una bitácora de una corrida de Vivado de 16 bits comprobada.

## Videos

- [Parte 1: Vivado](https://youtu.be/tq6Ijow62hY)
- [Parte 2: Synopsys](https://youtu.be/XmTP00SOyU8)

Los videos se enlazan para evitar subir archivos grandes y duplicar la publicación. Su contenido no reemplaza los reportes ni acredita por sí solo los pasos que carecen de archivos recuperados.
