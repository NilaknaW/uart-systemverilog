`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Company: ENTC, University of Moratuwa
// Engineer: N D Waarushavithana
// 
// Create Date: 05/05/2025 08:38:26 PM
// Design Name: UART 
// Module Name: uart
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

module uart #(
    parameter   
        WORD_SIZE = 8,  // 8 bits per word
        PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
        PACKET_SIZE = 10 // start, word, stop      
    )(
    input logic clk, rstn, 
                send_valid, 
                rx,
    input logic [WORD_SIZE-1:0] data_bits_tx, 
    output logic [WORD_SIZE-1:0] data_bits_rx,
    output logic rx_valid, 
                tx_ready, tx
    );
       
   // instantiate the transmitter    
    transmitter #(
            .WORD_SIZE(WORD_SIZE),
            .PULSE_WIDTH(PULSE_WIDTH),
            .PACKET_SIZE(PACKET_SIZE)
    ) UART_TX (
            .clk(clk),
            .rstn(rstn),
            .send_valid(send_valid),
            .data_bits(data_bits_tx),
            .tx_ready(tx_ready),
            .tx(tx)
            ); 
    
    // instantiate the reciever
    reciever #(
            .WORD_SIZE(WORD_SIZE),
            .PULSE_WIDTH(PULSE_WIDTH),
            .PACKET_SIZE(PACKET_SIZE)
    ) UART_RX (
            .clk(clk),
            .rstn(rstn),
            .data_bits(data_bits_rx),
            .rx(rx),
            .rx_valid(rx_valid)
            ); 


endmodule
