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

`timescale 1ns / 1ps
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
    logic [WORD_SIZE-1:0] data_bits;       			// data to/before transmit
	 logic [WORD_SIZE-1:0] test_values [0:9];			// words for 10 test cases
                            
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
	 
	 // generate test cases
    initial begin
        test_values[0] = 8'h55;
        test_values[1] = 8'hA3;
        test_values[2] = 8'h7E;
        test_values[3] = 8'h00;
        test_values[4] = 8'hFF;
        test_values[5] = 8'hC3;
        test_values[6] = 8'h3C;
        test_values[7] = 8'h5A;
        test_values[8] = 8'h81;
        test_values[9] = 8'h1E;
    end
    
    // test sequence
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        
        // reset
        #20 rstn = 1;       // remove reset  after 20 ns (2 clks)
        repeat(5) @(posedge clk) #1;
		  
		  
		  // send test cases (10 words)
        for (int i = 0; i < 10; i = i+1) begin
        // // generate random 10 test cases (10 words)
        // repeat (10) begin
		  
            //repeat ($urandom_range(1,20)) @(posedge clk);
				repeat(10) @(posedge clk);
				
            wait (tx_ready == 1);   // wait till tx is ready. ready in IDLE        
            
            // data_bits = $urandom(); // test pattern [7:0] recieve is 0,01001001,1
				data_bits = test_values[i];
            
            @(posedge clk) #1 send_valid = 1;     // start sending
            @(posedge clk) #1 send_valid = 0;     // send signal pulse ends

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
