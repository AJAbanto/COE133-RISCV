`timescale 1ns / 1ps

module regfile(
    input           clk,
    input           nrst,
    
    //read 
    input   [4:0]   rd_addr1,
    input   [4:0]   rd_addr2,
    output  [31:0]  rdata1,
    output  [31:0]  rdata2,
    
    //write
    input   [4:0]   wr_addr,
    input   [31:0]  wrdata, 
    input           wr_en
    
    );
    reg [31:0]  gen_reg[31:0]; //32-bit general purpose register
    reg [31:0]  rdata1_o;
    reg [31:0]  rdata2_o;
    
    //connect output registers to the outside
//    assign rdata1 = rdata1_o;
//    assign rdata2 = rdata2_o;
    
    assign rdata1 = gen_reg[rd_addr1];
    assign rdata2 = gen_reg[rd_addr2];
    
    always@(posedge clk)begin
        if(!nrst) begin
            //reset all generalpurpose registers
            gen_reg[0] <= 32'b0;
            gen_reg[1] <= 32'b0;
            gen_reg[2] <= 32'b0;
            gen_reg[3] <= 32'b0;
            gen_reg[4] <= 32'b0;
            gen_reg[5] <= 32'b0;
            gen_reg[6] <= 32'b0;
            gen_reg[7] <= 32'b0;
            gen_reg[8] <= 32'b0;
            gen_reg[9] <= 32'b0;
            gen_reg[10] <= 32'b0;
            gen_reg[11] <= 32'b0;
            gen_reg[12] <= 32'b0;
            gen_reg[13] <= 32'b0;
            gen_reg[14] <= 32'b0;
            gen_reg[15] <= 32'b0;
            gen_reg[16] <= 32'b0;
            gen_reg[17] <= 32'b0;
            gen_reg[18] <= 32'b0;
            gen_reg[19] <= 32'b0;
            gen_reg[20] <= 32'b0;
            gen_reg[21] <= 32'b0;
            gen_reg[22] <= 32'b0;
            gen_reg[23] <= 32'b0;
            gen_reg[24] <= 32'b0;
            gen_reg[25] <= 32'b0;
            gen_reg[26] <= 32'b0;
            gen_reg[27] <= 32'b0;
            gen_reg[28] <= 32'b0;
            gen_reg[29] <= 32'b0;
            gen_reg[30] <= 32'b0;
            gen_reg[31] <= 32'b0;
            
        end
        else begin
        
            //Writing operation
            if(wr_en) gen_reg[wr_addr] <= wrdata;       //write data from input
            else gen_reg[wr_addr] <= gen_reg[wr_addr];  //latch
           
            
        end
    end
endmodule
