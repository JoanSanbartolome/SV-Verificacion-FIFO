class FIFO_Scoreboard #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
);
    //Declaración de dos handle para FIFO_transaction.
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_expected;
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_obtained;

    // Guarda las transacciones predecidas por el predictor
    utilidades_pkg::FIFO_Transaction #(WIDTH,DEPTH) transaction_predicted; 

    mailbox #(FIFO_Transaction) mailbox_entradas;
    mailbox #(FIFO_Transaction) mailbox_salidas;

    // Mailbox que hace de buffer para las transacciones expected
    mailbox #(FIFO_Transaction) mailbox_predecidas; 

    logic [WIDTH-1:0] FIFO_ideal[$]; 
    logic [WIDTH-1:0] ultimo_dato_out = '0;   // Guarda el dato de salida anterior para los casos que no deberia cambiar

    // Contadores para el informe final: una posición por salida comprobada
    localparam int N_SALIDAS = 4;
    string nombres[N_SALIDAS] = '{"DATA_OUT", "F_EMPTY_N", "F_FULL_N", "USE_DW"};
    int    aciertos[N_SALIDAS];
    int    errores [N_SALIDAS];
    int    n_comparaciones = 0;

    function new(mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) mbx_in, mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) mbx_out);
        this.mailbox_entradas  = mbx_in;
        this.mailbox_salidas   = mbx_out; 

        mailbox_predecidas = new(); // Construimos el mailbox localmente ya que solo hace de buffer
    endfunction //new()

    //tasks de monitorizacion
    task predictor_resultados;
        begin
        while (1) begin
            mailbox_entradas.get(transaction_expected);

            if (!transaction_expected.rst_s)
                begin
                    FIFO_ideal.delete();
                    transaction_expected.data_out='0;
                    ultimo_dato_out = '0;
                end
            else
                begin
                    case ({transaction_expected.read_enable, transaction_expected.write_enable})
                
                    2'b01: if (FIFO_ideal.size()<DEPTH) FIFO_ideal.push_front(transaction_expected.data_in);
                    2'b10: ultimo_dato_out = FIFO_ideal.pop_back();
                    2'b11: 
                        begin
                            FIFO_ideal.push_front(transaction_expected.data_in);
                            ultimo_dato_out=FIFO_ideal.pop_back();              
                        end
                            
                    endcase
                end

            transaction_expected.data_out = ultimo_dato_out; // Ahora siempre conserva el valor aunque no haya escrituras
            transaction_expected.use_dw = FIFO_ideal.size();
            transaction_expected.full = !(FIFO_ideal.size() == DEPTH);
            transaction_expected.empty = !(FIFO_ideal.size() == 0);

            mailbox_predecidas.put(transaction_expected.clone());
            end
        end
    endtask
        
    task evaluator_resultados();
        begin
            while (1) begin
                mailbox_salidas.get(transaction_obtained);
                mailbox_predecidas.get(transaction_predicted);
                n_comparaciones++;

                assert (transaction_obtained.data_out == transaction_predicted.data_out)
                    aciertos[0]++;
                else begin
                    errores[0]++;
                    $error("Salida diferente: obtenido=%0h esperado=%0h",
                            transaction_obtained.data_out, transaction_predicted.data_out);
                end

                assert (transaction_obtained.empty == transaction_predicted.empty)
                    aciertos[0]++;
                else  begin
                    errores[0]++;
                    $error("Error vaciado: obtenido=%0b esperado=%0b",
                            transaction_obtained.empty, transaction_predicted.empty);
                end

                assert (transaction_obtained.full == transaction_predicted.full)
                    aciertos[0]++;
                else begin
                    errores[0]++;
                    $error("Error llenado: obtenido=%0b esperado=%0b",
                            transaction_obtained.full, transaction_predicted.full);
                end

                assert (transaction_obtained.use_dw == transaction_predicted.use_dw)
                    aciertos[0]++;
                else begin
                    errores[0]++;
                    $error("Fallo en grado de llenado: obtenido=%0d esperado=%0d",
                            transaction_obtained.use_dw, transaction_predicted.use_dw);    
                end
            end
        end
    endtask

    function void report();
        int total_errores = 0;

        $display("==================== INFORME DEL SCOREBOARD ====================");
        $display("Transacciones comparadas: %0d", n_comparaciones);
        foreach (nombres[i]) begin
            $display("  %-10s  aciertos = %6d   errores = %6d", nombres[i], aciertos[i], errores[i]);
            total_errores += errores[i];
        end
        $display("Esperados pendientes de comparar: %0d", mailbox_predecidas.num());

        if (n_comparaciones == 0)
            $error("RESULTADO: FALLO - el scoreboard no ha comparado ninguna transaccion");
        else if (total_errores > 0)
            $error("RESULTADO: FALLO - %0d errores en %0d comparaciones", total_errores, n_comparaciones);
        else if (mailbox_predecidas.num() > 1)
            $error("RESULTADO: FALLO - quedan %0d esperados sin pareja", mailbox_predecidas.num());
        else
            $display("RESULTADO: EXITO - %0d comparaciones sin errores", n_comparaciones);
        $display("================================================================");
    endfunction
endclass //FIFO_Scoreboard