# UART Verilog Design

A robust, fully parameterized UART (Universal Asynchronous Receiver-Transmitter) controller implemented in Verilog HDL. This core features independent transmitter (TX) and receiver (RX) modules coupled with dedicated baud rate generators, making it ideal for FPGA-based embedded systems and serial communication interfaces.

---

## 🚀 Features
* **Parameterized Design:** Easily configure system clock frequency and target baud rates without altering the underlying logic.
* **Modular Architecture:** Hardware split cleanly into dedicated transmitting, receiving, and clock division blocks.
* **Standard Packet Format:** Configured for standard 8-bit data, 1 start bit, 1 stop bit, and no parity (8N1).
* **Oversampling Receiver:** The RX module uses an oversampling clock to ensure accurate data sampling at the center of the bit period, minimizing noise and synchronization errors.

---

## 📁 Repository Structure
The project is organized into clean directories separating the design logic from verification files:

```text
UART_Verilog_Design/
├── rtl/                      # Hardware Description (Design Files)
│   ├── UART_Top.v            # Top-level wrapper module
│   ├── UART_tx.v             # Transmitter module
│   ├── UART_rx.v             # Receiver module
│   ├── baud_gen_tx.v         # Baud rate generator for TX
│   └── baud_gen_rx.v         # Baud rate generator for RX
├── sim/                      # Verification Suite (Testbenches)
│   ├── UART_Top_tb.v         # Top-level system testbench
│   ├── UART_tx_tb.v          # Transmitter testbench
│   └── UART_rx_tb.v          # Receiver testbench
└── README.md                 # Project documentation
