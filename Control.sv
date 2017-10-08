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
				output logic REG_reset,
 				output logic [2:0] REG_funct,
				output logic [4:0] REG_NumberOfShifts,
								
				output logic [7:0] StateOut,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				
				output logic wr, 					// memory write/read control				
				output logic IRWrite,				// Instruction register write
				output logic RegWrite,				// write registers control
				output logic RegReset,
												
				output logic [2:0] ALU_sel,
				
				output logic [2:0] MemtoReg, 
				output logic [2:0] PCSource,
				output logic ALUSrcA,
				output logic [1:0] ALUSrcB,
				output logic [1:0] IorD,
				output logic [1:0] RegDst,
				output logic [1:0] MemDataSize,
				
				output logic A_load,
				output logic A_reset,		
				output logic B_load,
				output logic B_reset,
				output logic PC_load,
				output logic PC_reset,
				output logic E_PC_load,
				output logic E_PC_reset,					
				output logic MDR_load,
				output logic MDR_reset,
				output logic ALUOut_load,
				output logic ALUOut_reset,
				output logic IR_reset			
			  );
				
	/* BEGIN OF DATA SECTION */				
		logic [7:0] state;
		// load it if PCWrite is set or a conditional jump is set and result of alu op is zero
		
		always_comb
		begin
			if (state == BNE) PC_load <= PCWrite | ( PCWriteCond & (~ALU_zero) );
			else PC_load <= PCWrite | ( PCWriteCond & ALU_zero );
		end
		
		assign StateOut = state;	 
	/* END OF DATA SECTION */
	
		
	/* BEGIN OF ENUM SECTION */		
		enum logic [5:0] { FUNCT_OP = 6'h0,
				  BEQ_OP = 6'h4, BNE_OP = 6'h5, LW_OP = 6'h23, SW_OP = 6'h2b, LUI_OP = 6'hf, J_OP = 6'h2 } OpCodeEnum;
				  
		enum logic [5:0] { ADD_FUNCT = 6'h20, AND_FUNCT = 6'h24, SUB_FUNCT = 6'h22, XOR_FUNCT = 6'h26, BREAK_FUNCT = 6'hd, NOP_FUNCT = 6'h0 } FunctEnum;
		
  enum logic [7:0] { RESET, STACK_INIT, FETCH, FETCH_MEM_DELAY1, FETCH_MEM_DELAY2, DECODE, BEQ, BNE, LW, SW, LUI, 		// 10
							J, NOP, ADD, R_WAIT, AND, SUB, XOR, BREAK, NOT_A, INC, 									// 20
							LW_ADDRESS_COMP, SW_ADDRESS_COMP, WRITE_BACK, LW_DELAY1, LW_DELAY2			// 24
						 } StateEnum;
							
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
			
	always_ff@(posedge Clk or posedge Reset_signal)
		begin
					
			if (Reset_signal)
				state <= RESET;
				
			else begin			
				case (state)
				
					RESET:
					begin
						state <= STACK_INIT;
					end
          
        	STACK_INIT:
          begin
            state <= FETCH;
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
					
						case (Op)
						
							FUNCT_OP:
							begin
								case (Funct)
							
									ADD_FUNCT:
									begin
										state <= ADD;
									end
									
									AND_FUNCT:
									begin
										state <= AND;
									end
									
									SUB_FUNCT:
									begin
										state <= SUB;
									end
									
									XOR_FUNCT:
									begin
										state <= XOR;
									end
									
									BREAK_FUNCT:
									begin
										state <= BREAK;
									end
									
									NOP_FUNCT:
									begin
										state <= NOP;
									end
							
								endcase // case funct
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
								state <= LW_ADDRESS_COMP;
							end
							
							SW_OP:
							begin
								state <= SW_ADDRESS_COMP;
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
					
					ADD:
					begin
						state <= R_WAIT;
					end
					
					R_WAIT:
					begin
						state <= FETCH;
					end
					
					AND:
					begin
						state <= R_WAIT;
					end
					
					SUB:
					begin
						state <= R_WAIT;
					end
					
					XOR:
					begin
						state <= R_WAIT;
					end
					
					BREAK:
					begin
						state <= BREAK;
					end
					
					BEQ:
					begin
						state <= FETCH;
					end
							
					BNE:
					begin
						state <= FETCH;
					end
										
					J:
					begin
						state <= FETCH;
					end
					
					LUI:
					begin
						state <= FETCH;
					end
					
					LW_ADDRESS_COMP:
					begin
						state <= LW;
					end
					
					LW:
					begin
						state <= LW_DELAY1;
					end
					
					LW_DELAY1:
					begin
						state <= LW_DELAY2;
					end
					
					LW_DELAY2:
					begin
						state <= WRITE_BACK;
					end
					
					WRITE_BACK:
					begin
						state <= FETCH;
					end
					
					SW_ADDRESS_COMP:
					begin
						state <= SW;
					end
					
					SW:
					begin
						state <= FETCH;
					end
					
					NOP:
					begin
						state <= FETCH;
					end
										
					default:
					begin
						state <= RESET;
					end
				endcase	// state
			end // RESET signal
		end

