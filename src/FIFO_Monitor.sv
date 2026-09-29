class FIFO_Monitor #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
);
    //Declaración de un handle para FIFO_transaction.
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_handle;
    //Declararemos un handle del mismo tipo que el anterior y que clonaremos antes de transmitirlo por el mailbox
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) tr_copy;
    //Declaración de un mailbox: lo haremos particularizando a elementos transmitidos de tipo handle FIFO_Transaction
    mailbox #(FIFO_Transaction) mbx;

//IMPORTANTE: Necesitamos un puntero a la interfaz, con modport de tipo monitor. Dicho modport lo teníamos pendiente de la primera sesión y esto nos obliga ahora a modificar el fichero donde tengamos definida la interfaz, para añadir ese modport y el clocking block del cual deriva. Tomando como referencia las explicaciones de la primera sesión y los códigos aportados, completad ese modport en la interfaz y luego cread en el monitor el puntero(virtual) correspondiente.
    virtual fifo_if.monitor vif_monitor;

//Declararemos el handle de la clase realizada en el paso anterior (de cobertura funcional)
    utilidades_pkg::FIFO_Coverage #(WIDTH,DEPTH) cov_handle;
//Definición del constructor, que tendrá como argumento la interfaz virtual de modport monitor, y se construirán el mailbox, la transacción original (la clonada se construye en la propia función de clonación) y, por supuesto, el objeto coverage que hayamos realizado en el paso anterior.
    function new(virtual fifo_if.monitor vif_monitor);
        this.vif_monitor = vif_monitor;
        mbx = new();
        transaction_handle = new();
        cov_handle = new(mbx);
    endfunction
//Se realizará un task en donde en un loop infinito tomaremos muestras de todas las señales pertenecientes al virtual interface de tipo monitor
    task run();
        forever begin
            @(vif_monitor.px); 
            if (!vif_monitor.reset_n) begin
                continue;
            end

            if (vif_monitor.wren || vif_monitor.rden) begin
                $cast(tr_copy, transaction_handle.clone());
                mbx.put(tr_copy);
            end 
        end
    endtask
endclass
