class FIFO_Enviroment#(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    utilidades_pkg::FIFO_Driver #(WIDTH,DEPTH) driver; //Declaracion de objeto tipo driver
    utilidades_pkg::FIFO_Monitor #(WIDTH,DEPTH) monitor; //Declaracion de objeto tipo monitor

    function new( virtual fifo_if#(WIDTH,DEPTH).driver driver_vif,
                  virtual fifo_if#(WIDTH,DEPTH).monitor monitor_vif
                );
        driver = new(driver_vif);
        monitor = new(monitor_vif);
    endfunction //new()

endclass //FIFO_Driver
