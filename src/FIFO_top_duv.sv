module FIFO_top_duv #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
) (
    fifo_if.duv bus  // El puerto se llama "bus"
);

  // Instancia del DUV
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

endmodule