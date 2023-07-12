`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sourav Das
// 
// Create Date: 12.07.2023 11:47:48
// Design Name: 
// Module Name: i2c_master_rd_slave_reg
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


module i2c_master_rd_slave_reg (
    input clk_200khz,    //operating 200KHz clk  
    input rst,           //reset
    inout sda,           //bidirectional SDA line
    output scl,          //SCL line of 10KHz
    output sda_dir,      //data direction on SDA from/to Master
    output [7:0] data_out
    );
    
        
    /* 
     **************** GENERATE SCL ******************
     * Generate 10KHz SCL from 200KHz clk
     * Number of count cycles = 0.5*(200K/10K)=10 -->4bit reg
     */
    reg [3:0] count = 0;   //Initial value 0
    reg clk_reg = 1'b1;    //Idle clk status 1
     
    always @ (posedge clk_200khz or posedge rst) begin
        if (rst) begin
            count   = 4'b0;
            clk_reg = 1'b1;
        end
        else begin
            if (count == 9) begin
                count <= 4'b0;
                clk_reg <= ~clk_reg;
            end
            else
                count <= count + 1;
        end
    end
    assign scl = clk_reg;
    
    
     
    /**************** GENERATE SDA ******************/
    //Variables
    parameter SLAVE_ADDR = 7'b110_1000; //0x68
    parameter SLAVE_ADDR_PLUS_R = 8'b1101_0001; //Slave address (7-bits) + Read  bit = (0x68 << 1) + 1 = 0xD1
    parameter SLAVE_ADDR_PLUS_W = 8'b1101_0000; //Slave address (7-bits) + Write bit = (0x68 << 1) + 0 = 0xD0
    parameter SLAVE_INT_REG_ADDR = 8'b0011_1100; //0x3C   or 0x42

    //reg [7:0] data_MSB      = 8'b0;             //data bits
    reg [7:0] data            = 8'b0;             //data bits
    reg output_bit            = 1'b1;             //output bit of sda data pulled up, so initially 1
    wire input_bit;                               //input bit from slave
    reg [15:0] count1         = 16'b1;            //counter for synchronize state machine (ticks)
    
    //Local parameters for states
    localparam [5:0] POWER_UP    = 0,
                     START1      = 1,
                     SEND1_ADDR6 = 2,
                     SEND1_ADDR5 = 3,
                     SEND1_ADDR4 = 4,
                     SEND1_ADDR3 = 5,
                     SEND1_ADDR2 = 6,
                     SEND1_ADDR1 = 7,
                     SEND1_ADDR0 = 8,
                     SEND1_W     = 9,
                     REC1_ACK    = 10,
                     
                     SEND1_DATA7 = 11, //Send internal reg address as data
                     SEND1_DATA6 = 12,
                     SEND1_DATA5 = 13,
                     SEND1_DATA4 = 14,
                     SEND1_DATA3 = 15,
                     SEND1_DATA2 = 16,
                     SEND1_DATA1 = 17,
                     SEND1_DATA0 = 18,
                     REC2_ACK    = 19,
                     
                     
                     
                     START2      = 20, // Start without stop
                     SEND2_ADDR6 = 21,  // Again send Slave addr to receive data from that internal reg
                     SEND2_ADDR5 = 22,
                     SEND2_ADDR4 = 23,
                     SEND2_ADDR3 = 24,
                     SEND2_ADDR2 = 25,
                     SEND2_ADDR1 = 26,
                     SEND2_ADDR0 = 27,
                     SEND2_R     = 28,
                     REC3_ACK    = 29,
                     
                     REC1_DATA7  = 30,
                     REC1_DATA6  = 31,
                     REC1_DATA5  = 32,
                     REC1_DATA4  = 33,
                     REC1_DATA3  = 34,
                     REC1_DATA2  = 35,
                     REC1_DATA1  = 36,
                     REC1_DATA0  = 37,
                     SEND1_NAK   = 38;
    
    //Initial state                 
    reg [5:0] state = POWER_UP;
    
    
    always @(posedge clk_200khz or posedge rst) begin
    
        if(rst) begin
            state  <= POWER_UP;
            count1 <= 1;
        end
        
        else begin
            count1 <= count1 + 1;
            
            case (state)
            
                POWER_UP: if(count1==2000) state <= START1; //2000*5u-Sec = 10m-Sec after go to start
                
                
                /***************** Start + Send SlaveAddr + Write + Receive ACK from Slave ******************/
                START1     : begin
                    if(count1==2005) output_bit <= 0;      //At 5th tick, SCL line is high, make SDA=0 for start
                    if(count1==2015) state <= SEND1_ADDR6;  //At 14th tick, SCL line is low, start sending addr (Setup time)
                end
                
                SEND1_ADDR6: begin
                    output_bit <= SLAVE_ADDR[6];
                    if(count1==2035) state <= SEND1_ADDR5;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR5: begin
                    output_bit <= SLAVE_ADDR[5];
                    if(count1==2055) state <= SEND1_ADDR4;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR4: begin
                    output_bit <= SLAVE_ADDR[4];
                    if(count1==2075) state <= SEND1_ADDR3;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR3: begin
                    output_bit <= SLAVE_ADDR[3];
                    if(count1==2095) state <= SEND1_ADDR2;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR2: begin
                    output_bit <= SLAVE_ADDR[2];
                    if(count1==2115) state <= SEND1_ADDR1;  //1 SCL period has 20 ticks.
                end
               
                SEND1_ADDR1: begin
                    output_bit <= SLAVE_ADDR[1];
                    if(count1==2135) state <= SEND1_ADDR0;  //1 SCL period has 20 ticks.
                end
                
                SEND1_ADDR0: begin
                    output_bit <= SLAVE_ADDR[0];
                    if(count1==2155) state <= SEND1_W;  //1 SCL period has 20 ticks.
                end
                
                SEND1_W   : begin
                    output_bit <= 1'b0; // For Write send 0
                    if(count1==2170) state <= REC1_ACK;  //When clk changes/at the edge of clk, change it.
                end
                
                REC1_ACK   : if(count1==2195) state <= SEND1_DATA7;
                
                
                
                /***************** Send Slave Internal Reg Addr + Receive ACK from Slave ******************/
                SEND1_DATA7: begin
                    output_bit <= SLAVE_INT_REG_ADDR[7];
                    if(count1==2215) state <= SEND1_DATA6;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA6: begin
                    output_bit <= SLAVE_INT_REG_ADDR[6];
                    if(count1==2235) state <= SEND1_DATA5;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA5: begin
                    output_bit <= SLAVE_INT_REG_ADDR[5];
                    if(count1==2255) state <= SEND1_DATA4;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA4: begin
                    output_bit <= SLAVE_INT_REG_ADDR[4];
                    if(count1==2275) state <= SEND1_DATA3;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA3: begin
                    output_bit <= SLAVE_INT_REG_ADDR[3];
                    if(count1==2295) state <= SEND1_DATA2;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA2: begin
                    output_bit <= SLAVE_INT_REG_ADDR[2];
                    if(count1==2315) state <= SEND1_DATA1;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA1: begin
                    output_bit <= SLAVE_INT_REG_ADDR[1];
                    if(count1==2335) state <= SEND1_DATA0;  //1 SCL period has 20 ticks.
                end
                
                SEND1_DATA0: begin
                    output_bit <= SLAVE_INT_REG_ADDR[0];
                    if(count1==2350) state <= REC2_ACK;  //1 SCL period has 20 ticks.
                end
                
                REC2_ACK   : if(count1==2370) state <= START2; /// If not work change to 75.
                
                
                
                
                /***************** Start + Send SlaveAddr + Read + Receive ACK from Slave ******************/
                START2     : begin
                    if(count1==2375) output_bit <= 1;
                    if(count1==2385) output_bit <= 0;      //At 5th tick, SCL line is high, make SDA=0 for start
                    if(count1==2395) state <= SEND2_ADDR6;  //At 14th tick, SCL line is low, start sending addr (Setup time)
                end
                
                SEND2_ADDR6: begin
                    output_bit <= SLAVE_ADDR[6];
                    if(count1==2415) state <= SEND2_ADDR5;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR5: begin
                    output_bit <= SLAVE_ADDR[5];
                    if(count1==2435) state <= SEND2_ADDR4;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR4: begin
                    output_bit <= SLAVE_ADDR[4];
                    if(count1==2455) state <= SEND2_ADDR3;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR3: begin
                    output_bit <= SLAVE_ADDR[3];
                    if(count1==2475) state <= SEND2_ADDR2;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR2: begin
                    output_bit <= SLAVE_ADDR[2];
                    if(count1==2495) state <= SEND2_ADDR1;  //1 SCL period has 20 ticks.
                end
               
                SEND2_ADDR1: begin
                    output_bit <= SLAVE_ADDR[1];
                    if(count1==2515) state <= SEND2_ADDR0;  //1 SCL period has 20 ticks.
                end
                
                SEND2_ADDR0: begin
                    output_bit <= SLAVE_ADDR[0];
                    if(count1==2535) state <= SEND2_R;  //1 SCL period has 20 ticks.
                end
                
                SEND2_R   : begin
                    output_bit <= 1'b1; // For Read send 1
                    if(count1==2550) state <= REC3_ACK;  //When clk changes/at the edge of clk, change it.
                end
                
                REC3_ACK   : if(count1==2570) state <= REC1_DATA7;
                
                
                
                /***************** Receive Data from slave + Send NACK to Slave ******************/
                REC1_DATA7  : begin
                    data[7] <= input_bit;               
                    if(count1==2590) state <= REC1_DATA6;
                end
                
                REC1_DATA6  : begin
                    data[6] <= input_bit;               
                    if(count1==2610) state <= REC1_DATA5;
                end
                
                REC1_DATA5  : begin
                    data[5] <= input_bit;               
                    if(count1==2630) state <= REC1_DATA4;
                end
                
                REC1_DATA4  : begin
                    data[4] <= input_bit;               
                    if(count1==2650) state <= REC1_DATA3;
                end
                
                REC1_DATA3  : begin
                    data[3] <= input_bit;               
                    if(count1==2670) state <= REC1_DATA2;
                end
                
                REC1_DATA2  : begin
                    data[2] <= input_bit;               
                    if(count1==2690) state <= REC1_DATA1;
                end
                
                REC1_DATA1  : begin
                    data[1] <= input_bit;               
                    if(count1==2710) state <= REC1_DATA0;
                end
                
                REC1_DATA0  : begin
                    output_bit <= 1; //Send ack
                    data[0] <= input_bit;               
                    if(count1==2730) state <= SEND1_NAK;
                end
                
                
                SEND1_NAK  : begin
                    if(count1==3500) begin     //Again 5 clk at start.... Repeated start with no delay(count1==2760) or add more delay....
                        count1 <= 2000;
                        state <= START1;
                    end
                end
                
            endcase
        end
    end
    
    
    
    assign sda_dir = (state==POWER_UP || state==START1 || 
             state==SEND1_ADDR6 || state==SEND1_ADDR5 || state==SEND1_ADDR4 || state==SEND1_ADDR3 || state==SEND1_ADDR2 || state==SEND1_ADDR1 || state==SEND1_ADDR0 ||
             state==SEND1_W || 
             state==SEND1_DATA7 || state==SEND1_DATA6 || state==SEND1_DATA5 || state==SEND1_DATA4 || state==SEND1_DATA3 || state==SEND1_DATA2 || state==SEND1_DATA1 || state==SEND1_DATA0 ||  
             state==START2 ||
             state==SEND2_ADDR6 || state==SEND2_ADDR5 || state==SEND2_ADDR4 || state==SEND2_ADDR3 || state==SEND2_ADDR2 || state==SEND2_ADDR1 || state==SEND2_ADDR0 || 
             state==SEND2_R || state==SEND1_NAK
              )  ?  1 : 0;
                     
    
    //SDA line contains output_bit when master sends data else it's TRI-state
    assign sda = sda_dir ? output_bit : 1'bz;
    
    //set value of input wire when slave sends data to master through SDA line
    assign input_bit = sda; 
    
    //Final output
    assign data_out = data;///340 + 36.53;
endmodule
