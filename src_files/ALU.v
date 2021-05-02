`timescale 1ns / 1ps

///////////////////////////NOTES///////////////////////////////
//this ALU was designed based on the single cycle 
//MIP processor shown in Computer Organization and Design
//by Patterson and Hennesy
///////////////////////////////////////////////////////////////

`include "def.v"


module ALU(
    input [2:0] Alu_op,
    input [63:0] rs1,
    input [63:0] rs2,
    output zero,
    output [63:0] Alu_res
    );
    

    reg [63:0] res_o;
    reg zero_o;
    
    //ALU arithmetic
    always@(*) begin
        case(Alu_op)
            `ALU_add: res_o <= rs1 + rs2;   //Add
            `ALU_sub: res_o <= rs1 - rs2;   //sub
            `ALU_and: res_o <= rs1 & rs2;   //bit-wise and
            `ALU_or:  res_o <= rs1 | rs2;    //bit-wise or
            `ALU_xor: res_o <= rs1 ^ rs2;   //bit-wise xor
            
            `ALU_addi:begin                 //Addi
                //since  immediate is signed we need to check if we should take the 2's complement first
                if(rs2[63] == 1'b1) res_o <= rs1 - (~rs2 + 1);
                else res_o <= rs1 + rs2;
            end
            `ALU_slt: begin                 //set destination to 1 if rs1 less than rs2
                if(rs1 < rs2) res_o <= 64'b1;
                else res_o <= 64'b0;
            end
        endcase
    end
    
    //Zero for conditional Branch
    always@(*)begin
        if((rs1 - rs2) == 64'b0) zero_o <= 1'b1;
        else zero_o <= 1'b0; 
    end
    
    
    assign Alu_res = res_o;
    assign zero = zero_o;
    
endmodule
