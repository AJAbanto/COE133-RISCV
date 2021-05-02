`timescale 1ns / 1ps

module regfile(
    input           clk,
    input           nrst,
    
    //read 
    input   [4:0]   rd_addr1,
    input   [4:0]   rd_addr2,
    output  [63:0]  rdata1,
    output  [63:0]  rdata2,
    
    //write
    input   [4:0]   wr_addr,
    input   [63:0]  wrdata, 
    input           wr_en
    
    );
    reg [63:0]  gen_reg[31:0]; //32-bit general purpose register
    
    assign rdata1 = gen_reg[rd_addr1];
    assign rdata2 = gen_reg[rd_addr2];
    
    always@(posedge clk)begin
        if(!nrst) begin
            //reset all generalpurpose registers
            gen_reg[0] <= 64'b0;
            gen_reg[1] <= 64'b0;
            gen_reg[2] <= 64'b0;
            gen_reg[3] <= 64'b0;
            gen_reg[4] <= 64'b0;
            gen_reg[5] <= 64'b0;
            gen_reg[6] <= 64'b0;
            gen_reg[7] <= 64'b0;
            gen_reg[8] <= 64'b0;
            gen_reg[9] <= 64'b0;
            gen_reg[10] <= 64'b0;
            gen_reg[11] <= 64'b0;
            gen_reg[12] <= 64'b0;
            gen_reg[13] <= 64'b0;
            gen_reg[14] <= 64'b0;
            gen_reg[15] <= 64'b0;
            gen_reg[16] <= 64'b0;
            gen_reg[17] <= 64'b0;
            gen_reg[18] <= 64'b0;
            gen_reg[19] <= 64'b0;
            gen_reg[20] <= 64'b0;
            gen_reg[21] <= 64'b0;
            gen_reg[22] <= 64'b0;
            gen_reg[23] <= 64'b0;
            gen_reg[24] <= 64'b0;
            gen_reg[25] <= 64'b0;
            gen_reg[26] <= 64'b0;
            gen_reg[27] <= 64'b0;
            gen_reg[28] <= 64'b0;
            gen_reg[29] <= 64'b0;
            gen_reg[30] <= 64'b0;
            gen_reg[31] <= 64'b0;
            
        end
        else begin
        
            //Writing operation
            if(wr_en) gen_reg[wr_addr] <= wrdata;       //write data from input
            else gen_reg[wr_addr] <= gen_reg[wr_addr];  //latch
           
            
        end
    end
endmodule
