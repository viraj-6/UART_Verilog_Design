`timescale 1ns/1ps

module UART_tx_tb;

    reg clk;
    reg rst;
    reg start_tx;
    reg [7:0] data;

    wire tx_out;
    wire tx_done;

    // DUT Instantiation
    UART_tx uut (
        .clk(clk),
        .rst(rst),
        .start_tx(start_tx),
        .data(data),
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    // Clock Generation: 50 MHz Clock -> 20ns period (Toggle every 10ns)
    always #10 clk = ~clk;

    initial
    begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start_tx = 0;
        data = 8'b00000000;

        // Reset
        #100;
        rst = 0;

        // Send First Data
        #20;
        data = 8'b01101001;
        start_tx = 1;

        #20;
        start_tx = 0; // De-assert start_tx after one clock cycle

        // Wait for transmission to complete
        // 10 bits (Start + 8 Data + Stop) * 434 cycles/bit * 20ns/cycle = 86,800 ns
        #90000; 

        // Send Second Data
        data = 8'b11000010;
        start_tx = 1;

        #20;
        start_tx = 0;

        // Wait for second transmission to complete
        #90000;

        $stop;
    end

endmodule
