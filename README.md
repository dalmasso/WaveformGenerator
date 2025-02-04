# Waveform Generator

This module implements a simple ROM-based Waveform Generator Module handling Sine, Triangle, Sawtooth and Square waveform according to the selection signal. Note that the selection signal can be updated at any time, the waveform output will immediatly switch to the selected waveform type. User can set the following parameters:
- ROM Address Bits length
- ROM Data Bits length

The waveform output frequency is defined by:  

  
$waveform_{Freq} = \frac{InputClock_{Freq}}{2^{ROMAddressBits}}$

<img width="439" alt="waveformgenerator" src="https://github.com/user-attachments/assets/a23d1a29-ecde-42a1-9042-df711a26a5e0" />

## Usage

Simply set the ROM parameters (i.e., ROM Address & Data bit length).

## Waveform Generator Pin Description

### Generics

| Name | Description |
| ---- | ----------- |
| rom_addr_bits | ROM Address Bits length |
| rom_data_bits | ROM Data Bits length |

### Ports

| Name | Type | Description |
| ---- | ---- | ----------- |
| i_sys_clock | Input | System Input Clock |
| i_waveform_select | Input | Waveform Generator Type Selector ("00": Sine, "01": Triangle, "10": Sawtooth, "11": Square)|
| i_waveform_step | Input | Waveform Step Value (Value Range: [0;2<sup>rom_addr_bits</sup>-1]) |
| o_waveform | Output | Waveform Signal Ouput Value (Value Range: [0;2<sup>rom_data_bits</sup>-1]) |
