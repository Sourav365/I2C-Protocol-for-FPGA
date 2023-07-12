`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.05.2023 22:59:42
// Design Name: 
// Module Name: i2c_master
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


module i2c_master_read_data #(parameter SLAVE_ADDR_RW = 8'b1101_0001)(  //Slave address with r/w bit = (0x68 << 1) + 1 = 0xD1
    input clk_200khz,    //operating 200KHz clk  
    input rst,           //reset
    inout sda,           //bidirectional SDA line
    output scl,          //SCL line of 10KHz
    output sda_dir,      //data direction on SDA from/to Master
    output [15:0] temperature
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
    //parameter SLAVE_ADDR_RW = 8'b1101_0001;     //Slave address with r/w bit = (0x68 << 1) + 1 = 0xD1
    reg [7:0] data_MSB      = 8'b0;             //data bits
    reg [7:0] data_LSB      = 8'b0;             //data bits
    reg output_bit          = 1'b1;             //output bit of sda data
    wire input_bit;                             //input bit from slave
    reg [11:0] count1       = 12'b0;            //counter for synchronize state machine (ticks)
    reg signed [15:0] temp_data_reg;            //temperature data reg buffer
    
    //Local parameters for states
    localparam [4:0] POWER_UP   = 0,
                     START      = 1,
                     SEND_ADDR6 = 2,
                     SEND_ADDR5 = 3,
                     SEND_ADDR4 = 4,
                     SEND_ADDR3 = 5,
                     SEND_ADDR2 = 6,
                     SEND_ADDR1 = 7,
                     SEND_ADDR0 = 8,
                     SEND_RW    = 9,
                     REC_ACK    = 10,
                     REC_MSB7   = 11,
                     REC_MSB6   = 12,
                     REC_MSB5   = 13,
                     REC_MSB4   = 14,
                     REC_MSB3   = 15,
                     REC_MSB2   = 16,
                     REC_MSB1   = 17,
                     REC_MSB0   = 18,
                     SEND_ACK   = 19,
                     REC_LSB7   = 20,
                     REC_LSB6   = 21,
                     REC_LSB5   = 22,
                     REC_LSB4   = 23,
                     REC_LSB3   = 24,
                     REC_LSB2   = 25,
                     REC_LSB1   = 26,
                     REC_LSB0   = 27,
                     SEND_NAC   = 28;
    
    //Initial state                 
    reg [4:0] state = POWER_UP;
    
    
    always @(posedge clk_200khz or posedge rst) begin
    
        if(rst) begin
            state  <= POWER_UP;
            count1 <= 0;
        end
        
        else begin
            count1 <= count1 + 1;
            
            case (state)
            
                POWER_UP: if(count1==1999) state <= START; //2000*5u-Sec = 10m-Sec after go to start
                
                START     : begin
                    if(count1==2004) output_bit <= 0;      //At 5th tick, SCL line is high, make SDA=0 for start
                    if(count1==2013) state <= SEND_ADDR6;  //At 14th tick, SCL line is low, start sending addr
                end
                
                SEND_ADDR6: begin
                    output_bit <= SLAVE_ADDR_RW[7];
                    if(count1==2033) state <= SEND_ADDR5;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR5: begin
                    output_bit <= SLAVE_ADDR_RW[6];
                    if(count1==2053) state <= SEND_ADDR4;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR4: begin
                    output_bit <= SLAVE_ADDR_RW[5];
                    if(count1==2073) state <= SEND_ADDR3;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR3: begin
                    output_bit <= SLAVE_ADDR_RW[4];
                    if(count1==2093) state <= SEND_ADDR2;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR2: begin
                    output_bit <= SLAVE_ADDR_RW[3];
                    if(count1==2113) state <= SEND_ADDR1;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR1: begin
                    output_bit <= SLAVE_ADDR_RW[2];
                    if(count1==2133) state <= SEND_ADDR0;  //1 SCL period has 20 ticks.
                end
                
                SEND_ADDR0: begin
                    output_bit <= SLAVE_ADDR_RW[1];
                    if(count1==2153) state <= SEND_RW;  //1 SCL period has 20 ticks.
                end
                
                SEND_RW   : begin
                    output_bit <= SLAVE_ADDR_RW[0];
                    if(count1==2169) state <= REC_ACK;  //When clk changes/at the edge of clk, change it./////4164????????
                end
                
                REC_ACK   : if(count1==2189) state <= REC_MSB7;
                
                REC_MSB7  : begin
                    data_MSB[7] <= input_bit;               
                    if(count1==2209) state <= REC_MSB6;
                end
                
                REC_MSB6  : begin
                    data_MSB[6] <= input_bit;               
                    if(count1==2229) state <= REC_MSB5;
                end
                
                REC_MSB5  : begin
                    data_MSB[5] <= input_bit;               
                    if(count1==2249) state <= REC_MSB4;
                end
                
                REC_MSB4  : begin
                    data_MSB[4] <= input_bit;               
                    if(count1==2269) state <= REC_MSB3;
                end
                
                REC_MSB3  : begin
                    data_MSB[3] <= input_bit;               
                    if(count1==2289) state <= REC_MSB2;
                end
                
                REC_MSB2  : begin
                    data_MSB[2] <= input_bit;               
                    if(count1==2309) state <= REC_MSB1;
                end
                
                REC_MSB1  : begin
                    data_MSB[1] <= input_bit;               
                    if(count1==2329) state <= REC_MSB0;
                end
                
                REC_MSB0  : begin
                    output_bit <= 0; //Send ack
                    data_MSB[0] <= input_bit;               
                    if(count1==2349) state <= SEND_ACK;
                end
                
                SEND_ACK  : if(count1==2369) state <= REC_LSB7;
                
                REC_LSB7  : begin
                    data_LSB[7] <= input_bit;
                    if(count1==2389) state <= REC_LSB6;
                end
                
                REC_LSB6  : begin
                    data_LSB[6] <= input_bit;
                    if(count1==2409) state <= REC_LSB5;
                end
                
                REC_LSB5  : begin
                    data_LSB[5] <= input_bit;
                    if(count1==2429) state <= REC_LSB4;
                end
                
                REC_LSB4  : begin
                    data_LSB[4] <= input_bit;
                    if(count1==2449) state <= REC_LSB3;
                end
                
                REC_LSB3  : begin
                    data_LSB[3] <= input_bit;
                    if(count1==2469) state <= REC_LSB2;
                end
                
                REC_LSB2  : begin
                    data_LSB[2] <= input_bit;
                    if(count1==2489) state <= REC_LSB1;
                end
                
                REC_LSB1  : begin
                    data_LSB[1] <= input_bit;
                    if(count1==2509) state <= REC_LSB0;
                end
                
                REC_LSB0  : begin
                    output_bit <= 1; //For NAC bit
                    data_LSB[0] <= input_bit;
                    if(count1==2529) state <= SEND_NAC;
                end
                
                SEND_NAC  : begin
                    if(count1==2559) begin     //59??????????
                        count1 <= 2000;
                        state <= START;
                    end
                end
                
            endcase
        end
    end
    
    //Temperature data
    always @(posedge clk_200khz)
        if(state == SEND_NAC)
            temp_data_reg <=  {data_MSB[7:0], data_LSB[7:0]};
    
    
    assign sda_dir = (state==POWER_UP || state==START || state==SEND_ADDR6 || state==SEND_ADDR5 || 
                      state==SEND_ADDR4 || state==SEND_ADDR3 || state==SEND_ADDR2 || state==SEND_ADDR1 || 
                      state==SEND_ADDR0 || state==SEND_RW || state==SEND_ACK || state==SEND_NAC)  ? 1 : 0;
                      
    
    //SDA line contains output_bit when master sends data else it's TRI-state
    assign sda = sda_dir ? output_bit : 1'bz;
    
    //set value of input wire when slave sends data to master through SDA line
    assign input_bit = sda; 
    
    //Final output
    assign temperature = (temp_data_reg);///340 + 36.53;
endmodule
