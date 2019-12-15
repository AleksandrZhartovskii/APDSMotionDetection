# APDS Motion Detection

VHDL project to recognize gestures using APDS-9960 sensor.

## Prerequisites

### Hardware

1. Altera DE2 Cyclone II EP2C35F672 board
1. APDS-9960 (GY-9960) sensor

### Software

1. Quartus II
2. Sigasi Studio 4 **or** Eclipse IDE

## Features

### Supported gestures

Project supports recognition of 6 basic gestures:

1. Up
2. Down
3. Left
4. Right
5. Near
6. Far

### Display modes

One 7-segment indicator is used to display recognized gesture,
while all other indicators are initialized with "turned off" state.

Indicator can display gesture in either alphabetic or numeric mode,
that you are free to toggle.

## Roadmap

#### V1.x

1. Nios II Integration
2. Simulation and Testbench Verification
