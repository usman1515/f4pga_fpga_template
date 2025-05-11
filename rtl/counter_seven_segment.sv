`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Design Name:
// Module Name: counter_seven_segment_display
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


module counter_seven_segment_display (
    input logic     clk,                    // system clk (100MHz)
    input logic     rst_n,                  // reset
    output logic    [3:0] o_anode_sel,      // anode select
    output logic    [6:0] o_seven_segment   // 7 segment output
);

    reg [26:0] counter_one_sec; // counter for generating 1 second clock enable
    wire en_one_sec;            // one second enable for counting numbers
    reg [3:0] led_bcd;
    wire [1:0] select_anode;

    // one second counter
    always_ff @(posedge clk) begin
        if(rst_n)
            counter_one_sec <= 0;
        else begin
            if(counter_one_sec <= 99999999)
                counter_one_sec <= counter_one_sec + 1;
            else
                counter_one_sec <= 0;
        end
    end

    assign en_one_sec = (counter_one_sec == 99999999)? 1 : 0;

    reg [15:0] num_displayed;   // counting number to be displayed

    // increment number after every 1 sec
    always_ff @(posedge clk) begin
        if(rst_n == 1)
            num_displayed <= 0;
        else if(en_one_sec == 1)
            num_displayed <= num_displayed + 1;
    end

    // the first 18-bit for creating 2.6ms digit period
    // the other 2-bit for creating 4 LED-activating signals
    reg [19:0] refresh_counter;

    always_ff @(posedge clk) begin
        if(rst_n==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    assign select_anode = refresh_counter[19:18];

    // decoder to generate anode signals
    always_comb begin
        case(select_anode)
            2'b00: begin
                o_anode_sel = 4'b0111;
                // activate LED1 and Deactivate LED2, LED3, LED4
                led_bcd = num_displayed/1000;
                // the first digit of the 16-bit number
            end
            2'b01: begin
                o_anode_sel = 4'b1011;
                // activate LED2 and Deactivate LED1, LED3, LED4
                led_bcd = (num_displayed % 1000)/100;
                // the second digit of the 16-bit number
            end
            2'b10: begin
                o_anode_sel = 4'b1101;
                // activate LED3 and Deactivate LED2, LED1, LED4
                led_bcd = ((num_displayed % 1000)%100)/10;
                // the third digit of the 16-bit number
            end
            2'b11: begin
                o_anode_sel = 4'b1110;
                // activate LED4 and Deactivate LED2, LED3, LED1
                led_bcd = ((num_displayed % 1000)%100)%10;
                // the fourth digit of the 16-bit number
            end
        endcase
    end

    // Cathode patterns of the 7-segment LED display
    always_comb begin
        case(led_bcd)
            4'b0000: o_seven_segment = 7'b000_0001; // "0"
            4'b0001: o_seven_segment = 7'b100_1111; // "1"
            4'b0010: o_seven_segment = 7'b001_0010; // "2"
            4'b0011: o_seven_segment = 7'b000_0110; // "3"
            4'b0100: o_seven_segment = 7'b100_1100; // "4"
            4'b0101: o_seven_segment = 7'b010_0100; // "5"
            4'b0110: o_seven_segment = 7'b010_0000; // "6"
            4'b0111: o_seven_segment = 7'b000_1111; // "7"
            4'b1000: o_seven_segment = 7'b000_0000; // "8"
            4'b1001: o_seven_segment = 7'b000_0100; // "9"
            default: o_seven_segment = 7'b000_0001; // "0"
        endcase
    end

endmodule

