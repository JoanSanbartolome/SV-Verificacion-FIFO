class FIFO_Testaleatorio1#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::FIFO_Enviroment #(WIDTH,DEPTH) enviroment; // Declaracion enviroment

    function new(virtual fifo_if#(WIDTH,DEPTH).driver vif_driver, 
                 virtual fifo_if#(WIDTH,DEPTH).monitor vif_monitor
                );
        enviroment = new(vif_driver, vif_monitor);
    endfunction //new()

    task reset;
        enviroment.driver.inicializar_duv();
    endtask

    task run_test; // Test para verificar el duv
        begin
            fork
                enviroment.monitor.run();
                enviroment.monitor.coverage_handle.run();
                enviroment.monitor.score_handle.predictor_resultados();
                enviroment.monitor.score_handle.evaluator_resultados();
            join_none
            // Secuencia de llenado de la FIFO
            $display("Secuencia 1: Llenado");
            repeat (2000) begin
                enviroment.driver.secuencia_llenado();
            end
            // Secuencia de vaciado de la FIFO
            $display("Secuencia 2: Vaciado");
            repeat (2000) begin
                enviroment.driver.secuencia_vaciado();
            end
            $display("FIN DEL TEST");
        end    
    endtask //automatic

endclass //FIFO_Driver
