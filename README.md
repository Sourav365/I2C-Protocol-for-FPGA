# I2C-Protocol-On-Basys3

Inter-Integrated Circuit (I2C), I^2 C, or even IIC, is a **two-wire** data transfer bus. Philips Semiconductor (now **NXP** Semiconductors) invented the protocol in 1982.

## I2C Slave-> MPU6050

Max I2C clock frequency = 400KHz

<img width="800" alt="image" src="https://user-images.githubusercontent.com/49667585/235461192-df514af8-a123-4b06-8e61-0ad830e3afb2.png">

```
Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 36.53     // (Everithing in Decimal value)
```

7-bit I2C Address.

0th and 7th bit is hard-coded to '0'.

Default I2C Address is `0x68`.

## Timing diagram

<img width="950" alt="image" src="https://user-images.githubusercontent.com/49667585/235472126-750ab4fa-c173-48b5-a74e-d0ab1b58320e.png">
<img width="618" alt="image" src="https://user-images.githubusercontent.com/49667585/235472206-4fe726a7-7d4e-477b-962f-efc23615dde4.png">

When ACK or Data bits come from slave, master releases SDA line means High Impedance state (Z)
```
Let's take SCL frequency = 10KHz. T = 100 u-sec
For proper operation (Start condition during High state of clk, data change during low state of clk...),
Let's take operating clk frequency = 20*10KHz = 200KHz. T = 5 u-sec

I2C addr = 0x68
I2C addr with R/W bit = (0x68<<1)+1 = 0xD1

```

## State Diagram

<img width="900" alt="image" src="https://user-images.githubusercontent.com/49667585/235473554-a9696eb7-2ebb-463d-b10c-97d63a97dc31.png">

## Output Waveform

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


## But in most of the sensor, they use following format
Start --> Send Slave Addr --> Send Slave Internal Reg Addr --> Receive Data --> Stop.

![image](https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/a84a8405-47d0-4318-ada4-bdd2dc76f4cb)

<img width="891" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/99070a12-b64d-46e2-9e14-4d5341c209d2">


<img width="871" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/e4232fde-d296-474f-bef2-31eaadab2876">

<img width="802" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/26c559a7-e129-43e0-a3a6-c8b95b5ab66e">


<img width="1000" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/4649b08d-4716-47cc-9d5b-a4ce76a95044">


<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/f73901fa-df62-426d-b63c-adcfc7149ee6">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/db60678e-24c1-43f7-83b1-15912594f73d">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/6e88bc4b-3cdf-4053-a723-77a0062edfe5">

<img width="900" alt="image" src="https://github.com/Sourav365/I2C-Protocol-On-Basys3/assets/49667585/f9c0fe39-7917-4da5-8c3d-9a61aee5a98e">
