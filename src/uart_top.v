module uart_top (
  input        clk,          // 10 MHz
  input        rst_n,
  // UART Interface
  output       txd,
  input        rxd,
  // TX Control
  input  [7:0] tx_data_in,
  input        tx_wr_en,
  output       tx_ready,
  output       tx_full,
  // RX Control
  output [7:0] rx_data_out,
  input        rx_rd_en,
  output       rx_valid,
  output       rx_empty
);

  //Submodules 
  wire tx_en, rx_en;
  wire [7:0] tx_fifo_data, rx_fifo_data;

  baud_gen u_baud (.*);
  
  uart_fifo #(.DEPTH(8)) tx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(tx_wr_en),
    .wr_data(tx_data_in),
    .full(tx_full),
    .rd_en(tx_ready),
    .rd_data(tx_fifo_data),
    .empty()
  );

  uart_fifo #(.DEPTH(8)) rx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(rx_valid),
    .wr_data(rx_fifo_data),
    .full(),
    .rd_en(rx_rd_en),
    .rd_data(rx_data_out),
    .empty(rx_empty)
  );

  uart_tx transmitter (
    .clk(clk),
    .rst_n(rst_n),
    .tx_en(tx_en),
    .data_in(tx_fifo_data),
    .tx_ready(tx_ready),
    .txd(txd)
  );

  uart_rx receiver (
    .clk(clk),
    .rst_n(rst_n),
    .rx_en(rx_en),
    .rxd(rxd),
    .data_out(rx_fifo_data),
    .valid(rx_valid)
  );

endmodule
