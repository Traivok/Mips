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
			output logic [31:0] Reg_Desloc,
			output logic [63:0] mul_Module,
			output logic [31:0] ALU_LHS,
			output logic [31:0] ALU_RHS,
			output logic [5:00] MultCounter	
  );
	  
	/* Begin of Control Section */
	logic PCWriteCond; 
	logic PCWrite; 				// ativo em 1
	logic [1:0] IorD;
	logic [2:0] MemtoReg; 
	logic [2:0] PCSource;
	logic [1:0] ALUOp;
	logic [1:0] ALUSrcB;
	logic ALUSrcA;
	logic [1:0] ALUOutSrc;
	logic RegReset;				// reset all registers of 31-0
	logic [1:0] RegDst;				
	logic [2:0] ALU_sel;
	logic ShamtOrRs;
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
	logic [5:0] workMult;
	logic endMult;

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
	logic MulReg_load;
	logic MulReg_reset;
	logic IR_reset;
	/* End of Control Section */
	
	/* Begin of Data Section */
	logic [31:0] NEW_PC;
	
	logic [31:0] Aout, Bout;	// content of registers a and b, respectively
	logic [31:0] ALUOutIn;
	logic [31:0] himul, lomul;

	logic [5:0] Instr31_26;
	logic [4:0] Instr25_21;
	logic [4:0] Instr20_16;
	logic [15:0] Instr15_0;
	logic [4:0] Instr15_11;
	logic [25:0] Instr25_0;
	logic [31:0] Instr15_0_EXTENDED; // sign extend result of Instruction[15:0]
	logic [31:0] UPPER_IMMEDIATE; 	// used in LUI instruction 15-0 field at MSD and 0 at LSD
    logic [5:0] Funct;
	logic [4:0] Shamt; // 10-6
    
	logic [31:0] ReadData1;
	logic [31:0] ReadData2;
	
	logic [31:0] JMP_address;
	logic [31:0] BEQ_address;
	logic [31:0] ALU_result;
	logic [31:0] Bout_Halfword;
	logic [31:0] Bout_Byte;
	logic [31:0] MDR_Byte;
	logic [31:0] MDR_Halfword;
	logic [31:0] Byte_Address;
	
	logic [31:0] SetLessThan;
  
	logic [31:0] OVERFLOW_EXCEPTION;
	logic [31:0] INVALIDCODE_EXCEPTION;
	logic [31:0] STACK_ADDRESS;
	logic [5:00] STACK_POINTER;
	logic [5:00] LINK_ADDRESS;
	/* End of Data Section */
	
	/* Assignment Section */
	
	// [15:11] field of instruction is used at reg write operations
	assign Instr15_11[4:0] = Instr15_0[15:11];
	
	assign Alu = ALU_result;
		
	// concatenate [25-0] instruction's bits 
	assign Instr25_0[25:00] = { Instr25_21, Instr20_16, Instr15_0};
	assign Shamt [4:0] = { Instr15_0 [10:6] };
	
	// extract JMP field of MSD of PC, and [25:0] field of instruction, also concatenate it with 00
	assign JMP_address[31:0] = { PC[31:28], Instr25_0, 2'b00 };
	
	SignExtend SignEx(Instr15_0, Instr15_0_EXTENDED);
	assign BEQ_address[31:00] = { Instr15_0_EXTENDED[29:00], 2'b00 };
		
	// extract Funct field of instruction
	assign Funct = Instr15_0[5:0];
	
	// extend 15-0 field
	assign UPPER_IMMEDIATE[31:00] = { Instr15_0[15:00], 16'd0 };
	
	assign SetLessThan [31:0] = { 31'd0, ALU_lt };
	
	assign Byte_Address [31:0] = { 24'd0, MemData[7:0] };
	  
	assign OVERFLOW_EXCEPTION = 32'd255;
	assign INVALIDCODE_EXCEPTION = 32'd254;
	assign STACK_ADDRESS = 32'd227;
	assign STACK_POINTER = 5'd29;
	assign LINK_ADDRESS = 5'd31;
	/* CONTROL SECTION BEGINS HERE */
	Control (	
			// control inputs
			.Clk(Clk), .Reset_signal(reset), .Op(Instr31_26), .Funct(Funct), 
			// alu flags
			.ALU_zero(ALU_zero), .ALU_overflow(ALU_overflow), .ALU_neg(ALU_neg), .ALU_eq(ALU_eq), .ALU_gt(ALU_gt), .ALU_lt(ALU_lt), 
			.endMult(endMult), .workMult(workMult),
			//Shift
			.REG_reset(REG_reset), .REG_funct(REG_funct),
			.ShamtOrRs(ShamtOrRs),
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
			.ALUOutSrc(ALUOutSrc),
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
			.MulReg_reset(MulReg_reset),
 			.MulReg_load(MulReg_load),
			.IR_reset(IR_reset),
			.RegReset(RegReset),
			.RegWrite(RegWrite)
						
		);			
	/* CONTROL SECTION ENDS HERE */
	
	Registrador ProgramCounter(Clk, PC_reset, PC_load, NEW_PC, PC);
	Registrador ExcProgramCounter(Clk, EPC_reset, EPC_load, ALU_result, EPC);
	
	Mux32bits_4x2 MemMux(IorD, PC, AluOut, OVERFLOW_EXCEPTION, INVALIDCODE_EXCEPTION, Address);
	
	MemWrapper MemDataSizeHandler( .MemData(MDR), .Address(Address), .value(Bout), .HalfWord(Bout_Halfword), .Byte(Bout_Byte) );
	
	Mux32bits_4x2 MemDataInMux(MemDataSize, Bout, Bout_Byte, Bout_Halfword, 32'd0, WriteDataMem);
  
	Memoria Memory(.Address(Address), .Clock(Clk), 
				   .wr(wr), .Datain(WriteDataMem), .Dataout(MemData));
	
	Instr_Reg Instruction_Register(Clk, IR_reset, IRWrite, MemData, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
	Registrador MemDataRegister(Clk, MDR_reset, MDR_load, MemData, MDR);
  
	ZeroExtension MDRExtract( .Word(MDR), .HalfWord(MDR_Halfword), .Byte(MDR_Byte) );
	
	Mux32bit_8x1 WriteDataMux(MemtoReg, AluOut, MDR, UPPER_IMMEDIATE, STACK_ADDRESS, SetLessThan, Reg_Desloc, MDR_Halfword, MDR_Byte, WriteDataReg);
	Mux5bits_4x2 WriteRegMux(RegDst, Instr20_16, Instr15_11, STACK_POINTER, LINK_ADDRESS, WriteRegister);
		
	Banco_reg Registers(Clk, RegReset, RegWrite, 
							 Instr25_21, Instr20_16,
							 WriteRegister, WriteDataReg,
							 ReadData1, ReadData2
						);
							
	Registrador A(Clk, A_reset, A_load, ReadData1, Aout);
	Registrador B(Clk, B_reset, B_load, ReadData2, Bout); 
  
	Mux32bit_2x1 LHS_Mux(ALUSrcA, PC, Aout, ALU_LHS);
	Mux32bits_4x2 RHS_Mux(ALUSrcB, Bout, 32'd4, Instr15_0_EXTENDED, BEQ_address, ALU_RHS);
  
	Mux5bit_2x1 ShiftAmountMux( ShamtOrRs, Aout, Shamt, REG_NumberOfShifts );
  
	ALS ALU (
				.oper_A(ALU_LHS), .oper_B(ALU_RHS), . ALU_sel(ALU_sel), 
				.ALU_result(ALU_result), .overflow(ALU_overflow), 
				.negative(ALU_neg), .zero(ALU_zero), .equal(ALU_eq), .greater(ALU_gt), .lesser(ALU_lt), 
				.Clk(Clk), .RegDesloc_reset(REG_reset), .RegDesloc_OP(REG_funct), 
				.NumberofShifts(REG_NumberOfShifts), .Array(ReadData2), .Shifted_Array(Reg_Desloc),
				.workMult(workMult), .mul(mul_Module), .endMult(endMult), .MultCounter(MultCounter)
			);
	
	Registrador HImul(Clk, MulReg_reset, MulReg_load, mul_Module[63:32], himul); 
	Registrador LOmul(Clk, MulReg_reset, MulReg_load, mul_Module[31:00], lomul);
	
	Mux32bits_4x2 ALUOut_MUX(ALUOutSrc, ALU_result, Reg_Desloc, himul, lomul, ALUOutIn);
	Registrador ALUOut_Reg(Clk, ALUOut_reset, ALUOut_load, ALUOutIn, AluOut);
	
	Mux32bit_8x1 PC_MUX( PCSource, ALU_result, AluOut, JMP_address, EPC, Aout, 
							32'd0, 32'd0, 32'd0,
							NEW_PC
						);

endmodule : MIPS



