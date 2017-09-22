module Control( 
				input logic Clk,
				input logic [5:0] Op,
				
				output logic PCWriteCond, 
				output logic PCWrite, 				// ativo em 1
				output logic IorD,
				output logic MemRead,
				output logic wr, 					// memory write/read control
				output logic MemtoReg, 
				output logic IRWrite, 				// Instruction register write controla a escrita no registrador de instruç˜oes.
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB
				output logic ALUSrcA,
				output logic RegWrite,				// write registers control
				output logic RegDst,
				output logic [7:0] StateOut
			  );
				
	/* BEGIN OF DATA SECTION */		
		logic A_load;
		logic A_reset;		
		logic B_load;
		logic B_reset;
		logic PC_load;
		logic PC_reset;		
		logic MDR_load;
		logic MDR_reset;
		logic ALUOut_load;
		logic ALUOut_reset;
		logic IR_load;
		logic IR_reset;
	/* END OF DATA SECTION */
		
	/* BEGIN OF STATE SECTION */
		logic [7:0] State;
		
		parameter init = 8'd0, funct_state = 8'h0x0, 
		rte = 8'h0x10, addi = 8'h0x8, addu = 8'h0x9, 
		andi = 8'h0xc, beq = 8'h0x4, bne = 8'h0x5, 
		lbu = 8'h0x24, lhu = 8'h0x25, lui = 8'h0xf, 
		lw = 8'h0x23, sb = 8'h0x28, sh = 8'h0x29, 
		slti = 8'h0xa, sw = 8'h0x2b, sxori = 8'h0xe, 
		j = 8'h0x2, jal = 8'h0x3, Fetch = 8'd1;
		
		initial State = Init;
	/* END OF STATE SECTION */	
		
		always_ff@(posedge Clk) begin //decodificador do op
			case (op)
				0x00:
					case(func) begin
						state <= FUNCT_STATE;
					end
				0x02:
					state <= ADD;
				0x03:
					state <= SUB;
				
			state <= state;
		end
			
			
		always_comb@(state)
			case (state)
				FETCH:  nexState <= FETCH2;
				FETCH2: nexState <= DECODE;
				ADD: 	nexState <= ADD2;
				ADD2: 	nexState <= OTH;
				FUNCT_STATE: 	nexState <= FETCH;
				
		always_comb@(posedge Clk)
		begin
			case(state)
				Init:
				begin
					
					
				end
				
				FUNCT_STATE:
				begin
				
				end
				
				Fetch:
				begin
					PCWrite = 1'b1;
					wr = 1'b1;
					PCWriteCond = 1'b0;
				end
				
		end
	
endmodule : Control;