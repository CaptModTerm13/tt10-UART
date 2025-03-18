module baud_gen #(
  parameter CLK_FREQ = 10_000_000,  // TT10 fixed clock
  parameter BAUD_RATE = 9_600
)(
  input  clk,
  input  rst_n,
  output reg tx_en,
  output reg rx_en
);

  localparam RX_DIVISOR = CLK_FREQ / (BAUD_RATE * 16);
  localparam TX_DIVISOR = RX_DIVISOR * 16;
  reg [$clog2(RX_DIVISOR)-1:0] counter;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 0;
      tx_en   <= 0;
      rx_en   <= 0;
    end else begin
      rx_en <= (counter == RX_DIVISOR - 1);
      tx_en <= (counter == RX_DIVISOR * 15);
      counter <= (counter == RX_DIVISOR - 1) ? 0 : counter + 1;
    end
  end

endmodule
