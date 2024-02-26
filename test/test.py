# SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@tinytapeout.com>
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# Magic numbers
# These should be what the Verilog localparams are
I2S_DIVIDE_SCLK = 4
I2S_DIVIDE_SCLK_LRCK = 5
VOICE_OCTAVE_PREDIVIDE = 5
# Bus delay can be changed, there's just limits to how fast commands can be sent
BUS_DELAY_CYCLES = 100
# Internally used
INTERNAL_I2S_WORD_RATE = 1 << (I2S_DIVIDE_SCLK + I2S_DIVIDE_SCLK_LRCK)



async def write_command(dut, address: int, data: int):
  """
  Writes a command to the SharkPSG device under test
  
  :param dut: the SharkPSG device under test
  :param int address: the 4-bit address to write to
  :param int data: the 8-bit data to write
  :return: the clock ticks that should have passed
  """
  def get_nybble_hi(what: int):
    return (what & 0xF0) >> 4
  
  def get_nybble_lo(what: int):
    return (what & 0x0F) >> 0

  # Our flags go here
  FLAG_STROBE = 1 << 0
  FLAG_ADDRESS = 1 << 1
  FLAG_DATA_HIGH = 1 << 2

  # NOTE: The DA[3:0] lines are ui_n[6:3] meaning we shift left by 3
  DA_SHIFT_BY = 3

  # Send off address first
  dut._log.info(f"Sending command {data:02x} to address {address:01x}")
  dut.ui_in.value = FLAG_STROBE | FLAG_ADDRESS | (get_nybble_lo(address) << DA_SHIFT_BY)
  await ClockCycles(dut.clk, BUS_DELAY_CYCLES)
  # Send off low nybble of data
  dut.ui_in.value = FLAG_STROBE | (get_nybble_lo(data) << 3)
  await ClockCycles(dut.clk, BUS_DELAY_CYCLES)
  # Send off high nybble of data
  dut.ui_in.value = FLAG_STROBE | FLAG_DATA_HIGH | (get_nybble_hi(data) << DA_SHIFT_BY)
  await ClockCycles(dut.clk, BUS_DELAY_CYCLES)
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, BUS_DELAY_CYCLES)



@cocotb.test()
async def test_sharkpsg_lock_on_left(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 81, units="ns") # We use a 12.288MHz I2S clock
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 10)
  dut.rst_n.value = 1

  await write_command(dut, 0x1, 0x03) # Sound highest octave on voice 0
  await write_command(dut, 0x2, 0xE0) # Sound A440 on voice 0
  await write_command(dut, 0x6, 0x0F) # Sound highest volume on voice 0
  await write_command(dut, 0x0, 0x01) # Sound left PSG channel
  
  MIXDOWN_WORD_L = 0x1FFF 
  MIXDOWN_WORD_R = 0x0000

  dut._log.info(f"Waiting out the remaining L channel...")
  while ((dut.uo_out.value & (1 << 1)) >> 1) == 0:
    await ClockCycles(dut.clk, 1 << I2S_DIVIDE_SCLK)

  dut._log.info(f"Waiting out the remaining R channel...")
  while ((dut.uo_out.value & (1 << 1)) >> 1) == 1:
    await ClockCycles(dut.clk, 1 << I2S_DIVIDE_SCLK)

  dut._log.info(f"=== Checking L channel ===")
  for i in range(15, 0, -1):
    await ClockCycles(dut.clk, 1 << I2S_DIVIDE_SCLK)
    wanted = (MIXDOWN_WORD_L & (1 << i)) >> i
    returned = ((dut.uo_out.value & (1 << 3)) >> 3)
    is_right = ((dut.uo_out.value & (1 << 1)) >> 1)
    dut._log.info(f"Checking L channel: bit {i:01d} wants {wanted}, is {returned}")
    dut._log.info(f"Checking L channel: word select is {is_right}")
    assert is_right == 0
    assert wanted == returned
  
  dut._log.info(f"=== Checking R channel ===")
  for i in range(15, 0, -1):
    await ClockCycles(dut.clk, 1 << I2S_DIVIDE_SCLK)
    wanted = (MIXDOWN_WORD_R & (1 << i)) >> i
    returned = ((dut.uo_out.value & (1 << 3)) >> 3)
    is_right = ((dut.uo_out.value & (1 << 1)) >> 1)
    dut._log.info(f"Checking R channel: bit {i:01d} wants {wanted}, is {returned}")
    dut._log.info(f"Checking R channel: word select is {is_right}")
    assert is_right == 1
    assert wanted == returned
