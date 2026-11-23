# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
# Adaptado para BCD a 7 segmentos (Bootcamp Open Silicon UTEQ)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# Patrones esperados: uo_out[6:0] = {g,f,e,d,c,b,a} (activo alto)
SEGMENTOS = {
    0: 0b0111111,
    1: 0b0000110,
    2: 0b1011011,
    3: 0b1001111,
    4: 0b1100110,
    5: 0b1101101,
    6: 0b1111101,
    7: 0b0000111,
    8: 0b1111111,
    9: 0b1101111,
}


@cocotb.test()
async def test_bcd7seg(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Dígitos válidos 0-9
    for digito, esperado in SEGMENTOS.items():
        dut.ui_in.value = digito
        await ClockCycles(dut.clk, 1)
        obtenido = int(dut.uo_out.value)
        assert (obtenido & 0x7F) == esperado, \
            f"BCD {digito}: esperado {esperado:07b}, obtenido {obtenido & 0x7F:07b}"
        assert (obtenido & 0x80) == 0, \
            f"BCD {digito}: la bandera INV debe estar en 0"
        dut._log.info(f"BCD {digito} -> {esperado:07b} OK")

    # Dígitos inválidos 10-15: bandera INV (uo_out[7]) en 1
    for invalido in range(10, 16):
        dut.ui_in.value = invalido
        await ClockCycles(dut.clk, 1)
        assert int(dut.uo_out.value) & 0x80, \
            f"BCD {invalido}: la bandera INV debe estar en 1"
        dut._log.info(f"BCD {invalido} -> inválido OK")
