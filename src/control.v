/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// The sound generator's control logic
module tt_um_accelshark_psg_control (
    input  wire       strobe,   // write a 4-bit nybble
    input  wire       address,  // high if it's an address bit
    input  wire       data_high,  // high if it's the high nybble
    input  wire [3:0] da,       // nybble input

    output wire [7:0] voice0123_enable,
    output wire [7:0] voice0123_octave,
    output wire [7:0] voice0_pitch,
    output wire [7:0] voice1_pitch,
    output wire [7:0] voice2_pitch,
    output wire [7:0] voice3_pitch,
    output wire [7:0] voice01_volume,
    output wire [7:0] voice23_volume,

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg [3:0] r_current_address = 4'h0;
    reg [7:0] r_current_data = 8'h00;
    reg [7:0] r_voice0123_enable = 8'h00;
    reg [7:0] r_voice0123_octave = 8'h00;
    reg [7:0] r_voice0_pitch = 8'h00;
    reg [7:0] r_voice1_pitch = 8'h00;
    reg [7:0] r_voice2_pitch = 8'h00;
    reg [7:0] r_voice3_pitch = 8'h00;
    reg [7:0] r_voice01_volume = 8'h00;
    reg [7:0] r_voice23_volume = 8'h00;
    // ========================================================================
    // Write data nybble
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r_current_data <= 8'h00;
        else if(ena & strobe & !address) begin
            if(data_high)
                r_current_data[7:4] <= da;
            else
                r_current_data[3:0] <= da;
        end
    end
    // ========================================================================
    // Write address nybble
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r_current_address <= 4'h0;
        else if(ena & strobe & address)
            r_current_address <= da;
    end
    // ========================================================================
    // Write registers
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_voice0123_enable <= 8'h00;
            r_voice0123_octave <= 8'h00;
            r_voice0_pitch <= 8'h00;
            r_voice1_pitch <= 8'h00;
            r_voice2_pitch <= 8'h00;
            r_voice3_pitch <= 8'h00;
            r_voice01_volume <= 8'h00;
            r_voice23_volume <= 8'h00;
        end else if(ena & strobe & !address) begin
            case (r_current_address)
                4'h0: r_voice0123_enable <= r_current_data;
                4'h1: r_voice0123_octave <= r_current_data;
                4'h2: r_voice0_pitch <= r_current_data;
                4'h3: r_voice1_pitch <= r_current_data;
                4'h4: r_voice2_pitch <= r_current_data;
                4'h5: r_voice3_pitch <= r_current_data;
                4'h6: r_voice01_volume <= r_current_data;
                4'h7: r_voice23_volume <= r_current_data;
                default: ; 
            endcase
        end
    end
    // ========================================================================
    // Out registers
    // ========================================================================
    assign voice0123_enable = r_voice0123_enable;
    assign voice0123_octave = r_voice0123_octave;
    assign voice0_pitch = r_voice0_pitch;
    assign voice1_pitch = r_voice1_pitch;
    assign voice2_pitch = r_voice2_pitch;
    assign voice3_pitch = r_voice3_pitch;
    assign voice01_volume = r_voice01_volume;
    assign voice23_volume = r_voice23_volume;
endmodule
