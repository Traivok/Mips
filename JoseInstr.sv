/* 
pra testar o sb/sh
de sb 2 M[0], 4 M[1], 6 M[2], 8 M[3]
e depois de lw em Z, veja se MemData e [2][4][6][8]
sh 516 M[0] e 2064 M[2]
lw em z e veja se MemData e [2][4][8][16]
*/

				RTE:
				begin	
					REG_reset <= 0;
					REG_funct <= 3'b000;
					
					PCWriteCond <= 0;
					PCWrite <= 1; 
          
					MemDataSize <= 2'b00;
					
					wr <= 0;				
					IRWrite <= ; 
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
			
				SB_READ:
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
					MDR_load <= 1;			// get word
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
			
				SH_READ:
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