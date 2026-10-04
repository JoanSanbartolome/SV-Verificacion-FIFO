// Esta clase establece una distribucion de activacion de lectura y escritura que 
// llena la fifo
// Read,Write
// 0    0    15%    No hace nada
// 0    1    40%    Solo escribe
// 1    0    15%    Solo lee
// 1    1    40%    Escribe y lee
//
class RCSG_subir #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) extends utilidades_pkg::RCSG_base #(WIDTH,DEPTH);

    constraint llenar_c {{rd_en,wr_en} dist {0 := 5, 1 := 45, 2 := 15, 3 := 35}; };

    function new();
        super.new();
    endfunction : new

endclass //RCSG_subir extends RCSG_base
