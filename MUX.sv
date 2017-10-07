module Mux32bits_4x2(
	input logic [1:0] sel,
	input logic [31:0] in0, in1, in2, in3,
	output logic [31:0] out);
	
	always_comb
	begin
		
		case(sel)
		
			2'b00:
			begin
				out <= in0;	
			end
			
			2'b01:
			begin
				out <= in1;
			end
			
			2'b10:
			begin
				out <= in2;
			end
		
			2'b11:
			begin
				out <= in3;
			end
			/*
			default:
			begin
				out <= 32'd1234567890;
			end*/
				
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
			
			1'b0:
			begin
				out <= in0;
			end
			
			1'b1:
			begin
				out <= in1;
			end
			/*
			default:
			begin
				out <= 5'd0;
			end
			*/
		endcase
	end
	
endmodule : Mux5bit_2x1

module Mux32bit_2x1 ( 
	input logic sel,
	input logic [31:0] in0, in1,
	output logic [31:0] out);
	
	always_comb
	begin
		case(sel)
			
			1'b0:
			begin
				out <= in0;
			end
			
			1'b1:
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

module Mux32bit_8x1(
	input logic [2:0] sel,
	input logic [31:0] in0, in1, in2, in3, in4, in5, in6, in7,
	output logic [31:0] out );
	
	always_comb
	begin
		case (sel)			
			3'b000: out <= in0;
			3'b001:	out <= in1;
			3'b010:	out <= in2;
			3'b011:	out <= in3;
			3'b100:	out <= in4;
			3'b101:	out <= in5;
			3'b110:	out <= in6;
			3'b111:	out <= in7;
			default: out <= 32'd1234567890;
		endcase
	end
	
endmodule : Mux32bit_8x1

module Mux32bits_4x2(
	input logic [1:0] sel,
	input logic [4:0] in0, in1, in2, in3,
	output logic [4:0] out);
	
	always_comb
	begin
		
		case(sel)
		
			2'b00:
			begin
				out <= in0;	
			end
			
			2'b01:
			begin
				out <= in1;
			end
			
			2'b10:
			begin
				out <= in2;
			end
		
			2'b11:
			begin
				out <= in3;
			end
			/*
			default:
			begin
				out <= 32'd1234567890;
			end*/
				
		endcase
	end
	
endmodule : Mux32bits_4x2