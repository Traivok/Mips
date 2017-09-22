module MUX_PC(input logic [31:0] ALUresult, // PC + 4
				input logic [31:0] ALUout, // jmp address
				input logic [31:0] instrShiftLeft, // 26 bits menos significativos do IR << 2 e concatenados com os
				// 4 bits mais significativos do PC incrementado, que � a origem quando a instru��o � um jump
				input logic [1:0] PCsource,
				input logic Clk, input logic PCwrite, 
				input logic [31:0] oldPC,
				input logic PCwriteCOND,
				input logic zeroSignal, // used to detect if the two operands of the beq are equal
				output logic [31:0] newPC);

initial newPC = oldPC;

logic sel; // seletor que diz se o pc vai ser escrito
assign sel = (PCwriteCOND && zeroSignal) || PCwrite;

enum logic {ALUplus4 = 2'b00, JMPadress = 2'b01, ShiftL = 2'b10} states; 

enum logic {write = 1'b0} select;

always_comb@(posedge Clk)
begin

	case(sel)
		
		write:
		begin
		
			case(PCSource)
	
			ALUplus4:
			begin
				newPC <= ALUresult;
			end

			JMPadress:
			begin
				newPC <= ALUout;
			end
	
			ShiftL:
			begin
				newPC <= instrShiftLeft;
			end
		
			default: newPC <= oldPC;

			endcase
			
		end
		
		default: newPC = oldPC;

	endcase

end

endmodule : MUX_PC
