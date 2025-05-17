`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ENTC, University of Moratuwa
// Engineer: N D Waarushavithana
// 
// Create Date: 05/05/2025 08:38:07 PM
// Design Name: UART
// Module Name: reciever
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


module reciever #(
    parameter   WORD_SIZE = 8,  // 8 bits per word
                PULSE_WIDTH = 4, // PULSE_WIDTH = CLOCK_FREQ/BAUD, CLOCK_FREQ = 100000000, BAUD = 115200, CLK_PERIOD = 10
                PACKET_SIZE = 10 // start, word, stop      
    )(
    input logic clk, rstn, rx,
    output logic rx_valid,
    output logic [WORD_SIZE-1:0]data_bits
    );
    
    typedef enum logic [2:0] {IDLE, START, DATA, STOP} statetype;   // define state data type
    statetype state;                                    // create state variable
    
    localparam PULSE_WIDTH_BITS = $clog2(PULSE_WIDTH);  // for clock count
    localparam WORD_SIZE_BITS = $clog2(WORD_SIZE);      // for bit count in word
    
    // counters for pulse and word
    logic [PULSE_WIDTH_BITS-1:0] clk_cnt;
    logic [WORD_SIZE_BITS-1:0] data_cnt;
    
    // reciever is ready to recieve in IDLE state
    assign rx_valid = (state==IDLE);
    
    // state machine
    always_ff @(posedge clk or negedge rstn) begin
        
        if (!rstn) begin
            state <= IDLE;
            data_bits <= '0;
            data_cnt <= 0;
            clk_cnt <= 0;
            end
        
        else case (state)
            IDLE: begin
                if (rx==0) state <= START;
                end
                
            START: begin
                if (clk_cnt == PULSE_WIDTH/2-1) begin
                    state <= DATA;  // halfway through start bit, switch to data state
                    clk_cnt <= 0;   // reset clock for data
                    end
                else clk_cnt += 1;  // if not increase clock count                
                end
            
            DATA: begin
                if (clk_cnt == PULSE_WIDTH-1) begin
                    clk_cnt <= 0;       // reset the pulse count clock
                    data_bits[data_cnt] <= rx;    // append the recieved bit rx
                    
                    if (data_cnt == WORD_SIZE-1) begin
                        data_cnt <= 0;      // reset data bit count for word
                        state <= STOP;      // go to STOP state
                        end
                    else data_cnt += 1;     // if word isnt finised, sount data bits
                    
                    end
                else clk_cnt += 1;  // if not increase pulse clock count
                end
            
            STOP: begin
                if (clk_cnt == PULSE_WIDTH-1) begin
                    state <= IDLE;          // go to IDLE state after this
                    clk_cnt <= 0;           // reset pulse clock
                    end
                else clk_cnt += 1;  // if not increase pulse clock count
                
                end
            endcase
        end
    
endmodule
