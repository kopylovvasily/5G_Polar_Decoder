//This Module represents a radix 12 with 8 F Processing units and 4 G Processing Units

module F_Acc #(
 	parameter int bitwidth = 7
) (
 	input logic clk_i, 
 	input logic rst_ni,
	input logic [bitwidth-1:0] f11_i,//input to first F- Funstions
	input logic [bitwidth-1:0] f12_i,//input to first F- Funstions
	input logic [bitwidth-1:0] f21_i,//input to second F- Funstions
	input logic [bitwidth-1:0] f22_i,//input to second F- Funstions
	input logic [bitwidth-1:0] f31_i,//input to third F- Funstions
	input logic [bitwidth-1:0] f32_i,//input to third F- Funstions
	input logic [bitwidth-1:0] f41_i,//input to fourth F- Funstions
	input logic [bitwidth-1:0] f42_i,//input to fourth F- Funstions
  input logic [3:0] four_frozen_bits,
	output logic f1_o,//Partial Sum of first F Processing Unit
	output logic g1_o,//Partial Sum of second F Processing Unit
	output logic f2_o,//Partial Sum of third F Processing Unit
 	output logic g2_o//Partial Sum of fourth F Processing Unit
);

  //temprorary outputs are stored in those signals
  logic f1otemp,g1otemp,f2otemp,g2otemp;
  logic [bitwidth-1:0] f1temp,f2temp,f3temp,f4temp;
  logic s10,s11; 




  logic[1:0] two_frozen_bits_FFG,	two_frozen_bits_GGF;
  //Addresing the 4 incoming Frozen bits at the right Radix
  assign two_frozen_bits_FFG = four_frozen_bits[3:2];
  assign two_frozen_bits_GGF = four_frozen_bits[1:0];
   



  //First 4 G-Processing units
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
    .r1_i(f31_i), 
    .r2_i(f32_i), 
    .f_o(f3temp)
    );

  F_func #(
    .bitwidth(bitwidth)
    ) f4 (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .r1_i(f41_i), 
    .r2_i(f42_i), 
    .f_o(f4temp)
  );

  //Instantiation of 2 4-Radixes
  FFG #(
    .bitwidth(bitwidth)
    ) ffg (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .f11_i(f1temp), 
    .f12_i(f3temp), 
    .f21_i(f2temp), 
    .f22_i(f4temp), 
    .f_o(f1otemp), 
    .g_o(g1otemp), 
    .two_frozen_bits(two_frozen_bits_FFG)
  );

  //F has to be computed First in order to compute the partial sums for G
  assign s11 = g1otemp;
  assign s10 = f1otemp^g1otemp;

  GGF #(
    .bitwidth(bitwidth)
    ) ggf (
    .clk_i(clk_i), 
    .rst_ni(rst_ni), 
    .g11_i(f1temp), 
    .g12_i(f3temp), 
    .c1_i(s10), 
    .g21_i(f2temp), 
    .g22_i(f4temp), 
    .c2_i(s11), 
    .f_o(f2otemp), 
    .g_o(g2otemp), 
    .two_frozen_bits(two_frozen_bits_GGF)
  );

  assign f1_o = f1otemp;
  assign g1_o = g1otemp;
  assign f2_o = f2otemp;
  assign g2_o = g2otemp;




endmodule