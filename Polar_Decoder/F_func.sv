// The "f" function is the first base function: f = sign(r1)*sign(r2)*min(|r1|,|r2|)  

module F_func #( // should be lower letter
  parameter int bitwidth = 7 // (5,1) quantization + sign 
) (
  input logic                 clk_i,  
  input logic                 rst_ni, 
  input logic [bitwidth-1:0]  r1_i,
  input logic [bitwidth-1:0]  r2_i,
  output logic [bitwidth-1:0] f_o
);

  logic [bitwidth-1:0] neg_r1, neg_r2, min, neg_min;
  logic [bitwidth-1:0] abs_r1, abs_r2;
  logic sign_r1, sign_r2, sign_o;

  //First find out what will be the sign of the number
  assign sign_r1 = r1_i[bitwidth-1];
  assign sign_r2 = r2_i[bitwidth-1];
  assign sign_o = sign_r1 ^ sign_r2; //sign of the output nr

  //compute the absolute values
  assign neg_r1     = ~r1_i + 1'b1; // negation of r1_i
  assign abs_r1 = (r1_i[bitwidth-1] == 1'b1) ? neg_r1 : r1_i; // absolute value of r1_i

  assign neg_r2     = ~r2_i + 1'b1; // negation of r2_i
  assign abs_r2 = (r2_i[bitwidth-1] == 1'b1) ? neg_r2 : r2_i; // absolute value of r2_i

  //compute the minimum
  assign min     = (abs_r1 > abs_r2) ? abs_r2 : abs_r1; // min
  assign neg_min = ~min + 1'b1; // negation of min

  //assign the output
  assign f_o = (sign_o == 1'b1) ? neg_min : min;

endmodule