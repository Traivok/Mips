module Control( 
				input logic Clk,
				input logic Reset_signal,
				input logic [5:0] Op,
				input logic [5:0] Funct, 			// in case of OP = 0x0
				input logic ALU_zero,				// alu zero result flag
				input logic ALU_overflow,
				input logic ALU_neg,				// alu < 0 flag
				input logic ALU_eq,					// alu equal flag
				input logic ALU_gt,					// alu greater flag
				input logic ALU_lt,					// alu less flag
								
				output logic [7:0] StateOut,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				
				output logic wr, 					// memory write/read control				
				output logic IRWrite,				// Instruction register write
				output logic RegWrite,				// write registers control
				output logic RegReset,
												
				output logic [2:0] ALU_sel,
				
				output logic MemtoReg, 
				output logic [1:0] PCSource,
				output logic ALUSrcA,
				output logic [1:0] ALUSrcB,
				output logic IorD,
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
				output logic IR_reset			
			  );
				
	/* BEGIN OF DATA SECTION */		
		logic holdState;		// use it if the value of some state will be used
		
		logic [7:0] state;
		// load it if PCWrite is set or a conditional jump is set and result of alu op is zero 
		assign PC_load = PCWrite | ( PCWriteCond & ALU_zero ); 
	/* END OF DATA SECTION */
	
		
	/* BEGIN OF ENUM SECTION */		
		enum logic [5:0] { FUNCT_OP = 6'h0,
				  BEQ_OP = 6'h4, BNE_OP = 6'h5, LW_OP = 6'h23, SW_OP = 6'h2b, LUI_OP = 6'hf, J_OP = 6'h2 } OpCodeEnum;
				  
		enum logic [5:0] { ADD_FUNCT = 6'h20, AND_FUNCT = 6'h24, SUB_FUNCT = 6'h22, XOR_FUNCT = 6'h26, BREAK_FUNCT = 6'hd, NOP_FUNCT = 6'h0 } FunctEnum;
		
		enum logic [7:0] { RESET, FETCH, FETCH_MEM_DELAY1, FETCH_MEM_DELAY2, DECODE, BEQ, BNE, LW, SW, LUI, J, BEQ1, BEQ2, NOPE } StateEnum;
	/* END OF enum SECTION */
		
		initial
		begin
			state = RESET;
			
			A_load = 0;
			A_reset = 0;
			B_load = 0;
			B_reset = 0;
			PC_load = 0;
			PC_reset = 0;
			MDR_load = 0;
			MDR_reset =	0;
			ALUOut_load = 0;
			ALUOut_reset = 0;
			IRWrite = 0;
			IR_reset = 0;		
			
		end
			
		always_ff@(posedge Clk)
		begin
			
			StateOut <= state;	
			
			if (Reset_signal)
				state <= RESET;
			else begin			
				case (state)
				
					RESET:
					begin
						state <= FETCH;
						holdState <= RESET;
					end
				
					FETCH:
					begin
						state <= FETCH_MEM_DELAY1;
					end
					
					FETCH_MEM_DELAY1:
					begin
						state <= FETCH_MEM_DELAY2;
					end
					
					FETCH_MEM_DELAY2:
					begin
						state <= DECODE;
					end
					
					DECODE:
					begin
						
						//state <= state; // TIRAR ISSO, ta pra compilar	
						/*
						case (Op)
						
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
						*/
					end // DECODE
					
					default:
					begin
						state <= FETCH;
					end
				endcase	// state
			end // RESET signal
		end

