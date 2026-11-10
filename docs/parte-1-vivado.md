# Parte 1 — Vivado: diseño y verificación de la ALU+ de 16 bits

[Volver al README](../README.md)

Esta sección explica cómo **repetir** la parte lógica a partir de los archivos recuperados. En la entrega comprimida no hay proyecto `.xpr`, bitstream, capturas de Vivado ni reportes de síntesis FPGA. Un informe PDF local separado incluye dos capturas de Vivado 2026.1: una vista elaborada y una vista con “Synthesis Complete” de la variante **combinacional de 8 bits** `alu_plus` para `xc7a35tcpg236-1`. Muestran una ruta local privada y por eso no se publican. No prueban la síntesis de `alu_plus_sync` de 16 bits. Los pasos siguientes son instrucciones de reproducción de esta última versión.

## 1. Crear el proyecto

1. En Vivado, use **Create Project → RTL Project** y seleccione el dispositivo o placa que realmente tenga disponible. No hay un dispositivo objetivo documentado en la entrega; no se asigna uno aquí.
2. Agregue como **Design Sources** los cinco archivos de [`rtl/`](../rtl/): `prefix_adder.sv`, `multiplicador.sv`, `bus_triestado.sv`, `alu_plus.sv`, `alu_plus_sync.sv`.
3. Seleccione `alu_plus_sync` como **top** de diseño. Su parámetro `WIDTH` ya tiene valor 16; así se obtienen operandos y resultado de 16 bits y producto completo de 32 bits.
4. Agregue [`tb_alu_plus_sync.sv`](../tb/tb_alu_plus_sync.sv) como **Simulation Source** y seleccione `tb_alu_plus_sync` como top de simulación. [`monitor_ondas.sv`](../tb/monitor_ondas.sv) es opcional para producir VCD con un simulador que admita `$dumpfile` y `$dumpvars`; el monitor es un módulo separado y su ejecución depende de que se instancie o se configure como top adicional. Vivado puede mostrar ondas directamente sin ese archivo.

## 2. Entender los módulos y las señales

| Archivo | Función |
| --- | --- |
| [`prefix_adder.sv`](../rtl/prefix_adder.sv) | Sumador prefijo parametrizado; entrega suma y acarreo |
| [`multiplicador.sv`](../rtl/multiplicador.sv) | Multiplicación combinacional sin signo con salida de `2*WIDTH` bits |
| [`bus_triestado.sv`](../rtl/bus_triestado.sv) | Ejemplo auxiliar de buses triestado AND/OR; no forma parte de la instancia superior |
| [`alu_plus.sv`](../rtl/alu_plus.sv) | Selección combinacional de operaciones e indicadores |
| [`alu_plus_sync.sv`](../rtl/alu_plus_sync.sv) | Registros de entrada y salida; reloj y reset |

Las entradas son `clk`, `rst_n`, `A[15:0]`, `B[15:0]` y `ALUControl[2:0]`. Las salidas son `Result[15:0]`, `ProductFull[31:0]`, `N`, `Z`, `C` y `V`. `N` toma el bit más significativo de `Result`; `Z` indica resultado cero. `C` y `V` solo se asignan para los códigos de suma y comparación menor que. En `011`, la salida es el indicador **signed less than**; la resta interna se usa para calcular indicadores. `ProductFull` se calcula continuamente a partir de A y B, incluso cuando se selecciona otra operación.

El reset asíncrono pone las salidas registradas en cero salvo `Z=1`. Los registros de entrada guardan `ALUControl=111` al reset. Un vector presentado antes del primer flanco se captura allí; la salida correspondiente se actualiza en el flanco siguiente. Es importante observar esa latencia al leer las ondas.

## 3. Simular y verificar

1. Ejecute **Run Simulation → Run Behavioral Simulation**.
2. Compruebe en consola que el banco de pruebas termina y revise `TOTAL DE PRUEBAS` y `TOTAL DE ERRORES`. El código contiene 13 casos dirigidos y 100 iteraciones aleatorias, para un total previsto de 113 llamadas a `probar`; el resultado real debe leerse de la ejecución.
3. En la ventana de ondas, añada reloj, reset, operandos, control, resultado, producto e indicadores. Compruebe el reset y los dos flancos de latencia.
4. Verifique explícitamente AND, OR, suma, comparación con signo, multiplicación, división, módulo, código `111`, acarreo y overflow, y división por cero. Los vectores dirigidos del testbench cubren estos casos; las iteraciones aleatorias amplían la cobertura sin sustituir una verificación formal.
5. La entrega incluye un [VCD generado anteriormente](../results/alu_plus_sync.vcd). Sirve para inspección de señales, pero no aporta por sí solo el resumen de errores de la corrida.

El testbench usa `$urandom` sin semilla registrada; los 100 vectores aleatorios pueden variar entre simuladores o corridas. Para un informe reproducible, registre versión del simulador, semilla, fecha, total de pruebas y errores en un log nuevo.

## 4. Sintetizar en Vivado

1. En **Flow Navigator → Run Synthesis**, sintetice `alu_plus_sync` para el dispositivo seleccionado.
2. Revise **Messages**, **Utilization** y **Timing Summary**. Registre versión de Vivado, familia y pieza exacta; la aritmética de división y módulo puede ocupar recursos importantes.
3. Guarde capturas auténticas del esquema elaborado/sintetizado y tablas de utilización y timing solo después de ejecutar el flujo. No hay resultados FPGA verificables en esta entrega.
4. Si se busca implementación en placa, agregue restricciones XDC reales de la placa, ejecute **Implementation** y **Generate Bitstream** y documente pines, reloj y pruebas físicas. No se incluyen XDC ni evidencia de hardware, por lo que aquí no se afirma una implementación en placa.

## 5. Evidencia disponible y pendiente

| Punto | Estado |
| --- | --- |
| Código RTL de la ALU+ y módulos auxiliares | Disponible en `rtl/` |
| Banco de pruebas | Disponible en `tb/` |
| VCD | Disponible en `results/` |
| Log de ejecución Vivado y resultado de 113 pruebas | No recuperado |
| Capturas de ondas Vivado de 16 bits | No recuperadas |
| Capturas de esquema y síntesis Vivado de 8 bits | Presentes en PDF local separado, no publicadas por ruta privada visible |
| Reportes de utilización/timing Vivado | No recuperados |
| Proyecto `.xpr`, XDC, placa y bitstream | No recuperados |

Para completar la evidencia académica de esta parte, agregue únicamente archivos exportados de una ejecución real, con la versión y el dispositivo identificados.
