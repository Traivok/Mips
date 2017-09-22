module Mux32bits_4x2(
	input logic [1:0] sel,
	input logic [31:0] in0, in1, in2, in3,
	output logic [31:0] out);
	
	always_comb
	begin
		
		case(sel)
		
			2'd0:
			begin
				out <= in0;	
			end
			
			2'd1:
			begin
				out <= in1;
			end
			
			2'd2:
			begin
				out <= in2;
			end
		
			2'd3:
			begin
				out <= in3;
			end
			
			default:
			begin
				out <= 32'd1234567890;
			end
				
		endcase
	end
	
endmodule : Mux32bits_4x2

module Mux5bit_2x1 (
	input logic sel,
	input logic [4:0] in0, in1,
	output logic [4:0] out);
	
	always_comb
	begin
		case(sel)
			
			1'd0:
			begin
				out <= in0;
			end
			
			1'd1:
			begin
				out <= in1;
			end
			
			default:
			begin
				out <= 5'd0;
			end
		
		endcase
	end
	
endmodule : Mux5bit_2x1

module Mux32bit_2x1 ( 
	input logic sel,
	input logic [31:0] in0, in1,
	output logic out);
	
	always_comb
	begin
		case(sel)
			
			1'd0:
			begin
				out <= in0;
			end
			
			1'd1:
			begin
				out <= in1;
			end
			
			default:
			begin
				out <= 32'd1234567890;
			end
		endcase
	end

endmodule : Mux32bit_2x1
	