/*		APAGAR ISSO DEPOIS, ZE
				PCWriteCond =  
				PCWrite = 
				
				wr = 				
				IRWrite = 
				RegWrite = 
				RegReset = 
												
				ALU_sel = 3'bxxx;
				
				MemtoReg = 1'bx;
				PCSource = 2'bxx; 
				
				ALUSrcA = 1'bx;
				ALUSrcB = 2'bxx; 
				IorD = 1'bx;
				RegDst = 1'bx;
				
				A_load = 
				A_reset = 		
				B_load = 
				B_reset = 
				PC_reset = 		
				MDR_load = 
				MDR_reset = 
				ALUOut_load = 
				ALUOut_reset = 
				IR_reset = 


*/
	always_comb
		begin
			case (state)
				
				RESET:					// reset ALL registers
				begin
					PCWriteCond = 0;
					PCWrite = 0;
					
					wr = 0;		
					IRWrite = 0; 
					RegWrite = 0;
					RegReset = 1;
													
					ALU_sel = 3'b000;
					
					MemtoReg = 1'b0;
					PCSource = 2'b00; 
					ALUSrcA = 1'b0;
					ALUSrcB = 2'b00; 
					IorD = 1'b0;
					RegDst = 1'b0;
					
					A_load = 0;
					A_reset = 1;	
					B_load = 0;
					B_reset = 1;

					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 1;
					ALUOut_load = 0;
					ALUOut_reset = 1;
					IR_reset = 	1;			
				end					
			
				FETCH:					// get content of pc, read it and send a memread signal
				begin					// the MDR and IR will be loaded with Memory content
					PCWriteCond = 0;
					PCWrite = 0;
					
					wr = 0;		
					IRWrite = 1;			// get the current instruction
					RegWrite = 0;
					RegReset = 0;
													
					ALU_sel = 3'b000;
					
					MemtoReg = 1'b0;
					PCSource = 2'b00; 
					ALUSrcA = 1'b0;
					ALUSrcB = 2'b01; 
					IorD = 1'b0;			// instruction set
					RegDst = 1'b0;
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;

					PC_reset = 0;	
					MDR_load = 1;			// store the content of address read 
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_reset = 	0;			
				end
				
				FETCH_MEM_DELAY1:					// just hold memread signal
				begin
					PCWriteCond = 0;
					PCWrite = 0;
					
					wr = 0;		
					IRWrite = 1; 
					RegWrite = 0;
					RegReset = 0;
													
					ALU_sel = 3'b000;
					
					MemtoReg = 1'b0;
					PCSource = 2'b00; 
					ALUSrcA = 1'b0;
					ALUSrcB = 2'b01; 
					IorD = 1'b0;			// instruction set
					RegDst = 1'b0;
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;

					PC_reset = 0;	
					MDR_load = 1;			// store the content of address read 
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_reset = 	0;	
				end
				
				FETCH_MEM_DELAY2: 				// increment PC+4 and hold memread signals
				begin
					PCWriteCond = 0;
					PCWrite = 1;
					
					wr = 0;		
					IRWrite = 1; 
					RegWrite = 0;
					RegReset = 0;
													
					ALU_sel = 3'b001;		// 001 is the ADD code of ALU
					
					MemtoReg = 1'b0;
					PCSource = 2'b00;		// perform a sum of PC + 4 
					ALUSrcA = 1'b0;			// get the PC value
					ALUSrcB = 2'b01; 		// and +4
					IorD = 1'b0;			// instruction set
					RegDst = 1'b0;
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;

					PC_reset = 0;	
					MDR_load = 1;			// store the content of address read 
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_reset = 	0;	
				end
				
				DECODE:					// store values read of 32 Mips registers at A,B;
				begin					// add PC content with instruction offset field, uset if next OP is beq
					PCWriteCond = 0;	// and store it's content at aluout
					PCWrite = 0; 
					
					wr = 0;	
					IRWrite = 0; 
					RegWrite = 0;
					RegReset = 0;
													
					ALU_sel = 3'b001;	// perform an addition of PC and offset field
					
					MemtoReg = 1'b0;
					PCSource = 2'b00; 
					ALUSrcA = 1'b0;
					ALUSrcB = 2'b11;	// get the [15-0] field of instruction extentend and multiplied by 4 
					IorD = 1'b0;
					RegDst = 1'b0;
					
					A_load = 1;			// load read1 at A
					A_reset = 0;	
					B_load = 1;			// load read2 at B
					B_reset = 0;

					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 1;	// store the alu result at aluout, it may be needed for Branch operations
					ALUOut_reset = 0;
					IR_reset = 0;					
				end
				
				NOPE:
				begin
					PCWriteCond = 0;
					PCWrite = 0;
					
					wr = 0;				
					IRWrite = 0; 
					RegWrite = 0;
					RegReset = 0;
													
					ALU_sel = 3'b000;
					
					MemtoReg = 1'b0;
					PCSource = 2'b00; 
					
					ALUSrcA = 1'b0;
					ALUSrcB = 2'b00; 
					IorD = 1'b0;
					RegDst = 1'b0;
					
					A_load = 0;
					A_reset = 0;	
					B_load = 0;
					B_reset = 0;
					PC_reset = 0;	
					MDR_load = 0;
					MDR_reset = 0;
					ALUOut_load = 0;
					ALUOut_reset = 0;
					IR_reset = 0;
				end
			endcase // state
		end //end always comb
	
endmodule : Control
