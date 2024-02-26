/*
 * Copyright (c) 2024 Roland Metivier
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

/// A clock divider by 2
module tt_um_accelshark_psg_divider (
    output wire       clk_div,  // signal at half the rate of "clk"
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    reg r_clk_div = 1'b1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            r_clk_div <= 1'b1;
        else
            r_clk_div <= !r_clk_div;
    end
    assign clk_div = r_clk_div & ena;
endmodule
