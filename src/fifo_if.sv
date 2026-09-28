`timescale 1 ns/ 1 ps //escala de tiempos de 1 ns y una precisón de 1 ps.

interface fifo_if(input bit clk);   //cabecera del interfaz. Recorda con dos parámetros y un puerto
                                    // de entrada
    parameter  WIDTH = 32;
    parameter  DEPTH = 12;
    localparam ADDRESS =$clog2(DEPTH);

    logic       rst_a       ;
    logic       rst_s       ;
    logic       lleno       ;
    logic       vacio       ;
    logic       rd_en       ;
    logic       wr_en       ;

    logic   [ADDRESS:0]   use_dw ;
    logic   [WIDTH-1:0]     data_in;
    logic   [WIDTH-1:0]     data_out;

    //4.1 definición clocking block px
    clocking px @(posedge clk);

    input #1ns      lleno;
    input #1ns      vacio;
    input #1ns      data_out;
    input #1ns      use_dw;

    endclocking:px;

    //4.2 definición clocking tx
    clocking tx @(posedge clk);

    output #2ns     rst_s;
    output #2ns     data_in;
    output #2ns       rd_en;
    output #2ns       wr_en;
    endclocking:tx;

    //4.3 definición del clocking neg_event
    clocking neg_event @(negedge clk);
    output #2ns rst_a;
    endclocking:neg_event;

    //5.1 definición del modport duv
    //añadir vuestro código, absolutamente necesario para esta primera sesion
    modport duv (
        input     clk,
        input     rst_a,
        input     rst_s,
        input     rd_en,
        input     wr_en,
        input     data_in,

        output    data_out,
        output    vacio,
        output    use_dw,
        output    lleno
    );

    //5.2 definición del modport monitor
    modport monitor (clocking px);

    //5.3 definición del modport driver
    //os proporciono el código
    modport driver (
        input    clk,
        clocking tx,
        clocking neg_event
    );

endinterface //fifo_if
