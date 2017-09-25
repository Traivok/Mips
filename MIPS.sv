module MIPS(output logic SO_PRA_COMPILAR);
	
	/* Begin of Control Section */
	logic PCWriteCond; 
	logic PCWrite; 				// ativo em 1
	logic IorD;
	logic wr; 					// memory write/read control
	logic MemtoReg; 
	logic IRWrite; 				// Instruction register write controla a escrita no registrador de instru�oes.
	logic [1:0] PCSource;
	logic [1:0] ALUOp;
	logic [1:0] ALUSrcB;
	logic ALUSrcA;
	logic RegWrite;				// write registers control
	logic RegReset;				// reset all registers of 31-0
	logic RegDst;				
				
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
						
	logic [04:0] WriteRegister; // Register to be overwrited
	
	logic BEQ_SHIFTLEFT_reset, JMP_SHIFTLEFT_reset;
	logic [2:0] BEQ_SHIFTLEFT_funct, JMP_SHIFTLEFT_funct;
	logic [4:0] BEQ_SHIFTLEFT_N, JMP_SHIFTLEFT_N;
	/* End of Control Section */
	
	/* Begin of Data Section */
	logic [31:0] NEW_PC;
	logic [31:0] PC;			// PC content
	initial NEW_PC = 31'd0;

	logic [31:0] MemData;		// Memory content
	logic [31:0] Address;		// address of memory query

	logic [31:0] WriteDataReg; 	// Data to be write
	logic [31:0] WriteDataMem;	// data to write at memory
	logic [31:0] MDR;			// Memory Data Register content
	logic [31:0] Alu;			// ALU result
	logic [31:0] AluOut; 		// ALU out register content
	logic [31:0] Aout, Bout;	// content of registers a and b, respectively
	
	logic [31:0] Reg_Desloc; 	// Content of shift register

	logic [31:0] EPC;			// Exception Program Counter content
	logic [31:0] mul;			// mult

	logic [5:0] Instr31_26;
	logic [4:0] Instr25_21;
	logic [4:0] Instr20_16;
	logic [15:0] Instr15_0;
	logic [15:11] Instr15_11;
	logic [25:0] Instr25_0;
	logic [31:0] Instr15_0_EXTENDED;
		
	logic [31:0] ReadData1;
	logic [31:0] ReadData2;
	
	logic [31:0] JMP_address;
	/* End of Data Section */
	
	// extract [15-11] field of instruction to Instr15_11
	assign Instr15_11 = { Instr15_0[15], Instr15_0[14], Instr15_0[13], Instr15_0[12], Instr15_0[11]};
	// concatenate [25-0] instruction's bits 
	assign Instr25_0 = { Instr25_21, Instr20_16, Instr15_0 };
	
	Registrador ProgramCounter(Clk, PC_reset, PC_load, NEW_PC, PC);
	Mux32bit_2x1 MemMux(IorD, PC, AluOut, Address);
	Memoria Memory(Address, Clk, wr, WriteDataMem, MemData);
	
	Instr_Reg Instruction_Register(Clk, IR_reset, IR_load, MemData, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
	Registrador MemDataRegister(Clk, MDR_reset, MDR_load, MDR);
	

	Mux5bit_2x1 WriteRegMux(RegDst, Instr25_21, Instr15_11, WriteRegister);
	Mux32bit_2x1 WriteDataMux(MemtoReg, AluOut, MDR, WriteDataReg);
	
	Banco_reg Registers(Clk, RegReset, RegWrite, 
							 Instr25_21, Instr20_16,
							 WriteRegister, WriteDataReg,
							 ReadData1, ReadData2
						);
			
	// The output of this 2bit shift left will be used at rhs of ALU
	RegDesloc BEQ_SHIFTLEFT(Clk, BEQ_SHIFTLEFT_reset, 
								  BEQ_SHIFTLEFT_shift, BEQ_SHIFTLEFT_N, 
								  Instr15_0_EXTENDED, Reg_Desloc
							);
	
	Registrador A(Clk, A_reset, A_load, ReadData1, Aout);
	Registrador B(Clk, B_reset, B_load, ReadData2, Bout); 
	
	// muf for lhs input of alu
	Mux32bit_2x1 LHS_Mux(AluSrcA, PC, Aout);
	Mux32bits_4x2 RHS_Mux(AluSrcB, Bout, 32'd4, Instr15_0_EXTENDED, Reg_Desloc);
	
	/*
	JMP_SHIFTLEFT RegDesloc(Clk, JMP_SHIFTLEFT_reset,
								  JMP_SHIFTLEFT_shift, JMP_SHIFTLEFT_N, 
								  Instr25_0, jmp 
								  
	JMP_ADDRESS HOW TO CONCAT							
	*/
	
	
endmodule : MIPS