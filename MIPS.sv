module MIPS(input logic Clk, input logic reset,
			output logic [31:0] MemData,
			output logic [31:0] Address,
			output logic [31:0] WriteDataMem,
			output logic [04:0] WriteRegister,
			output logic [31:0] WriteDataReg,
			output logic [31:0] MDR,
			output logic [31:0] Alu,
			output logic [31:0] AluOut,
			output logic [31:0] PC,
			output logic wr,
			output logic RegWrite,
			output logic IRWrite,
			output logic [7:0] Estado,
			output logic [31:0] EPC,
			output logic [31:0] Reg_Desloc
  );
	  
	/* Begin of Control Section */
	logic PCWriteCond; 
	logic PCWrite; 				// ativo em 1
	logic IorD;
	logic DP_wr; 					//  memory write/read control
	logic [1:0] MemtoReg; 
	logic DP_IRWrite; 				// Instruction register write controla a escrita no registrador de instrucoes.
	logic [2:0] PCSource;
	logic [1:0] ALUOp;
	logic [1:0] ALUSrcB;
	logic ALUSrcA;
	logic DP_RegWrite;				// write registers control
	logic RegReset;				// reset all registers of 31-0
	logic [1:0] RegDst;				
	logic [2:0] ALU_sel;
	logic [1:0] MemDataSize;

	logic ALU_zero;				// alu zero result flag
	logic ALU_overflow;
	logic ALU_neg;				// alu < 0 flag
	logic ALU_eq;					// alu equal flag
	logic ALU_gt;					// alu greater flag
	logic ALU_lt;					// alu less flag
	logic REG_reset;
	logic [2:0] REG_funct;
	logic [4:0] REG_NumberOfShifts;
	logic [31:0] REG_array;
	logic [31:0] Shifted_Register;

	logic A_load;
	logic A_reset;		
	logic B_load;
	logic B_reset;
	logic PC_load;
	logic PC_reset;
	logic EPC_load;
	logic EPC_reset;	
	logic MDR_load;
	logic MDR_reset;
	logic ALUOut_load;
	logic ALUOut_reset;
	logic IR_reset;
						
	logic [04:0] DP_WriteRegister; // Register to be overwrited
	/* End of Control Section */
	
	/* Begin of Data Section */
	logic [31:0] NEW_PC;
	logic [31:0] DP_PC;			// PC content
	
	logic [31:0] DP_MemData;		// Memory content
	logic [31:0] DP_Address;		// address of memory query

	logic [31:0] DP_WriteDataReg; 	// Data to be write
	logic [31:0] DP_WriteDataMem;	// data to write at memory
	logic [31:0] DP_MDR;			// Memory Data Register content
	logic [31:0] DP_Alu;			// ALU result
	logic [31:0] ALU_LHS;		// left operand of alu
	logic [31:0] ALU_RHS;		// right operand of alu
	logic [31:0] DP_AluOut; 		// ALU out register content
	logic [31:0] Aout, Bout;	// content of registers a and b, respectively
 
	logic [31:0] mul;			// mult

	logic [5:0] Instr31_26;
	logic [4:0] Instr25_21;
	logic [4:0] Instr20_16;
	logic [15:0] Instr15_0;
	logic [4:0] Instr15_11;
	logic [25:0] Instr25_0;
	logic [31:0] Instr15_0_EXTENDED; // sign extend result of Instruction[15:0]
	logic [5:0] Funct;
	logic [31:0] UPPER_IMMEDIATE; 	// used in LUI instruction 15-0 field at MSD and 0 at LSD
    
	logic [31:0] ReadData1;
	logic [31:0] ReadData2;
	
	logic [31:0] JMP_address;
	logic [31:0] BEQ_address;
	logic [31:0] ALU_result;
	logic [31:0] Half_Word;
	logic [31:0] Byte;
	logic [31:0] Bout_Halfword;
	logic [31:0] Bout_Byte;
	logic [31:0] SetLessThan;
  
	logic [31:0] OVERFLOW_EXCEPTION;
	logic [31:0] INVALIDCODE_EXCEPTION;
	logic [31:0] STACK_ADDRESS;
	logic [5:00] STACK_POINTER;
	/* End of Data Section */
	
	/* Assignment Section */
	
	// [15:11] field of instruction is used at reg write operations
	assign Instr15_11[4:0] = Instr15_0[15:11];
		
	// concatenate [25-0] instruction's bits 
	assign Instr25_0[25:00] = { Instr25_21, Instr20_16, Instr15_0};
		
	// extract JMP field of MSD of PC, and [25:0] field of instruction, also concatenate it with 00
	assign JMP_address[31:0] = { DP_PC[31:28], Instr25_0, 2'b00 };
	
	SignExtend SignEx(Instr15_0, Instr15_0_EXTENDED);
	assign BEQ_address[31:00] = { Instr15_0_EXTENDED[29:00], 2'b00 };
		
	// extract Funct field of instruction
	assign Funct = Instr15_0[5:0];
	
	// extend 15-0 field
	assign UPPER_IMMEDIATE[31:00] = { Instr15_0[15:00], 16'd0 };
	
	assign SetLessThan [31:0] = { 32{ALU_lt} };
	  
	assign OVERFLOW_EXCEPTION = 32'd255;
	assign INVALIDCODE_EXCEPTION = 32'd254;
	assign STACK_ADDRESS = 32'd227;
	assign STACK_POINTER = 5'd29;
  
	/* CONTROL SECTION BEGINS HERE */
	Control (	
			// control inputs
			.Clk(Clk), .Reset_signal(reset), .Op(Instr31_26), .Funct(Funct), 
			// alu flags
			.ALU_zero(ALU_zero), .ALU_overflow(ALU_overflow), .ALU_neg(ALU_neg), .ALU_eq(ALU_eq), .ALU_gt(ALU_gt), .ALU_lt(ALU_lt), 
    
			//Shift
			.REG_reset(REG_reset), .REG_funct(REG_funct), .REG_NumberOfShifts(REG_NumberOfShifts),
				
			.StateOut(Estado),
				
			// enables, disables
			.PCWriteCond(PCWriteCond),
			.PCWrite(PCWrite),
			.IorD(IorD),
			.wr(DP_wr),
			.MemtoReg(MemtoReg),
			.IRWrite(DP_IRWrite),
			.PCSource(PCSource),
			.ALUSrcB(ALUSrcB),
			.ALUSrcA(ALUSrcA),
			.RegDst(RegDst),
			.ALU_sel(ALU_sel),
			.MemDataSize(MemDataSize),  
    
			// registers load and reset signals
			.A_load(A_load),
			.A_reset(A_reset),		
			.B_load(B_load),
			.B_reset(B_reset),
			.PC_load(PC_load),
			.PC_reset(PC_reset),
			.E_PC_load(EPC_load),					
			.E_PC_reset(EPC_reset),
			.MDR_load(MDR_load),
			.MDR_reset(MDR_reset),
			.ALUOut_load(ALUOut_load),
			.ALUOut_reset(ALUOut_reset),
			.IR_reset(IR_reset),
			.RegReset(RegReset),
			.RegWrite(DP_RegWrite)
						
		);			
	/* CONTROL SECTION ENDS HERE */
	
	Registrador ProgramCounter(Clk, PC_reset, PC_load, NEW_PC, DP_PC);
	Registrador ExcProgramCounter(Clk, EPC_reset, EPC_load, ALU_result, EPC);
	
	Mux32bit_2x1 MemMux(IorD, DP_PC, DP_AluOut, DP_Address);
	
	Extract_LSB MemDataInExtract( .Word(Bout), .HalfWord(Bout_Halfword), .Byte(Bout_Byte) );
	
	Mux32bits_4x2 MemDataInMux(MemDataSize, Bout, Bout_Byte, Bout_Halfword, 32'd0, DP_WriteDataMem);
  
	Memoria Memory(.Address(DP_Address), .Clock(Clk), 
				   .wr(DP_wr), .Datain(DP_WriteDataMem), .Dataout(DP_MemData));
	
	Instr_Reg Instruction_Register(Clk, IR_reset, DP_IRWrite, DP_MemData, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
	Registrador MemDataRegister(Clk, MDR_reset, MDR_load, DP_MemData, DP_MDR);

	Extract_LSB extract(Bout, Half_Word, Byte);
  
	Mux32bit_8x1 WriteDataMux(MemtoReg, DP_AluOut, DP_MDR, UPPER_IMMEDIATE, STACK_ADDRESS, SetLessThan, Reg_Desloc, Half_Word, Byte, DP_WriteDataReg);
	Mux5bits_4x2 WriteRegMux(RegDst, Instr20_16, Instr15_11, STACK_POINTER, 5'd0, DP_WriteRegister);
		
	Banco_reg Registers(Clk, RegReset, DP_RegWrite, 
							 Instr25_21, Instr20_16,
							 DP_WriteRegister, DP_WriteDataReg,
							 ReadData1, ReadData2
						);
							
	Registrador A(Clk, A_reset, A_load, ReadData1, Aout);
	Registrador B(Clk, B_reset, B_load, ReadData2, Bout); 
  
	Mux32bit_2x1 LHS_Mux(ALUSrcA, DP_PC, Aout, ALU_LHS);
	Mux32bits_4x2 RHS_Mux(ALUSrcB, Bout, 32'd4, Instr15_0_EXTENDED, BEQ_address, ALU_RHS);
  
	ALS ALU(ALU_LHS, ALU_RHS, ALU_sel, ALU_result, ALU_overflow, ALU_neg, ALU_zero, ALU_eq, ALU_gt, ALU_lt, Clk, REG_reset, REG_funct, REG_NumberOfShifts, Bout, Reg_Desloc);
	Registrador ALUOut_Reg(Clk, ALUOut_reset, ALUOut_load, ALU_result, DP_AluOut);
	
	Mux32bit_8x1 PC_MUX(	PCSource, ALU_result, DP_AluOut, JMP_address, EPC, Aout, INVALIDCODE_EXCEPTION, 
							32'd0, Aout,
							NEW_PC
						 );

endmodule : MIPS

module ALS(	/* BEGIN OF ALU INPUTS/OUTPUTS SECTION */
			input logic [31:0] oper_A, oper_B, input logic [2:0] ALU_sel,
			output logic [31:0] ALU_result,	output logic overflow, 
			negative, zero, equal, greater, lesser,
			/* BEGIN OF SHIFT INPUTS/OUTPUTS SECTION */
			input logic Clk, reset, input logic [2:0] funct, 
			input logic [4:0] NumberofShifts, input logic [31:0] Array, 
			output logic [31:0] Shifted_Array);
		
	ula32 ALU(oper_A, oper_B, ALU_sel, ALU_result, overflow, negative, zero, equal, greater, lesser);
	
	RegDesloc DESL(Clk, reset, funct, NumberofShifts, Array, Shifted_Array);

endmodule : ALS



