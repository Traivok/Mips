module Control( 
				input logic Clk,
				input logic Reset,
				input logic [5:0] Op,
				input logic [7:0] nextFunctState, 	// in case of OP = 0x0
				input logic ALU_ZERO,	
				
				output logic [7:0] StateOut,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				output logic IorD,
				output logic wr, 					// memory write/read control
				output logic MemtoReg, 
				output logic IRWrite, 				// Instruction register write controla a escrita no registrador de instruç˜oes.
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB,
				output logic ALUSrcA,
				output logic RegWrite,				// write registers control
				output logic RegReset,
				output logic RegDst,				
				
				output logic A_load,
				output logic A_reset,		
				output logic B_load,
				output logic B_reset,
				output logic PC_load,
				output logic PC_reset,		
				output logic MDR_load,
				output logic MDR_reset,
				output logic ALUOut_load,
				output logic ALUOut_reset,
				output logic IR_load,
				output logic IR_reset,
				
				output logic BEQ_SHIFTLEFT_reset, JMP_SHIFTLEFT_reset,
				output logic [2:0] BEQ_SHIFTLEFT_funct, JMP_SHIFTLEFT_funct,
				output logic [4:0] BEQ_SHIFTLEFT_N, JMP_SHIFTLEFT_N,			
				
			  );
				
	/* BEGIN OF DATA SECTION */		

		
		logic [7:0] state;
		logic [7:0] nextFunctState;
		// load it if PCWrite is set or a conditional jump is set and result of alu op is zero 
		assign PC_load = PCWrite | ( PCWriteCond & ALU_ZERO ); 
	/* END OF DATA SECTION */
	
		
	/* BEGIN OF ENUM SECTION */		
		enum logic [5:0] { FUNCT_OP = 8'h0,
				  BEQ_OP = 8'h4, BNE_OP = 8'h5, LW_OP = 8'h23, SW_OP = 8'h2b, LUI_OP = 8'hf, J_OP = 8'h2 } OpCodeEnum;
				  
		enum logic [5:0] { ADD_FUNCT = 8'h20, AND_FUNCT = 8'h24, SUB_FUNCT = 8'h22, XOR_FUNCT = 8'h26, BREAK_FUNCT = 8'hd, NOP_FUNCT = 8'h0 } FunctEnum;
		
		enum logic [7:0] { FETCH, DELAY1, DELAY2, DECODE, BEQ, BNE, LW, SW, LUI, J } StateEnum;
	/* END OF enum SECTION */
		
		initial
		begin
			state = FETCH;
			
			A_load = A_reset = B_load = B_reset = PC_load = PC_reset =		
					 MDR_load = MDR_reset =	ALUOut_load = ALUOut_reset = IR_load =
					 IR_reset = 0;		
			
		end
			
		always_ff@(posedge Clk)
		begin
			
			StateOut <= state;	
			
			case (state)
				FETCH:
				begin
					state <= DELAY1;
				end
				
				DELAY1:
				begin
					state <= DELAY2;
				end
				
				DELAY2:
				begin
					state <= DECODE;
				end
				
				DECODE:
				begin
			
					case (Op)
						FUNCT_OP:	// funct field
						begin
							state <= nextFunctState;						
						end
						
						BEQ_OP:
						begin
							state <= BEQ;
						end
						
						BNE_OP:
						begin
							state <= BNE;
						end
						
						LW_OP:
						begin
							state <= LW;
						end
						
						SW_OP:
						begin
							state <= SW;
						end
						
						LUI_OP:
						begin
							state <= LUI;
						end	
						
						J_OP:
						begin
							state <= J;
						end
						
					endcase // case OP		
				
				end // DECODE
				
				default:
				begin
					state <= FETCH;
				end
		
			endcase	// state
		end

