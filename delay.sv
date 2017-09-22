module delay (input integer a,
					input logic clk, 
					output logic b);

integer i;

always @(posedge clk)begin 

	for(i=0;i<=a;i++) begin
		if(i == a) begin
			b <= 1;
		end
	
	end

end


endmodule
