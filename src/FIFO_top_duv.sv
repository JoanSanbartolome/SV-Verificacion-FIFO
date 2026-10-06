module FIFO_top_duv #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32,
    parameter bit FIFO_PROFESOR = 0   // 0: FIFO_sintetizable (propia), 1: FIFO_no_sintetizable (profesor)
) (
    fifo_if.duv bus  // El puerto se llama "bus"
);

  // Instancia del DUV: se elige con el parametro FIFO_PROFESOR, sin recompilar
  // (vsim -gFIFO_PROFESOR=1 ...). Los dos bloques se llaman igual (g_duv) para
  // que la jerarquia sea la misma: /FIFO_tb/duv/g_duv/duv
  if (FIFO_PROFESOR) begin : g_duv
    FIFO_no_sintetizable #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) duv (
        .CLOCK    (bus.clk),
        .RESET_N  (bus.rst_a),
        .DATA_IN  (bus.data_in),
        .READ     (bus.rd_en),
        .WRITE    (bus.wr_en),
        .CLEAR_N  (bus.rst_s),
        .F_FULL_N (bus.lleno),
        .F_EMPTY_N(bus.vacio),
        .USE_DW   (bus.use_dw),
        .DATA_OUT (bus.data_out)
    );
  end else begin : g_duv
    FIFO_sintetizable #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) duv (
        .CLOCK    (bus.clk),
        .RESET_N  (bus.rst_a),
        .DATA_IN  (bus.data_in),
        .READ     (bus.rd_en),
        .WRITE    (bus.wr_en),
        .CLEAR_N  (bus.rst_s),
        .F_FULL_N (bus.lleno),
        .F_EMPTY_N(bus.vacio),
        .USE_DW   (bus.use_dw),
        .DATA_OUT (bus.data_out)
    );
  end

endmodule
