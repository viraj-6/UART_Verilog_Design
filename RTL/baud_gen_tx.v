module baud_gen(clk, rst, baud_tick);

	input clk, rst;
	output reg baud_tick;
	
	parameter div_value = 434;//50M/115200 = 434;
	
	reg [8:0] count;
	
	always @(posedge clk or posedge rst) begin
	
		if(rst) begin
			count <= 9'd0;
			baud_tick <= 1'b0;
		end
		
		else begin
			if(count == div_value-1) begin
				count <= 9'd0;
				baud_tick <= 1'b1;
			end
			
			else begin
				count <= count + 1'b1;
				baud_tick <= 1'b0;
			end
		end
	end
endmodule	
	
