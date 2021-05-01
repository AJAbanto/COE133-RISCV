`timescale 1ns / 1ps


module tb();

    reg             clk;
    reg             nrst;
    reg     [31:0]  inst;
    wire    [31:0]  pc;
    wire    [31:0]  addr;
    wire            wr_en;
    wire    [63:0]  wdata;
    wire    [7:0]   wmask;
    reg     [31:0]  rdata;
    
    //Branch immediates
    reg     [20:0]  jal_imm;
    reg     [12:0]  bra_imm;
    
    //Generate clock 
    always #5 clk = ~clk;
    
    
    //Instantiating
    processor UUT(
        .clk(clk),
        .nrst(nrst),
        .inst(inst),
        .pc(pc),
        .addr(addr),
        .wr_en(wr_en),
        .wdata(wdata),
        .wmask(wmask),
        .rdata(rdata)
    );
    
    
    //To Do:
    //-Test Conditional branching
    //-Integrate instruction memory module
    //-Integrate memory module
    //-Integrate Load and save instructions
    initial begin
        clk <= 0;
        nrst <= 0;
        inst <= 32'b0;
        rdata <= 32'b0;
        jal_imm <= 21'b111111111111111110100; //-12 (negative offset)
        bra_imm <= {{10{1'b1}},3'b100};        //- 2 (negative offset)                    
        #5;
        nrst <= 1;
        #10;
        //I-type, addi $1,1
        inst <= 32'b000000000001_00001_000_00001_0010011; 
        #10;
        //I-type, addi $1,2
        inst <= 32'b000000000010_00001_000_00001_0010011; 
        #10;
        //R-type , add $1, $1 , $1
        inst <= 32'b0000000_00001_00001_000_00001_0110011;
        #10;
        //R-type , sub $1, $1 , $1
        inst <= 32'b0100000_00001_00001_000_00001_0110011;
        #10;
        //J-type, jal $1, -12
        //Note: at this point PC + 4 should be equal to 18
        inst <= {jal_imm[20],jal_imm[10:1],jal_imm[11],jal_imm[19:12],5'b10,7'b1101111};
        #10;
        //B-type, beq $1, $0, -4 (branch should be taken)
        //Note: at this clock cycle PC + 4 should still be equal to 8 but 4 in the next
        inst <= {bra_imm[12],bra_imm[10:5],5'b00001,5'b00000,3'b000,bra_imm[4:1],bra_imm[11],7'b1100011};
        #10;
        //B-type, bne $1, $0, -4 (branch should NOT be taken)
        //Note: at this clock cycle PC + 4 should still be equal to 4 but 0 in the next
        inst <= {bra_imm[12],bra_imm[10:5],5'b00001,5'b00000,3'b001,bra_imm[4:1],bra_imm[11],7'b1100011};
        #10;
        //NOP
        inst <= 32'b0;
        
    end
    
endmodule
