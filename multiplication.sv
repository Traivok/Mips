module multiplication (
	    input logic Clk, reset, input logic [5:0] state, input logic [31:0] lhs, rhs,
		output logic [63:0] result, output logic endSignal, output logic [5:0] counter
	   );
	
	logic [31:0] multiplier;
	logic [63:0] multiplicand;
	parameter MULT_IDLE = 6'd0;
	parameter MULT_INIT = 6'd1;
	parameter MULT_WORK = 6'd2;

	always_ff@(posedge Clk or posedge reset)
	begin
		if (reset)
		begin
			endSignal = 1;
			result = 64'd0;
			counter = 6'd0;
			multiplier = 32'd0;
			multiplicand = 64'd0;
		end
		else
		begin
			
			if (state == MULT_IDLE)
			begin
				endSignal = 1;
			end
			
			else if (state == MULT_INIT)
			begin
				endSignal = 0;
				counter = 6'd0;
				result = 64'd0;
				multiplier = lhs;
				multiplicand = { 32'd0, rhs };		
			end
			else if (state == MULT_WORK)
			begin
				
				if (counter > 6'd31) 
				begin
					endSignal = 1; 
				end
				
				else
				begin
					
					endSignal = 0;
							
					if (multiplier[0] == 1'b1)
						result = multiplicand + result;
										
					counter = counter + 1'b1;
					multiplicand = multiplicand << 1;
					multiplier = multiplier >> 1;				
				end
				
			end // state
						
		end // reset
		
	end // always_ff
	
endmodule : multiplication 