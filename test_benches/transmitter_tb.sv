`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2025 10:49:10 PM
// Design Name: 
// Module Name: transmitter_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transmitter_tb;
//    timeunit 1ns; timeprecision 1ps;
    
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
            tx;          
    logic [WORD_SIZE-1:0] data_bits;      // data to/before transmit
//    logic [WORD_SIZE-1:0] expected_bits;    // latch for reference
//    logic [WORD_SIZE-1:0] tx_bits;      // data after transmit
                            
    // instantiate the transmitter    
    transmitter #(  .WORD_SIZE(WORD_SIZE),
                    .PULSE_WIDTH(PULSE_WIDTH),
                    .PACKET_SIZE(PACKET_SIZE))
                 dut (
                    .clk(clk),
                    .rstn(rstn),
                    .send_valid(send_valid),
                    .data_bits(data_bits),
                    .tx_ready(tx_ready),
                    .tx(tx)
                 );                  
    
    // clock generation
    always #(CLK_PERIOD/2) clk <= !clk;      // 5 = CLK_PERIOD/2
    
    // test sequence
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        
        // reset
        #20 rstn = 1;       // remove reset  after 20 ns (2 clks)
        repeat(5) @(posedge clk) #1;

        // generate random 10 test cases (10 words)
        repeat (10) begin
            repeat ($urandom_range(1,20)) @(posedge clk);
//            repeat(20) @(posedge clk);
            wait (tx_ready == 1);   // wait till tx is ready. ready in IDLE        
            
            data_bits = $urandom(); // test pattern [7:0] recieve is 0,01001001,1
//            data_bits = 8'b01011001;  // 0, 1001 1010, 1
//            expected_bits = data_bits;
            
            @(posedge clk) #1 send_valid = 1;     // start sending
            @(posedge clk) #1 send_valid = 0;     // send signal pulse ends
//            #(PULSE_WIDTH*PACKET_SIZE*10+100); // wait for the transmission to complete

            #10 $display("sending 0,%b,1", data_bits);
            end
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
