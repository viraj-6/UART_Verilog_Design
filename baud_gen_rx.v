module baud_gen_rx(
    input clk, 
    input rst,
    input enable,       // Signal from UART to start counting
    output reg half_tick,
    output reg full_tick
);
    
    // 50MHz / 115200 = 434
    parameter FULL = 434;
    parameter HALF = 217;
    
    reg [8:0] count;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 9'd0;
            half_tick <= 1'b0;
            full_tick <= 1'b0;
        end
		  else if (enable == 1'b0) begin
				count <= 0; // Force the timer back to 0 when in IDLE
		  end
        else if (!enable) begin
            // Hold counter at zero while waiting for a start bit
            count <= 9'd0; 
            half_tick <= 1'b0;
            full_tick <= 1'b0;
        end
        else begin
            // Default ticks to 0
            half_tick <= 1'b0;
            full_tick <= 1'b0;

            if (count == FULL - 1) begin
                count <= 9'd0;
                full_tick <= 1'b1; // Trigger full tick
            end
            else begin
                count <= count + 1'b1;
                if (count == HALF - 1)
                    half_tick <= 1'b1; // Trigger half tick
            end
        end
    end
    
endmodule
