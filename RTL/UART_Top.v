module UART_Top (
    input clk,
    input rst,

    // ------------------------------------
    // Receiver (RX) Interface
    // ------------------------------------
    input        rx_in,       // The physical wire bringing data IN
    output [7:0] rx_data,     // The 8-bit data we successfully received
    output       rx_done,     // Pulses HIGH for 1 clk cycle when data is ready
    output       parity_err,  // Pulses HIGH if the received data is corrupted

    // ------------------------------------
    // Transmitter (TX) Interface
    // ------------------------------------
    input        start_tx,    // Pulse HIGH to tell the TX to start sending
    input  [7:0] tx_data,     // The 8-bit data you want to send out
    output       tx_out,      // The physical wire sending data OUT
    output       tx_done      // Pulses HIGH for 1 clk cycle when finished sending
);

    // ==================================================
    // 1. Instantiate the Transmitter
    // ==================================================
    UART_tx my_transmitter (
        .clk(clk),
        .rst(rst),
        .start_tx(start_tx),
        .data(tx_data),       // Connect the top-level tx_data down to the TX module
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    // ==================================================
    // 2. Instantiate the Receiver
    // ==================================================
    UART_rx my_receiver (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err)
    );

endmodule
//D:/FPGA/UART Transceiver/UART_Top.v
