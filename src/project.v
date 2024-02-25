/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// Top module
module tt_um_accelshark_psg (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] mix_l;
    wire [7:0] mix_r;
    wire [7:0] voice0123_enable;
    wire [7:0] voice0123_octave;
    wire [7:0] voice0_pitch;
    wire [7:0] voice1_pitch;
    wire [7:0] voice2_pitch;
    wire [7:0] voice3_pitch;
    wire [7:0] voice01_volume;
    wire [7:0] voice23_volume;
    // ========================================================================
    // Control logic
    // ========================================================================
    tt_um_accelshark_psg_control control(
        // Input signals
        .strobe(ui[0]),
        .address(ui[1]),
        .data_high(ui[2]),
        .da(ui[6:3]),

        // Control outputs
        .voice0123_enable(voice0123_enable),
        .voice0123_octave(voice0123_octave),
        .voice0_pitch(voice0_pitch),
        .voice1_pitch(voice1_pitch),
        .voice2_pitch(voice2_pitch),
        .voice3_pitch(voice3_pitch),
        .voice01_volume(voice01_volume),
        .voice23_volume(voice23_volume),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    // ========================================================================
    // Voices
    // ========================================================================
    wire [4:0] mix_l0;
    wire [4:0] mix_r0;
    wire [4:0] mix_l1;
    wire [4:0] mix_r1;
    wire [4:0] mix_l2;
    wire [4:0] mix_r2;
    wire [4:0] mix_l3;
    wire [4:0] mix_r3;
    // Voice 0
    tt_um_accelshark_psg_voice voice_0(
        .mix_l(mix_l0),
        .mix_r(mix_r0),

        .pan(voice0123_enable[1:0]),
        .octave(voice0123_octave[1:0]),
        .pitch(voice0_pitch),
        .volume(voice01_volume[3:0]),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    // Voice 1
    tt_um_accelshark_psg_voice voice_0(
        .mix_l(mix_l1),
        .mix_r(mix_r1),

        .pan(voice0123_enable[3:2]),
        .octave(voice0123_octave[3:2]),
        .pitch(voice1_pitch),
        .volume(voice01_volume[7:4]),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    // Voice 2
    tt_um_accelshark_psg_voice voice_0(
        .mix_l(mix_l2),
        .mix_r(mix_r2),

        .pan(voice0123_enable[5:4]),
        .octave(voice0123_octave[5:4]),
        .pitch(voice2_pitch),
        .volume(voice23_volume[3:0]),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    // Voice 3
    tt_um_accelshark_psg_voice voice_0(
        .mix_l(mix_l3),
        .mix_r(mix_r3),

        .pan(voice0123_enable[7:6]),
        .octave(voice0123_octave[7:6]),
        .pitch(voice3_pitch),
        .volume(voice23_volume[7:4]),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    // Sum up voices
    assign mix_l = {mix_l0[4], 2'b00, mix_l0[3:0], 1'b0} +
                   {mix_l1[4], 2'b00, mix_l1[3:0], 1'b0} +
                   {mix_l2[4], 2'b00, mix_l2[3:0], 1'b0} +
                   {mix_l3[4], 2'b00, mix_l3[3:0], 1'b0};
    assign mix_r = {mix_r0[4], 2'b00, mix_r0[3:0], 1'b0} +
                   {mix_r1[4], 2'b00, mix_r1[3:0], 1'b0} +
                   {mix_r2[4], 2'b00, mix_r2[3:0], 1'b0} +
                   {mix_r3[4], 2'b00, mix_r3[3:0], 1'b0};
    // ========================================================================
    // I2S interfacing
    // ========================================================================
    tt_um_accelshark_psg_i2s i2s(
        // Mix input signals
        .mix_l(mix_l),
        .mix_r(mix_r),

        // I2S output signals
        .mclk(uo_out[0]),
        .lrck(uo_out[1]),
        .sclk(uo_out[2]),
        .sdata(uo_out[3]),

        // Global signals
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out[7:4]  = 4'b0000;
    assign uio_out = 0;
    assign uio_oe  = 0;
endmodule
