// The "g" function is the second base function: g = r2 + (1 - 2*b_i) * r1;  

module G_func #(
  parameter int bitwidth = 7
) (
  input logic clk_i, 
  input logic rst_ni,
  input logic [bitwidth-1:0] r1_i,
  input logic [bitwidth-1:0] r2_i,
  input logic b_i,
  output logic [bitwidth-1:0] g_o
);

 // Saturation in case inputs and outputs are greater than the max an minimum nr represented by bitwidth
 logic [bitwidth-1:0] g_temp;
 logic [bitwidth-1:0] most_positive, most_negative, threshold;
 logic sign_r1, sign_r2, sign_gtemp;

 assign g_temp = (b_i == 'b0) ? r1_i + r2_i : r2_i - r1_i; // gtemp is the output if there is no overflow 

 // We also want to saturate if g_temp goes out of the range that can be represented with 7 bits 

 // There are four possible overflow scenarios:
 // 1) if g = r1 + r2: r1 and r2 both are large positive numbers
 // 2) if g = r1 + r2: r1 and r2 both are large negative numbers 
 // 3) if g = r2 - r1: r2 is a large positive and r1 is a large negative number
 // 4) if g = r2 - r1: r2 is a large negative and r1 is a large positive number
 // Below we consider each of them.

 assign most_positive = {1'b0, {bitwidth-1{1'b1}}}; // most_positive number
 assign most_negative = {1'b1, {bitwidth-1{1'b0}}} + 1'b1; //most_negative_number
 assign threshold = {1'b1, {bitwidth-1{1'b0}}}; // forbidden negative number

 assign sign_r1 = r1_i[bitwidth-1]; // the sign of input1
 assign sign_r2 = r2_i[bitwidth-1]; // the sign of input2
 assign sign_gtemp = g_temp[bitwidth-1]; // the sign of output

 always_comb begin
 	//responsible for saturation
 	if (sign_gtemp == 1'b1 && sign_r1 == 1'b0 && sign_r2 == 1'b0 && b_i == 1'b0) begin // if r1 and r2 are positive but r1+r2 is negative
    g_o = most_positive; // then saturate to the most positive number 
 	end else if (sign_gtemp == 1'b0 && sign_r1 == 1'b1 && sign_r2 == 1'b1 && b_i == 1'b0) begin // if r1 and r2 are negative but r1+r2 is positive
    g_o = most_negative; // then saturate to the most negative number 
 	end else if (sign_gtemp == 1'b1 && sign_r1 == 1'b1 && sign_r2 == 1'b0 && b_i == 1'b1) begin // if r1<0 and r2>0 but r2-r1 is negative
    g_o = most_positive; // then saturate to the most positive number 
 	end else if (sign_gtemp == 1'b0 && sign_r1 == 1'b0 && sign_r2 == 1'b1 && b_i == 1'b1) begin // if r1<0 and r2<0 but r2-r1 is positive 
    g_o = most_negative; // then saturate to the most negative number 
 	end else begin
 		g_o = (g_temp == threshold) ? most_negative : g_temp; // then we don't saturate; we also don't want to have a negative number below most_negative  
 	end
 end

endmodule