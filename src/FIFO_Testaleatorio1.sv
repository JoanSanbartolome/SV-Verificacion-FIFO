class FIFO_Testaleatorio1#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::FIFO_Enviroment #(WIDTH,DEPTH) enviroment; // Declaracion enviroment

    real cobertura;
    int  ciclos   = 0;
    int  objetivo;
    localparam int MAX_CICLOS = 10000;
    localparam int RAFAGA     = 50;

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
            repeat (1000) begin
                enviroment.driver.secuencia_llenado();
            end
            // Secuencia de vaciado de la FIFO
            $display("Secuencia 2: Vaciado");
            repeat (1000) begin
                enviroment.driver.secuencia_vaciado();
            end
            
            cobertura = enviroment.monitor.coverage_handle.Cobertura_funcional.get_inst_coverage();

            while (cobertura < 100.0 && ciclos < MAX_CICLOS) begin
                objetivo = $urandom_range(DEPTH, 0);            // nivel al que llevar la FIFO
                repeat (RAFAGA) begin
                    if (enviroment.driver.handler_subir.use_dw < objetivo)
                    enviroment.driver.secuencia_llenado();      // por debajo: llenar
                    else
                    enviroment.driver.secuencia_vaciado();      // por encima: vaciar
                    ciclos++;
                end
                cobertura = enviroment.monitor.coverage_handle.Cobertura_funcional.get_inst_coverage();
                $display("[%0t] Cobertura = %0.2f %% tras %0d ciclos (objetivo nivel %0d)",
                    $time, cobertura, ciclos, objetivo);
            end

            $display("FIN DEL TEST");

            $display("grado_llenado    : %0.2f %%", enviroment.monitor.coverage_handle.Cobertura_funcional.grado_llenado.get_inst_coverage());
            $display("estados_normales : %0.2f %%", enviroment.monitor.coverage_handle.Cobertura_funcional.estados_normales.get_inst_coverage());
            $display("casos_especiales : %0.2f %%", enviroment.monitor.coverage_handle.Cobertura_funcional.casos_especiales.get_inst_coverage());
            $display("Cobertura total ($get_coverage): %0.2f %%", $get_coverage());

            repeat (2) @(enviroment.driver.driver_interface.tx);   // deja que llegue la última salida
            enviroment.monitor.score_handle.report();
        end    
    endtask //automatic

endclass //FIFO_Driver
