//This module is a radix 4 with 3 F Processing Units and 1 G Processing Unit 

module FFG #(
  parameter int bitwidth = 7
) (
  input logic clk_i, 
  input logic rst_ni,
  input logic [bitwidth-1:0] f11_i,//first input to first F Function
  input logic [bitwidth-1:0] f12_i,//second input to first F Function
  input logic [bitwidth-1:0] f21_i,//first input to second F Function
  input logic [bitwidth-1:0] f22_i,//second input to second F Function
  input logic [1:0] two_frozen_bits, // Frozen Bits are introduced to this module in order to make the decisions for the ouput
  output logic f_o, //The output from F-Function
  output logic g_o  // The output from G-function
);


  //responsible to store intermediate results between functions
  logic [bitwidth-1:0] f1temp,f2temp,f3temp,gtemp;


    // We instatiate 3 "f" elemnts and 1 "g" element
  F_func #(
    .bitwidth(bitwidth)
    ) f1 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .r1_i(f11_i), 
    .r2_i(f12_i), 
    .f_o(f1temp)
  );

  F_func #(
    .bitwidth(bitwidth)
    ) f2 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .r1_i(f21_i), 
    .r2_i(f22_i), 
    .f_o(f2temp)
  );
    
  F_func #(
    .bitwidth(bitwidth)
    ) f3 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(f1temp), 
    .r2_i(f2temp), 
    .f_o(f3temp)
  );

  G_func #(
    .bitwidth(bitwidth)
    ) g1 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(f1temp), 
    .r2_i(f2temp), 
    .b_i(f_o), 
    .g_o(gtemp)
  );


  // Frozen bits are checked before the decision for the output is made
  assign f_o = (two_frozen_bits[1] == 1'b1) ? '0 : (f3temp[bitwidth-1] == 1'b1) ? 1'b1 : 1'b0;
  assign g_o = (two_frozen_bits[0] == 1'b1) ? '0 : (gtemp[bitwidth-1] == 1'b1) ? 1'b1 : 1'b0;

endmodule