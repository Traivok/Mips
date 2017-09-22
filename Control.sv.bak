module Control( 
				
				input logic Clk,
				input logic [5:0] Op,
				
				output logic PCWriteCond, 
				output logic PCWrite, 
				output logic IorD,
				output logic MemRead,
				output logic MemWrite,
				output logic MemtoReg, 
				output logic IRWrite, 
				output logic [1:0] PCSource,
				output logic [1:0] ALUOp,
				output logic [1:0] ALUSrcB
				output logic ALUSrcA,
				output logic RegWrite,
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
		enum { Init, Fetch_Pre_Memory, Memory_Delay1, Memory_Delay2, Fetch_Pos_Memory } PossibleStates;		
		initial State = Init;
	/* END OF STATE SECTION */
		
		always_ff@(posedge Clk)
		begin
			case (State)
				Init:
				begin
					StateOut <= State;
					State <= Fetch_Pre_Memory;
				end
				
				Fetch_Pre_Memory:
				begin
					StateOut <= State;
					State <= Memory_Delay1;
				end
				
				Memory_Delay1:
				begin
					StateOut <= State;
					State <= Memory_Delay2;
				end
				
				Memory_Delay2:
				begin
					StateOut <= State;
					State <= Fetch_Pos_Memory;
				end
								
				Fetch_Pos_Memory:
				begin
					StateOut <= State;
					State <= Fetch_Pre_Memory;
				end
				
			endcase	
		end		
		
		
		always_comb
		begin
			case (State)
				Init:
				begin
					StateOut <= State;
					State <= Fetch_Pre_Memory;
				end
				
				Fetch_Pre_Memory:
				begin
					StateOut <= State;
					State <= Memory_Delay1;
				end
				
				Memory_Delay1:
				begin
					StateOut <= State;
					State <= Memory_Delay2;
				end
				
				Memory_Delay2:
				begin
					StateOut <= State;
					State <= Fetch_Pos_Memory;
				end
								
				Fetch_Pos_Memory:
				begin
					StateOut <= State;
					State <= Fetch_Pre_Memory;
				end	
		end
	
endmodule : Control;