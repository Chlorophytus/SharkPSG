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

    input wire  [15:0] mix_l,    // Mixed left-channel input to send to I2S DAC
    input wire  [15:0] mix_r,    // Mixed right-channel input to send to I2S DAC

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    localparam DIVIDE_SCLK = 4;
    localparam DIVIDE_SCLK_LRCK = 5;
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
                .clk_div(divide_by[divide_i])
            );
        end
    endgenerate
    assign mclk = divide_by[0];
    assign sclk = divide_by[DIVIDE_SCLK];
    assign lrck = divide_by[DIVIDE_ALL];
    // ========================================================================
    // Mixing
    // ========================================================================
    reg [16:0] r_mix_hold_l = 17'h00000;
    reg [16:0] r_mix_hold_r = 17'h00000;
    // mix left
    always @(posedge sclk or negedge rst_n) begin
        if(!rst_n)
            r_mix_hold_l <= 17'h00000;
        else if(lrck)
            r_mix_hold_l <= {1'b0, mix_l};
        else
            r_mix_hold_l <= {r_mix_hold_l[15:0], 1'b0};
    end
    // mix right
    always @(posedge sclk or negedge rst_n) begin
        if(!rst_n)
            r_mix_hold_r <= 17'h00000;
        else if(!lrck)
            r_mix_hold_r <= {1'b0, mix_r};
        else
            r_mix_hold_r <= {r_mix_hold_r[15:0], 1'b0};
    end
    assign sdata = (lrck ? r_mix_hold_r[16] : r_mix_hold_l[16]) & ena;
endmodule
