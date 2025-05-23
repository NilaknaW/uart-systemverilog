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
`timescale 1ns / 1ps

module uart_tb;
    // parameters
    localparam  WORD_SIZE = 8,  							// 8 bits per word
                PULSE_WIDTH = 4, 						// PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
                PACKET_SIZE = 10, 						// start, word, stop
                CLK_PERIOD = 10; 						// 100MHz
    
    // signals in test bench            
    logic   clk = 0,
            rstn = 0, 										// start in reset mode
            send_valid = 0,
            tx_ready,
            tx,
            rx = 1,
            rx_valid;        
				
    logic [WORD_SIZE-1:0] data_bits_tx;     			// data to transmit
    logic [WORD_SIZE-1:0] data_bits_rx;     			// data recieved
	 logic [WORD_SIZE-1:0] test_values [0:9];			// words for 10 test cases 
    
    // clock generation
    always #(CLK_PERIOD/2) clk <= !clk;      		// 10 ns period
                 
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
	 
	 // connecting tx and rx.
    always @(posedge clk) begin
		  #1 rx = tx;
		  end
            
	 
    // test sequence
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        
        // reset
        #20 rstn = 1;       								// remove reset  after 20 ns (2 clks)
        repeat(5) @(posedge clk) #1;
		  
		  // test case - sending single word
        wait (tx_ready);   								// wait till tx is ready. ready in IDLE         
  		  data_bits_tx = 8'b00100001;
        @(posedge clk) #1 send_valid = 1;     		// start sending
        @(posedge clk) #1 send_valid = 0;     		// send signal pulse ends

        #10 $display("sending %b", data_bits_tx); 	// display the sending message (debugging)
            
		 @(posedge rx_valid);								// wait until rx is valid
		 @(posedge clk);										// wait for data to be fully latched
		 #1 $display("Received: %b", data_bits_rx); 	// display the recieved message (debugging)
	  
		  
        // send test cases (10 words)
        for (int i = 0; i < 10; i = i+1) begin
		  //repeat (10) begin
		  
				repeat (5) @(posedge clk);						// add a delay
            // repeat ($urandom_range(1,20)) @(posedge clk); // random delay. worked in vivado. not supported in quartus.
				
            wait (tx_ready);   								// wait till tx is ready. ready in IDLE        
            
				data_bits_tx = test_values[i];
            // data_bits_tx = $urandom(); // test pattern [7:0] recieve is 0,01001001,1. random test cases. worked in vivado. not supported in quartus.
				
            
            @(posedge clk) #1 send_valid = 1;     		// start sending
            @(posedge clk) #1 send_valid = 0;     		// send signal pulse ends

            #10 $display("sending %b", data_bits_tx);	// display the sending message (debugging)
            
				@(posedge rx_valid);								// wait until rx is valid
				@(posedge clk);									// wait for data to be fully latched
				#1 $display("Received: %b", data_bits_rx);// display the recieved message (debugging)
				end				
        
		  end // test sequence
    
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
