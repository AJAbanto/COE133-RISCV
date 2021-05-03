`timescale 1ns / 1ps

`include "def.v"
    


module control(
    input  [31:0] instr,
    output ALUsrc,
    output [2:0] ALUOp,
    output [1:0] memtoreg,
    output mem_wr,
    output bne,
    output bra,
    output reg_wr,
    output reg_dst,
    output sd,
    output [7:0] wmask,
    output jump
    );
    
    //Output registers
    reg ALUsrc_o;
    reg [2:0] ALUOp_o;
    reg [1:0] memtoreg_o;
    reg mem_wr_o;
    reg mem_rd_o;
    reg bne_o;
    reg bra_o;
    reg reg_wr_o;
    reg reg_dst_o;
    reg sd_o;
    reg [7:0] wmask_o;
    reg jump_o;
    
    //Connection to outputs
    assign ALUsrc   = ALUsrc_o;
    assign ALUOp    = ALUOp_o;
    assign memtoreg = memtoreg_o;
    assign mem_wr   = mem_wr_o;
    assign bne      = bne_o;
    assign bra      = bra_o;
    assign reg_wr   = reg_wr_o;
    assign reg_dst  = reg_dst_o;
    assign sd       = sd_o; 
    assign wmask    = wmask_o;
    assign jump     = jump_o;
    
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
                memtoreg_o  <= 2'b0;
                mem_wr_o    <= 0;
                bne_o       <= 0;
                bra_o       <= 0;
                reg_wr_o    <= 1;       //enable regwrite 
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 0;
                
                
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
                ALUsrc_o    <= 1;           //  set rs2 of ALU to be from immediate
                ALUOp_o     <= `ALU_addi;
                memtoreg_o  <= 2'b00;       //  store ALU result to register
                mem_wr_o    <= 0;
                bne_o       <= 0;
                bra_o       <= 0;
                reg_wr_o    <= 1;           //  enable regwrite 
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 0;
            end
            
            //Conditional branch (bne and beq) operation
            `COND: begin
                ALUsrc_o    <= 0;   
                memtoreg_o  <= 2'b00;
                mem_wr_o    <= 0;
                bra_o       <= 1;           //  flag branch instruction
                reg_wr_o    <= 0;           // deassert regwrite 
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 0;
                
                //if bne instruction then assert bne flag
                if(funct3 == `BNE)  bne_o <= 1;
                else                bne_o <= 0;
            end
            
            //Unconditional Jump operation
            `JAL: begin
                ALUsrc_o    <= 0;   
                memtoreg_o  <= 2'b10;       //  store (PC+4) to rd
                mem_wr_o    <= 0;
                bra_o       <= 0;
                bne_o       <= 0;   
                reg_wr_o    <= 1;           //  enable regwrite to store (PC+4) 
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 1;           //  flag JAL instruction
            end
            
            
            //Unconditional Jump using immediate + offset operation
            `JALR: begin
                ALUsrc_o    <= 1;           //  Immediate as rs2 source for ALU   
                memtoreg_o  <= 2'b10;       //  store(PC+4) into rd
                mem_wr_o    <= 0;
                bra_o       <= 0;
                bne_o       <= 0;   
                reg_wr_o    <= 1;           //  enable regwrite to store (PC+4) 
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 1;           //  flag JAL instruction
            end
            
            //Load data from memory module
            `LOAD: begin
                ALUsrc_o    <= 1;           //  Immediate as rs2 source for ALU   
                ALUOp_o     <= `ALU_addi;   //  since we are getting the memory address from rs1 + imm
                memtoreg_o  <= 2'b01;       //  store memdata to register
                mem_wr_o    <= 0;
                bra_o       <= 0;
                bne_o       <= 0;   
                reg_wr_o    <= 1;           //  enable regwrite to store loaded data from memory
                reg_dst_o   <= 0;
                wmask_o     <= 8'b00000000;
                sd_o        <= 0;           //  do NOT assert store word flag
                jump_o      <= 0;       
                

            end
            
            //store data  in memory module
            `STORE: begin
                ALUsrc_o    <= 1;           //  Immediate as rs2 source for ALU
                ALUOp_o     <= `ALU_addi;   //  since we are getting the memory address from rs1 + imm
                memtoreg_o  <= 2'b00;       //  actually a dont care
                mem_wr_o    <= 1;           //  write to memory
                bra_o       <= 0;
                bne_o       <= 0;   
                reg_wr_o    <= 0;           //  disable regwrite
                reg_dst_o   <= 0;
                sd_o        <= 1;           //  actually flag the store word instruction
                jump_o      <= 0;       
                
                case(funct3)
                    `SD: wmask_o <= 8'b11111111;  //store all 64-bits of data in mem
                    `SW: wmask_o <= 8'b00001111;  //store only 32-bits of data in mem
                    `SH: wmask_o <= 8'b00000011;  //store only 16-bits of data in mem
                endcase
                
            end
            
            //deassert all signals by default
            default: begin
                ALUsrc_o    <= 0;           //  regfile as source
                memtoreg_o  <= 2'b00;       //  alu as register writedata
                mem_wr_o    <= 0;     
                bra_o       <= 0;
                bne_o       <= 0;   
                reg_wr_o    <= 0;           //  disable regwrite
                reg_dst_o   <= 0;
                sd_o        <= 0;
                wmask_o     <= 8'b00000000;
                jump_o      <= 0;       
            end
            
        endcase
    end
    
    
endmodule
