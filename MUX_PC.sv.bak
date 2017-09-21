module MUX_PC(input logic [31:0] ALUresult, // PC + 4
				input logic [31:0] ALUout, // jmp address
				input logic [31:0] instrShiftLeft,
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
