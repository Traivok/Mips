module ULA_MUX(input logic [3:0] ALUSrcB, // a mux control for rhs of ALU 
				input logic [1:0] ALUSrcA, // mux control for lhs of ALU
				input logic [1:0] ALUOp); // alu operation control);
				
logic [31:0] ALU_rhs;
initial ALU_rhs = 32'd0;	
logic [2:0] ALU_select;
logic [31:0] Aout, Bout; // the A and B content

/* BEGIN OF ENUM SECTION */
enum logic [3:0] { // Rhs alu control
				   ALU_RHS_B = 4'b00, // content of register B
				   ALU_RHS_4 = 4'b01, // constant 4
				   ALU_RHS_SIGNEX = 4'b10, // Sign extend
				   ALU_RHS_SHLFT = 4'b11 } ALU_RHS_SEL; // shift left (2)
/* ENd OF ENUM SECTION */
		
/* RHS ULA MUX */
always_comb
begin
	case (ALUSrcB)
		ALU_RHS_B:
		begin
			ALU_rhs <= Bout;
		end
			
		ALU_RHS_4:
		begin
			ALU_rhs <= 32'd4;
		end
			
		/*
		ALU_RHS_SIGNEX:
			ALU_rhs <= ;
		end
			
		ALU_RHS_SHLFT:
			ALU_rhs <= ;
		end*/
			
		default: ALU_rhs <= 32'd0;
	endcase			
end

endmodule : ULA_MUX