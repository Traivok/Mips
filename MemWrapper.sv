module MemWrapper(input logic [31:0] MemData, input logic [31:0] Address, input logic [31:0] value, output logic [31:0] HalfWord, output logic [31:0] Byte);

logic [07:00] byte_value;
logic [15:00] hw_value;

assign byte_value = value [07:00];
assign hw_value= value [15:00];

assign HalfWord [31:00] = { hw_value [15:00], MemData[15:00] };
assign Byte [31:00] = { byte_value [07:00], MemData[23:00] };

/*
//Halfword
always_comb
begin
	case (Address[1:0])
		2'b00: HalfWord [31:0] <= { MemData [31:16] , hw_value [15:0] };
		2'b10: HalfWord [31:0] <= { hw_value [15:0], MemData [15:0] };
		default: HalfWord [31:0] <= { MemData [31:16] , hw_value [15:0] };
	endcase
end

//byte
always_comb
begin
	case (Address[1:0])
		2'b00: Byte [31:0] <= { MemData[31:8], byte_value [7:0] };
		2'b01: Byte [31:0] <= { MemData[31:16], byte_value [7:0], MemData [7:0] };
		2'b10: Byte [31:0] <= { MemData[31:24], byte_value [7:0], MemData[15:0] };
		2'b11: Byte [31:0] <= { byte_value [7:0], MemData [23:0] };
		default: Byte [31:0] <= { MemData[31:8], byte_value [7:0] };
	endcase
end */

endmodule : MemWrapper