`timescale 1ns / 1ps

`include "def.v"
    


module control(
    input [31:0] instr,
    output ALUsrc,
    output [2:0] ALUOp,
    output memtoreg,
    output mem_wr,
    output mem_rd,
    output bne,
    output bra,
    output reg_wr,
    output reg_dst,
    output jal
    );
    
    //Output registers
    reg ALUsrc_o;
    reg [2:0] ALUOp_o;
    reg memtoreg_o;
    reg mem_wr_o;
    reg mem_rd_o;
    reg bne_o;
    reg bra_o;
    reg reg_wr_o;
    reg reg_dst_o;
    reg jal_o;
    
    //Connection to outputs
    assign ALUsrc = ALUsrc_o;
    assign ALUOp = ALUOp_o;
    assign memtoreg = memtoreg_o;
    assign mem_wr = mem_wr_o;
    assign mem_rd = mem_rd_o;
    assign bne = bne_o;
    assign bra = bra_o;
    assign reg_wr = reg_wr_o;
    assign reg_dst = reg_dst_o;
    assign jal = jal_o;
    
    //Instruction control bits
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    
    //Abstracting Instruction bits
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign opcode = instr[6:0];
    
    
    //Change control signals when instruction changes
    always@(instr)begin
        case(opcode)
        
            //Reg-to-reg arithmetic operation
            `ARITH: begin 
                ALUsrc_o    <= 0;
                memtoreg_o  <= 0;
                mem_wr_o    <= 0;
                mem_rd_o    <= 0;
                bne_o       <= 0;
                bra_o       <= 0;
                reg_wr_o    <= 1;   //enable regwrite 
                reg_dst_o   <= 0;
                jal_o       <= 0;
                
                //Choosing ALU Opcode
                case(funct3)
                    `ADD_SUB: begin    
                        //deciding  ALU opcode if add or sub
                        if(funct7 == `SUB) ALUOp_o <= `ALU_sub;
                        else ALUOp_o <= `ALU_add;
                    end
                    `AND:   ALUOp_o <= `ALU_and;
                    `OR:    ALUOp_o <= `ALU_or;
                    `XOR:   ALUOp_o <= `ALU_xor;
                    `SLT:   ALUOp_o <= `ALU_slt;
                endcase
            end
            
            //Reg-immediate operation
            `ADDI: begin
                ALUsrc_o    <= 1;   //set rs2 of ALU to be from immediate
                memtoreg_o  <= 0;
                mem_wr_o    <= 0;
                mem_rd_o    <= 0;
                bne_o       <= 0;
                bra_o       <= 0;
                reg_wr_o    <= 1;   //enable regwrite 
                reg_dst_o   <= 0;
                jal_o       <= 0;
            end
            
            //Conditional branch (bne and beq)
            `COND: begin
                ALUsrc_o    <= 0;   
                memtoreg_o  <= 0;
                mem_wr_o    <= 0;
                mem_rd_o    <= 0;
                bra_o       <= 1;   //flag branch instruction
                reg_wr_o    <= 0;   //enable regwrite 
                reg_dst_o   <= 0;
                jal_o       <= 0;
                
                //if bne instruction then assert bne flag
                if(funct3 == `BNE) bne_o <= 1;
                else bne_o <= 0;
            end
            
            
        endcase
    end
    
    
endmodule
