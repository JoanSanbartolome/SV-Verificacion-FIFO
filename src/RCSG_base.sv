class RCSG_base #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) ;
//introducid vuestro código
    virtual fifo_if intf_fifo;
//Propiedades
// 1.1 para datos
    rand bit [WIDTH-1:0]data_in;
// 1.2 para lectura y escritura
    rand bit rd_en;
    rand bit wr_en;
// 2  constraint para datos
    constraint dt_c {data_in inside {[0:2**WIDTH-1]};};
// 3 propiedad para clear
    bit clr;
// 4 variable estática de grado de llenado
    static bit [DEPTH-1:0] use_dw;
// 5.1 constraint que controle que no hay lecturas solo cuando la FIFO esta vacia
    constraint rd_c {use_dw == 0 -> rd_en == 0;};
//5.2 constraint que controle que no hay escrituras solo cuando la FIFO está llena
    constraint wr_c {use_dw == DEPTH -> wr_en == 0;};
//metodos
//1 constructor
    function new(virtual fifo_if intf_fifo);
        this.clr = 0;
        this.intf_fifo=intf_fifo;
    endfunction : new
//2 funcion calculo del grado de llenado
    function void gradoLlenado;
        if (wr_en && !rd_en) begin
            use_dw++;
        end
        else
            if (!wr_en && rd_en) begin
                use_dw--;
            end
    endfunction

//3 funcion reset del grado de llenado
    static function void gradoLlenado_rst;
        use_dw = 0;
    endfunction
//4 funcion post_randomize
    function void post_randomize();
      begin
        gradoLlenado();
      end
    endfunction
endclass
