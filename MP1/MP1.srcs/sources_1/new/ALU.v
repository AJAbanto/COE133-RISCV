`timescale 1ns / 1ps

///////////////////////////NOTES///////////////////////////////
//this ALU was designed based on the single cycle 
//MIP processor shown in Computer Organization and Design
//by Patterson and Hennesy
///////////////////////////////////////////////////////////////


///////// ALUOp Definitions////////
`define ALU_add     2'b000
`define ALU_sub     2'b001
`define ALU_and     2'b010
`define ALU_or      2'b011
///////////////////////////////////


module ALU(
    input [2:0] Alu_op,
    input [31:0] A,
    input [31:0] B,
    output zero,
    output [31:0] Alu_res
    );
    
    reg [31:0] res_o;
    reg zero_o;
    
    //ALU arithmetic
    always@(A or B or Alu_op) begin
        case(Alu_op)
            `ALU_add: res_o <= A + B; //Add
            `ALU_sub: res_o <= A - B; //sub
            `ALU_and: res_o <= A & B; //bit-wise and
            `ALU_or: res_o <= A | B; //bit-wise or
        endcase
    end
    
    //Zero for conditional Branch
    always@(*)begin
        if((A - B) == 32'b0) zero_o <= 1'b1;
        else zero_o <= 1'b0; 
    end
    
    
    assign Alu_res = res_o;
    assign zero = zero_o;
    
endmodule
