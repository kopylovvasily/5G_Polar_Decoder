// the purpose of the module: the module returns the mother code block length (N) for the specified number of input bits (K) and number of rate-matched output bits (E)
// the module is analogous to the "nr5g.internal.polar.getN" module from the Matworks "5G Toolbox"  
// we follow the same naming as in the Mathworks module for the convenience

module getN (
 		input logic [8:0] K_i, // K can have any value from 18 to 140 
 		input logic [14:0] E_i, // E can have any value from 18 to 8192 (E>K) 
 		output logic [2:0] N_o // N_o can have one of 5 values: "110" (N=512), "101" (N=256), "100" (N=128), "011" (N=64), "010" (N=32)
);

  logic [5:0] cl2e; 
  logic [5:0] n1, n2, nmin, nmax, ntemp1;
  logic [20:0] mult2; 
  logic [5:0] ntemp2;
  logic [10:0] ntemp3; 
  logic [20:0] mult1, mult3, mult4; 
  logic [14:0] multK;

  clog2 clog1 ( // the same as $clog2(E_i) but takes less area
   .x_i(E_i), 
   .x_o(cl2e) 
  );

  clog2 clog2 ( // the same as $clog2(multK) but takes less area
   .x_i(multK), 
   .x_o(n2) 
  );

  assign multK = K_i * 15'd8;

  assign mult1 = E_i * 15'd8; 
  assign mult2 = $unsigned(2 ** (cl2e - 1'b1)) * 10'd9; 
  assign mult3 = K_i * 11'd16; 
  assign mult4 = E_i * 15'd9; 
  
  assign nmin = 10'd5; 
  assign nmax = 10'd9;

  assign ntemp2 = (ntemp1 > nmin) ? ntemp1 : nmin; 

  assign ntemp3 = $unsigned(2 ** ntemp2); 


  always_comb begin
  	N_o = 3'b000;

  	if ((mult1 <= mult2) && (mult3 < mult4)) begin
  		n1 = cl2e - 1'b1;
  	end else begin
  		n1 = cl2e;
  	end

  	if ((n1 <= n2) && (n1 <= nmax)) begin
  		ntemp1 = n1;
  	end else if ((n2 <= n1) && (n2 <= nmax)) begin
  		ntemp1 = n2;
  	end else begin
  		ntemp1 = nmax;
  	end

  	if (ntemp3 == 11'd512) begin 
  		N_o = 3'b110; 
  	end else if (ntemp3 == 11'd256) begin
  		N_o = 3'b101; 
  	end else if (ntemp3 == 11'd128) begin
  		N_o = 3'b100; 
  	end else if (ntemp3 == 11'd64) begin
  		N_o = 3'b011; 
  	end else if (ntemp3 == 11'd32) begin
  		N_o = 3'b010; 
  	end 
  end



endmodule