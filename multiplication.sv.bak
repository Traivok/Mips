module multiplication(input logic Clk, start, reset, input logic [31:0] lhs, rhs, output logic [63:0] result, output logic endSignal, output logic [4:0] counter);
	
	logic [31:0] multiplier, multiplicand;
	assign result = {multiplier, multiplicand} ;
	
	always_ff@(posedge Clk or posedge reset)
	begin
			if (reset)
			begin
				endSignal = 1;
			end
			else if (start)
			begin
				multiplier = lhs;
				multiplicand = rhs;
				result = 64'd0;
				counter = 5'd0;
				endSignal = 0;
			end
			
			for ( counter = counter; counter != 5'd31; counter++ )
			begin
				if (multiplier[0] == 1)
				begin
					result = multiplicand + result; 
				end
				
				multiplicand = multiplicand << 1;
				multiplier = multiplier >> 1;
				
			end
			
			if (counter == 5'd31)
			begin
				endSignal = 1;
			end						
	end

endmodule : multiplication 