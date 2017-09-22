module MUX_2x1_32bits (input logic Clk, input logic sel,
						input logic [31:0] B, input logic [31:0] A, 
						output logic [31:0] OUT);

always_ff@(posedge Clk)
begin	
	
	if(sel)
		OUT <= A;
	else
		OUT <= B;
end


endmodule : MUX_2x1_32bits