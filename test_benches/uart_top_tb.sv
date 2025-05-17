`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 03:44:58 PM
// Design Name: UART
// Module Name: uart_top_tb
// Project Name: EN2111_Project
// Target Devices: Deo Nano
// Tool Versions: 
// Description: Two UART modules communicating: A_tx to B_rx
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top_tb;
    // parameters
    localparam  WORD_SIZE = 8,  // 8 bits per word
                PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
                PACKET_SIZE = 10, // start, word, stop
                CLK_PERIOD = 10; // 100MHz
    
    // signals in test bench            
    logic clk_A = 0, clk_B = 0, rstn_A = 0, rstn_B = 0; // start in reset mode
    logic tx_ready_A, tx_ready_B, tx_A, tx_B,
            send_valid_A = 0, send_valid_B = 0, rx_valid_A, rx_valid_B;
    logic [WORD_SIZE-1:0] data_bits_tx_A, data_bits_tx_B;     // data to transmit
    logic [WORD_SIZE-1:0] data_bits_rx_A, data_bits_rx_B;     // data recieved
    
    // clock generation
    always #(CLK_PERIOD/2) clk_A <= !clk_A;      // 10 ns period
    always #(CLK_PERIOD/2) clk_B <= !clk_B;      // 10 ns period
                 
    // Instantiate UART module
    uart_top #(
        .WORD_SIZE(WORD_SIZE),
        .PULSE_WIDTH(PULSE_WIDTH),
        .PACKET_SIZE(PACKET_SIZE)
    ) dut (
        .clk_A(clk_A), .clk_B(clk_B), .rstn_A(rstn_A), .rstn_B(rstn_B),
        .data_bits_tx_A(data_bits_tx_A), .data_bits_tx_B(data_bits_tx_B),
        .tx_ready_A(tx_ready_A), .tx_ready_B(tx_ready_B),
        .data_bits_rx_A(data_bits_rx_A), .data_bits_rx_B(data_bits_rx_B),
        .send_valid_A(send_valid_A), .send_valid_B(send_valid_B),
        .rx_valid_A(rx_valid_A), .rx_valid_B(rx_valid_B)
    );
    
    // test sequence
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        
        // reset
        #20 rstn_A = 1; #1 rstn_B = 1;      // remove reset  after 20 ns (2 clks)
        repeat(5) @(posedge clk_A) #1;

        // generate random 10 test cases (10 words) tx_A to rx_B
        repeat (10) begin
            repeat ($urandom_range(1,20)) @(posedge clk_A);
            wait (tx_ready_A);   // wait till tx is ready. ready in IDLE        
            
            data_bits_tx_A = $urandom(); // test pattern [7:0] recieve is 0,01001001,1
            @(posedge clk_A) #1 send_valid_A = 1;     // start sending
            @(posedge clk_A) #1 send_valid_A = 0;     // send signal pulse ends

//            repeat (PACKET_SIZE * PULSE_WIDTH + 10) @(posedge clk_A);
            wait(rx_valid_B); @(posedge clk_A);
                        
            $display("TX A sent     = 0x%0h", data_bits_tx_A);
            $display("RX B received = 0x%0h", data_bits_rx_B);
            end
            
        end
    
    // count uart bits - for waveform
    int bits;
    initial forever begin
        bits = 0;
        wait (!tx_A);
        for (int j = 0; j < PACKET_SIZE; j = j+1) begin
            bits += 1;
            repeat (PULSE_WIDTH) @(posedge clk_A);
            end
        end    
endmodule
