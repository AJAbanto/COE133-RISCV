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
    wire    [63:0]  rdata;
    
    //data memory module parameters
    parameter       MEM_DATA_DEPTH      = 512;
    parameter       MEM_DATA_ADDR_WIDE  = 29;
    
    //Branch immediates
    reg     [20:0]  jal_imm;
    reg     [12:0]  bra_imm;
    
    //Load/store immediates
    reg     [11:0]  sd_imm;
    reg     [11:0]  sw_imm;
    reg     [11:0]  sh_imm;
    reg     [11:0]  ld_imm;
    
    //Generate clock 
    always #5 clk = ~clk;
    
    
    //Instantiating processor module
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
    
    
    //Instatiating data memory module
    mem_model #(MEM_DATA_DEPTH,MEM_DATA_ADDR_WIDE) 
        data_mem(
        .clk(clk),
        .addr(addr[31:3]),
        .rdata(rdata),
        .wr_en(wr_en),
        .wdata(wdata),
        .wmask(wmask)
    );
    
    
    //To Do:
    //-Test lw,lh,lwu,lhu
    //-Test negative offsets on all store and load instructions
    //-Integrate instruction memory module
    
    initial begin
        clk <= 0;
        nrst <= 0;
        inst <= 32'b0;
        jal_imm <= 21'b111111111111111110100;   // -12 (negative offset)
        bra_imm <= {{10{1'b1}},3'b100};         // -2 (negative offset)    
        sd_imm  <= 12'b100000;                  // 4 (positive offset) (note that this accesses data 4 memory  slots offsets from the base address
                                                // since last 3 bits of the offset are actually ignored

        sw_imm  <= 12'b101000;                  // 5 (positive offset) (note that this accesses data 5 memory  slots offsets from the base address
                                                // since last 3 bits of the offset are actually ignored
                                                
        sh_imm  <= 12'b110000;                  // 6 (positive offset) (note that this accesses data 6 memory  slots offsets from the base address
                                                // since last 3 bits of the offset are actually ignored
                                                
        #5;
        nrst <= 1;
        #10;
        
        //////////////////////ARITHMETIC INSTRUCTIONS///////////////////////
        //I-type, addi $1,3
        inst <= 32'b000000000011_00001_000_00001_0010011; 
        #10;
        //I-type, addi $1,-1
        inst <= 32'b111111111111_00001_000_00001_0010011; 
        #10;
        //R-type , add $1, $1 , $1
        inst <= 32'b0000000_00001_00001_000_00001_0110011;
        #10;
        //R-type , sub $1, $1 , $1
        inst <= 32'b0100000_00001_00001_000_00001_0110011;
        #10;
        ///////////////////////////////////////////////////////////////////
        
        
        //////////////////////BRANCH INSTRUCTIONS/////////////////////////
        
        //--------NEGATIVE OFFSET--------
        
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
        
        /////////////////////////////////////////////////////////////////
        
        
        //////////////////////LOAD INSTRUCTIONS//////////////////////////
        
        //--------POSITIVE OFFSET--------
        
        //I-type, ld $3, 0($0) (load contents of (0x0 + 0) into $3)
        inst <= 32'b000000000000_00000_011_00011_0000011; 
        #10;
        //I-type, ld $3, 1($0) (load contents of (0x0 + 1) into $3)
        inst <= 32'b000000001000_00000_011_00011_0000011; 
        #10;
        //I-type, ld $3, 2($0) (load contents of (0x0 + 2) into $3)
        inst <= 32'b000000010000_00000_011_00011_0000011; 
        #10;
        ////////////////////////////////////////////////////////////////
        
        
        ///////////////////STORE INSTRUCTIONS///////////////////////////
        
        //--------POSITIVE OFFSET--------
        
        //S-type, sd $3, 4($0) (save contents of $3 into (0x0 + 4))
        inst <= {sd_imm[11:5],5'b11,5'b0 , 3'b011, sd_imm[4:0],7'b0100011};
        #10;
        //S-type, sd $3, 5($0) (save contents of $0 into (0x0 + 5))
        inst <= {sw_imm[11:5],5'b0,5'b0 , 3'b011, sw_imm[4:0],7'b0100011};
        #10;
        //S-type, sw $3, 5($0) (save contents of $3 into (0x0 + 5))
        inst <= {sw_imm[11:5],5'b11,5'b0 , 3'b010, sw_imm[4:0],7'b0100011};
        #10;
        //S-type, sd $3, 6($0) (save contents of $0 into (0x0 + 6))
        inst <= {sh_imm[11:5],5'b0,5'b0 , 3'b011, sh_imm[4:0],7'b0100011};
        #10;
        //S-type, sh $3, 6($0) (save contents of $3 into (0x0 + 6))
        inst <= {sh_imm[11:5],5'b11,5'b0 , 3'b1, sh_imm[4:0],7'b0100011};
        #10;
        /////////////////////////////////////////////////////////////////
        
        
        
        //NOP
        inst <= 32'b0;
        
    end
    
endmodule
