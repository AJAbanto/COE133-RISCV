`timescale 1ns / 1ps

module regfile(
    input   [4:0]   rd_addr1,
    input   [4:0]   rd_addr2,
    input   [4:0]   wr_addr,
    input   [31:0]  wrdata, 
    output  [31:0]  rdata1,
    output  [31:0]  rdata2,
    input           reg_wr_en
    );
    reg [31:0]  gen_reg[4:0]; //32-bit general purpose register
    reg [31:0]  rdata1_o;
    reg [31:0]  rdata2_o;
    
    always@(*)begin
        
    end
endmodule
