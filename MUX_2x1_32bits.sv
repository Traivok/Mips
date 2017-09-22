module MUX_2x1_32bits (input logic Clk, input logic sel,
						input logic [31:0] B, input logic [31:0] A, 
						output logic [31:0] OUT);

enum logic {selectA = 1'b0, selectB = 1'b1} state;

always_comb@(posedge Clk)
begin	
	
	case sel:

		selectA:
		begin
			OUT <= A;
		end
		
		selectB:
		begin
			OUT <= B;
		end
		
		default: OUT <= 32'b0;
		
end


endmodule : MUX_2x1_32bits
