class FIFO_Driver#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::RCSG_subir #(WIDTH,DEPTH) handler_subir;
    utilidades_pkg::RCSG_bajar #(WIDTH,DEPTH) handler_bajar;

    virtual fifo_if#(WIDTH,DEPTH).driver driver_interface;

    function new(virtual fifo_if#(WIDTH,DEPTH).driver driver_interface);
        handler_subir = new();
        handler_bajar = new();
        this.driver_interface = driver_interface;
    endfunction //new()

    task inicializar_duv; 
        begin // Establece las condiciones iniciales para el test
            
            @(driver_interface.neg_event); // Reseta a nivel bajo en los flancos de bajada del reloj
            driver_interface.neg_event.rst_a <= 1'b1;
            driver_interface.tx.rst_s <= 1'b1;
            driver_interface.tx.data_in <= 1'b0; // Inicializa las señales del duv
            driver_interface.tx.rd_en   <= 1'b0;
            driver_interface.tx.wr_en   <= 1'b0;
            @(driver_interface.neg_event);
            driver_interface.neg_event.rst_a <= 1'b0;
            repeat(3)begin
                @(driver_interface.neg_event);
            end
            driver_interface.neg_event.rst_a <= 1'b1;
            @(driver_interface.neg_event);
        end
    endtask

    task secuencia_llenado;
        begin
            @(driver_interface.tx);
            assert(handler_subir.randomize())
            else $fatal("Randomization failed in sec_item1");

            @(driver_interface.tx);
            driver_interface.tx.data_in <= handler_subir.data_in;
            driver_interface.tx.rd_en   <= handler_subir.rd_en;
            driver_interface.tx.wr_en   <= handler_subir.wr_en;

            @(driver_interface.tx);
        end
    endtask

    task secuencia_vaciado;
        begin
            @(driver_interface.tx);
            assert(handler_bajar.randomize())
            else $fatal("Randomization failed in sec_item1");
                
            @(driver_interface.tx);
            driver_interface.tx.data_in <= handler_bajar.data_in;
            driver_interface.tx.rd_en   <= handler_bajar.rd_en;
            driver_interface.tx.wr_en   <= handler_bajar.wr_en;

            @(driver_interface.tx);
        end
    endtask
endclass //FIFO_Driver