/*		APAGAR ISSO DEPOIS, ZE
				PCWriteCond <=  
					PCWrite <= 
          
					MemDataSize <= 2'b00;
					
					wr <= 				
					IRWrite <= 
					RegWrite <= 
					RegReset <= 
													
					ALU_sel <= 3'bxxx;
					
					MemtoReg <= 3'bxxx;
					PCSource <= 3'b0xx; 
					
					ALUSrcA <= 1'bx;
					ALUSrcB <= 2'bxx; 
					IorD <= 2'bxx;
					RegDst <= 2'bxx;
					
					A_load <= 
					A_reset <= 		
					B_load <= 
					B_reset <= 
					PC_reset <= 
					E_PC_load <=
					E_PC_reset <=	
					MDR_load <= 
					MDR_reset <= 
					ALUOut_load <= 
					ALUOut_reset <= 
					IR_reset <= 

*/

	always_comb
		begin
			case (state)
				
				RESET:					// reset ALL registers
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 1;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 1;	
					B_load <= 0;
					B_reset <= 1;

					PC_reset <= 1;
					E_PC_load <= 0;
					E_PC_reset <= 1;
					MDR_load <= 0;
					MDR_reset <= 1;
					ALUOut_load <= 0;
					ALUOut_reset <= 1;
					IR_reset <= 1;			
				end
        
        STACK_INIT:
        begin
 					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b011;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b10;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
        end
			
				FETCH:					// get content of pc, read it and send a memread signal
				begin					// the MDR and IR will be loaded with Memory content
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0;			// get the current instruction
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01; 
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;	
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;			// store the content of address read 
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 	0;			
				end
				
				FETCH_MEM_DELAY1:					// just hold memread signal
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01; 
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;			// store the content of address read 
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;	
				end
				
				FETCH_MEM_DELAY2: 				// increment PC+4 and hold memread signals
				begin
					PCWriteCond <= 0;
					PCWrite <= 1;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 1; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001;		// 001 is the ADD code of ALU
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;		// perform a sum of PC + 4 
					ALUSrcA <= 1'b0;			// get the PC value
					ALUSrcB <= 2'b01; 		// and +4
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 1;			// store the content of address read 
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 	0;	
				end
				
				DECODE:					// store values read of 32 Mips registers at A,B;
				begin					// add PC content with instruction offset field, uset if next OP is beq
					PCWriteCond <= 0;	// and store it's content at aluout
					PCWrite <= 0; 
          
					MemDataSize <= 2'b00;
					
					wr <= 0;	
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001;	// perform an addition of PC and offset field
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b11;	// get the [15-0] field of instruction extended and multiplied by 4 
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 1;			// load read1 at A
					A_reset <= 0;	
					B_load <= 1;			// load read2 at B
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;	// store the alu result at aluout, it may be needed for Branch operations
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				ADD:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b001;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				R_WAIT:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000; //
					PCSource <= 3'b000;
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b01; //
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				NOP:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				AND:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b011;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				SUB:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b010;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				XOR:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b110;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				/*NOT_A:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b101;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // don't care
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				INC:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b101;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // don't care
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end*/
				
				BREAK:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				J:
				begin
					PCWriteCond <= 0; // Don't care?
					PCWrite <= 1;     // Write at PC
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			 // Don't write
					IRWrite <= 0;     // DÃƒÂºvida
					RegWrite <= 0;    // ?
					RegReset <= 0;	
													
					ALU_sel <= 3'b001; //sum
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b010;  // PC <<= {PC[31:28],(IR[25:0], 2'b00)}
					ALUSrcA <= 1'b0; 
					ALUSrcB <= 2'b11;   // The 2nd input of ALU is the sign-extended, lower 16 bits of the IR shiftled left 2 bits
					IorD <= 2'b01;
					RegDst <= 2'b00;     // Don't Care
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				BEQ:		// branch if Aout == Bout
				begin
					PCWriteCond <= 1; 
					PCWrite <= 0;     
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			  // read from memory
					IRWrite <= 0;         //
					RegWrite <= 0;        // 
					RegReset <= 0;	
													
					ALU_sel <= 3'b010;   //	sub
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b001;   // ???
					ALUSrcA <= 1'b1;     // The first ALU operend comes from the A register
					ALUSrcB <= 2'b00;    // The 2nd input of ALU comes from B register
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;				
				end
								
				BNE:					//	branch if Aout != Bout
				begin
					PCWriteCond <= 1; 
					PCWrite <= 0;     
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			  // read from memory
					IRWrite <= 0;
					RegWrite <= 0; 
					RegReset <= 0;	
													
					ALU_sel <= 3'b010;   //sub
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b001;   // ???
					ALUSrcA <= 1'b1;     // The first ALU operend comes from the A register
					ALUSrcB <= 2'b00;    // The 2nd input of ALU comes from B register
					IorD <= 2'b00;
					RegDst <= 2'b00; 
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;				
				end
				
				LUI:
				begin
					PCWriteCond <= 0;  
					PCWrite <= 0;
					
					MemDataSize <= 2'b00;
          
					wr <= 0;		
					IRWrite <= 0;
					RegWrite <= 1;				// write UI at rt
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b010;			// get 15-0 extendend field
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;				// [20-16] will specify what reg will be overwrited
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;		
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
				
				SW_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;	
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;	// store the PC+OFFSET at aluout
					ALUOut_reset <= 0;
					IR_reset <= 	0;			
				end
				
				SW:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 1;					// write
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					IorD <= 2'b01;			// set to data
					RegDst <= 2'b00;
						
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;	
				end

				LW_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;	// store the PC+OFFSET at aluout
					ALUOut_reset <= 0;
					IR_reset <= 0;			
				end
			
				LW:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
						
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1;			// get word
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;			
				end
				
				LW_DELAY1:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1;			// get word
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;			
				end
				
				LW_DELAY2:
				begin
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
						
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1;			// get word
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;			
				end
			
				WRITE_BACK:
				begin
					PCWriteCond <= 0; 
					PCWrite <= 0;
          
					MemDataSize <= 2'b0;
					
					wr <= 0;		
					IRWrite <= 0;
					RegWrite <= 1;			// write mem content at some register specified by rt
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b001;		// Write the content of MDR at WriteReg
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;			// content of rt (20-16)
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;	
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;	
				end
				
				default:
				begin
					PCWriteCond <= 0; 
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					IorD <= 2'b00;
					RegDst <= 2'b00;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;		
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					IR_reset <= 0;
				end
							
			endcase // state
		end //end always comb
	
endmodule : Control
