`timescale 1ns/1ps
import utilidades_pkg::*;

module fifo_tb();

  parameter int DATA_WIDTH = 8;
  parameter int DEPTH = 32;

  logic clk;

  // 1. Generación del reloj
  initial begin
    clk = 0;
    forever #50 clk = ~clk;
  end

  // 2. Instanciación de la Interfaz (debe estar ANTES del DUV que la utiliza)
  fifo_if #(
      .WIDTH(DATA_WIDTH),
      .DEPTH(DEPTH)
  ) if_fifo (
      .clk(clk)
  );

  // 3. Instanciación del DUV
  FIFO_top_duv #(
      .WIDTH(DATA_WIDTH),
      .DEPTH(DEPTH)
  ) duv (
      .bus(if_fifo)
  );

  // 4. Guardado del VCD
  initial begin
    $dumpfile("fifo_tb_all.vcd");
    $dumpvars(1,fifo_tb.duv);
  end

  // 5. Lanzamiento del test
  initial begin
    FIFO_Testaleatorio1 #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) test_h;

    // Dejar el DUV en reposo inicial
    if_fifo.rst_a   <= 1'b0;
    if_fifo.rst_s   <= 1'b0;
    if_fifo.data_in <= '0;
    if_fifo.rd_en   <= 1'b0;
    if_fifo.wr_en   <= 1'b0;

    // Reset de inicialización
    repeat (3) @(posedge clk);
    if_fifo.rst_a <= 1'b1;
    if_fifo.rst_s <= 1'b1;
    repeat (2) @(posedge clk);

    // Instanciación y ejecución del Test
    test_h = new(if_fifo);
    test_h.run();

    // Finalizar la simulación
    #2000;
    $display("Simulacion finalizada exitosamente.");
    $finish;
  end

endmodule