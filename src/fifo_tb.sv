`timescale 1ns/1ps
import utilidades_pkg::*;

module FIFO_tb();

  parameter int DATA_WIDTH = 8;
  parameter int DEPTH = 32;

  logic clk;

  // 1. Generación del reloj
  initial begin
    clk = 0;
    forever #50 clk = ~clk;
  end
  
  //Declaracion de bloques
  fifo_if #(DATA_WIDTH,DEPTH) interfaz1(.clk(clk));

  FIFO_Testaleatorio1 #(DATA_WIDTH,DEPTH) test1;
  
  // 3. Instanciación del DUV
  FIFO_top_duv #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) duv (.bus(interfaz1));

  // 4. Guardado del VCD
  initial begin
    $dumpfile("fifo_tb_all.vcd");
    $dumpvars(1, duv);
  end

  // 5. Lanzamiento del test
  initial begin
    // Instanciación y ejecución del Test
    test1 = new(interfaz1, interfaz1);
    
    //Inicializacion
    test1.reset_duv();

    //Lanzamiento de casos
    test1.test_duv();

    // Finalizar la simulación
    #2000;
    $display("Simulacion finalizada exitosamente.");
    $finish
  end

endmodule
