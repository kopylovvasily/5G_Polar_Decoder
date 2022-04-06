//This is a radix 4 module with 3 G Processing Units and 1 F Processing Unit

module GGF #(
 	parameter int bitwidth = 7
) (
  input logic clk_i, 
  input logic rst_ni,
  input logic [bitwidth-1:0] g11_i, // first input to the first G Processing unit
  input logic [bitwidth-1:0] g12_i, // second input to the first G Processing Unit
  input logic c1_i, // partial sum computed by the proceeding processing units in order to control first G Processing Unit
  input logic [bitwidth-1:0] g21_i, //first input to the second G processing Unit
  input logic [bitwidth-1:0] g22_i, // second input to the second G processing Unit
  input logic c2_i, // partial sum computed by the proceeding processing units in order to control second G Processing Unit
  output logic f_o, // The output from the F Processing Unti
  output logic g_o, // The ouput from the G Processing Unit
  input logic[1:0] two_frozen_bits //Frozen bits which would have an effect in the decsion making of this module
);
   
  logic [bitwidth-1:0] g1temp,g2temp,g3temp,ftemp;

  //Instantiation of 3 G processing units and 1 F Processing Unit
  G_func #(
    .bitwidth(bitwidth)
  ) g1 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g11_i), 
    .r2_i(g12_i),
    .b_i(c1_i), 
    .g_o(g1temp)
  );

  G_func #(
    .bitwidth(bitwidth)
  ) g2 (
    .clk_i(clk_i),
    .rst_ni(rst_ni), 
    .r1_i(g21_i), 
    .r2_i(g22_i),
    .b_i(c2_i), 
    .g_o(g2temp)
  );


  F_func #(
    .bitwidth(bitwidth)
  ) f (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g1temp), 
    .r2_i(g2temp), 
    .f_o(ftemp)
  );

  assign f_o = (two_frozen_bits[1] == 1'b1) ? '0 : (ftemp[bitwidth-1] == 1'b1) ? 1'b1 : 1'b0; //F must be first computed before G is computed

  G_func #(
    .bitwidth(bitwidth)
  ) g3 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g1temp), 
    .r2_i(g2temp), 
    .b_i(f_o), 
    .g_o(g3temp)
  );

  assign g_o = (two_frozen_bits[0] == 1'b1) ? '0 : (g3temp[bitwidth-1] == 1'b1) ? 1'b1 : 1'b0;


endmodule