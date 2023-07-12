`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2023 13:00:24
// Design Name: 
// Module Name: top_module
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


module top_module(
    input clk, rst,
    inout sda, sda1,
    output scl, scl1,
    output [7:0] led
    );
    assign scl1 = scl;
    assign sda1 = sda;
    
    
    wire sda_dir, clk_200khz;
    wire [7:0] data;

    
    i2c_master_rd_slave_reg i2c1 (
    .clk_200khz(clk_200khz),    //operating 200KHz clk  
    .rst(rst),           //reset
    .sda(sda),           //bidirectional SDA line
    .scl(scl),           //SCL line of 10KHz
    .sda_dir(sda_dir),      //data direction on SDA from/to Master
    .data_out(data)
    );
    
    slow_clk_200khz slw_clk_200khz1(
    .clk(clk), //100MHz
    .clk_200khz(clk_200khz)
    );
    
    assign led = data;
    assign sda1 = sda;
    assign scl1 = scl;
endmodule
