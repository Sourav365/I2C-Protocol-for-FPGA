# I2C-Protocol-On-Basys3

## I2C Slave-> MPU6050

<img width="800" alt="image" src="https://user-images.githubusercontent.com/49667585/235461192-df514af8-a123-4b06-8e61-0ad830e3afb2.png">

```
Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 36.53     // (Everithing in Decimal value)
```

7-bit I2C Address.

0th and 7th bit is hard-coded to '0'.

Default I2C Address is `0x68`.

## Timing diagram

<img width="960" alt="image" src="https://user-images.githubusercontent.com/49667585/235472126-750ab4fa-c173-48b5-a74e-d0ab1b58320e.png">
<img width="618" alt="image" src="https://user-images.githubusercontent.com/49667585/235472206-4fe726a7-7d4e-477b-962f-efc23615dde4.png">

When ACK or Data bits come from slave, master releases SDA line means High Impedance state (Z)

