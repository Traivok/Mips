module DataPath(
		output logic [31:0] MemData_out,		// Memory content
		output logic [31:0] Address_out,		// address of memory query
		output logic [31:0] WriteDataMem_out,	// data to write at memory
		output logic [4:0] WriteRegister_out, 	// Register to be overwrited
		output logic [31:0] WriteDataReg_out, 	// Data to be write
		output logic [31:0] MDR_out,			// Memory Data Register content
		output logic [31:0] Alu_out,			// ALU result
		output logic [31:0] AluOut_out, 		// ALU out register content
		output logic [31:0] PC_out,			// PC content
		output logic [31:0] Reg_Desloc_out, 	// Content of shift register
		output logic wr_out, 					// memory write/read control
		output logic RegWrite_out,				// write registers control
		output logic IRWrite_out,				// Instruction register write controlola a escrita no registrador de instru�c�oes.
		output logic [31:0] EPC_out,			// Exception Program Counter content
		output logic [31:0] mul_out,			// mult
		output logic [7:0] Estado_out			// state
	);
	
	/* Begin of Control Section */
	logic [31:0] MemData;		// Memory content
	logic [31:0] Address;		// address of memory query
	logic [31:0] WriteDataMem;	// data to write at memory
	logic [04:0] WriteRegister; // Register to be overwrited
	logic [31:0] WriteDataReg; 	// Data to be write
	logic [31:0] MDR;			// Memory Data Register content
	logic [31:0] Alu;			// ALU result
	logic [31:0] AluOut; 		// ALU out register content
	logic [31:0] PC;			// PC content
	logic [31:0] Reg_Desloc; 	// Content of shift register
	logic wr; 					// memory write/read control
	logic RegWrite;				// write registers control
	logic IRWrite;				// Instruction register write controlola a escrita no registrador de instru�c�oes.
	logic [31:0] EPC;			// Exception Program Counter content
	logic [31:0] mul;			// mult
	logic [7:0] Estado;			// state
	/* End of Control Section */
	
	/* Begin of Control Section */
	logic PC_reset, PC_load;
	
	/* End of Control Section */
	
	logic [31:0] NEW_PC;
	initial NEW_PC = 31'd0;
	
	Registrador ProgramCounter(Clk, PC_reset, PC_load, NEW_PC, PC);
	Mux32bit_2x1 MemMux(IorD, PC, AluOut, Address);
	Memoria Memory(Address, Clk, wr, WriteDataMem, MemData);
	
	/*
	Instr_Reg Instruction_Register
	Registers Banco_reg
	MemDataRegister Registrador
	Registrador A
	Registrador B
	ALU ula32
	Registrador ALUOut_reg*/	
	
endmodule : DataPath