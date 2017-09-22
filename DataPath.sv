module DataPath(
		logic [31:0] MemData_out;		// Memory content
		logic [31:0] Address_out;		// address of memory query
		logic [31:0] WriteDataMem_out;	// data to write at memory
		logic [4:0] WriteRegister_out; 	// Register to be overwrited
		logic [31:0] WriteDataReg_out; 	// Data to be write
		logic [31:0] MDR_out;			// Memory Data Register content
		logic [31:0] Alu_out;			// ALU result
		logic [31:0] AluOut_out; 		// ALU out register content
		logic [31:0] PC_out;			// PC content
		logic [31:0] Reg_Desloc_out; 	// Content of shift register
		logic wr_out; 					// memory write/read control
		logic RegWrite_out;				// write registers control
		logic IRWrite_out;				// Instruction register write controlola a escrita no registrador de instru�c�oes.
		logic [31:0] EPC_out;			// Exception Program Counter content
		logic [31:0] mul_out;			// mult
		logic [7:0] Estado_out;			// state
	);
	
	/* Begin of Control Section */
	logic [31:0] MemData;		// Memory content
	logic [31:0] Address;		// address of memory query
	logic [31:0] WriteDataMem;	// data to write at memory
	logic [4:0] WriteRegister; 	// Register to be overwrited
	logic [31:0] WriteDataReg; 	// Data to be write
	logic [31:0] MDR;			// Memory Data Register content
	logic [31:0] Alu;			// ALU result
	logic [31:0] AluOut; 		// ALU out register content
	logic [31:0] PC;			// PC content
	logic [31:0] Reg Desloc; 	// Content of shift register
	logic wr; 					// memory write/read control
	logic RegWrite;				// write registers control
	logic IRWrite;				// Instruction register write controlola a escrita no registrador de instru�c�oes.
	logic [31:0] EPC;			// Exception Program Counter content
	logic [31:0] mul;			// mult
	logic [7:0] Estado			// state
	/* End of Control Section */
	
	/* Begin of Control Section */
	logic PC_reset, PC_load;
	/* End of Control Section */
	
	Clk		: IN  STD_LOGIC;						-- Clock do registrador
			Reset	: IN  STD_LOGIC;						-- Reinicializa o conteudo do registrador
			Load	: IN  STD_LOGIC;						-- Carrega o registrador com o vetor Entrada
			Entrada : IN  STD_LOGIC_vector (31 downto 0); 	-- Vetor de bits que possui a informa��o a ser carregada no registrador
			Saida	: OUT STD_LOGIC_vector (31 downto 0)	-- Vetor de bits que possui a informa��o j� carregada no registrador
	Registrador ProgramCounter(Clk, PC_reset, PC_load
	
	Memoria Memory
	Instr_Reg Instruction_Register
	Registers Banco_reg
	MemDataRegister Registrador
	Registrador A
	Registrador B
	ALU ula32
	Registrador ALUOut_reg	
	
endmodule : DataPath