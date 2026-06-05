`timescale 1ns/1ps

module UART_Top_tb;

    // Inputs to the Top Module (driven as regs in the testbench)
    reg clk;
    reg rst;
    reg start_tx;
    reg [7:0] tx_data;
    
    // Outputs from the Top Module (captured as wires)
    wire tx_out;
    wire tx_done;
    wire [7:0] rx_data;
    wire rx_done;
    wire parity_err;

    // Loopback Connection: Connect the Tx output directly back into the Rx input!
    wire rx_in = tx_out; 

    // Instantiate the Top Module
    UART_Top uut (
        .clk(clk),
        .rst(rst),
        
        // RX connections
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err),
        
        // TX connections
        .start_tx(start_tx),
        .tx_data(tx_data),
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    // Clock Generation: 50 MHz clock frequency (20ns full period)
    always #10 clk = ~clk;

    initial begin
        // --- 1. System Initialization ---
        clk      = 1;
        rst      = 1;
        start_tx = 0;
        tx_data  = 8'b00000000;

        // Release Reset after a brief moment
        #100;
        rst = 0;
        #200; // Let the system settle down

        // ==================================================
        // TEST CASE 1: Send Data 8'b10100101 (0xA5)
        // Even Parity: Four '1's, so Parity bit should be '0'
        // ==================================================
        $display("[TB] Starting Test Case 1: Sending 0xA5");
        
        tx_data  = 8'b10100101; 
        start_tx = 1;           // Trigger the transmitter
        #20;                    // Hold high for exactly 1 system clock cycle
        start_tx = 0;           // Pull back down so we don't double-trigger

        // Wait until both modules finish their work
        // (This takes around 100,000 ns at 115,200 baud)
        @(posedge tx_done);
        $display("[TB] Tx is finished sending!");
        
        @(posedge rx_done);
        $display("[TB] Rx is finished receiving!");

        // Quick automatic logic check in the console
        if ((rx_data == tx_data) && (parity_err == 1'b0)) begin
            $display("[SUCCESS] Received data matches sent data! Data: %b", rx_data);
        end else begin
            $display("[ERROR] Mismatch or Parity Error! Sent: %b, Got: %b, Error Flag: %b", tx_data, rx_data, parity_err);
        end

        // Wait a bit before starting the next transmission
        #50000;

        // ==================================================
        // TEST CASE 2: Send Data 8'b01110001 (0x71)
        // Even Parity: Four '1's, so Parity bit should be '0'
        // ==================================================
        $display("[TB] Starting Test Case 2: Sending 0x71");
        
        tx_data  = 8'b01110001;
        start_tx = 1;
        #20;
        start_tx = 0;

        // Wait for flags to finish
        @(posedge tx_done);
        @(posedge rx_done);

        if ((rx_data == tx_data) && (parity_err == 1'b0)) begin
            $display("[SUCCESS] Received data matches sent data! Data: %b", rx_data);
        end else begin
            $display("[ERROR] Mismatch or Parity Error! Sent: %b, Got: %b, Error Flag: %b", tx_data, rx_data, parity_err);
        end

        #50000;
        $display("[TB] Simulation Completed Successfully.");
        $stop;
    end

endmodule
//D:/FPGA/UART Transceiver/UART_Top_tb.v

