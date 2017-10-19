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
				input logic endMult,
				input logic [4:0] Shamt,
				
				output logic ShamtOrRs,
				output logic REG_reset,
 				output logic [2:0] REG_funct,
								
				output logic [7:0] StateOut,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				
				output logic wr, 					// memory write/read control				
				output logic IRWrite,				// Instruction register write
				output logic RegWrite,				// write registers control
				output logic RegReset,
												
				output logic [2:0] ALU_sel,
				output logic [5:0] workMult,
				
				output logic [2:0] MemtoReg, 
				output logic [2:0] PCSource,
				output logic ALUSrcA,
				output logic [1:0] ALUSrcB,
				output logic [1:0] ALUOutSrc,
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
				output logic MulReg_reset,
				output logic MulReg_load,
				output logic IR_reset		
			  );
				
	/* BEGIN OF DATA SECTION */				
		logic [7:0] state;
		logic [7:0] nextState;
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
				  BEQ_OP = 6'h04, BNE_OP = 6'h05, LW_OP = 6'h23, SW_OP = 6'h2b,
				  LUI_OP = 6'h0f, J_OP = 6'h02, ADDI_OP = 6'h08, ADDIU_OP = 6'h09,
				  ANDI_OP = 6'h0c, SXORI_OP = 6'h0e, JAL_OP = 6'h03, RTE_OP = 6'h10,
				  SB_OP = 6'h28, SH_OP = 6'h29, LBU_OP = 6'h24, LHU_OP = 6'h25,
				  SLTI_OP = 6'h0a } OpCodeEnum;
				  
		enum logic [5:0] { ADD_FUNCT = 6'h20, AND_FUNCT = 6'h24, SUB_FUNCT = 6'h22,
						  XOR_FUNCT = 6'h26, BREAK_FUNCT = 6'hd, NOP_FUNCT = 6'h0,
						 ADDU_FUNCT = 6'h21, SUBU_FUNCT = 6'h23,
						 MULT_FUNCT = 6'h18, MFHI_FUNCT = 6'h10, MHLO_FUNCT = 6'h12,
						 SRL_FUNCT = 6'h2, SLLV_FUNCT = 6'h4,
						 SRA_FUNCT = 6'h3, SRAV_FUNCT = 6'h7, JR_FUNCT = 6'h8, 
						  SLT_FUNCT = 6'h2a /*,	 RTE_FUNCT = 6'h10 == MFHI*/ } FunctEnum;
		
  enum logic [7:0] { RESET, STACK_INIT, FETCH, FETCH_MEM_DELAY1, FETCH_MEM_DELAY2, DECODE, BEQ, BNE, LW, SW , LUI, 		// 10
							J, NOP, ADD, R_WAIT, AND, SUB, XOR, BREAK, NOT_A, INC, 									// 20
							LW_ADDRESS_COMP, SW_ADDRESS_COMP, WRITE_BACK, LW_DELAY1, LW_DELAY2, ADDU, ADDI, ADDIU, // 28
							R_WAIT_IMMEDIATE, ANDI, SUBU, SXORI, SLL, SRL, SLLV, SRA, SRAV, S_WAIT,  // 38
							TREATING_OVERFLOW_1, TREATING_OVERFLOW_2, OVERFLOW_EXCEPTION_DELAY1, // 42
							OVERFLOW_EXCEPTION_DELAY2, LOAD_PC_OVERFLOW_EXCEPTION, 
							TREATING_INVALID_OP_1, TREATING_INVALID_OP_2, OP_EXCEPTION_DELAY1, 
							OP_EXCEPTION_DELAY2,LOAD_PC_OP_EXCEPTION, //45
							MULT0, MULT1, MFHI, MHLO, MFSTORE, JAL_WR31, JR, SLT, RTE, // 54
							SB_ADDRESS_COMP, SB_DELAY1, SB_DELAY2, SB_DELAY3, SB_WRITE, //59
							SH_ADDRESS_COMP, SH_DELAY1, SH_DELAY2, SH_DELAY3, SH_WRITE, //64
							LBU_1, LBU_2, LBU_2_DELAY1, LBU_2_DELAY2, LBU_3, // 69
		    				LHU_1, LHU_2, LHU_2_DELAY1, LHU_2_DELAY2, LHU_3, // 74											
							JAL_COMP, SLTI, SHF_LOAD 						 // 77
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
						nextState <= TREATING_INVALID_OP_1;
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
									if(Shamt == 5'd0)
										state <= NOP;
									else
										state <= SHF_LOAD;
										nextState <= SLL;
									end
									
									ADDU_FUNCT:
									begin
										state <= ADDU;
									end
									
									SUBU_FUNCT:
									begin
										state <= SUBU;
									end
									
									MULT_FUNCT:
									begin
										state <= MULT0;
									end
									
									MFHI_FUNCT:
									begin
										state <= MFHI;
									end
									
									MHLO_FUNCT:
 									begin
										state <= MHLO;
									end
									
									SRL_FUNCT:
 									begin
										state <= SHF_LOAD;
										nextState <= SRL;
									end
									
									SLLV_FUNCT:
 									begin
										state <= SHF_LOAD;
										nextState <= SLLV;
									end
									
									SRA_FUNCT:
 									begin
										state <= SHF_LOAD;
										nextState <= SRA;
									end
									
									SRAV_FUNCT:
 									begin
										state <= SHF_LOAD;
										nextState <= SRAV;
									end
									
									JR_FUNCT:
									begin
										state <= JR;
									end
									
									SLT_FUNCT:
									begin
										state <= SLT;
									end
									
									default:
										state <= TREATING_INVALID_OP_1;
							
								endcase // case funct
							end
							
							RTE_OP:
							begin
								if (Funct == 6'h10) state <= RTE;
								else state <= TREATING_INVALID_OP_1;//INVALID OPCODE;								
							end
							
							LBU_OP:
							begin
								state <= LBU_1;
							end
							
							LHU_OP:
							begin
								state <= LHU_1;
							end
							
							BEQ_OP:
							begin
								state <= BEQ;
							end							
							
							BNE_OP:
							begin
								state <= BNE;
							end
							
							ANDI_OP:
							begin
								state <= ANDI;
							end
							
							LW_OP:
							begin
								state <= LW_ADDRESS_COMP;
							end
							
							SW_OP:
							begin
								state <= SW_ADDRESS_COMP;
							end
							
							SB_OP:
							begin
								state <= SB_ADDRESS_COMP;
							end
							
							SH_OP:
							begin
								state <= SH_ADDRESS_COMP;
							end							
							
							LUI_OP:
							begin
								state <= LUI;
							end	
							
							J_OP:
							begin
								state <= J;
							end
							
							JAL_OP:
							begin
								state <= JAL_COMP;
							end
							
							ADDI_OP:
							begin
								state <= ADDI;
							end
							
							ADDIU_OP:
							begin
								state <= ADDIU;
							end
							
							SXORI_OP:
							begin
								state <= SXORI;
							end
							
							SLTI_OP:
							begin
								state <= SLTI;
							end
							
							default:
								state <= TREATING_INVALID_OP_1;
							
						endcase // case OP		
						
					end // DECODE
					
					LBU_1:
					begin
						state <= LBU_2;
					end
					
					LBU_2:
					begin
						state <= LBU_2_DELAY1;
					end
						
					LBU_2_DELAY1:
					begin
						state <= LBU_2_DELAY2;
					end
						
					LBU_2_DELAY2:
					begin
						state <= LBU_3;
					end
						
					LBU_3:
					begin
						state <= FETCH;
					end	

					LHU_1:
					begin
						state <= LHU_2;
					end
					
					LHU_2:
					begin
						state <= LHU_2_DELAY1;
					end
						
					LHU_2_DELAY1:
					begin
						state <= LHU_2_DELAY2;
					end
						
					LHU_2_DELAY2:
					begin
						state <= LHU_3;
					end
						
					LHU_3:
					begin
						state <= FETCH;
					end						
					ADDU:
					begin
						state <= R_WAIT; 
					end
					
					ADDI:
					begin
						if(ALU_overflow) 
							state <= TREATING_OVERFLOW_1;
						else 
							state <= R_WAIT_IMMEDIATE;
					end
					
					ADDIU:
					begin
						state <= R_WAIT_IMMEDIATE; 
					end
				
					ADD: 
					begin
						if(ALU_overflow) 
							state <= TREATING_OVERFLOW_1;
						else 
							state <= R_WAIT;
					end
					
					TREATING_OVERFLOW_1:
					begin
						state <= TREATING_OVERFLOW_2;
					end
					
					TREATING_OVERFLOW_2:
					begin
						state <= OVERFLOW_EXCEPTION_DELAY1;
					end
					
					OVERFLOW_EXCEPTION_DELAY1:
					begin
						state <= OVERFLOW_EXCEPTION_DELAY2;
					end
					
					OVERFLOW_EXCEPTION_DELAY2:
					begin
						state <= LOAD_PC_OVERFLOW_EXCEPTION;
					end
					
					LOAD_PC_OVERFLOW_EXCEPTION:
					begin
						state <= FETCH;
					end
					
					TREATING_INVALID_OP_1:
					begin
						state <= TREATING_INVALID_OP_2;
					end
					
					TREATING_INVALID_OP_2:
					begin
						state <= OP_EXCEPTION_DELAY1;
					end
					
					OP_EXCEPTION_DELAY1:
					begin
						state <= OP_EXCEPTION_DELAY2;
					end
					
					OP_EXCEPTION_DELAY2:
					begin
						state <= LOAD_PC_OP_EXCEPTION;
					end
					
					LOAD_PC_OP_EXCEPTION:
					begin
						state <= FETCH;
					end
					
					R_WAIT:
					begin
						state <= FETCH;
					end
					
					R_WAIT_IMMEDIATE:
					begin
						state <= FETCH;
					end
					
					AND:
					begin
						state <= R_WAIT;
					end
					
					ANDI:
					begin
						state <= R_WAIT_IMMEDIATE;
					end
					
					SUB:
					begin
						if(ALU_overflow) 
							state <= TREATING_OVERFLOW_1;
						else 
							state <= R_WAIT;
					end
					
					SUBU:
					begin
						state <= R_WAIT;
					end
							
					XOR:
					begin
						state <= R_WAIT;
					end
					
					SXORI:
					begin
						state <= R_WAIT_IMMEDIATE;
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
					
					JR:
					begin
						state <= FETCH;
					end
					
					JAL_COMP:
					begin
						state <= JAL_WR31;
					end
					
					JAL_WR31:
					begin
						state <= FETCH;
					end
					
					SLT:
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
					
					
					SB_ADDRESS_COMP:
					begin
						state <= SB_DELAY1;
					end
					
					SB_DELAY1:
					begin
						state <= SB_DELAY2;
					end

					SB_DELAY2:
					begin
						state <= SB_DELAY3;
					end
					
					SB_DELAY3:
					begin
						state <= SB_WRITE;
					end
					
					SB_WRITE:
					begin
						state <= FETCH;
					end
										
					SH_ADDRESS_COMP:
					begin
						state <= SH_DELAY1;
					end
					
					SH_DELAY1:
					begin
						state <= SH_DELAY2;
					end
					
					SH_DELAY2:
					begin
						state <= SH_DELAY3;
					end

					SH_DELAY3:
					begin
						state <= SH_WRITE;
					end
					
					SH_WRITE:
					begin
						state <= FETCH;
					end					
					
					SHF_LOAD:
					begin
						state <= nextState;
					end
					
					SLL:
					begin
						state <= S_WAIT;
					end
					
					SRL:
					begin
						state <= S_WAIT;
					end
					
					SLLV:
					begin
						state <= S_WAIT;
					end
					
					SRA:
					begin
						state <= S_WAIT;
					end
					
					SRAV:
					begin
						state <= S_WAIT;
					end
					
					S_WAIT:
					begin
						state <= FETCH;
					end
										
					NOP:
					begin
						state <= FETCH;
					end
					
					MULT0:
					begin
						state <= MULT1;
					end
						
					MULT1:
					begin
						if (endMult == 1'b0) state <= MULT1;
						else state <= FETCH;
					end
					
					MFHI:
					begin
						state <= MFSTORE;
					end
								
					MHLO:
					begin
						state <= MFSTORE;
					end

					MFSTORE:
					begin
						state <= FETCH;
					end
					
					RTE:
					begin
						state <= FETCH;
					end
					
					SLTI:
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
				REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <=  
					PCWrite <= 
          
					MemDataSize <= 2'b00;
					
					wr <= 				
					IRWrite <= 
					RegWrite <= 
					RegReset <= 
													
					ALU_sel <= 3'bxxx;
					workMult <= 6'd0;
					
					MemtoReg <= 3'bxxx;
					PCSource <= 3'b0xx; 
					
					ALUSrcA <= 1'bx;
					ALUSrcB <= 2'bxx;
					ALUOutSrc <= 2'bxx;
					IorD <= 2'bxx;
					RegDst <= 2'bxx;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 
*/

	always_comb
		begin
			case (state)
				
				RESET:					// reset ALL registers
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 1;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 1;
 					MulReg_load <= 0;
					IR_reset <= 1;			
				end
        
				STACK_INIT:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
 					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b011;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b10;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
			
				FETCH:					// get content of pc, read it and send a memread signal
				begin					// the MDR and IR will be loaded with Memory content
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0;			// get the current instruction
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				FETCH_MEM_DELAY1:					// just hold memread signal
				begin
				
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end
				
				FETCH_MEM_DELAY2: 				// increment PC+4 and hold memread signals
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 1;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 1; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001;		// 001 is the ADD code of ALU
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;		// perform a sum of PC + 4 
					ALUSrcA <= 1'b0;			// get the PC value
					ALUSrcB <= 2'b01; 		// and +4
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end
				
				DECODE:					// store values read of 32 Mips registers at A,B;
				begin					// add PC content with instruction offset field, uset if next OP is beq
					REG_reset <= 0;
					REG_funct <= 3'b000; // load regdesloc with content of ReadData1			
					
					PCWriteCond <= 0;	// and store it's content at aluout
					PCWrite <= 0; 
          
					MemDataSize <= 2'b00;
					
					wr <= 0;	
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001;	// perform an addition of PC and offset field
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b11;	// get the [15-0] field of instruction extended and multiplied by 4
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LBU_1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001; // sum
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b10; // instr[15:0] sign extended
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; // ALU_result to ALUOut
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LBU_2:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; // leitura			
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01; // ALUOut
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LBU_2_DELAY1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; 	
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00; 
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LBU_2_DELAY2: 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; 	
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00; 
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; // a leitura vai para o MDR
					MDR_reset <= 0;
					ALUOut_load <= 0; 
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LBU_3:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b111; // MDR_Byte
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00; // rt
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LHU_1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001; // sum
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b10; // instr[15:0] sign extended
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; // ALU_result to ALUOut
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LHU_2:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; // leitura			
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01; // ALUOut
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LHU_2_DELAY1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; 	
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00; 
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LHU_2_DELAY2: 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; 	
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00; 
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; // a leitura vai para o MDR
					MDR_reset <= 0;
					ALUOut_load <= 0; 
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end

				LHU_3:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b110; // MDR_Word
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00; // rt
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				TREATING_OVERFLOW_1: // EPC = PC - 4 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;	
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b010; // sub
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0; //PC
					ALUSrcB <= 2'b01; //4
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 1; // resultado no EPC
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0; 
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				TREATING_OVERFLOW_2: // leitura da memória do endereço 255 (overflow)
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; // leitura
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b10; // EXCEPTION_ADDRESS
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1;
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
	
				OVERFLOW_EXCEPTION_DELAY1: 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; //
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				OVERFLOW_EXCEPTION_DELAY2: // mdr recebe o valor lido da memoria
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; //
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LOAD_PC_OVERFLOW_EXCEPTION:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 1; // escreve no pc o MDR_Byte
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b101;  // MDR_Byte (255)
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				TREATING_INVALID_OP_1: // EPC = PC - 4 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b010; // sub
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0; //PC
					ALUSrcB <= 2'b01; //4
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 1; // resultado no EPC
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 0; 
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				TREATING_INVALID_OP_2: // leitura da memória do endereço 252 (invalid opcode)
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0; // leitura
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b10; // EXCEPTION_ADDRESS
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				OP_EXCEPTION_DELAY1: 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; //
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				OP_EXCEPTION_DELAY2: // mdr recebe o valor lido da memoria
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 1; //
					MDR_reset <= 0;
					ALUOut_load <= 0;
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				LOAD_PC_OP_EXCEPTION:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 1; // escreve no pc o BYTE DE 254
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b110;  // (254)
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				ADDIU:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001; // soma 
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; 
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1; // A (rs)
					ALUSrcB <= 2'b10; // sign_extend
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00; 
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; //
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				ADDI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001; // soma 
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; 
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1; // A (rs)
					ALUSrcB <= 2'b10; // sign_extend
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00; 
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; //
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				ADDU: 
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b001;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				ADD:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b001;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				R_WAIT:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; //
					PCSource <= 3'b000;
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b01; 
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				R_WAIT_IMMEDIATE:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; // ALUout
					PCSource <= 3'b000;
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				S_WAIT:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1; //
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; //
					PCSource <= 3'b000;
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b01; // Reg_Desl
					IorD <= 2'b00;
					RegDst <= 2'b01; 
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end

				
				NOP:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				AND:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b011;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				ANDI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b011; // and
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000; 
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b10; // sign_extend
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; //
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SUB:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b010;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SUBU:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b010; // sub
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; //
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				XOR:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;

					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b110;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SXORI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b110; // xor
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b10; // sign_extend
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; //
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				BREAK:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				J:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0; // Don't care?
					PCWrite <= 1;     // Write at PC
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			 // Don't write
					IRWrite <= 0;     // 
					RegWrite <= 0;    // ?
					RegReset <= 0;	
													
					ALU_sel <= 3'b001; //sum
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b010;  // PC <<= {PC[31:28],(IR[25:0], 2'b00)}
					ALUSrcA <= 1'b0; 
					ALUSrcB <= 2'b11;   // The 2nd input of ALU is the sign-extended, lower 16 bits of the IR shiftled left 2 bits
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;
					RegDst <= 2'b00;     // Don't Care
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end				
				
				JAL_COMP:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0;			// get the current instruction
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b001; // sum
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;			// instruction set
					RegDst <= 2'b11; // link adress
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;	
					B_load <= 0;
					B_reset <= 0;

					PC_reset <= 0;	
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1;   // store PC + 4
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end
				
				JAL_WR31:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 1;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0;
					RegWrite <= 1;  // write PC+4 at 31
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b010; // jump address 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b01;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b11; // link adress
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end
			
				JR:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0; 
					PCWrite <= 1;     // Write at PC
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			 // 
					IRWrite <= 0;     // 
					RegWrite <= 0;    // ?
					RegReset <= 0;	
													
					ALU_sel <= 3'b001; //sum
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b100;  // PC <<= Aout
					ALUSrcA <= 1'b1; // LHS = Aout
					ALUSrcB <= 2'b01;   // constat 4
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;
					RegDst <= 2'b00;     // Don't Care
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SLT:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0	;	
					IRWrite <= 0;
					RegWrite <= 1;
					RegReset <= 0;
													
					ALU_sel <= 3'b111;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b100;// set less than
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SLTI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0	;	
					IRWrite <= 0;
					RegWrite <= 1;
					RegReset <= 0;
													
					ALU_sel <= 3'b111;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b100;// set less than
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b1;
					ALUSrcB <= 2'b10;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
								
				BEQ:		// branch if Aout == Bout
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 1; 
					PCWrite <= 0;     
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			  // read from memory
					IRWrite <= 0;         //
					RegWrite <= 0;        // 
					RegReset <= 0;	
													
					ALU_sel <= 3'b010;   //	sub
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b001;   // ???
					ALUSrcA <= 1'b1;     // The first ALU operend comes from the A register
					ALUSrcB <= 2'b00;    // The 2nd input of ALU comes from B register
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;				
				end
								
				BNE:					//	branch if Aout != Bout
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 1; 
					PCWrite <= 0;     
          
					MemDataSize <= 2'b00;
					
					wr <= 0;			  // read from memory
					IRWrite <= 0;
					RegWrite <= 0; 
					RegReset <= 0;	
													
					ALU_sel <= 3'b010;   //sub
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b001;   // ???
					ALUSrcA <= 1'b1;     // The first ALU operend comes from the A register
					ALUSrcB <= 2'b00;    // The 2nd input of ALU comes from B register
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00; 
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;				
				end
				
				LUI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;  
					PCWrite <= 0;
					
					MemDataSize <= 2'b00;
          
					wr <= 0;		
					IRWrite <= 0;
					RegWrite <= 1;				// write UI at rt
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b010;			// get 15-0 extendend field
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;				// [20-16] will specify what reg will be overwrited
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SW_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
					workMult <= 6'd0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SW:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 1;					// write
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end

				LW_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
					workMult <= 6'd0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
			
				LW:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				LW_DELAY1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				LW_DELAY2:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
			
				WRITE_BACK:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0; 
					PCWrite <= 0;
          
					MemDataSize <= 2'b0;
					
					wr <= 0;		
					IRWrite <= 0;
					RegWrite <= 1;			// write mem content at some register specified by rt
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b001;		// Write the content of MDR at WriteReg
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;			// content of rt (20-16)
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;	
				end
				
				SLL:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b010;
					 // NumberOfShifts = shamt?
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b01;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SRL:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b011;
					 // NumberOfShifts = shamt?
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b01;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SLLV:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b010;
					 // NumberOfShifts = rs ?
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b01;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b1;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SRA:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b100;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b01;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end	
				
				SRAV:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b100;
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b01; // alu_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b1;  
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end				
				
				MULT0:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd1;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 1;
					IR_reset <= 0;		
				end

				MULT1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 6'd2;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b1; // A
					ALUSrcB <= 2'b00; // B
					ALUOutSrc <= 2'b00; // ALU_result
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 1;
					IR_reset <= 0;		
				end
			
				MFHI:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 1;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b10;  //get himul
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; 		// store himul at ALUOut
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end

				MHLO:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 0;
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 1;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000;
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b11;  //get lomul
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
					A_load <= 0;
					A_reset <= 0;
					B_load <= 0;
					B_reset <= 0;
					PC_reset <= 0;
					E_PC_load <= 0;
					E_PC_reset <= 0;
					MDR_load <= 0;
					MDR_reset <= 0;
					ALUOut_load <= 1; 		// store lomul at ALUOut
					ALUOut_reset <= 0;
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end

				MFSTORE:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;
					IRWrite <= 0;
					RegWrite <= 1;   // write mul result
					RegReset <= 0;
					
					ALU_sel <= 3'b000;
					workMult <= 1;
					
					MemtoReg <= 3'b000;  // select aluout
					PCSource <= 3'b000;
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b01; // select RD
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
					
				RTE:
				begin	
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 1; 
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b00;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b011;
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SB_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
					workMult <= 0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
							
				SB_DELAY1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SB_DELAY2:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SB_DELAY3:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SB_WRITE:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b01;
						
					wr <= 1;
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;        // the value of address is stored in aluout
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
				
				SH_ADDRESS_COMP: 			// compute the address of memory acsess
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;		
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
												
					ALU_sel <= 3'b001;	// add the Aout to Offset
					workMult <= 0;
						
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b1;		// get the content of the A register
					ALUSrcB <= 2'b10; 	// and the sign extended of offset
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
			
				SH_DELAY1:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SH_DELAY2:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end

				SH_DELAY3:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
						
					wr <= 0;					// read
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;			// set to data to memmux
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end
				
				SH_WRITE:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b01;
						
					wr <= 1;
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
														
					ALU_sel <= 3'b000;
					workMult <= 0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00;
					ALUOutSrc <= 2'b00;
					IorD <= 2'b01;        // the value of address is stored in aluout
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
						
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;			
				end 
				
				default:
				begin
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					
					PCWriteCond <= 0;
					PCWrite <= 0;
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= 0; 
					RegWrite <= 0;
					RegReset <= 0;
													
					ALU_sel <= 3'b000;
					workMult <= 6'd0;
					
					MemtoReg <= 3'b000;
					PCSource <= 3'b000; 
					
					ALUSrcA <= 1'b0;
					ALUSrcB <= 2'b00; 
					ALUOutSrc <= 2'b00;
					IorD <= 2'b00;
					RegDst <= 2'b00;
					ShamtOrRs <= 1'b0;
					
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
					MulReg_reset <= 0;
 					MulReg_load <= 0;
					IR_reset <= 0;
				end
							
			endcase // state
		end //end always comb
	
endmodule : Control