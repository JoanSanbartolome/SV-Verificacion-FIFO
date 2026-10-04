// Esta clase establece una distribucion de activacion de lectura y escritura que 
// vacia la fifo
// Read,Write
// 0    0    15%    No hace nada
// 0    1    15%    Solo escribe
// 1    0    40%    Solo lee
// 1    1    40%    Escribe y lee
//
class RCSG_bajar #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) extends utilidades_pkg::RCSG_base #(WIDTH,DEPTH);

        constraint llenar_c {{rd_en,wr_en} dist {0 := 5, 1 := 15, 2 := 45, 3 := 35}; };

    function new();
        super.new();
    endfunction : new

endclass //RCSG_bajar extends RCSG_base
