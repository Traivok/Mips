module Control( input logic [5:0] Op,
				output logic PCWriteCond, 
				output logic PCWrite, 
				output logic IorD,
				output logic MemRead,
				output logic MemWrite,
				output logic MemtoReg, 
				output logic IRWrite, 
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB
				output logic ALUSrcA,
				output logic RegWrite,
				output logic RegDst,
				output logic [7:0] StateOut);
				
endmodule : Control;