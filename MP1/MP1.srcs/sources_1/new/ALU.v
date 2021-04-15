`timescale 1ns / 1ps

module ALU(
    input [2:0] Alu_op,
    input A,
    input B,
    output [31:0] Alu_out
    );
    
    always@(A or B) begin
        case(Alu_op)
            3'b000: Alu_out = A + B;
            3'b001: 
        endcase
        
    
    end
    
    
endmodule
