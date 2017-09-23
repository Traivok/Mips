module Control( 
				input logic Clk,
				input logic [5:0] Op,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				output logic IorD,
				output logic MemRead,
				output logic wr, 					// memory write/read control
				output logic MemtoReg, 
				output logic IRWrite, 				// Instruction register write controla a escrita no registrador de instruç˜oes.
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB,
				output logic ALUSrcA,
				output logic RegWrite,				// write registers control
				output logic RegDst,
				output logic [7:0] StateOut
			  );
				
	/* BEGIN OF DATA SECTION */		
		logic A_load;
		logic A_reset;		
		logic B_load;
		logic B_reset;
		logic PC_load;
		logic PC_reset;		
		logic MDR_load;
		logic MDR_reset;
		logic ALUOut_load;
		logic ALUOut_reset;
		logic IR_load;
		logic IR_reset;
		
		logic [7:0] State;
	/* END OF DATA SECTION */
		
	/* BEGIN OF ENUM SECTION */		
		enum logic [5:0] { ADD_OP = 8'h0, AND_OP = 8'h0, SUB_OP = 8'h0, XOR_OP = 8'h0, BREAK_OP = 8'h0, NOP_OP = 8'h0,
				  BEQ_OP = 8'h4, BNE_OP = 8'h5, LW_OP = 8'h23, SW_OP = 8'h2b, LUI_OP = 8'hf } OpCodeEnum;
				  
		enum logic [5:0] { ADD_FUNCT = 8'h20, AND_FUNCT = 8'h24, SUB_FUNCT = 8'h22, XOR_FUNCT = 8'h26, BREAK_FUNCT = 8'hd, NOP_FUNCT = 8'h0 } FunctEnum;
		
		enum logic [7:0] { FETCH, DELAY1, DELAY2, DECODE } StateEnum;
	/* END OF enum SECTION */
		
		initial
		begin
			State = FETCH;	
		end
		
		
		always_ff@(posedge Clk)
		begin
			
//			case (State)
			
		
//			endcase
			
	
		end
		
	
endmodule : Control