<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is an 8-bit programmable sound generator that generates square waves.

## External hardware

Use a [PmodI2S2][pmodi2s2] as the "Output Pmod".

[pmodi2s2]: https://digilent.com/reference/pmod/pmodi2s2/reference-manual

## Register updating

- Assert `strobe` high to update the 4-bit address or data nybble.
- Assert `address` high when strobing the register address. Assert `address` low when strobing the register data.
- Assert `data_high` high when strobing the 4-bit upper nybble of the data. 
- `da0` is bit 4 or bit 0.
- `da1` is bit 5 or bit 1.
- `da2` is bit 6 or bit 2.
- `da3` is bit 7 or bit 3.

## Register map

### `0x0`: Enable
- Bit 0: Voice 0 enable left channel
- Bit 1: Voice 0 enable right channel
- Bit 2: Voice 1 enable left channel
- Bit 3: Voice 1 enable right channel
- Bit 4: Voice 2 enable left channel
- Bit 5: Voice 2 enable right channel
- Bit 6: Voice 3 enable left channel
- Bit 7: Voice 3 enable right channel
### `0x1`: Octave Select
- Bit 0: Voice 0 select octave division bit 0
- Bit 1: Voice 0 select octave division bit 1
- Bit 2: Voice 1 select octave division bit 0
- Bit 3: Voice 1 select octave division bit 1
- Bit 4: Voice 2 select octave division bit 0
- Bit 5: Voice 2 select octave division bit 1
- Bit 6: Voice 3 select octave division bit 0
- Bit 7: Voice 3 select octave division bit 1
#### Notes
- Octave 3 (`2'b11`): Do not divide the pitch
- Octave 2 (`2'b10`): Divide the pitch by 2
- Octave 1 (`2'b01`): Divide the pitch by 4
- Octave 0 (`2'b00`): Divide the pitch by 8
### `0x2`: Voice 0 Pitch
Sets the pitch counter reset value of Voice 0, bit 7 being the most significant bit.
### `0x3`: Voice 1 Pitch
Sets the pitch counter reset value of Voice 1, bit 7 being the most significant bit.
### `0x4`: Voice 2 Pitch
Sets the pitch counter reset value of Voice 2, bit 7 being the most significant bit.
### `0x5`: Voice 3 Pitch
Sets the pitch counter reset value of Voice 3, bit 7 being the most significant bit.
### `0x6`: Voice 0/1 Volume
- Bits 0-3: Voice 0 volume, 15 (`4'hF`) being highest volume and 0 (`4'h0`) being silent.
- Bits 4-7: Voice 1 volume, 15 (`4'hF`) being highest volume and 0 (`4'h0`) being silent.
### `0x7`: Voice 2/3 Volume
- Bits 0-3: Voice 2 volume, 15 (`4'hF`) being highest volume and 0 (`4'h0`) being silent.
- Bits 4-7: Voice 3 volume, 15 (`4'hF`) being highest volume and 0 (`4'h0`) being silent.