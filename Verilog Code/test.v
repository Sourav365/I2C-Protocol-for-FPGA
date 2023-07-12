`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sourav Das
// 
// Create Date: 08.05.2023 09:45:20
// Design Name: 
// Module Name: test
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


module test();

    reg clk_200khz;
    reg rst;
    wire sda;
    wire scl;
    wire sda_dir;
    //wire [15:0] temperature;
    wire [7:0] data_out;
    

    i2c_master_rd_slave_reg uut (
    .clk_200khz(clk_200khz),    //operating 200KHz clk  
    .rst(rst),           //reset
    .sda(sda),           //bidirectional SDA line
    . scl(scl),          //SCL line of 10KHz
    . sda_dir(sda_dir),      //data direction on SDA from/to Master
    . data_out(data_out)
    );
    
    always #5 clk_200khz=~clk_200khz;
    
    initial begin
        rst=1;
        clk_200khz=0; #3 rst=0;
    end
endmodule
