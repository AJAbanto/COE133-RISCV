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
    
    initial begin
        clk <= 0;
        nrst <= 0;
        inst <= 32'b0;
        rdata <= 32'b0;
        #5;
        nrst <= 1;
        #20;
        //R-type , add $1, $1 , $1
        inst <= 32'b0000000_00001_00001_000_00001_0110011;
        #20;
    end
    
endmodule
