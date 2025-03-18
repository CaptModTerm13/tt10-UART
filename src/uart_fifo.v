module uart_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 8
)(
  input                      clk,
  input                      rst_n,
  input                      wr_en,
  input  [DATA_WIDTH-1:0]   wr_data,
  output                     full,
  input                      rd_en,
  output reg [DATA_WIDTH-1:0] rd_data,
  output                     empty
);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
  reg [$clog2(DEPTH):0] count;

  assign full = (count == DEPTH);
  assign empty = (count == 0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count <= 0;
      rd_data <= 0;
    end else case ({wr_en && !full, rd_en && !empty})
      2'b01: begin  // Read
        rd_data <= mem[rd_ptr];
        rd_ptr <= (rd_ptr + 1) % DEPTH;
        count <= count - 1;
      end
      2'b10: begin  // Write
        mem[wr_ptr] <= wr_data;
        wr_ptr <= (wr_ptr + 1) % DEPTH;
        count <= count + 1;
      end
      2'b11: begin  // Read+Write
        mem[wr_ptr] <= wr_data;
        rd_data <= mem[rd_ptr];
        wr_ptr <= (wr_ptr + 1) % DEPTH;
        rd_ptr <= (rd_ptr + 1) % DEPTH;
      end
    endcase
  end

endmodule
