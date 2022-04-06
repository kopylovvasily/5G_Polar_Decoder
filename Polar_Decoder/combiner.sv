//it takes the outputs of F and G accelerators and transform them into the combined value  

module combiner #(
 	parameter int bitwidth_outLLR,
 	parameter int bitwidth_inLLR
) (
 	input logic clk_i, 
 	input logic rst_ni,
 	input logic [bitwidth_inLLR-1:0] gl_i,
 	input logic [bitwidth_inLLR-1:0] gr_i,
	output logic [bitwidth_outLLR-1:0] g_o
);


  assign g_o[bitwidth_inLLR-1:0] = gr_i;
  assign g_o[bitwidth_outLLR-1:bitwidth_inLLR] = gl_i ^ gr_i;


endmodule 