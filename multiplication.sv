module multiplication(input logic Clk, work, reset, input logic [31:0] lhs, rhs, output logic [63:0] result, output logic endSignal, output logic [5:0] counter);
	
	logic [31:0] multiplier, multiplicand;

	always_ff@(posedge Clk or posedge reset)
	begin
			if (reset)
			begin
				endSignal = 1;
				result = 64'd0;
				multiplier = lhs;
				multiplicand = rhs;
			end
			else
			begin
				if (~work)
				begin
					endSignal = 1;
					result = 64'd0;
					multiplier = lhs;
					multiplicand = rhs;
				end
				else
				begin
					for (counter = 6'd0; counter < 6'd32; counter++)
					begin
						if (multiplicand[0] == 31'd0)
						begin
							result = multiplicand + result;
						end
						
						multiplicand = multiplicand << 1;
						multiplier = multiplier >> 1;
						
						if (counter == 6'd32) endSignal = 1;
						else endSignal = 0;						
						
					end
				end				
			end
		end
	
endmodule : multiplication 