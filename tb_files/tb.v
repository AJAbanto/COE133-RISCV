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
    reg     [20:0]  jal_immediate;
    
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
    //-Integrate Instruction memory
    //-Integrate memody instructions
    initial begin
        clk <= 0;
        nrst <= 0;
        inst <= 32'b0;
        rdata <= 32'b0;
        jal_immediate <= 21'b111111111111111110100; //-12 (negative offset)
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
        inst <= {jal_immediate[20],jal_immediate[10:1],jal_immediate[11],jal_immediate[19:12],5'b10,7'b1101111};
        #10;
        //NOP
        inst <= 32'b0;
        
    end
    
endmodule
