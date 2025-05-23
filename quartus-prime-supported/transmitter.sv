
//////////////////////////////////////////////////////////////////////////////////
// Company: ENTC, University of Moratuwa
// Engineer: N D Warushavithana
// 
// Create Date: 05/05/2025 08:36:57 PM
// Design Name: UART
// Module Name: transmitter
// Project Name: EN2111_Project
// Target Devices: DEO Nano
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - File Created
// Additional Comments: 100 MHz clock (10nS period) 115200 baudrate
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module transmitter #(
    parameter 
    WORD_SIZE = 8,  		// 8 bits per word
    PULSE_WIDTH = 4, 	// PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
    PACKET_SIZE = 10 	// start, word, stop      
    )
    (
    input logic clk, rstn, send_valid,
    input logic [WORD_SIZE-1:0]data_bits, 							// input data bit for a word
    output logic tx_ready, tx
    );
    
    typedef enum logic [1:0] {IDLE, SEND} statetype;    			// data type for states
    statetype state;                                    			// state variable
    
    localparam PACKET_WIDTH_BITS = $clog2(PACKET_SIZE); 			// for data count
    localparam PULSE_WIDTH_BITS = $clog2(PULSE_WIDTH); 			// for clock count
    
    // initialize data packet to transmit
    logic [PACKET_SIZE-1:0] data_packet;
    logic [PACKET_SIZE-1:0] send_packet;
    
    // assign start bit and stop bit to data packet
    assign send_packet = {1'b1, data_bits, 1'b0}; 					//stop bit = 1, data, start bit = 0
    
    // initiate a tx register to update the bit to send
    logic tx_reg;
    
    // assign output bit
    assign tx = tx_reg;
    
    // counters for packet length in pulses and pulse length in clocks
    logic [PACKET_WIDTH_BITS-1:0] data_cnt;
    logic [PULSE_WIDTH_BITS-1:0] clk_cnt;
    
    // transmitter is ready to transmit in IDLE state
    assign tx_ready = (state==IDLE);

    // state machine
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            data_packet <= '1;
            data_cnt <= 0;
            clk_cnt <= 0;
				tx_reg <= 1'b1; 												// UART line is high when idle
            end
        else case (state)
            IDLE: if (send_valid) begin
                state <= SEND;                 						// if send is valid move to send state
                data_packet <= send_packet;    						// copy the packet to data  
					 data_cnt <= 0;											// reset counter
					 tx_reg <= send_packet[0];								// set the first bit immediately
					 end
            
            SEND: begin
                if (clk_cnt == PULSE_WIDTH-1) begin
                    clk_cnt <= 0;                               // reset the clock count
                    
                    if (data_cnt == PACKET_SIZE-1) begin        // if all data in packet is sent, finish and IDLE
                        data_packet <= '1;
                        data_cnt <= 0;
                        state <= IDLE;
								tx_reg <= 1'b1;                         // Set line high when returning to idle
                        end
                    else begin                                  // if not finished with data yet, send them
                        data_cnt <= data_cnt + 1;               // count the bits
                        data_packet <= (data_packet >> 1);      // shift the data register
                        tx_reg <= data_packet[1];					 // update the sending bit to the next bit
								end
                    end 
                else clk_cnt <= clk_cnt + 1;                    // if pulse is not complete count the clocks
                end
            endcase
    end
    
endmodule
