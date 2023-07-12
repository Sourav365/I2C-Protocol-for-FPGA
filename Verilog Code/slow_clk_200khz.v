`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2023 09:32:49
// Design Name: 
// Module Name: slow_clk_200khz
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


module slow_clk_200khz(
    input clk, //100MHz
    output clk_200khz
    );
    
  //No of cycles = 0.5*(100MHz/200KHz) = 250 --> 8 bit counter
    reg [7:0] count = 8'b0;
    reg clk_reg;
    always @(posedge clk) begin 
        if(count==249) begin
            count = 0;
            clk_reg <= ~clk_reg; 
        end
        else count <= count +1;
    end
    
    assign clk_200khz = clk_reg;
endmodule
