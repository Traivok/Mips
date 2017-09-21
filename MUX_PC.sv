module MUX_PC(input logic [31:0] ALUresult, // PC + 4
				input logic [31:0] ALUout, // jmp address
				input logic [31:0] instrShiftLeft, // 26 bits menos significativos do IR << 2 e concatenados com os
				// 4 bits mais significativos do PC incrementado, que é a origem quando a instrução é um jump
				input logic [1:0] PCsource,
				input logic Clk, input logic PCwrite, 
				input logic PCwriteCOND,
				input logic zeroSignal, // used to detect if the two operands of the beq are equal
				output logic [31:0] newPC);

reg [31:0] PC_aux;

always_ff@(posedge Clk)
begin
	if(PCsource == 2'b00)
		PC_aux <= ALUresult;
	else if (PCsource == 2'b01)
		PC_aux <= ALUout;
	else if (PCsource == 2'b10)
		PC_aux <= instrShiftLeft;
	else
		PC_aux <= 0;
	
	if ((PCwriteCOND && zeroSignal) || PCwrite)
		newPC <= PC_aux;
end

endmodule : MUX_PC
