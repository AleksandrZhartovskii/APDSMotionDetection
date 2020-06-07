# APDS Motion Detection

FPGA project to recognize gestures using APDS-9960 sensor.

## Prerequisites

### Hardware

1. Altera DE2 Cyclone II EP2C35F672 board
1. APDS-9960 (GY-9960) sensor

### Software

1. Quartus II
2. Sigasi Studio 4 **or** Eclipse IDE

## Installing

To install the sensor, connect it to Expansion Header 1 (GPIO 0) of
the board as shown on picture below.

<p align="center">
  <img width="390" src="https://raw.githubusercontent.com/AleksandrZhartovskii/APDSMotionDetection/e833c31b726ddeeb1877e46759a51573d9fd24ee/installing_sensor.png">
</p>

## Features

### Supported Gestures

Project supports recognition of 6 basic gestures:

1. Up
2. Down
3. Left
4. Right
5. Near
6. Far

### Display Modes

One 7-segment indicator is used to display recognized gesture,
while all other indicators are initialized with "turned off" state.

Indicator can display gesture in either alphabetic or numeric mode
that you are free to toggle with SW16 board switch.

### Async Reset

You can reset project state with SW17 board switch signal. To
do it turn the switch on and return it back.

## Demo

Alphabetic mode ('down' gesture):

<p align="center">
  <img width="500" src="https://raw.githubusercontent.com/AleksandrZhartovskii/APDSMotionDetection/e833c31b726ddeeb1877e46759a51573d9fd24ee/demo_alphabetic.jpg">
</p>

Numeric mode ('down' gesture):

<p align="center">
  <img width="500" src="https://raw.githubusercontent.com/AleksandrZhartovskii/APDSMotionDetection/e833c31b726ddeeb1877e46759a51573d9fd24ee/demo_numeric.jpg">
</p>

## Internal Structure

<p align="center">
  <img width="100%" src="https://raw.githubusercontent.com/AleksandrZhartovskii/APDSMotionDetection/e833c31b726ddeeb1877e46759a51573d9fd24ee/internal_structure.png">
</p>

Or see the scheme without compression in PDF
[here](https://raw.githubusercontent.com/AleksandrZhartovskii/APDSMotionDetection/e833c31b726ddeeb1877e46759a51573d9fd24ee/internal_structure.pdf).

## Roadmap

#### v1.x

1. Nios II Integration
2. Simulation and Testbench Verification
