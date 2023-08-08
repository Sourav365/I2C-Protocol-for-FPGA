# I2C-Protocol-On-Basys3

Inter-Integrated Circuit (I2C), I^2 C, or even IIC, is a **two-wire** data transfer bus. Philips Semiconductor (now **NXP** Semiconductors) invented the protocol in 1982.

## I2C Slave-> MPU6050

Accelerometer, Gyroscope, Temperature Sensor

Max I2C clock frequency = 400KHz

7-bit I2C Address.

0th and 7th bit is hard-coded to '0'.

Default I2C Address is `0x68`.

### Register map
![img1](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/c4c1bd4e-ba65-4b62-894f-d8c13ebc093d)


```
Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 36.53     // (Everithing in Decimal value)
```

# Verilog Code

1. Let's take SCL frequency = 10KHz. T = 100 u-sec
2. For proper operation (Start condition during High state of clk, data change during low state of clk...)
3. Let's take operating clk frequency = 20*10KHz = 200KHz. T = 5 u-sec
   
(One clk cycle divided into 20 sub-parts)

![img2](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/8c94de03-3802-4343-b6e8-a13e187bcc3f)

![img3](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/c83eaecd-bae0-4582-ba37-07d02b60e0f6)



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

<img width="902" alt="img13" src="https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/8ecc9c10-28bf-4eed-b470-096b2c0a3945">


## Code 2 (Receive data from internal Reg of Slave)

(But in most of the sensor, they use following format)
Start --> Send Slave Addr --> Send Slave Internal Reg Addr --> Receive Data --> Stop.

![img14](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/8bc5b42b-07b6-4211-a7d4-33e2df91e628)


### States
```mermaid
graph TD;
    START1-->SEND1_ADDR6-->Send1_Addr... -->SEND1_ADDR0-->SEND_W-->REC1_ACK;
    REC1_ACK -->SEND_DATA7-->Snd_Data... -->SEND_DATA0-->REC2_ACK;
    REC2_ACK -->START2-->SEND2_ADDR6-->Send2_Addr... -->SEND2_ADDR0-->SEND_R-->REC3_ACK;
    REC3_ACK-->REC_DATA7-->Receive... -->REC_DATA0-->SEND_NAK-->WAIT-->START1;
```


                   
                     
                  

### Using Arduino and MPU6050

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/44cdc5db-9cd1-4dd1-8f69-e31bfcabe31b)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/d7befd64-cfc7-4192-8de4-3a893bb74791)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/a6c8e674-1a95-4d84-b363-07c3313ac291)


### RTL Code Simulation on Viavado

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/6370ec6d-f7f0-4079-860f-44dfa50fa07a)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/e021ec10-1b28-4c08-a518-f999a58c206e)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/f793d166-dec6-463a-a8b6-c27d15caa35b)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/ed1f011e-7e4c-46ac-b72a-2767a844b096)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/8aca82b1-c57b-4099-a66b-97f871cc0b18)


### Using FPGA Board and MPU6050

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/90f35dc6-e2e6-4074-b485-7bcda744e017)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/6bf3aebe-d3c8-4377-9d00-6104eea728b8)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/f8cba8f6-e44a-4bbc-b24d-4fdd7127a6ad)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/07d98904-5e0d-4250-8cb0-de575ff6b37d)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/68328620-86ef-49e3-ad70-63a7c34c6728)

**Output of Start1->Send Addr+Wr->Send Internal Reg Addr->Stop->Start2->Send Addr+Rd->Read Data->NAK->Start2**

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/9c8cfced-d332-4a14-b2ac-c378661681ee)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/b5cb9174-b5b1-4629-b8a0-10b221aee32a)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/d6fcea2f-39b6-4427-ad79-1a34136bccf7)

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/d8642be1-5547-4ace-93d4-23dfe53a6726)


Sometimes it's giving ```0x00``` values. This may be due to Reading data at a very high speed, or the sensor is not able to store its sense data to its internal reg.

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/40101bcf-8061-4b21-b0ff-55b7d6e1eacf)

**Output of Start1->Send Addr+Wr->Send Internal Reg Addr->Stop->Start2->Send Addr+Rd->Read Data->NAK->Start1**

![image](https://github.com/Sourav365/I2C-Protocol-for-FPGA/assets/49667585/c0052a68-6d25-4b2b-b987-1044a668d644)

Here Speed is less, but no ```0x00``` data comes.

