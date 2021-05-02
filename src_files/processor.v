`timescale 1ns / 1ps

module processor(
    input           clk,
    input           nrst,
    input   [31:0]  inst,
    output  [31:0]  pc,
    output  [31:0]  addr,
    output          wr_en,
    output  [63:0]  wdata,
    output  [7:0]   wmask,
    input   [63:0]  rdata
    );
    
    //////////////////WIRES//////////////////
    //Control signal wires
    wire        ALUsrc;
    wire [2:0]  ALUOp;
    wire [1:0]  memtoreg;
    wire        bne;
    wire        bra;
    wire        reg_wr;
    wire        reg_dst;
    wire        jump;
    
    //ALU wires
    wire [63:0] rs1;
    wire [63:0] rs2;
    
    wire [63:0] alu_res;
    wire        zero;
    
    //PC wires
    reg     [31:0]  PC;
    
    //Regfile wires
    wire [4:0]  reg_rd_addr1;
    wire [4:0]  reg_rd_addr2;
    wire [63:0] reg_rdata1;
    wire [63:0] reg_rdata2;
    
    wire [4:0] reg_wr_addr;
    
    //for connecting to register that actually stores the data
    wire [63:0] reg_wrdata_in;
    reg  [63:0] reg_wrdata;
    
    /////////////////////////////////////////
    
    
    ///////////Instruction decoding///////////
    
    //Immediate decoding for conditional and unconditional branch
    wire    [31:0]  jal_imm;     //decoded and sign-extended immediate for jal
    wire    [31:0]  jalr_imm;    //decoded and sign-extended immediate for jalr
    wire    [31:0]  bra_imm;     //decoded and sign-extended immediate for branch
    
    //Immediate decoding for Register-immediate instructions
    wire    [63:0]  addi_imm;    //decoded and sign-extended immediate for Register-Immediate arithmetic
    
    assign jal_imm = {{12{inst[31]}},  {inst[31],inst[19:12],inst[20],inst[30:21],1'b0}};   // decodes SB-type format instruction encoding 
    assign jalr_imm = {{20{inst[31]}}, {inst[31:20]}};                                      // decodes I-type format instruction encoding
    assign bra_imm = {{19{inst[31]}},  {inst[31],inst[7],inst[30:25],inst[11:8],1'b0}};     // decodes B-type format instruction encoding
    assign addi_imm = {{52{inst[31]}}, {inst[31:20]}};                                      // decodes I-type format instruction encoding 
    
    //Instruction control bits
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    
    //Abstracting Instruction bits
    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign opcode = inst[6:0];
    
    //Connect alu to decoded instructions
    //Register read address
    assign reg_rd_addr1 = inst[19:15];
    assign reg_rd_addr2 = inst[24:20];
    
    //valid for I-type and R-type
    assign reg_wr_addr = inst[11:7];
    
    /////////////////////////////////////////
    
    //////////////Program Counter////////////
    
    
    //Program Counter logic
    always@(posedge clk)begin
        if(!nrst) PC <= 32'b0;
        else begin
            if(jump)begin
                if(opcode == `JALR) begin
                    //if Jalr, add PC with decoded immediate and address from readdata1 from regfile
                    //Note: we take into consideration the sign of the immediate
                    if(jalr_imm[31] == 1'b1) PC <= PC - (~jalr_imm + 1) + reg_rdata1;    
                    else PC <= PC <= PC + jalr_imm + reg_rdata1;
                end else begin
                    
                    //if Jal, add PC with sign extended offset
                    //Note: we take into consideration the sign 
                    if(jal_imm[31] == 1'b1) PC <= PC - (~jal_imm + 1);                                 
                    else PC <= PC +jal_imm;
                end
            end
            else begin
                if(bne && ~zero) begin
                    //If BNE and not zero, branch to PC + offset
                    //Note: we take into consideration the sign of the immediate
                    if(bra_imm[31] == 1'b1) PC <= PC - (~bra_imm + 1);
                    PC <= PC + bra_imm;        
                    
                end
                else if(bra && zero) begin
                
                    //else if BEQ and zero, branch to PC + offset
                    //Note: we take into consideration the sign of the immediate
                    if(bra_imm[31] == 1'b1) PC <= PC - (~bra_imm + 1);
                    else PC <= PC + bra_imm;    
                end
                else PC <= PC + 3'd4;         //just increment PC if no branch or jump is taken
            end
        end
    end
    
    //attach to output
    assign pc = PC;
    
    /////////////////////////////////////////
    
    //////////////Control block//////////////
    
    
    //Instantiation 
    control c0(
        .instr(inst),
        .ALUsrc(ALUsrc),
        .ALUOp(ALUOp),
        .memtoreg(memtoreg),
        .mem_wr(wr_en),
        .bne(bne),
        .bra(bra),
        .reg_wr(reg_wr),
        .reg_dst(reg_dst),
        .jump(jump)
    );
    
    /////////////////////////////////////////
    
    //////////////////ALU////////////////////
    
    //Choose source of rs2 (should assert if instruction is Register-Immediate)
    assign rs2 = (ALUsrc)? addi_imm : reg_rdata2;    //Take if 1 Immidiate in I-type format
                                                     //else take source from register data
    assign rs1 = reg_rdata1;                        //Take next operand from register file
    //Instantiation
    ALU a0(
        .Alu_op(ALUOp),
        .rs1(rs1),
        .rs2(rs2),
        .zero(zero),
        .Alu_res(alu_res)
    );
    
    
    /////////////////////////////////////////
    
    ////////////////Reg File/////////////////

    
    //Instantiation
    regfile r0(
        .clk(clk),
        .nrst(nrst),
        
        .wr_en(reg_wr),
        .wr_addr(reg_wr_addr),
        .wrdata(reg_wrdata_in),
        
        .rd_addr1(reg_rd_addr1),
        .rd_addr2(reg_rd_addr2),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2)
        
    );
    
    assign reg_wrdata_in = reg_wrdata;
    //Logic for choosing data to write back to register
    always@(*)begin
        case(memtoreg)
            2'b00: reg_wrdata <= alu_res;   //get writeback data from alu
            2'b01: reg_wrdata <= rdata;     //get writeback data from memory module
            2'b10: reg_wrdata <= PC + 3'd4; //get writeback data from (PC + 4) 
        endcase
    end
    
    /////////////////////////////////////////
    
    //////////////Data memory////////////////
    
    /////////////////////////////////////////
endmodule
