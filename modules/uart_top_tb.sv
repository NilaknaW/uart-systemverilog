// testing code for the uart module

module uart_top (
    input logic clk,  				// 50MHz clock from DE0-Nano
    output logic tx, 				// pin 5 of JP1
    input logic rx, 					// pin 7 of JP1
    output logic [7:0] LED			// LED7 to LED0
);

    logic [7:0] data_bits_tx = 8'b10101011;  // tx data
    logic [7:0] data_bits_rx;
    logic rx_valid;
    logic tx_ready;
	 logic send_valid;
	 logic rstn;
	 
	 assign rstn = 1'b1;

    uart #(
        .WORD_SIZE(8),
        .PULSE_WIDTH(434),
        .PACKET_SIZE(10)
    ) uart_inst (
        .clk(clk),
        .rstn(rstn),
        .send_valid(send_valid),
        .data_bits_tx(data_bits_tx),
        .data_bits_rx(data_bits_rx),
        .rx_valid(rx_valid),
        .tx_ready(tx_ready),
        .tx(tx),
        .rx(rx)
    );

    logic [7:0] data_latch;
	 
	 // send_valid signal
	 always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        send_valid <= 0;
    else if (tx_ready)
        send_valid <= 1;
    else
        send_valid <= 0;
	 end

    // Latch data when rx_valid goes high
    always_ff @(posedge clk) begin
        if (!rstn)
            data_latch <= 8'b0;
        else if (rx_valid)
            data_latch <= data_bits_rx;
    end

    assign LED = data_latch;

endmodule
