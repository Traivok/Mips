module ALS( input logic operation, // se quer usar alu ou shift
			/* BEGIN OF ALU INPUTS/OUTPUTS SECTION */
			input logic [31:0] oper_A, oper_B, input logic [2:0] ALU_sel,
			output logic [31:0] ALU_result,	output logic overflow, 
			negative, zero, equal, greater, lesser,
			/* BEGIN OF SHIFT INPUTS/OUTPUTS SECTION */
			input logic Clk, reset, input logic [2:0] funct, 
			input logic [4:0] NumberofShifts, input logic [31:0] Array, 
			output logic [31:0] Shifted_Array);
		
	ula32 ALU(oper_A, oper_B, ALU_sel, ALU_result, overflow, negative, zero, equal, greater, lesser);
	
	RegDesloc DESL(Clk, reset, funct, NumberofShifts, Array, Shifted_Array);

endmodule 