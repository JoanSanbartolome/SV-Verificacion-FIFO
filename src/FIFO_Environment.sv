class FIFO_Environment #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);
    virtual fifo_if #(WIDTH, DEPTH).driver driver_interface;
    FIFO_Driver #(WIDTH, DEPTH) driver_h;

    function new(virtual fifo_if #(WIDTH, DEPTH).driver driver_interface);
        this.driver_interface = driver_interface;
        driver_h = new(driver_interface);
    endfunction

    task run();
        repeat (20) begin
            driver_h.secuencia_subida();
            @(posedge driver_interface.clk); 
        end
        repeat (20) begin
            driver_h.secuencia_bajada();
            @(posedge driver_interface.clk);
        end
    endtask
endclass
