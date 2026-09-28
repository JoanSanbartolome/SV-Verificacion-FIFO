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
  FIFO_Testaleatorio1 test1;
  fifo_if interfaz1(.clk(clk));

  // 3. Instanciación del DUV
  FIFO_top_duv #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) duv (.bus(interfaz1));

  // 4. Guardado del VCD
  initial begin
    $dumpfile("fifo_tb_all.vcd");
    $dumpvars(1,fifo_tb.duv);
  end

  // 5. Lanzamiento del test
  initial begin
    // Instanciación y ejecución del Test
    test1 = new(fifo_if);
    //Inicializacion
    test.reset_duv();
    //Lanzamiento de casos
    test.test_duv();

    // Finalizar la simulación
    #2000;
    $display("Simulacion finalizada exitosamente.");
    $finish;
  end

endmodule