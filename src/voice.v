/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// The sound generator's voice
module tt_um_accelshark_psg_voice (
    output wire [15:0] mix_l,      // voice mix audio signal
    output wire [15:0] mix_r,      // voice mix audio signal

    input wire [1:0]  pan,        // bit 1 right, bit 0 left
    input wire [1:0]  octave,     // select divider
    input wire [7:0]  pitch,      // select pitch
    input wire [3:0]  volume,      // select volume

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    localparam OCTAVE_PREDIVIDE = 5;

    wire [OCTAVE_PREDIVIDE + 3:0] octaves;
    reg [1:0] r_curr_octave = 2'b00;
    wire oclk;

    reg [7:0] r_pitch_accum = 8'h00;
    reg r_square_state = 1'b0;
    reg [15:0] r_mix_l = 0;
    reg [15:0] r_mix_r = 0;
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
                .clk_div(octaves[octave_i])
            );
        end
    endgenerate

    always @(*) begin
        case(octave)
            2'b11: r_curr_octave = 2'b00;
            2'b10: r_curr_octave = 2'b01;
            2'b01: r_curr_octave = 2'b10;
            2'b00: r_curr_octave = 2'b11;
            default: ;
        endcase
    end
    // ========================================================================
    // Phase accumulation
    // ========================================================================
    always @(posedge octaves[OCTAVE_PREDIVIDE + r_curr_octave] or negedge rst_n) begin
        if(!rst_n)
            r_pitch_accum <= 8'h00;
        else if(!(|r_pitch_accum))
            r_pitch_accum <= pitch;
        else
            r_pitch_accum <= r_pitch_accum - 8'h01;
    end
    // ========================================================================
    // Square wave generation
    // ========================================================================
    always @(posedge octaves[OCTAVE_PREDIVIDE + r_curr_octave] or negedge rst_n) begin
        if(!rst_n)
            r_square_state <= 1'b0;
        else if(!(|r_pitch_accum))
            r_square_state <= !r_square_state;
    end
    // ========================================================================
    // Square wave mix
    // ========================================================================
    always @(*) begin
        if(r_square_state)
            r_mix_l =  (16'h0001 << volume);
        else
            r_mix_l = -(16'h0001 << volume);
    end
    always @(*) begin
        if(r_square_state)
            r_mix_r =  (16'h0001 << volume);
        else
            r_mix_r = -(16'h0001 << volume);
    end
    assign mix_l = (ena & pan[0]) ? r_mix_l : 16'h0000;
    assign mix_r = (ena & pan[1]) ? r_mix_r : 16'h0000;
endmodule
