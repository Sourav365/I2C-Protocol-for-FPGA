# I2C-Protocol-On-Basys3

Inter-Integrated Circuit (I2C), I^2 C, or even IIC, is a **two-wire** data transfer bus. Philips Semiconductor (now **NXP** Semiconductors) invented the protocol in 1982.

## I2C Slave-> MPU6050

Accelerometer, Gyroscope, Temperature Sensor

Max I2C clock frequency = 400KHz

7-bit I2C Address.

0th and 7th bit is hard-coded to '0'.

Default I2C Address is `0x68`.

### Register map
![image](https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/9203af55-f1de-4947-aa30-4c3ababc4a6f)

```
Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 36.53     // (Everithing in Decimal value)
```

# Verilog Code

1. Let's take SCL frequency = 10KHz. T = 100 u-sec
2. For proper operation (Start condition during High state of clk, data change during low state of clk...)
3. Let's take operating clk frequency = 20*10KHz = 200KHz. T = 5 u-sec
   
(One clk cycle divided into 20 sub-parts)

![image](https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/ac0ff2fc-2e8a-4df4-acb4-0111f8e99e58)


![image](https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/c02f83b8-4d6f-4192-b2cd-60fe52eb5cb9)



## Code 1 (Only Receive from Slave Address)

<img width="950" alt="image" src="https://user-images.githubusercontent.com/49667585/235472126-750ab4fa-c173-48b5-a74e-d0ab1b58320e.png">
<img width="618" alt="image" src="https://user-images.githubusercontent.com/49667585/235472206-4fe726a7-7d4e-477b-962f-efc23615dde4.png">

When ACK or Data bits come from slave, master releases SDA line means High Impedance state (Z)


### State Diagram

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/235473554-a9696eb7-2ebb-463d-b10c-97d63a97dc31.png">

### Output Waveform

<img width="1000" alt="image" src="https://user-images.githubusercontent.com/49667585/237013531-130fd0f0-1c55-4b4a-b6f0-4856240f282b.png">

1. Start condition (SCL high, SDA data changesfrom 1 to 0)

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/237016840-5861b8f8-1b07-49b3-961b-ac48313687e4.png">

2. Send Address bits and RW (SCL low, SDA data changes, checked at posedge)

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/237019542-d656768e-71c1-4d44-b493-894f86ecfb7b.png">

3. Receive ACk from sensor and data bits and Master sends ACK for more data to receive (ACK->0 for 1 entire scl period)

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/237020210-bcbe582e-44c9-43c5-b994-53fc845498cd.png">

4. Slave sends more data and master sends NACK not to receive anymore data (NACK->1 for 1 entire scl period)

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/237021587-b82ec741-6a9f-4dcb-832d-ba5c1c659f3c.png">

5. Send STOP signal by Master (SCL high, SDA data changesfrom 0 to 1)

***But here we're not stopping the data-transfer, we're continiously receiving data... So, sending repeated start bit

6. Repeated start bit

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/237024530-fbdfb100-1f21-448b-810f-94e44d5ae3c3.png">

<img width="902" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/f8bccaaa-b0a3-4447-abf2-125e006426a3">


## Code 2 (Receive data from internal Reg of Slave)

(But in most of the sensor, they use following format)
Start --> Send Slave Addr --> Send Slave Internal Reg Addr --> Receive Data --> Stop.

![image](https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/a84a8405-47d0-4318-ada4-bdd2dc76f4cb)

### States
```mermaid
graph TD;
    START1-->SEND1_ADDR6-->Send1_Addr... -->SEND1_ADDR0-->SEND_W-->REC1_ACK;
    REC1_ACK -->SEND_DATA7-->Snd_Data... -->SEND_DATA0-->REC2_ACK;
    REC2_ACK -->START2-->SEND2_ADDR6-->Send2_Addr... -->SEND2_ADDR0-->SEND_R-->REC3_ACK;
    REC3_ACK-->REC_DATA7-->Receive... -->REC_DATA0-->SEND_NAK-->WAIT-->START1;
```


                   
                     
                  

### Using Arduino and MPU6050
<img width="891" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/99070a12-b64d-46e2-9e14-4d5341c209d2">

<img width="871" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/e4232fde-d296-474f-bef2-31eaadab2876">

<img width="802" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/26c559a7-e129-43e0-a3a6-c8b95b5ab66e">




### RTL Code Simulation on Viavado

<img width="1000" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/4649b08d-4716-47cc-9d5b-a4ce76a95044">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/f73901fa-df62-426d-b63c-adcfc7149ee6">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/db60678e-24c1-43f7-83b1-15912594f73d">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/6e88bc4b-3cdf-4053-a723-77a0062edfe5">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/f9c0fe39-7917-4da5-8c3d-9a61aee5a98e">



### Using FPGA Board and MPU6050

<img width="904" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/0aef678c-c2ed-4e2a-99f4-79cc35de9ed0">
<img width="911" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/2006c78d-bee8-4cef-ad36-6e83d17489cb">



<img width="903" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/3b7cc8b6-a520-4701-808f-a280d2106185">
<img width="906" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/843f8799-8ea0-48ed-9b98-4e118709a769">
<img width="905" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/5f858ffc-95ec-4ee3-99a7-c8bf78bf3c08">



<img width="906" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/6910702d-bd4f-48ea-b4ec-a80f9feebfb1">
<img width="899" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/3731cdae-8981-4c44-a32a-2d8006b03182">
<img width="892" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/7b2caff2-b6d2-40d1-825c-1fe37fe52e88">
