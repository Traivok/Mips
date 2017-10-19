module MemWrapper(input logic [31:0] MemData, input logic [31:0] Address, input logic [31:0] value, output logic [31:0] HalfWord, output logic [31:0] Byte);

assign HalfWord [31:00] = { MemData[31:16], value [15:00] };
assign Byte [31:00] = { MemData[31:08], value [07:00] };

endmodule : MemWrapper