module FIFO_sintetizable
#(parameter DEPTH=32,
  parameter WIDTH=8)

  ( input logic CLOCK,//!reloj de sistema
   input  logic RESET_N, //!reset asíncrono activo en bajo
   input  logic CLEAR_N, //!limpia la fifo, activo en bajo
   input  logic [WIDTH-1:0] DATA_IN, //!dato a escribir en la fifo
   input  logic READ, //!señal de lectura
   input  logic WRITE, //!señal de escritura
   output logic [WIDTH-1:0] DATA_OUT, //!dato leido de la fifo
   output logic [$clog2(DEPTH):0] USE_DW, //!número de palabras usadas en la fifo
   output logic F_EMPTY_N, //!fifo vacía activo a nivel bajo
   output logic F_FULL_N //!fifo llena activo a nivel bajo
  );

  localparam int AW = $clog2(DEPTH); //ancho de los punteros / direcciones de la RAM

  //------------------------------------------------------------------
  // Estados del diagrama ASM
  //------------------------------------------------------------------
  typedef enum logic [1:0] {VACIO=2'b00, OTROS=2'b01, LLENO=2'b10} estado_t;
  estado_t estado, estado_sig;

  //------------------------------------------------------------------
  // Señales internas
  //------------------------------------------------------------------
  logic [AW-1:0]    countw;      //puntero de escritura
  logic [AW-1:0]    countr;      //puntero de lectura
  logic             wren;        //RAM[countw]<=DATA_IN ; countw<=countw+1
  logic             rden;        //DATA_OUT<=RAM[countr] ; countr<=countr+1
  logic             inc_dw;      //USE_DW<=USE_DW+1
  logic             dec_dw;      //USE_DW<=USE_DW-1
  logic             bypass;      //DATA_OUT<=DATA_IN (vacio con lectura y escritura)
  logic [WIDTH-1:0] DPO;         //salida registrada de la RAM
  logic [WIDTH-1:0] data_bypass; //dato registrado de la ruta directa DATA_IN->DATA_OUT
  logic             sel_bypass;  //1: DATA_OUT=data_bypass ; 0: DATA_OUT=DPO

  //------------------------------------------------------------------
  // Unidad de control: salidas de Moore (banderas)
  //------------------------------------------------------------------
  always_comb
    case (estado)
      VACIO:   begin F_EMPTY_N = 1'b0; F_FULL_N = 1'b1; end
      LLENO:   begin F_EMPTY_N = 1'b1; F_FULL_N = 1'b0; end
      default: begin F_EMPTY_N = 1'b1; F_FULL_N = 1'b1; end //OTROS
    endcase

  //------------------------------------------------------------------
  // Unidad de control: estado siguiente y salidas condicionales
  //------------------------------------------------------------------
  always_comb
  begin
    estado_sig = estado;
    wren       = 1'b0;
    rden       = 1'b0;
    inc_dw     = 1'b0;
    dec_dw     = 1'b0;
    bypass     = 1'b0;

    if (CLEAR_N) //durante CLEAR_N=0 no se opera sobre la RAM
      case (estado)
        VACIO:
          if (WRITE)
          begin
            if (READ)
              bypass = 1'b1;                       //DATA_OUT<=DATA_IN
            else
            begin
              wren       = 1'b1;                   //RAM[countw]<=DATA_IN, countw++
              inc_dw     = 1'b1;                   //USE_DW++
              estado_sig = OTROS;
            end
          end

        OTROS:
          if (WRITE)
          begin
            if (READ)
            begin
              wren = 1'b1;                         //RAM[countw]<=DATA_IN, countw++
              rden = 1'b1;                         //DATA_OUT<=RAM[countr], countr++
            end
            else
            begin
              wren   = 1'b1;
              inc_dw = 1'b1;
              if (USE_DW == DEPTH-1)               //USE_DW==31
                estado_sig = LLENO;
            end
          end
          else
            if (READ)
            begin
              rden   = 1'b1;
              dec_dw = 1'b1;
              if (USE_DW == 1)
                estado_sig = VACIO;
            end

        LLENO:
          if (WRITE)
          begin
            if (READ)
            begin
              wren = 1'b1;
              rden = 1'b1;
            end
          end
          else
            if (READ)
            begin
              rden       = 1'b1;
              dec_dw     = 1'b1;
              estado_sig = OTROS;
            end

        default:
          estado_sig = VACIO;
      endcase
  end

  //------------------------------------------------------------------
  // Registros: estado, punteros, contador de palabras y ruta directa
  //------------------------------------------------------------------
  always_ff @(negedge RESET_N, posedge CLOCK)
    if (!RESET_N)
    begin
      estado      <= VACIO;
      countw      <= '0;
      countr      <= '0;
      USE_DW      <= '0;
      data_bypass <= '0;
      sel_bypass  <= 1'b1;   //DATA_OUT=0 tras el reset
    end
    else
      if (!CLEAR_N)
      begin
        estado      <= VACIO;
        countw      <= '0;
        countr      <= '0;
        USE_DW      <= '0;
        data_bypass <= '0;
        sel_bypass  <= 1'b1; //DATA_OUT=0 tras el clear
      end
      else
      begin
        estado <= estado_sig;

        if (wren)
          countw <= (countw == DEPTH-1) ? '0 : countw + 1'b1;

        if (rden)
          countr <= (countr == DEPTH-1) ? '0 : countr + 1'b1;

        if (inc_dw)
          USE_DW <= USE_DW + 1'b1;
        else if (dec_dw)
          USE_DW <= USE_DW - 1'b1;

        if (bypass)
        begin
          data_bypass <= DATA_IN;
          sel_bypass  <= 1'b1;
        end
        else if (rden)
          sel_bypass  <= 1'b0;
      end

  //------------------------------------------------------------------
  // Ruta de datos: memoria de doble puerto
  //------------------------------------------------------------------
  ram_dp #(.mem_depth(DEPTH), .size(WIDTH)) RAM
  (
    .data      (DATA_IN),
    .wren      (wren),
    .clock1    (CLOCK),
    .clock2    (CLOCK),
    .rden      (rden),
    .wraddress (countw),
    .rdaddress (countr),
    .DPO       (DPO)
  );

  //DATA_OUT: dato leído de la RAM o dato de la ruta directa (vacio, R y W a la vez)
  assign DATA_OUT = sel_bypass ? data_bypass : DPO;

  //------------------------------------------------------------------
  // Aserciones (ignoradas en síntesis)
  //------------------------------------------------------------------
  // synthesis translate_off
property  llenado ;
    (@(posedge CLOCK) not (WRITE==1'b1 && F_FULL_N==1'b0 &&READ==1'b0));
endproperty
sobrellenado:assert property (llenado)  else $error("estas escribiendo sobre una fifo llena");

property  vaciado ;
  (@(posedge CLOCK) not (READ==1'b1 && F_EMPTY_N==1'b0&& WRITE==1'b0)) ;
endproperty
sobrevaciado:assert property  (vaciado) else $error("estas leyendo de una fifo vacia");
  // synthesis translate_on

endmodule