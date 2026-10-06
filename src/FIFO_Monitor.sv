class FIFO_Monitor #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
);
    //Declaración de un handle para FIFO_transaction.
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_handle;

    //Declararemos un handle del mismo tipo que el anterior para cada objeto que lo va a utilizar
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_coverage;
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_scb_in;
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_scb_out;

    //Declaración de un mailbox: lo haremos particularizando a elementos transmitidos de tipo handle FIFO_Transaction
    mailbox #(FIFO_Transaction) mailbox_coverage;
    mailbox #(FIFO_Transaction) mailbox_predictor;
    mailbox #(FIFO_Transaction) mailbox_evaluator;

    virtual fifo_if#(WIDTH,DEPTH).monitor vif_monitor;

    utilidades_pkg::FIFO_Coverage #(WIDTH,DEPTH) coverage_handle;
    utilidades_pkg::FIFO_Scoreboard #(WIDTH,DEPTH) score_handle;

    //Definición del constructor, que tendrá como argumento la interfaz virtual de modport monitor, y se construirán el mailbox, la transacción original (la clonada se construye en la propia función de clonación) y, por supuesto, el objeto coverage que hayamos realizado en el paso anterior.
    function new(virtual fifo_if#(WIDTH,DEPTH).monitor vif_monitor);
        this.vif_monitor = vif_monitor;
        mailbox_coverage    = new();
        mailbox_predictor   = new();
        mailbox_evaluator   = new();

        coverage_handle = new(mailbox_coverage);
        score_handle    = new(mailbox_predictor,mailbox_evaluator);

        transaction_handle  = new();
    endfunction

    task run(); 
        begin
            while (1) begin
                @(vif_monitor.px);
                
                transaction_handle.full         = vif_monitor.px.lleno   ;
                transaction_handle.empty        = vif_monitor.px.vacio   ;
                transaction_handle.data_out     = vif_monitor.px.data_out;
                transaction_handle.use_dw       = vif_monitor.px.use_dw  ;
                transaction_handle.rst_a        = vif_monitor.px.rst_a   ;
                transaction_handle.rst_s        = vif_monitor.px.rst_s   ;
                transaction_handle.data_in      = vif_monitor.px.data_in ;
                transaction_handle.write_enable = vif_monitor.px.wr_en   ;
                transaction_handle.read_enable  = vif_monitor.px.rd_en   ;

                transaction_coverage            = transaction_handle.clone();
                

                mailbox_coverage.put(transaction_coverage);
                
                if (!transaction_handle.rst_s) begin
                    transaction_scb_in = transaction_handle.clone();

                    fork
                        mailbox_predictor.put(transaction_scb_in);

                        begin
                            transaction_scb_out = transaction_handle.clone();
                            @(vif_monitor.px);
                            transaction_scb_out.data_out = vif_monitor.px.data_out;
                            transaction_scb_out.full     = vif_monitor.px.lleno;
                            transaction_scb_out.empty    = vif_monitor.px.vacio;
                            transaction_scb_out.use_dw   = vif_monitor.px.use_dw;
                            mailbox_evaluator.put(transaction_scb_out);
                        end
                    join_any
                end
            end
        end
    endtask
endclass
