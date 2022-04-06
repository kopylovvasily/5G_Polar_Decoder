//This Module represents a radix 12 with 8 G Processing units and 4 F Processing Units

module G_Acc #(
 	parameter int bitwidth = 7
) (
 	input logic clk_i, 
 	input logic rst_ni,
 	input logic [bitwidth-1:0] g11_i,//input to first G- Funstions
 	input logic [bitwidth-1:0] g12_i,//input to First G-Function
 	input logic [bitwidth-1:0] g21_i,//input to second G-Function
 	input logic [bitwidth-1:0] g22_i,//input to second G-Function
 	input logic [bitwidth-1:0] g31_i,//inpput to third G-Funtion
 	input logic [bitwidth-1:0] g32_i,//inpput to third G-Funtion
 	input logic [bitwidth-1:0] g41_i,//inpput to fourth G-Funtion
 	input logic [bitwidth-1:0] g42_i,//inpput to fourth G-Funtion
 	input logic s20_i,//Partial Sum of first G Processing Unit
 	input logic s21_i,//Partial Sum of second G Processing Unit
 	input logic s22_i,//Partial Sum of third G Processing Unit
 	input logic s23_i, // Partial Sum of fourth G processing Unit
  input logic [3:0] four_frozen_bits,
 	output logic f1_o,
 	output logic g1_o,
 	output logic f2_o,
 	output logic g2_o
);

  //temprorary outputs are stored in those signals
  logic f1otemp,g1otemp,f2otemp,g2otemp;
  logic [bitwidth-1:0] g1temp,g2temp,g3temp,g4temp;
  logic s15, s14; 

  logic[1:0] two_frozen_bits_FFG,	two_frozen_bits_GGF;
  //Addresing the 4 incoming Frozen bits at the right Radix
  assign two_frozen_bits_FFG = four_frozen_bits[3:2]; 
  assign two_frozen_bits_GGF = four_frozen_bits[1:0];




  //First 4 G-Processing units
  G_func #(
    .bitwidth(bitwidth)
    ) g1 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g11_i), 
    .r2_i(g12_i), 
    .b_i(s20_i), 
    .g_o(g1temp)
  );


  G_func #(
    .bitwidth(bitwidth)
    ) g2 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g21_i), 
    .r2_i(g22_i), 
    .b_i(s21_i), 
    .g_o(g2temp)
  );


  G_func #(
    .bitwidth(bitwidth)
   ) g3 (
  .clk_i(clk_i), 
  .rst_ni(rst_ni), 
  .r1_i(g31_i), 
  .r2_i(g32_i), 
  .b_i(s22_i), 
  .g_o(g3temp)
  );


  G_func #(
    .bitwidth(bitwidth)
    ) g4 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(g41_i), 
    .r2_i(g42_i), 
    .b_i(s23_i), 
    .g_o(g4temp)
    );

  //Instantiation of 2 4-Radixes

  FFG #(
    .bitwidth(bitwidth)
  ) ffg (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .f11_i(g1temp), 
    .f12_i(g3temp), 
    .f21_i(g2temp), 
    .f22_i(g4temp), 
    .f_o(f1otemp), 
    .g_o(g1otemp), 
    .two_frozen_bits(two_frozen_bits_FFG)
   );

  GGF #(
    .bitwidth(bitwidth)
    ) ggf (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .g11_i(g1temp), 
    .g12_i(g3temp), 
    .c1_i(s14), 
    .g21_i(g2temp), 
    .g22_i(g4temp), 
    .c2_i(s15), 
    .f_o(f2otemp), 
    .g_o(g2otemp), 
    .two_frozen_bits(two_frozen_bits_GGF)
  );

  assign s15 = g1otemp;
  assign s14 = f1otemp^g1otemp;
  assign f1_o = f1otemp;
  assign g1_o = g1otemp;
  assign f2_o = f2otemp;
  assign g2_o = g2otemp;


endmodule