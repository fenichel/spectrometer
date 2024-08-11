This repository contains resources for debugging a system consisting of an Arduino and a spectrometer.

## Hardware

### Arduino UNO Rev 3*
- [Root page for documentation](https://store-usa.arduino.cc/products/arduino-uno-rev3?selectedStore=us)
- [Schematic](https://content.arduino.cc/assets/UNO-TH_Rev3e_sch.pdf)
- [Datasheet](https://docs.arduino.cc/resources/datasheets/A000066-datasheet.pdf)
- [Pinout](https://content.arduino.cc/assets/A000066-full-pinout.pdf)

*I’m actually using the rev2, but they are pin-compatible and the documentation for the rev3 is way better.

### Hamamatsu C12880MA Breakout Board v2
- [Example code repository on GitHub](https://github.com/groupgets/c12880ma)
- [Datasheet](https://groupgets-files.s3.amazonaws.com/hamamatsu/uspectrometer/C12880MA%20Breakout%20Board%20v2%20-%20Datasheet%20-%201.2.pdf)
- [Schematic, layout, and bill of materials (BOM)](https://groupgets-files.s3.amazonaws.com/hamamatsu/uspectrometer/c12880ma_v2_breakout.pdf)

### Hamamatsu C12880MA mini-spectrometer
- [Root page for documentation](https://www.hamamatsu.com/us/en/product/optical-sensors/spectrometers/mini-spectrometer/C12880MA.html)
- [Datasheet for C12880MA and C16767MA](https://www.hamamatsu.com/content/dam/hamamatsu-photonics/sites/documents/99_SALES_LIBRARY/ssd/c12880ma_c16767ma_kacc1226e.pdf)


## Software

### Programming environments
- [Arduino IDE (Integrated Development Environment)](https://www.arduino.cc/en/software)
- [Processing IDE](https://processing.org/download)

### Code

[Arduino code](https://github.com/fenichel/spectrometer/blob/master/arduino_c12880ma_example/arduino_c12880ma_example.ino)
- Reads data from the spectrometer and writes it to serial

[Processing code](https://github.com/groupgets/c12880ma/blob/master/processing_plot_c12880ma/processing_plot_c12880ma.pde)
 - Reads data from serial and displays a colorful graph

## Tools

- Multimeter
- Oscilloscope
- Serial monitor
- Compiler
- The internet
- NHS
- Rachel
- Each other

## Want to build and run this yourself?
Hamamatsu breakout board
- [Buy from groupgets](https://groupgets.com/products/hamamatsu-c12880ma-breakout-board)
- [Buy from digikey](https://www.digikey.com/en/products/detail/groupgets-llc/BO-HAMA-C12880-V2-SENSOR/14306449)

Arduino Uno
- [Buy from Arduino](https://store-usa.arduino.cc/products/arduino-uno-rev3)
