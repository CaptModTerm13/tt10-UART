module uart_rx (
  input        clk,
  input        rst_n,
  input        rx_en,
  input        rxd,
  output reg [7:0] data_out,
  output reg       valid
);

  reg [1:0] sync_reg;
  reg [3:0] sample_cnt;
  reg [2:0] bit_cnt;
  reg [7:0] data_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync_reg <= 2'b11;
      valid <= 0;
      sample_cnt <= 0;
      bit_cnt <= 0;
    end else if (rx_en) begin
      sync_reg <= {sync_reg[0], rxd};
      valid <= 0;

      if (sync_reg == 2'b10) begin         // Start bit
        sample_cnt <= 8;                   // Mid-sample at 8/16
        bit_cnt <= 0;
      end else if (sample_cnt > 0) begin
        sample_cnt <= sample_cnt - 1;
        if (sample_cnt == 8) begin         // Sample point
          data_reg[bit_cnt] <= sync_reg[1];
          if (bit_cnt == 7) begin
            valid <= 1;
            sample_cnt <= 0;
          end else begin
            bit_cnt <= bit_cnt + 1;
            sample_cnt <= 15;              // Next bit
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if (valid) data_out <= data_reg;
  end

endmodule
