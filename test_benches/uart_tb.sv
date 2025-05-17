`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 02:55:56 PM
// Design Name: UART
// Module Name: uart_tb
// Project Name: EN2111_Project
// Target Devices: Deo Nano
// Tool Versions: 
// Description: UART transmitter to reciever
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tb;
    // parameters
    localparam  WORD_SIZE = 8,  // 8 bits per word
                PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
                PACKET_SIZE = 10, // start, word, stop
                CLK_PERIOD = 10; // 100MHz
    
    // signals in test bench            
    logic   clk = 0,
            rstn = 0, // start in reset mode
            send_valid = 0,
            tx_ready,
            tx,
            rx = 1,
            rx_valid;          
    logic [WORD_SIZE-1:0] data_bits_tx;     // data to transmit
    logic [WORD_SIZE-1:0] data_bits_rx;     // data recieved
    
    // clock generation
    always #(CLK_PERIOD/2) clk <= !clk;      // 10 ns period
                 
    // Instantiate UART module
    uart #(
        .WORD_SIZE(WORD_SIZE),
        .PULSE_WIDTH(PULSE_WIDTH),
        .PACKET_SIZE(PACKET_SIZE)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .send_valid(send_valid),
        .rx(rx),
        .data_bits_tx(data_bits_tx),
        .data_bits_rx(data_bits_rx),
        .rx_valid(rx_valid),
        .tx_ready(tx_ready),
        .tx(tx)
    );
    
    // test sequence
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        
        // reset
        #20 rstn = 1;       // remove reset  after 20 ns (2 clks)
        repeat(5) @(posedge clk) #1;

        // generate random 10 test cases (10 words)
        repeat (10) begin
            repeat ($urandom_range(1,20)) @(posedge clk);
            wait (tx_ready);   // wait till tx is ready. ready in IDLE        
            
            data_bits_tx = $urandom(); // test pattern [7:0] recieve is 0,01001001,1
            
            @(posedge clk) #1 send_valid = 1;     // start sending
            @(posedge clk) #1 send_valid = 0;     // send signal pulse ends

            #10 $display("sending %b", data_bits_tx);
            
            // connecting tx and rx.
            fork
            forever begin
                #1;
                rx = tx;
            end
            join_none
            
            end
            
            // wait till transmission is fully done
            repeat (PACKET_SIZE * PULSE_WIDTH + 10) @(posedge clk);
        
            if (rx_valid) $display("Received: %h", data_bits_rx);
        end
    
    // count uart bits - for waveform
    int bits;
    initial forever begin
        bits = 0;
        wait (!tx);
        for (int j = 0; j < PACKET_SIZE; j = j+1) begin
            bits += 1;
            repeat (PULSE_WIDTH) @(posedge clk);
            end
        end    
endmodule
