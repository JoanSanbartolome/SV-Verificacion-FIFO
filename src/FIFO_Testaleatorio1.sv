class FIFO_Testaleatorio1#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::FIFO_Enviroment #(WIDTH,DEPTH) enviroment; // Declaracion enviroment

    function new(virtual fifo_if#(WIDTH,DEPTH) vif_test);
        enviroment = new(vif_test);
    endfunction //new()

    task reset_duv;
        enviroment.driver.inicializar_duv();
    endtask

    task test_duv; // Test para verificar el duv
        begin
            // Secuencia de llenado de la FIFO
            $display("secuencia 1");
            repeat (2000) begin
                enviroment.driver.secuencia_llenado();
            end
            // Secuencia de vaciado de la FIFO
            $display("secuencia 2");
            repeat (20000) begin
                enviroment.driver.secuencia_vaciado();
            end
            $display("FIN DEL TEST");
        end    
    endtask //automatic

endclass //FIFO_Driver
