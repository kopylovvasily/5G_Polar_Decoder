//This module is used in order to store the incoming LLRs and the internal LLRs, It is a RAM with a depth of 3 and 128 width, so a size of (3x128)
//It is designed for 7 bit LLRs
module MemoryAlpha2 #(
	parameter int BITWIDTH_ADDRESS = 2, 
	parameter int BITWIDTH_LLRS = 7, 
 	parameter int DEPTH = 3
) (
	input logic clk_i,
	input logic rst_ni,
	input logic wr_i,
	input logic [BITWIDTH_ADDRESS-1:0] address_i,
	input logic [127:0][BITWIDTH_LLRS-1:0]  data_i,
	output logic [127:0][BITWIDTH_LLRS-1:0]  data_o
); 

  logic [127:0][BITWIDTH_LLRS-1:0] mem_q [DEPTH-1:0];
  logic [127:0][BITWIDTH_LLRS-1:0] mem_d [DEPTH-1:0];


  always_comb begin
  	data_o = '0;
    mem_d = mem_q;
  	if (wr_i == 1'b1) begin
  		mem_d[address_i] = data_i;
  	end
  	data_o = mem_q[address_i];
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin 
  	if(~rst_ni) begin
  		mem_q[5] <= '0;
  		mem_q[4] <= '0;
  		mem_q[3] <= '0;
  		mem_q[2] <= '0;
  		mem_q[1] <= '0;
  		mem_q[0] <= '0;
  	end else begin
  		mem_q <= mem_d;
  	end
  end


endmodule