`timescale 1ns/1ps

module FIFO_inyeccion_errores #(
  parameter WIDTH = 8,
  parameter DEPTH = 32
)(
  // Solo observamos: todo son entradas
  input logic                   CLOCK,
  input logic                   READ,
  input logic                   WRITE,
  input logic [$clog2(DEPTH):0] USE_DW
);

  string                  modo;            // error elegido con +ERR=...
  logic [WIDTH-1:0]       dato_corrupto;   // valores que se fuerzan
  logic [$clog2(DEPTH):0] usedw_corrupto;  // (a nivel de módulo, no automatic)

  // Espera un flanco con lectura y escritura a la vez y la FIFO a medias.
  // El #1 deja que la FIFO actualice sus salidas tras el flanco.
  task automatic esperar_rw();
    @(posedge CLOCK iff (READ && WRITE && USE_DW inside {[1:DEPTH-2]}));
    #1;
  endtask

  // Error 1: un bit de DATA_OUT invertido durante un ciclo
  task automatic error_dato();
    esperar_rw();
    dato_corrupto = FIFO_sintetizable.DATA_OUT ^ 1;
    force FIFO_sintetizable.DATA_OUT = dato_corrupto;
    $display("[%0t] INYECCION DATO: DATA_OUT forzado a %0h", $time, dato_corrupto);
    @(posedge CLOCK); #1;
    release FIFO_sintetizable.DATA_OUT;
  endtask

  // Error 2: flag de lleno activo sin estar llena
  task automatic error_flag();
    esperar_rw();
    force FIFO_sintetizable.F_FULL_N = 1'b0;
    $display("[%0t] INYECCION FLAG: F_FULL_N forzado a 0 con USE_DW=%0d", $time, USE_DW);
    @(posedge CLOCK); #1;
    release FIFO_sintetizable.F_FULL_N;
  endtask

  // Error 3: contador desplazado en +1 (es un registro: el fallo persiste tras el release)
  task automatic error_usedw();
    esperar_rw();
    usedw_corrupto = USE_DW + 1;
    force FIFO_sintetizable.USE_DW = usedw_corrupto;
    $display("[%0t] INYECCION USE_DW: forzado a %0d", $time, usedw_corrupto);
    @(posedge CLOCK); #1;
    release FIFO_sintetizable.USE_DW;
  endtask

  // Error 4: la FSM salta a LLENO estando a medias (fallo que se propaga)
  task automatic error_estado();
    esperar_rw();
    force FIFO_sintetizable.estado = FIFO_sintetizable.LLENO;
    $display("[%0t] INYECCION ESTADO: estado forzado a LLENO con USE_DW=%0d", $time, USE_DW);
    @(posedge CLOCK); #1;
    release FIFO_sintetizable.estado;
  endtask

  // Selección del error al lanzar la simulación
  initial begin
    if ($value$plusargs("ERR=%s", modo)) begin
      $display("[%0t] Inyeccion de errores activada: %s", $time, modo);
      case (modo)
        "DATO":   error_dato();
        "FLAG":   error_flag();
        "USEDW":  error_usedw();
        "ESTADO": error_estado();
        default:  $warning("Modo de error desconocido: %s", modo);
      endcase
    end
  end

endmodule

// Engancha el inyector dentro de cada FIFO_sintetizable.
// Módulo contenedor del bind: se carga como segundo top solo en SimErr.do
module FIFO_inyeccion_bind;
  bind FIFO_sintetizable FIFO_inyeccion_errores #(.WIDTH(WIDTH), .DEPTH(DEPTH))
    u_inyeccion (.CLOCK(CLOCK), .READ(READ), .WRITE(WRITE), .USE_DW(USE_DW));
endmodule