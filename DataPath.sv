module DataPath(
		input logic Clk, // the system clock
	
		/* Begin of Register control section */
		input logic pc_reset, pc_load, // PC control	
		input logic mem_write, // Memory control
		input logic instReg_reset, instReg_load, // Instruction register control
		//input logic mdr_reset, mdr_load, // MDR control
		input logic a_reset, a_load, // A register control
		input logic b_reset, b_load, // B register control
		input logic ALUout_reset, ALUout_load, // ALU control
		input logic [3:0] ALUSrcB, // a mux control for rhs of ALU 
		/* End of Register control section */
		
		input AluOut_reset, AluOut_load, // AluOut control
		
		output logic [5:0] Operation // for control	
		);
		
		/* BEGIN OF DATA SECTION */		
		logic [31:0] nextInstruction, currentInstruction; // PC in/out
		logic [31:0] testVar;
		logic [31:0] mem_DataWrite, mem_DataRead; // Memory  in/out
		logic [31:0] instruction; // the instruction code
		initial Operation = 6'h0; // start with NoOp
		logic [31:0] Aout, Bout; // the A and B content
		logic [31:0] ALUout_data; // alu out content
		logic [31:0] ALU_opResult; // ALU operation result
		logic ALU_overflow; // arithmetic overflow
		logic ALU_negSignal; // A + B < 0
		logic ALU_zero; // A + B = 0
		logic ALU_equal; // A = B
		logic ALU_greater; // A > B 
		logic ALU_lesser; // A < B
		logic [2:0] ALU_select;
		logic [31:0] ALU_rhs;
		initial ALU_rhs = 32'd0;		
		/* END OF DATA SECTION */
		
		/* BEGIN OF ENUM SECTION */
		enum logic [3:0] { // Rhs alu control
						   ALU_RHS_B = 4'b00, // content of register B
						   ALU_RHS_4 = 4'b01, // constant 4
						   ALU_RHS_SIGNEX = 4'b10, // Sign extend
						   ALU_RHS_SHLFT = 4'b11 } ALU_RHS; // shift left (2)
		/* ENd OF ENUM SECTION */
		
		// pass Clk, reset and load control, the input is the next instruction, and get the current instruction
		Registrador PC(Clk, pc_reset, pc_load, nextInstruction, currentInstruction);
		
		// currentInstruction as address, and the may write and value readed by the memory
		Memoria Memory(currentInstruction, Clk, mem_DataWrite, mem_DataRead);
		
		// instruction register
		Registrador InstructionReg(Clk, instReg_reset, instReg_load, mem_DataRead, instruction);
		
		//MemDataReg Registrador(Clk, mdr_reset, mdr_load, );
		
		// A and B registers
		Registrador A(Clk, a_reset, a_load, Aout);
		Registrador B(Clk, b_reset, b_load, Bout);
		
		/* RHS ULA MUX */
		always_comb
		begin
			case (ALUSrcB)
				ALU_RHS_B:
				begin
					ALU_rhs <= Bout;
				end
				
				ALU_RHS_4:
				begin
					ALU_rhs <= 32'd4;
				end
				
				/*
				ALU_RHS_SIGNEX:
					ALU_rhs <= ;
				end
				
				ALU_RHS_SHLFT:
					ALU_rhs <= ;
				end*/
				
				default: ALU_rhs <= 32'd0;
			endcase			
		end	
		
		ALU ula32(Aout, Bout, ALU_select, ALU_opResult, ALU_overflow, ALU_negSignal, ALU_zero, ALU_equal, ALU_greater, ALU_lesser);
		
		Registrador ALUout(Clk, ALUout_reset, ALUout_load, ALU_opResult, testVar);		
		
endmodule : DataPath