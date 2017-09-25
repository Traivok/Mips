module SignExtend(input logic [15:0] in_vector, output logic [31:0] out_vector);
	assign out_vector = {{16{in_vector[15]}}, {in_vector[15:0]}};
endmodule