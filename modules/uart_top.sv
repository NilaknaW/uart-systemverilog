`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ENTC, University of Moratuwa
// Engineer: N D Waarushavithana
// 
// Create Date: 05/06/2025 02:22:42 PM
// Design Name: UART
// Module Name: uart_top
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


module uart_top #(
    parameter   
        WORD_SIZE = 8,  // 8 bits per word
        PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
        PACKET_SIZE = 10 // start, word, stop      
    )(
    input logic clk_A, clk_B, rstn_A, rstn_B,
    input logic [WORD_SIZE-1:0] data_bits_tx_A, data_bits_tx_B,
    input logic send_valid_A, send_valid_B, // rx_A, rx_B,
    output logic tx_ready_A, tx_ready_B, tx_A, tx_B, rx_valid_A, rx_valid_B,
    output logic [WORD_SIZE-1:0] data_bits_rx_A, data_bits_rx_B
    );
    
    // logic tx_A, tx_B, rx_valid_A, rx_valid_B;
    logic rx_A, rx_B;
    
    uart #(.WORD_SIZE(WORD_SIZE),
           .PULSE_WIDTH(PULSE_WIDTH),
           .PACKET_SIZE(PACKET_SIZE)
           ) 
           UART_A (
            .clk(clk_A), .rstn(rstn_A),
            .send_valid(send_valid_A), .data_bits_tx(data_bits_tx_A),
            .tx_ready(tx_ready_A), .tx(tx_A),
            .rx(rx_A), .data_bits_rx(data_bits_rx_A), .rx_valid(rx_valid_A)
        );
        
    uart #(.WORD_SIZE(WORD_SIZE),
           .PULSE_WIDTH(PULSE_WIDTH),
           .PACKET_SIZE(PACKET_SIZE)
           ) 
           UART_B (
            .clk(clk_B), .rstn(rstn_B),
            .send_valid(send_valid_B), .data_bits_tx(data_bits_tx_B),
            .tx_ready(tx_ready_B), .tx(tx_B),
            .rx(rx_B), .data_bits_rx(data_bits_rx_B), .rx_valid(rx_valid_B)
        );
    
    assign rx_A = tx_B;
    assign rx_B = tx_A;
    
    
endmodule
