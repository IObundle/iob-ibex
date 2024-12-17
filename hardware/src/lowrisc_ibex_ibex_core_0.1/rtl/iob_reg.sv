//`timescale 1ns / 1ps

module iob_reg
  #(
    parameter int DATA_W = 0,
    parameter logic [DATA_W-1:0] RST_VAL = '0
    )
   (
    input  logic                   clk,
    input  logic                   arst,
    input  logic                   rst,
    input  logic                   en,
    input  logic [DATA_W-1:0]      data_in,
    output logic [DATA_W-1:0]      data_out
    );

   // Prevent width mismatch
   localparam logic [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   always_ff @(posedge clk or negedge arst) begin
      if (arst) begin
         data_out <= RST_VAL_INT;
      end else if (rst) begin
         data_out <= RST_VAL_INT;
      end else if (en) begin
         data_out <= data_in;
      end
   end

endmodule
