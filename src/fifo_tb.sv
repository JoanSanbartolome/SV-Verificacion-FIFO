`timescale 1ns/1ps
import utilidades_pkg::*;

module FIFO_tb();

  parameter int DATA_WIDTH = 8;
  parameter int DEPTH = 32;
  parameter bit FIFO_PROFESOR = 0;   // 0: FIFO propia, 1: FIFO del profesor

  logic clk;

  // 1. Generación del reloj
  initial begin
    clk = 0;
    forever #50 clk = ~clk;
  end
  
  //Declaracion de bloques
  // 1.Objeto tipo interface
  fifo_if #(DATA_WIDTH,DEPTH) interfaz1(.clk(clk));

  // 2.Objeto de tipo test que contiene la secuencia de test
  FIFO_Testaleatorio1 #(DATA_WIDTH,DEPTH) test1;
  
  // 3. Instanciación del DUV
  FIFO_top_duv #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .FIFO_PROFESOR(FIFO_PROFESOR)) duv (.bus(interfaz1));

  /*
  4. Guardado del VCD
  initial begin
    $dumpfile("fifo_tb_all.vcd");
    $dumpvars(1, duv);
  end
  */
  // 5. Lanzamiento del test
  initial begin
    // Instanciación y ejecución del Test
    test1 = new(interfaz1, interfaz1);
    
    //Inicializacion
    test1.reset();

    //Lanzamiento de casos
    test1.run_test();

    // Finalizar la simulación
    $display("Fin de la simulacion (WIDTH=%0d, DEPTH=%0d, FIFO %s).", DATA_WIDTH, DEPTH, FIFO_PROFESOR ? "del profesor" : "propia");
    $finish;
  end

endmodule
