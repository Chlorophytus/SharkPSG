/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// The sound generator's voice
module tt_um_accelshark_psg_voice (
    output wire [4:0] mix_l,      // voice mix audio signal
    output wire [4:0] mix_r,      // voice mix audio signal

    input wire [1:0]  pan,        // bit 1 right, bit 0 left
    input wire [1:0]  octave,     // select divider
    input wire [7:0]  pitch,      // select pitch
    input wire [3:0]  volume,      // select volume

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    localparam OCTAVE_PREDIVIDE = 2;

    wire [OCTAVE_PREDIVIDE + 3:0] octaves;
    wire oclk;

    reg [7:0] r_pitch_accum = 8'h00;
    reg r_square_state = 1'b0;
    // ========================================================================
    // Octave dividers
    // ========================================================================
    assign octaves[0] = clk;
    genvar octave_i;
    generate
        for (octave_i = 1; octave_i <= (OCTAVE_PREDIVIDE + 3); octave_i = octave_i + 1) begin
            tt_um_accelshark_psg_divider gen_divider(
                .rst_n(rst_n),
                .ena(ena),
                .clk(octaves[octave_i - 1]),
                .clk_div(octaves[octave_i]),
            );
        end
    endgenerate

    always @(*) begin
        case(octave)
            2'b11: oclk = octaves[OCTAVE_PREDIVIDE + 0];
            2'b10: oclk = octaves[OCTAVE_PREDIVIDE + 1];
            2'b01: oclk = octaves[OCTAVE_PREDIVIDE + 2];
            2'b00: oclk = octaves[OCTAVE_PREDIVIDE + 3];
            default: ;
        endcase
    end
    // ========================================================================
    // Phase accumulation
    // ========================================================================
    wire do_phase;
    assign do_phase = !(|r_pitch_accum);
    always @(posedge oclk or negedge rst_n) begin
        if(!rst_n)
            r_pitch_accum <= 8'h00;
        else if(do_phase)
            r_pitch_accum <= pitch;
        else
            r_pitch_accum <= r_pitch_accum - 8'h01;
    end
    // ========================================================================
    // Square wave generation
    // ========================================================================
    always @(posedge oclk or negedge rst_n) begin
        if(!rst_n)
            r_square_state <= 1'b0;
        else if(do_phase)
            r_square_state <= !r_square_state;
    end
    // ========================================================================
    // Square wave mix
    // ========================================================================
    always @(*) begin
        case ({pan[0], volume})
            5'h11: mix_l = r_square_state ? 1  : -1;
            5'h12: mix_l = r_square_state ? 2  : -2;
            5'h13: mix_l = r_square_state ? 3  : -3;
            5'h14: mix_l = r_square_state ? 4  : -4;
            5'h15: mix_l = r_square_state ? 5  : -5;
            5'h16: mix_l = r_square_state ? 6  : -6;
            5'h17: mix_l = r_square_state ? 7  : -7;
            5'h18: mix_l = r_square_state ? 8  : -8;
            5'h19: mix_l = r_square_state ? 9  : -9;
            5'h1A: mix_l = r_square_state ? 10 : -10;
            5'h1B: mix_l = r_square_state ? 11 : -11;
            5'h1C: mix_l = r_square_state ? 12 : -12;
            5'h1D: mix_l = r_square_state ? 13 : -13;
            5'h1E: mix_l = r_square_state ? 14 : -14;
            5'h1F: mix_l = r_square_state ? 15 : -15;
            default: mix_l = 0;
        endcase
    end
    always @(*) begin
        case ({pan[1], volume})
            5'h11: mix_r = r_square_state ? 1  : -1;
            5'h12: mix_r = r_square_state ? 2  : -2;
            5'h13: mix_r = r_square_state ? 3  : -3;
            5'h14: mix_r = r_square_state ? 4  : -4;
            5'h15: mix_r = r_square_state ? 5  : -5;
            5'h16: mix_r = r_square_state ? 6  : -6;
            5'h17: mix_r = r_square_state ? 7  : -7;
            5'h18: mix_r = r_square_state ? 8  : -8;
            5'h19: mix_r = r_square_state ? 9  : -9;
            5'h1A: mix_r = r_square_state ? 10 : -10;
            5'h1B: mix_r = r_square_state ? 11 : -11;
            5'h1C: mix_r = r_square_state ? 12 : -12;
            5'h1D: mix_r = r_square_state ? 13 : -13;
            5'h1E: mix_r = r_square_state ? 14 : -14;
            5'h1F: mix_r = r_square_state ? 15 : -15;
            default: mix_r = 0;
        endcase
    end
endmodule
