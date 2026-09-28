class FIFO_Enviroment#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::FIFO_Driver #(WIDTH,DEPTH) driver; //Declaracion de objeto tipo driver

    function new(virtual fifo_if#(WIDTH,DEPTH).driver driver_vif);
        driver = new(driver_vif);
    endfunction //new()

endclass //FIFO_Driver
