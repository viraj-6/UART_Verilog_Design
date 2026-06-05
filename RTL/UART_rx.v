module UART_rx (
    input clk,
    input rst,
    input rx_in,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg parity_err 
);

    parameter IDLE    = 3'b000;
    parameter start   = 3'b001;
    parameter receive = 3'b010;
    parameter check_p = 3'b011; 
    parameter stop    = 3'b100;
    parameter done    = 3'b101;

    reg [2:0] current_state, next_state;
    reg [2:0] bit_counte;

    // Wires to connect to the separate baud module
    wire half_tick;
    wire full_tick;
    wire baud_enable; 
    
    // Calculate what the parity SHOULD be based on the 8 bits we just received.
    // We use even parity (^rx_data) to perfectly match your Tx module.
    wire expected_parity = ^rx_data; 
    
    // The baud generator runs whenever we are NOT in IDLE
    assign baud_enable = (current_state != IDLE);

    //==================================================
    // 1. INSTANTIATE THE SEPARATE BAUD GENERATOR
    //==================================================
    baud_gen_rx my_rx_timer (
        .clk(clk),
        .rst(rst),
        .enable(baud_enable),
        .half_tick(half_tick),
        .full_tick(full_tick)
    );

    //==================================================
    // 2. STATE & DATA REGISTERS (Sequential Logic)
    //==================================================
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= IDLE;
            bit_counte    <= 3'b000;
            rx_data       <= 8'b00000000;
            parity_err    <= 1'b0; // Reset error flag
        end 
        else begin
            current_state <= next_state;

            if (current_state == IDLE) begin
                bit_counte <= 3'b000;
                parity_err <= 1'b0; // Clear any old errors when waiting for new data
            end
            
            // Sample the 8 data bits
            else if (current_state == receive && full_tick == 1'b1) begin
                rx_data[bit_counte] <= rx_in;
                bit_counte <= bit_counte + 1'b1;
            end
            
            // NEW: Sample the Parity Bit
            else if (current_state == check_p && full_tick == 1'b1) begin
                // If the bit arriving on the wire doesn't match our math, it's an error!
                if (rx_in != expected_parity)
                    parity_err <= 1'b1; 
                else
                    parity_err <= 1'b0; 
            end
        end
    end

    //==================================================
    // 3. NEXT STATE LOGIC (The Map)
    //==================================================
    always @(*) begin
        next_state = current_state; 

        case(current_state)
            IDLE : begin
                if(rx_in == 1'b0)
                    next_state = start; // Start bit detected, turn on the timer!
            end

            start : begin
                // Wait for the middle of the start bit to make sure it's real
                if(half_tick == 1'b1) begin
                    if(rx_in == 1'b0) 
                        next_state = receive;
                    else
                        next_state = IDLE; // False alarm, go back to sleep
                end
            end

            receive : begin
                // Once we have all 8 bits, move to the parity checker instead of stop
                if(full_tick == 1'b1 && bit_counte == 3'b111)
                    next_state = check_p;
            end

            check_p : begin
                // Wait for the full tick to sample the parity bit, then move to stop
                if(full_tick == 1'b1)
                    next_state = stop;
            end

            stop : begin
                // Wait for the full tick to ensure the stop bit is finished
                if(full_tick == 1'b1)
                    next_state = done;
            end

            done : begin
                 next_state = IDLE; // Returning to IDLE shuts off the baud module automatically
            end
            
            default : next_state = IDLE; // Safe fallback
        endcase
    end

    //==================================================
    // 4. OUTPUT LOGIC
    //==================================================
    always @(*) begin
        rx_done = 1'b0;
        
        // Only pulse 'done' high for one cycle to tell the main system to read the data
        if (current_state == done) begin
            rx_done = 1'b1;
        end
    end

endmodule
