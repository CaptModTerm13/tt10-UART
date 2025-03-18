module uart_tx (
  input        clk,
  input        rst_n,
  input        tx_en,
  input  [7:0] data_in,
  output       tx_ready,
  output reg   txd
);

  typedef enum {IDLE, START, DATA, STOP} state_t;
  state_t state;
  reg [2:0] bit_cnt;
  reg [7:0] data_reg;

  assign tx_ready = (state == IDLE);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      txd <= 1'b1;
    end else case(state)
      IDLE: if (tx_ready) begin
        data_reg <= data_in;
        state <= START;
      end
      START: begin
        txd <= 0;
        state <= (tx_en) ? DATA : START;
      end
      DATA: begin
        txd <= data_reg[bit_cnt];
        if (tx_en) begin
          bit_cnt <= (bit_cnt == 7) ? 0 : bit_cnt + 1;
          state <= (bit_cnt == 7) ? STOP : DATA;
        end
      end
      STOP: begin
        txd <= 1'b1;
        state <= (tx_en) ? IDLE : STOP;
      end
    endcase
  end

endmodule
