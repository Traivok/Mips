module MIPS(input logic Clk, input logic reset,
			output logic [31:0] OUT_MemData,
			output logic [31:0] OUT_Address,
			output logic [31:0] OUT_WriteDataMem,
			output logic [05:0] OUT_WriteDataReg,
			output logic [31:0] OUT_MDR,
			output logic [31:0] OUT_Alu,
			output logic [31:0] OUT_AluOut,
			output logic [31:0] OUT_PC,
			output logic OUT_wr,
			output logic [31:0] OUT_RegWrite,
			output logic [31:0] OUT_IRWrite,
			output logic [31:0] OUT_Estado
	);
	
	/* Begin of Control Section */
	logic PCWriteCond; 
	logic PCWrite; 				// ativo em 1
	logic IorD;
	logic wr; 					//  memory write/read control
	logic MemtoReg; 
	logic IRWrite; 				// Instruction register write controla a escrita no registrador de instruç˜oes.
	logic [1:0] PCSource;
	logic [1:0] ALUOp;
	logic [1:0] ALUSrcB;
	logic ALUSrcA;
	logic RegWrite;				// write registers control
	logic RegReset;				// reset all registers of 31-0
	logic RegDst;				
	logic [2:0] ALU_sel;

	logic ALU_zero;				// alu zero result flag
	logic ALU_overflow;
	logic ALU_neg;				// alu < 0 flag
	logic ALU_eq;					// alu equal flag
	logic ALU_gt;					// alu greater flag
	logic ALU_lt;					// alu less flag

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
	logic IR_reset;
						
	logic [04:0] WriteRegister; // Register to be overwrited
	/* End of Control Section */
	
	/* Begin of Data Section */
	logic [31:0] NEW_PC;
	logic [31:0] PC;			// PC content
	
	logic [31:0] MemData;		// Memory content
	logic [31:0] Address;		// address of memory query

	logic [31:0] WriteDataReg; 	// Data to be write
	logic [31:0] WriteDataMem;	// data to write at memory
	logic [31:0] MDR;			// Memory Data Register content
	logic [31:0] Alu;			// ALU result
	logic [31:0] ALU_LHS;		// left operand of alu
	logic [31:0] ALU_RHS;		// right operand of alu
	logic [31:0] AluOut; 		// ALU out register content
	logic [31:0] Aout, Bout;	// content of registers a and b, respectively
	
	logic [31:0] Reg_Desloc; 	// Content of shift register

	logic [31:0] EPC;			// Exception Program Counter content
	logic [31:0] mul;			// mult

	logic [5:0] Instr31_26;
	logic [4:0] Instr25_21;
	logic [4:0] Instr20_16;
	logic [15:0] Instr15_0;
	logic [4:0] Instr15_11;
	logic [25:0] Instr25_0;
	logic [31:0] Instr15_0_EXTENDED; // sign extend result of Instruction[15:0]
	logic [5:0] Funct;
		
	logic [31:0] ReadData1;
	logic [31:0] ReadData2;
	
	logic [31:0] JMP_address;
	logic [31:0] BEQ_address;
	logic [31:0] ALU_result;
	/* End of Data Section */
	
	/* Assignment Section */
	
	assign OUT_MemData = MemData;
	assign OUT_Address = Address;
	assign OUT_WriteDataMem = WriteDataMem;
	assign OUT_WriteDataReg = WriteDataReg;
	assign OUT_MDR = MDR;
	assign OUT_Alu = ALU_result;
	assign OUT_AluOut = AluOut;
	assign OUT_PC = PC;
	assign OUT_wr = wr;
	assign OUT_RegWrite = RegWrite;
	assign OUT_IRWrite = IRWrite; 
	assign OUT_Estado = Estado;
	
	// [15:11] field of instruction is used at reg write operations
	assign Instr15_11[4:0] = Instr15_0[15:11];
		
	// concatenate [25-0] instruction's bits 
	assign Instr25_0[25:00] = { Instr25_21, Instr20_16, Instr15_0};
		
	// extract JMP field of MSD of PC, and [25:0] field of instruction, also concatenate it with 00
	assign JMP_address[31:0] = { 2'b00, Instr25_21, Instr20_16, Instr15_0, PC[03:00] };
	
	SignExtend(Instr15_0, Instr15_0_EXTENDED);	
	assign BEQ_address[31:00] = { 2'b00, Instr15_0_EXTENDED[29:00] };
		
	// extract Funct field of instruction
	assign Funct = Instr15_0[5:0];
		
	assign WriteDataMem = Bout;
	
	/* CONTROL SECTION BEGINS HERE */
	Control(	
			// control inputs
			.Clk(Clk), .Reset_signal(reset), .Op(Instr31_26), .Funct(Funct), 
			// alu flags
			.ALU_zero(ALU_zero), .ALU_overflow(ALU_overflow), .ALU_neg(ALU_neg), .ALU_eq(ALU_eq), .ALU_gt(ALU_gt), .ALU_lt(ALU_lt), 
				
			.StateOut(Estado),
				
			// enables, disables
			.PCWriteCond(PCWriteCond),
			.PCWrite(PCWrite),
			.IorD(IorD),
			.wr(wr),
			.MemtoReg(MemtoReg),
			.IRWrite(IRWrite),
			.PCSource(PCSource),
			.ALUSrcB(ALUSrcB),
			.ALUSrcA(ALUSrcA),
			.RegDst(RegDst),
			.ALU_sel(ALU_sel),
					
			// registers load and reset signals
			.A_load(A_load),
			.A_reset(A_reset),		
			.B_load(B_load),
			.B_reset(B_reset),
			.PC_load(PC_load),
			.PC_reset(PC_reset),		
			.MDR_load(MDR_load),
			.MDR_reset(MDR_reset),
			.ALUOut_load(ALUOut_load),
			.ALUOut_reset(ALUOut_reset),
			.IR_reset(IR_reset),
			.RegReset(RegReset),
			.RegWrite(RegWrite)
						
		);			
	/* CONTROL SECTION ENDS HERE */
	
	Registrador ProgramCounter(Clk, PC_reset, PC_load, NEW_PC, PC);
	
	
	Mux32bit_2x1 MemMux(IorD, PC, AluOut, Address);

	Memoria Memory(.Address(Address), .Clock(Clk), 
				   .wr(wr), .Datain(WriteDataMem), .Dataout(MemData));
	
	Instr_Reg Instruction_Register(Clk, IR_reset, IRWrite, MemData, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
	Registrador MemDataRegister(Clk, MDR_reset, MDR_load, MemData, MDR);	

	Mux32bit_2x1 WriteDataMux(MemtoReg, AluOut, MDR, WriteDataReg);
	Mux5bit_2x1 WriteRegMux(RegDst, Instr20_16, Instr15_11, WriteRegister);
	
	
	Banco_reg Registers(Clk, RegReset, RegWrite, 
							 Instr25_21, Instr20_16,
							 WriteRegister, WriteDataReg,
							 ReadData1, ReadData2
						);
							
	Registrador A(Clk, A_reset, A_load, ReadData1, Aout);
	Registrador B(Clk, B_reset, B_load, ReadData2, Bout); 
		
	Mux32bit_2x1 LHS_Mux(ALUSrcA, PC, Aout, ALU_LHS);
	Mux32bits_4x2 RHS_Mux(ALUSrcB, Bout, 32'd4, Instr15_0_EXTENDED, BEQ_address, ALU_RHS);
		
	Ula32 ALU(ALU_LHS, ALU_RHS, ALU_sel, ALU_result, ALU_overflow, ALU_neg, ALU_zero, ALU_eq, ALU_gt, ALU_lt);
	Registrador ALUOut_Reg(Clk, ALUOut_reset, ALUOut_load, ALU_result, AluOut);
	
	Mux32bits_4x2 PC_MUX(PCSource, ALU_result, AluOut, JMP_address, 31'd12345, NEW_PC);

endmodule : MIPS