/*		APAGAR ISSO DEPOIS, ZE

					PCWriteCond = 
					PCWrite = 					
					wr = 					  
					IRWrite = 
					RegWrite = 
					RegReset = 
						
					ALUOp = 2'b
					
					IorD = 1'b				
					MemtoReg = 1'b
					ALUSrcB = 2'b
					ALUSrcA = 1'b
					PCSource = 2'b
					RegDst = 1'b
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b

					A_load =
					A_reset =		
					B_load =
					B_reset =
					PC_reset =		
					MDR_load =
					MDR_reset =
					ALUOut_load =
					ALUOut_reset =
					IR_load =
					IR_reset =
*/

		
		always_comb
		begin
			case (state)
				FETCH:
				begin

					PCWriteCond = 0;	// Not conditional jump
					PCWrite = 1;		// load pc + 4 result
					wr = 0;				// read			  
					IRWrite = 1;		// write at IR
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'b00;		// perform an pc + 4 operation
					
					IorD = 1'bx;			
					MemtoReg = 1'bx;
					ALUSrcB = 2'b01;	// get +4 constant
					ALUSrcA = 1'b0;		// get content of PC
					PCSource = 2'b00;	// use pc + 4 result
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
									
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 1;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_load = 1;
					IR_reset = 0;	
				
				end
				
				DELAY1:
				begin

					PCWriteCond = 0;
					PCWrite = 0;			
					wr = 0;			// read			  
					IRWrite = 1;	// write at IR
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'bxx;
					
					IorD = 1'bx;			
					MemtoReg = 1'bx;
					ALUSrcB = 2'bxx;
					ALUSrcA = 1'bx;
					PCSource = 2'bxx;
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 1;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_load = 1;
					IR_reset = 0;	
				
				end
				
				DELAY2:
				begin

					PCWriteCond = 0;
					PCWrite = 0;			
					wr = 0;			// read			  
					IRWrite = 1;	// write at IR
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'bxx;
					
					IorD = 1'bx;			
					MemtoReg = 1'bx;
					ALUSrcB = 2'bxx;
					ALUSrcA = 1'bx;
					PCSource = 2'bxx;
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 1;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_load = 1;
					IR_reset = 0;
				
				end
				
				DECODE:
				begin

					PCWriteCond = 0;
					PCWrite = 0;			
					wr = 0;		  
					IRWrite = 0; 
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'b00;			// pc + offset
					
					IorD = 1'bx;		
					MemtoReg = 1'bx;
					ALUSrcB = 2'b11;		// get the signex and shift left of 15-0 instruction field
					ALUSrcA = 1'b0;			// pc content
					PCSource = 2'bxx;
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 1;				// store read1 at A
					A_reset = 0;	
					B_load = 1;				// store read2 at B
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 1;		// write the pc + offset result at aluout register
					ALUOut_reset = 0;
					IR_load = 0;
					IR_reset = 0;
		
				end
				
				BEQ1: // PERFORM SUBTRACTION
				begin

					PCWriteCond = 0;
					PCWrite = 0;
					wr = 0;			  
					IRWrite = 0;
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'b01;
					
					IorD = 1'bx;		
					MemtoReg = 1'bx;
					ALUSrcB = 2'b00;
					ALUSrcA = 1'b1;
					PCSource = 2'bxx;
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 1;
					ALUOut_reset = 0;
					IR_load = 0;
					IR_reset = 0;
	
				end
				
				BEQ2: // CONDITIONAL JUMP
				begin

					PCWriteCond = 1; 	// if result of Bout - Aout is zero, then PC will be overwrite
					PCWrite = 0;
					wr = 0;			  
					IRWrite = 0;
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'b01;
					
					IorD = 1'bx;		
					MemtoReg = 1'bx;
					ALUSrcB = 2'bxx;
					ALUSrcA = 1'bx;
					PCSource = 2'b01;
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_load = 0;
					IR_reset = 0;

				end
				
				J:
				begin
					PCWriteCond = 0;
					PCWrite = 1; // unconditional jump			
					wr = 0;
					IRWrite = 0;
					RegWrite = 0;
					RegReset = 0;
					
					ALUOp = 2'bxx;
					
					IorD = 1'bxx;		
					MemtoReg = 1'bx;
					ALUSrcB = 2'bxx;
					ALUSrcA = 1'bx;
					PCSource = 2'b10;	// PC = contentOf(25-0)*4
					RegDst = 1'bx;
					
					BEQ_SHIFTLEFT_reset = 
					BEQ_SHIFTLEFT_funct = 3'b 
					BEQ_SHIFTLEFT_N = 5'b
					
					JMP_SHIFTLEFT_reset = 
					JMP_SHIFTLEFT_funct = 3'b
					JMP_SHIFTLEFT_N = 5'b
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_load = 0;
					IR_reset = 0;
				end
				
		end
		
	
endmodule : Control