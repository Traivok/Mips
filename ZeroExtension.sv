module ZeroExtension ( input logic [31:0] Word, output logic [31:0] HalfWord, output logic [31:0] Byte); // Get the least significant bits of an word
	assign HalfWord = { 16'b0, {Word[15:0]} };
	assign Byte = { 24'b0, {Word[7:0]} };
endmodule : ZeroExtension