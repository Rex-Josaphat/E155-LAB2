// Josaphat Ngoga
// jngoga@g.hmc.edu
// 9/5/2025

// This module takes in switch inputs and clk and also handles the multiplexing determining which of the
// segment displays gets to be on. It also has the 4-bit adder that calculates the sum of the two input 
// digits and lights up the external LEDs. 

module ledControl( 
        input logic reset,
        input logic [3:0] sw1, sw2,
        output logic [1:0] onSeg, // Segment enablers, onSeg[0]: Left Display, onSeg[1]: Right Display, 
        output logic [4:0] segSum,
        output logic [3:0] sevenSegIn);

        // Internal Logic
        logic int_osc;
        logic seg_en; // Selector for which segment goes on
        logic [24:0] counter;
        logic [7:0] swDip; // Captures all available switch states from the 2 4-DIP switch blocks

        // Sum of displayed digits
        segSum = sw1 + sw2;

        ////////////// Time-multiplexing logic ///////////////
    
        // Internal high-speed oscillator
        HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc)); // 48 MHz

        // Counter
        always_ff @(posedge int_osc) begin
            if(reset == 0) begin
                counter <= 0; seg_en <= 0;
            end
            
            else if (counter == 200_000) begin // Switch every 2*10^5 cycles (2 ms)
                counter <= 0;
                seg_en <= seg_en + 1; 
            end

            else counter <= counter + 1;
        end

        //////////////// 7-segment display input and enabler logic //////////////////
        assign swDIP = {sw2, sw1}

        if (seg_en == 0) begin
            assign onSeg = 2'b10; // Turn on left segment
            assign sevenSegIn = swDIP[0]; // Choose on-board DIP switch inputs
        
        end else if (seg_en == 1) begin
            assign onSeg = 2'b01; // Turn on right segment
            assign sevenSegIn = swDIP[1]; // Choose Breadboard DIP switch inputs

        end else begin
            assign onSeg = 2'b00; // Turn off all segments
            assign sevenSegIn = 4'b0000; // Default input to zero                        
        end

endmodule