//////////////////////////////////////////////////////////////////////////////////
// Company: Company: ENTC, University of Moratuwa
// Engineer: N D Waarushavithana
// 
// Create Date: 05/06/2025 12:21:25 PM
// Design Name: UART 
// Module Name: reciever_tb
// Project Name: EN2111_Project
// Target Devices: DEO Nano
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
module reciever_tb;
    //parameters
    localparam  WORD_SIZE = 8,  // 8 bits per word
                PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
                PACKET_SIZE = 10, // start, word, stop
                CLK_PERIOD = 10; // 100MHz
    
    // signals
    logic   clk = 0,
            rstn = 0, // start in reset
            rx = 1,
            rx_valid;
    logic [WORD_SIZE-1:0] data_bits;
    
    // test bench data and packet simul
    logic [WORD_SIZE-1:0] sample_data;
    logic [WORD_SIZE-1+2:0] sample_packet;
	 logic [WORD_SIZE-1:0] test_values [0:9];			// words for 10 test cases

    
    // instantiate the reciever
    reciever #(  .WORD_SIZE(WORD_SIZE),
                 .PULSE_WIDTH(PULSE_WIDTH),
                 .PACKET_SIZE(PACKET_SIZE))
              dut (
                 .clk(clk),
                 .rstn(rstn),
                 .data_bits(data_bits),
                 .rx(rx),
                 .rx_valid(rx_valid)
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
        // generate random 10 test cases (10 words)
        // repeat (10) begin
            // generate sample data stream
            // sample_data = $urandom(); // test pattern [7:0] recieve is 0,01001001,1
				sample_data = test_values[i];
            sample_packet = {1'b1, sample_data, 1'b0}; // packet format
            
            
            //  send these to the reciever
            repeat ($urandom_range(1,20)) @(posedge clk);
            for (int i = 0; i < WORD_SIZE+2; i = i+1)
                repeat (PULSE_WIDTH) @(posedge clk) #1 rx <= sample_packet[i];      // latch bit from the packet
            
            // for debugging
            #10 $display("should recieve %b", sample_data);
            
            // add some delay
            repeat ($urandom_range(1,50)) @(posedge clk);            end
        end

    // count uart bits - for waveform
    int bits;
    initial forever begin
        bits = 0;
        wait (!rx);
        for (int j = 0; j < PACKET_SIZE; j = j+1) begin
            bits += 1;
            repeat (PULSE_WIDTH) @(posedge clk);
            end
        end    

endmodule
