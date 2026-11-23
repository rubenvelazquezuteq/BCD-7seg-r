/*
 * BCD a 7 segmentos — decodificador para display de 7 segmentos
 * IEEE Open Silicon Bootcamp 2026 · UTEQ
 * SPDX-License-Identifier: Apache-2.0
 *
 * Entrada : ui_in[3:0] = dígito BCD (0-9)
 * Salida  : uo_out[6:0] = segmentos {g,f,e,d,c,b,a} (activo alto, cátodo común)
 *           uo_out[7]   = 1 si el dígito no es BCD válido (>9)
 */

`default_nettype none

module tt_um_bcd7seg (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire [3:0] bcd;
    assign bcd = ui_in[3:0];

    // Segmentos: uo_out[6:0] = {g, f, e, d, c, b, a}
    reg [6:0] seg;
    always @(*) begin
        case (bcd)
            4'd0:    seg = 7'b0111111; // 0
            4'd1:    seg = 7'b0000110; // 1
            4'd2:    seg = 7'b1011011; // 2
            4'd3:    seg = 7'b1001111; // 3
            4'd4:    seg = 7'b1100110; // 4
            4'd5:    seg = 7'b1101101; // 5
            4'd6:    seg = 7'b1111101; // 6
            4'd7:    seg = 7'b0000111; // 7
            4'd8:    seg = 7'b1111111; // 8
            4'd9:    seg = 7'b1101111; // 9
            default: seg = 7'b0000000; // 10-15: todo apagado
        endcase
    end

    assign uo_out[6:0] = seg;
    assign uo_out[7]   = (bcd > 4'd9); // bandera de dígito inválido

    // Salidas no usadas a 0
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Lista entradas no usadas para evitar warnings
    wire _unused = &{ena, clk, rst_n, uio_in, 1'b0};

endmodule
