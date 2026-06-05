module UART_tx(
    input clk, 
    input rst, 
    input start_tx, 
    input [7:0] data, 
    output reg tx_out, 
    output reg tx_done
);

    // State definitions: Using names instead of binary numbers makes the flow much easier to read.
    parameter IDL    = 3'b000;
    parameter start  = 3'b001;
    parameter txing  = 3'b010;
    parameter parity = 3'b011;
    parameter stop   = 3'b100;
    
    reg [2:0] current_state, next_state;
    reg [2:0] bit_count;
    reg       parity_reg;
	 // NEW: The TX timer should only run when we are NOT in IDLE
    wire tx_baud_enable = (current_state != IDL);
    
    wire baud_tick; // The pulse that acts like a metronome for our baud rate
    
    // Quick way to calculate Even Parity by XORing all bits in the data array
    wire calc_parity = ^data;
    
    // -------------------------------------------------------------------------
    // 1. Baud Generator
    // -------------------------------------------------------------------------
    // This provides the timing ticks so we know exactly when to send the next bit.
    baud_gen_tx my_baud_clock (
        .clk(clk),
        .rst(rst),
		  .enable(tx_baud_enable),
        .baud_tick(baud_tick)
    );
    
    // -------------------------------------------------------------------------
    // 2. State Memory & Counters
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            // Reset everything to a default, safe state
            current_state <= IDL;       
            bit_count     <= 3'b000;
            parity_reg    <= 1'b0;
        end
        else begin
            current_state <= next_state;
            
            // Grab a snapshot of the parity bit right when we start. 
            // This prevents errors if the 'data' input changes mid-transmission.
            if(current_state == IDL && start_tx) begin
                parity_reg <= calc_parity;
            end
            
            if(current_state == start) begin
                bit_count <= 3'b000; // Reset the bit counter for a fresh transmission
            end
            else if(current_state == txing) begin
                // Move to the next bit ONLY when our baud metronome ticks
                if(baud_tick) begin
                    bit_count <= bit_count + 1'b1; 
                end
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // 3. Next State Routing
    // -------------------------------------------------------------------------
    // The "map" of our state machine: where do we go next?
    always @(*) begin 
        next_state = current_state; // Default: stay right where we are
        
        case(current_state)
            IDL : begin
                if(start_tx)
                    next_state = start; // Someone hit "go", start the transmission!
            end
            
            start : begin
                if(baud_tick)
                    next_state = txing; // Start bit is finished, move on to the data
            end
            
            txing : begin
                // Check if we just finished sending the 8th bit (index 7)
                if(baud_tick && bit_count == 3'b111)
                    next_state = parity;        
            end
            
            parity : begin
                if(baud_tick)
                     next_state = stop; // Parity is sent, time to wrap things up
            end
                    
            stop : begin
                if(baud_tick)
                    next_state = IDL; // We're all done! Go back to sleep until the next request.
            end
        endcase
    end
    
    // -------------------------------------------------------------------------
    // 4. Output Logic
    // -------------------------------------------------------------------------
    // What the physical pins should actually be doing during each state
    always @(*) begin 
        // Default pin states (UART lines are normally HIGH when resting)
        tx_out  = 1'b1;
        tx_done = 1'b0;
        
        case(current_state)
            IDL : begin
                tx_out  = 1'b1;
                tx_done = 1'b0;
            end
                
            start : begin 
                tx_out  = 1'b0; // Pull line LOW to tell the receiver we are starting
                tx_done = 1'b0;
            end
                
            txing : begin    
                tx_out  = data[bit_count]; // Send out the data bit by bit
                tx_done = 1'b0;
            end
            
            parity : begin
                 tx_out = parity_reg; // Send out our saved parity bit
            end
            
            stop : begin 
                tx_out  = 1'b1; // Pull line HIGH for the stop bit
                tx_done = 1'b1; // Let the rest of the system know we finished successfully!
            end
        endcase
    end
    
endmodule
