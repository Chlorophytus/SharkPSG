/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// A stereo 8-bit I2S output
module tt_um_accelshark_psg_i2s (
    output wire       mclk,     // I2S Master Clock
    output wire       lrck,     // I2S Word Select
    output wire       sclk,     // I2S Slave Clock
    output wire       sdata,    // I2S Serial Data

    input wire  [7:0] mix_l,    // Mixed left-channel input to send to I2S DAC
    input wire  [7:0] mix_r,    // Mixed right-channel input to send to I2S DAC

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    localparam DIVIDE_SCLK = 4;
    localparam DIVIDE_SCLK_LRCK = 4;
    localparam DIVIDE_ALL = DIVIDE_SCLK + DIVIDE_SCLK_LRCK;
    // ========================================================================
    // Generate clock dividers
    // ========================================================================
    wire [DIVIDE_ALL:0] divide_by;
    assign divide_by[0] = clk;
    genvar divide_i;
    generate
        for (divide_i = 1; divide_i <= DIVIDE_ALL; divide_i = divide_i + 1) begin
            tt_um_accelshark_psg_divider gen_divider(
                .rst_n(rst_n),
                .ena(ena),
                .clk(divide_by[divide_i - 1]),
                .clk_div(divide_by[divide_i]),
            );
        end
    endgenerate
    assign mclk = divide_by[0];
    assign sclk = divide_by[DIVIDE_SCLK];
    assign lrck = divide_by[DIVIDE_ALL];
    // ========================================================================
    // Mixing
    // ========================================================================
    reg [7:0] r_mix_hold_l = 8'h00;
    reg [7:0] r_mix_hold_r = 8'h00;
    // mix left
    always @(posedge sclk or posedge lrck or negedge rst_n) begin
        if(!rst_n)
            r_mix_hold_l <= 8'h00;
        else if(lrck)
            r_mix_hold_l <= mix_l;
        else
            r_mix_hold_l <= r_mix_hold_l << 1;
    end
    // mix right
    always @(posedge sclk or negedge lrck or negedge rst_n) begin
        if(!rst_n)
            r_mix_hold_r <= 8'h00;
        else if(!lrck)
            r_mix_hold_r <= mix_r;
        else
            r_mix_hold_r <= r_mix_hold_r << 1;
    end
    assign sdata = (lrck ? r_mix_hold_r[7] : r_mix_hold_l[7]) & ena;
endmodule
