module ALS(		
				input logic reset, Clk,

				/* BEGIN OF ALU INPUTS/OUTPUTS SECTION */
				input logic [31:0] oper_A, oper_B, input logic [2:0] ALU_sel,
				output logic [31:0] ALU_result,	output logic overflow, 
				negative, zero, equal, greater, lesser,
				/* BEGIN OF SHIFT INPUTS/OUTPUTS SECTION */
				input logic RegDesloc_reset, input logic [2:0] RegDesloc_OP, 
				input logic [4:0] NumberofShifts, input logic [31:0] Array, 
				output logic [31:0] Shifted_Array,
				/* BEGIN OF MULTIPLICATION SECTION */
				input logic workMult, output logic [63:0] mul, output logic endMult 			
			);
		
	ula32 ALU(oper_A, oper_B, ALU_sel, ALU_result, overflow, negative, zero, equal, greater, lesser);
	
	RegDesloc DESL(Clk, RegDesloc_reset, RegDesloc_OP, NumberofShifts, Array, Shifted_Array);

	multiplication( .Clk(Clk), .state(workMult), .reset(reset), 
					.lhs(oper_A), .rhs(oper_B), .result(mul), .endSignal(endMult)
				   );
endmodule 
