`timescale 1ns/1ps

module UART_rx_tb;

    reg clk, rst, rx_in;
    wire [7:0] rx_data;
    wire rx_done;
    wire parity_err; 

    // Time duration for 1 single bit at 115,200 baud (8,680 ns)
    parameter BIT_TIME = 8680;

    UART_rx dut(
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err) 
    );

    // Clock generation: 50 MHz clock frequency (20ns period)
    always #10 clk = ~clk;

    initial begin

        // Initial values
        clk   = 1;
        rst   = 1;
        rx_in = 1;   // UART idle line = HIGH

        // Reset
        #100;
        rst = 0;
        #100; // Let it settle

        // ==================================================
        // Frame 1: Data = 8'b01101001 (0x69)
        // Even Parity calculation: Four '1's, so parity bit is '0'
        // ==================================================
        
        // START BIT
        rx_in = 0;
        #(BIT_TIME);

        // DATA BITS (LSB first)
        rx_in = 1; #(BIT_TIME); // bit0
        rx_in = 0; #(BIT_TIME); // bit1
        rx_in = 0; #(BIT_TIME); // bit2
        rx_in = 1; #(BIT_TIME); // bit3
        rx_in = 0; #(BIT_TIME); // bit4
        rx_in = 1; #(BIT_TIME); // bit5
        rx_in = 1; #(BIT_TIME); // bit6
        rx_in = 0; #(BIT_TIME); // bit7

        rx_in = 0; // Correct even parity for this byte
        #(BIT_TIME);

        // STOP BIT
        rx_in = 1;
        #(BIT_TIME);

        // Wait between frames
        #50000;
         
        // ==================================================
        // Frame 2: Data = 8'b10010110 (0x96)
        // Even Parity calculation: Four '1's, so parity bit is '0'
        // ==================================================
        
        // START BIT
        rx_in = 0;
        #(BIT_TIME);

        // DATA BITS
        rx_in = 0; #(BIT_TIME); // bit0
        rx_in = 1; #(BIT_TIME); // bit1
        rx_in = 1; #(BIT_TIME); // bit2
        rx_in = 0; #(BIT_TIME); // bit3
        rx_in = 1; #(BIT_TIME); // bit4
        rx_in = 0; #(BIT_TIME); // bit5
        rx_in = 0; #(BIT_TIME); // bit6
        rx_in = 1; #(BIT_TIME); // bit7

        rx_in = 0; // Correct even parity for this byte
        #(BIT_TIME);

        // STOP BIT
        rx_in = 1;
        #(BIT_TIME);

        #50000;

        // ==================================================
        // Frame 3: INTENTIONAL ERROR TEST
        // Data = 8'b11110000 (0xF0)
        // Even Parity should be '0', but we will send '1' to trigger the error!
        // ==================================================
        
        // START BIT
        rx_in = 0;
        #(BIT_TIME);

        // DATA BITS
        rx_in = 0; #(BIT_TIME); // bit0
        rx_in = 0; #(BIT_TIME); // bit1
        rx_in = 0; #(BIT_TIME); // bit2
        rx_in = 0; #(BIT_TIME); // bit3
        rx_in = 1; #(BIT_TIME); // bit4
        rx_in = 1; #(BIT_TIME); // bit5
        rx_in = 1; #(BIT_TIME); // bit6
        rx_in = 1; #(BIT_TIME); // bit7

        rx_in = 1; // Sending 1, even though it should be 0
        #(BIT_TIME);

        // STOP BIT
        rx_in = 1;
        #(BIT_TIME);

        // Final Wait before ending simulation
        #50000;

        $stop;

    end

    // Monitor Output: Updated to print the parity error status too
    initial begin
        $monitor("TIME=%0t RX_IN=%b RX_DATA=%b RX_DONE=%b PARITY_ERR=%b",
                  $time, rx_in, rx_data, rx_done, parity_err);
    end

endmodule
