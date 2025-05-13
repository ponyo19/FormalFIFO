import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fifo(dut):
    
    clock = dut.in_clk
    reset = dut.in_rst
    cocotb.start_soon(Clock(clock, 1, units="ns").start()) # Start the clock

    # Apply reset sequence
    reset.value = 0
    await ClockCycles(clock, 2)
    reset.value = 1
    await ClockCycles(clock, 2)
    reset.value = 0

    test_arr = [113, 43, 78, 99, 154, 999]

    dut.in_wen  = 0
    dut.in_ren  = 0

    # Writes
    for value in test_arr:
        dut.in_wdata    = value
        dut.in_wen      = 1
        await ClockCycles(clock, 1)
    dut.in_wen = 0

    # Reads
    for value in test_arr:
        dut.in_ren      = 1
        await ClockCycles(clock, 1)
    dut.in_ren  = 0

    # Reads and Writes
    for value in test_arr:
        dut.in_wdata    = value
        dut.in_wen      = 1
        dut.in_ren      = 1
        await ClockCycles(clock, 1)
    dut.in_wen = 0
    dut.in_ren = 0
