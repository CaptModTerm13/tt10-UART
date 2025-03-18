/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_yourusername_uart (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (0=input, 1=output)
    input  wire       ena,      // Design enable (ignore)
    input  wire       clk,      // 10 MHz clock
    input  wire       rst_n     // Active-low reset
);

  //UART Core Signals 
  wire txd, rxd;
  wire tx_ready, tx_full;
  wire rx_valid, rx_empty;
  wire [7:0] rx_data;

  // Pin Assignment
  assign rxd = uio_in[1];        // RX input on uio_in[1]
  assign uio_out[0] = txd;       // TX output on uio_out[0]
  assign uo_out = rx_data;       // RX data on dedicated outputs

  // Status signals on uio_out[2:5]
  assign uio_out[2] = tx_ready;  // Transmitter ready
  assign uio_out[3] = tx_full;   // TX FIFO full
  assign uio_out[4] = rx_valid;  // RX data valid
  assign uio_out[5] = rx_empty;  // RX FIFO empty

  // Bidirectional pin control (0=input, 1=output)
  assign uio_oe = 8'b0011_1101;  // Pins 0,2-5 as outputs

  // UART Core Instantiation
  uart_top uart_core (
    .clk(clk),
    .rst_n(rst_n),
    .txd(txd),
    .rxd(rxd),
    .tx_data_in(ui_in),       // TX data from UI pins
    .tx_wr_en(uio_in[6]),     // Write enable on uio_in[6]
    .tx_ready(tx_ready),
    .tx_full(tx_full),
    .rx_data_out(rx_data),    // RX data to UO pins
    .rx_rd_en(uio_in[7]),     // Read enable on uio_in[7]
    .rx_valid(rx_valid),
    .rx_empty(rx_empty)
  );

  //Unused Signal Handling
  assign uio_out[7:6] = 0;     // Unused output pins
  wire _unused = &{ena, uio_in[5:0], uio_in[7], 1'b0};

endmodule
