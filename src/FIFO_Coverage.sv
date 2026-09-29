class FIFO_Coverage #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
);
  
  FIFO_Transaction #(WIDTH, DEPTH) tr_handle;
  
  mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) cov_mbx;
  
  covergroup fifo_cover with function sample(FIFO_Transaction #(WIDTH,DEPTH) tr);
    grado_llenado:coverpoint tr.use_dw
        {bins intermedio[] = {[1:31]};
        bins corner_case_vacio ={0};
        bins corner_case_lleno ={32};
        }
//escribid vuestro código aquí
endgroup;
  
  // 5. Definición del constructor (new)
  function new(mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) mbx_in);
    // Se asocia el mailbox interno con el que se recibe por argumento
    this.cov_mbx = mbx_in;
    
    // Se construye el covergroup
    fifo_cover = new();
  endfunction
  
  // 6. Task con loop infinito (forever) para recolectar y muestrear
  task run();
    forever begin
      // El hilo se bloquea aquí hasta que el monitor haga un put() en el mailbox
      cov_mbx.get(tr_handle); 
      
      // Una vez recibida la transacción, se pasa como argumento al sample()
      fifo_cover.sample(tr_handle);
    end
  endtask
  
endclass