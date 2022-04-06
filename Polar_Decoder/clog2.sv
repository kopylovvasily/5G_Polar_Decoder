// similar to $clog2(..) but takes less area because the inputs range is constrained

module clog2(
 		input logic [14:0] x_i, 
 		output logic [5:0] x_o
);

  int unsigned x; 
  int unsigned y1, y2; 
  logic [5:0] x_temp;

  always_comb begin
  	x = x_i;
  	x_temp = '0;
  	for (int unsigned i = 5; i < 14 ; i++) begin 
  		y1 = $unsigned(2 ** (i));
  		y2 = $unsigned(2 ** (i-1));
  		if ((x_i <= y1) && (x_i > y2)) begin
  			x_temp = i;
  		end  
  	end
  end

  assign x_o = x_temp; 

endmodule 



