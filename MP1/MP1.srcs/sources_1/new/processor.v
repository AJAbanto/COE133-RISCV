`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2021 00:39:03
// Design Name: 
// Module Name: processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor(
    input [31:0] pc,
    input [31:0] inst,
    input clk,
    input nrst,
    output [31:0] addr,
    output wr_en,
    output [63:0] wdata,
    output [7:0] wmask,
    input [31:0] rdata
    );
endmodule
