# I2C-Protocol-On-Basys3

## I2C Slave-> MPU6050

<img width="800" alt="image" src="https://user-images.githubusercontent.com/49667585/235461192-df514af8-a123-4b06-8e61-0ad830e3afb2.png">

```
Temperature in degrees C = (TEMP_OUT Register Value as a signed quantity)/340 + 36.53     // (Everithing in Decimal value)
```

7-bit I2C Address.

0th and 7th bit is hard-coded to '0'

Default I2C Address is 0x68.
