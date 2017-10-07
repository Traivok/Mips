module Extract_LSB ( input logic [31:0] Word, output logic [31:0] HalfWord, output logic [31:0] Byte); // Get the least significant bits of an word
	assign HalfWord = { {16{Word[15]}}, {Word[15:0]} };
	assign Byte = { {24{Word[7]}}, {Word[7:0]} };
endmodule : Extract_LSB