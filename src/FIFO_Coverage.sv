class FIFO_Coverage #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
);
  
  utilidades_pkg::FIFO_Transaction #(WIDTH, DEPTH) tr_handle;
  
  mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) cov_mbx;
  
 covergroup Cobertura_funcional with function sample (FIFO_Transaction #(WIDTH, DEPTH) tr);

    option.per_instance = 1;

    grado_llenado:coverpoint tr.use_dw
      {
        bins intermedio[] = {[1:DEPTH-1]};
        bins corner_case_vacio = {0};
        bins corner_case_lleno = {DEPTH};
      }
   
    flags: coverpoint {tr.empty, tr.full}
      {
        bins flag_vacio = {1};
        bins flag_lleno = {2};
        bins flag_intermedio = {3};
        illegal_bins flags_no_posibles ={0};
      }
 
    rw:coverpoint {tr.read_enable, tr.write_enable}
      {
        bins solo_lectura = {2};
        bins solo_escritura = {1};
        bins lectura_escritura= {3};
        bins nada = default;
      }
    /*datos_entrada: coverpoint tr.data_in
      {
        bins datos_posibles = {[0:19]};
      // ignore_bins datos_no_posibles ={[20:255]};
      }
      */
    estados_normales: cross grado_llenado, rw 
      {
        ignore_bins ilegales =
        (binsof(grado_llenado.corner_case_lleno) && binsof(rw.solo_escritura)) ||
        (binsof(grado_llenado.corner_case_vacio) && binsof(rw.solo_lectura));
      }

    casos_especiales:cross  rw, flags
      {
        bins casos_intermedios = binsof(flags.flag_intermedio);  
        ignore_bins no_admisible = (binsof(flags.flag_lleno)&& binsof(rw.solo_escritura))|| (binsof(flags.flag_vacio)&& binsof(rw.solo_lectura));
      }
endgroup;
  
  // 5. Definición del constructor (new)
  function new(mailbox #(FIFO_Transaction #(WIDTH, DEPTH)) mbx_in);
    // Se asocia el mailbox interno con el que se recibe por argumento
    this.cov_mbx = mbx_in;
    
    // Se construye el covergroup
    Cobertura_funcional = new();
  endfunction
  
  // 6. Task con loop infinito (forever) para recolectar y muestrear
  task run();
    begin
      while(1) begin
        // El hilo se bloquea aquí hasta que el monitor haga un put() en el mailbox
        cov_mbx.get(tr_handle); 
        
        // Una vez recibida la transacción, se pasa como argumento al sample()
        Cobertura_funcional.sample(tr_handle);
      end
    end
  endtask
  
endclass