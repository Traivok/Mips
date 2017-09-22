module DataPath(
			input logic Clk, // the system clock
			
			output logic PCWriteCond_Out,		// Pc write for conditional jumps
			output logic PCWrite_Out,			// Pc Write control
			output logic IorD_Out,				// Instruction or Data	
			output logic MemRead_Out,			// Memory read control
			output logic MemtoReg_Out,			// Memory write control
			output logic IRWrite_Out,			// Instruction register write
			output logic [1:0] PCSource_Out,	// PC source mux
			output logic [1:0] ALUOp_Out,		// Alu Operation 
			output logic [1:0] ALUSrcB_Out,		// Alu source B mux
			output logic ALUSrcA_Out,			// Alu source A mux
			
			output logic [7:0] ControlState_Out	
		);
		
		/* Control Data */
		logic PCWriteCond;
		logic PCWrite;
		logic IorD;
		logic MemRead;
		logic MemtoReg;
		logic IRWrite;
		logic [1:0] PCSource;
		logic [1:0] ALUOp;
		logic [1:0] ALU_RHS_Mux;
		logic ALU_LHS_Mux;
		/* Control Data */		
		
		/* BEGIN OF DATA SECTION */		
		logic [31:0] nextInstruction, currentInstruction; // PC in/out
		logic [31:0] mem_DataWrite, mem_DataRead; // Memory  in/out
		logic [31:0] instruction; // the instruction code
		logic [5:0] Operation;
		initial Operation = 6'h0; // start with NoOp
		logic [31:0] ALUout_data; // alu out content
		logic [31:0] ALU_opResult; // ALU operation result
		logic ALU_overflow; // arithmetic overflow
		logic ALU_negSignal; // A + B < 0
		logic ALU_zero; // A + B = 0
		logic ALU_equal; // A = B
		logic ALU_greater; // A > B 
		logic ALU_lesser; // A < B	
		/* END OF DATA SECTION */
		
		/*
		// pass Clk, reset and load control, the input is the next instruction, and get the current instruction
		Registrador PC(Clk, pc_reset, pc_load, nextInstruction, currentInstruction);
		
		// currentInstruction as address, and the may write and value readed by the memory
		Memoria Memory(currentInstruction, Clk, MemWrite,mem_DataWrite, mem_DataRead);
		
		// instruction register
		Registrador InstructionReg(Clk, instReg_reset, instReg_load, mem_DataRead, instruction);
		
		//MemDataReg Registrador(Clk, mdr_reset, mdr_load, );
		
		// A and B registers
		Registrador A(Clk, a_reset, a_load, Aout);
		Registrador B(Clk, b_reset, b_load, Bout);
		
		ALU ula32(Aout, Bout, ALU_select, ALU_opResult, ALU_overflow, ALU_negSignal, ALU_zero, ALU_equal, ALU_greater, ALU_lesser);
		
		Registrador ALUout(Clk, ALUout_reset, ALUout_load, ALU_opResult, testVar);		
		*/
		
endmodule : DataPath