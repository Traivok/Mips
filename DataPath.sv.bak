module DataPath(
			input logic Clk, // the system clock
			
			output logic PCWriteCond_Out,		// Pc write for conditional jumps
			output logic PCWrite_Out,			// Pc Write control
			output logic IorD_Out,				// Instruction or Data	
			output logic MemRead_Out,			// Memory read control
			output logic MemWrite_Out, 			// Memory write control
			output logic MemtoReg_Out,			// Reg write control
			output logic IRWrite_Out,			// Instruction register write
			output logic [1:0] PCSource_Out,	// PC source mux
			output logic [1:0] ALUOp_Out,		// Alu Operation 
			output logic [1:0] ALUSrcB_Out,		// Alu source B mux
			output logic ALUSrcA_Out,			// Alu source A mux
			
			output logic [31:0] PC_content, 	// PC out, current instruction address
			
			output logic [7:0] ControlState_Out	// Control state
		);
		
		/* Begin of Control Section */
		logic PCWriteCond;
		logic PCWrite;
		logic IorD;
		logic MemRead;
		logic MemWrite;
		logic MemtoReg;
		logic IRWrite;
		logic [1:0] PCSource;
		logic [1:0] ALUOp;
		logic [1:0] ALU_RHS_Mux;
		logic ALU_LHS_Mux;
		/* End of Control Section */
		
		/* Begin of Register Control Section */
		logic PC_reset, PC_load;	// reset content
		logic IR_reset, IR_load;
		logic A_reset, A_load;
		logic B_reset, B_load;
		logic ALUOut_reset, ALUOut_load;
		logic MDR_reset, MDR_load;
		/* End of Register Control Section */
		
		/* Begin of Memory Control */
		logic Memory_Wr;
		assign Memory_Wr = (~MemRead) & MemWrite;		// write control, Read priority
		logic [31:0] MemData; 						      // Memory content
		logic [31:0] Mem_Write_Data;
		/* End of Memory Control */
		
		/* Begin of Registers Bank Section */
		logic RegBank_write;	// write control
		logic RegBank_reset;	// reset all registers
		logic [4:0] RegBank_ReadReg1, RegBank_ReadReg2; // what register to read
		logic [4:0] RegBank_WriteReg;
		logic [31:0] RegBank_WriteData, RegBank_ReadData1, RegBank_ReadData2;
		/* End of Registers Bank Section */
		
		/* BEGIN OF DATA SECTION */		
		logic [31:0] PC_in, PC_out; // PC next instruction / current instruction
		
		logic [5:0] Instr31_26; // mostly Op field
		logic [4:0] Instr25_21;
		logic [4:0] Instr20_16;
		logic [15:0] Instr15_0;

		logic [31:0] Aout, Bout;
		logic [31:0] ALUout_data; // alu out content
		logic [31:0] MDRout;
		
		logic [31:0] ALU_result; // ALU operation result
		logic ALU_overflow; // arithmetic overflow
		logic ALU_negSignal; // A + B < 0
		logic ALU_zero; // A + B = 0
		logic ALU_equal; // A = B
		logic ALU_greater; // A > B 
		logic ALU_lesser; // A < B	
		/* END OF DATA SECTION */
		
		
		
		logic [31:0] testVar;		
		
		// pass Clk, reset and load control, the input is the next instruction, and get the current instruction
		Registrador PC(Clk, pc_reset, pc_load, PC_in, PC_out);
		
		// currentInstruction as address, and the may write and value readed by the memory
		Memoria Memory(PC_out, Clk, Memory_Wr, Mem_Write_Data, MemData);
		
		// instruction register
		Instr_Reg Instruction_Register(Clk, RegBank_reset, RegBank_write, MemData, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
			
		Registers Banco_reg(Clk, RegBank_reset, RegBank_write, RegBank_ReadReg1, RegBank_ReadReg2,
							RegBank_WriteReg, RegBank_WriteData, RegBank_ReadData1, RegBank_ReadData2); 
		
		MemDataReg Registrador(Clk, MDR_reset, MDR_load, MDROut);
		
		// A and B registers
		Registrador A(Clk, A_reset, A_load, Aout);
		Registrador B(Clk, A_reset, A_load, Bout);
		
		ALU ula32(Aout, Bout, ALUOp, ALU_result, ALU_overflow, ALU_negSignal, ALU_zero, ALU_equal, ALU_greater, ALU_lesser);
		
		Registrador ALUout(Clk, ALUout_reset, ALUout_load, ALU_opResult, testVar);		
		
endmodule : DataPath