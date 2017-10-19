module MemWrapper(input logic [31:0] MemData, input logic [31:0] Address, input logic [31:0] value, output logic [31:0] HalfWord, output logic [31:0] Byte);

assign HalfWord [31:00] = { value [15:00], MemData[15:00] };
assign Byte [31:00] = { value [07:00], MemData[23:00] };

endmodule : MemWrapper