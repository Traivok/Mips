module Control( input logic [5:0] Op,
				output logic PCWriteCond, 
				output logic PCWrite, 
				output logic IorD,
				output logic MemRead,
				output logic MemWrite,
				output logic MemtoReg, 
				output logic IRWrite, 
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB
				output logic ALUSrcA,
				output logic RegWrite,
				output logic RegDst,
				output logic [7:0] StateOut);
				
	/* BEGIN OF DATA SECTION */		
		logic a_load;
		logic a_reset;		
		logic b_load;
		logic b_reset;
		logic PC_load;
		logic PC_reset;		
		logic MDR_load;
		logic MDR_reset;
		logic ALU_load;
		logic ALU_reset;
		logic IR_load;
		logic IR_reset;
		/* END OF DATA SECTION */
		
		
				
	
	
endmodule : Control;