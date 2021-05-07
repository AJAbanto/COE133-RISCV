`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////
//   NOTE: 
//        This testbench is for stimulating the 
//        instructions manually and it should only
//        be used to check if control signals are correct
//        and if the instructions are being decoded correctly.
//        This is why the instruction memory output inst 
//        does not connect to the processor module.
//
//        To test the complete setup which includes the instruction memory
//        use tb_main.v as testbench
/////////////////////////////////////////////////////////////////////////////////////
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
    
    //instruction memory module parameters
    parameter       INST_MEM_DEPTH      = 512;
    parameter       INST_MEM_ADDR_WIDE  = 30;
    
    //Output of instruction memory module;
    wire    [31:0]  inst_mem_o;
    
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
    
    
    // NOTE: that in this test bench the Instructions are stimulated 
    // manually. There will be a separate testbench in which intructions will be 
    // sourced from the actual instruction memory module.
    
    //Instantiating instruction memory module
    mem_model #(INST_MEM_DEPTH,INST_MEM_ADDR_WIDE) 
        inst_mem(
        .addr(pc[31:2]),
        .rdata(inst_mem_o)
    );
    
    //To Do:
    //-Integrate instruction memory module
    
    initial begin
        clk <= 0;
        nrst <= 0;
        inst <= 32'b0;
        jal_imm <= 21'b111111111111111110100;   // -12 (negative offset)
        bra_imm <= {{10{1'b1}},3'b100};         // -4 (negative offset)    
        
        sd_imm  <= 12'b100000;                  // Byte address offset of 32
        sw_imm  <= 12'b101000;                  // Byte address offset of 40
        sh_imm  <= 12'b110000;                  // Byte address offset of 48
                                                
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
        
        ////////////////////Setup for Memory testing/////////////////////
        //I-type, addi $5,64
        inst <= 32'b000001000000_00000_000_00101_0010011; 
        #10;
        /////////////////////////////////////////////////////////////////
        
        //////////////////////BRANCH INSTRUCTIONS/////////////////////////
        
        //--------NEGATIVE OFFSET--------
        
        //J-type, jal $1, -12
        //Note: at the end of this clock cycle PC should equal to 12
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
         
        //--------------------------NOTE:---------------------
        // in I-type [31:20] is alloted for Immediate and in a load instruction this is provides the immediate to be 
        // added to the contents of rs1 to get the effective address (addr) to be sent to the Data memory.
        // REMEMBER that this immediate is a byte offset not a memory address offset (i.e 64-bit)
        
        //--------POSITIVE OFFSET--------
        
        //I-type, ld $3,  0($0) (load contents of memory address [0] into $3)
        inst <= 32'b000000000000_00000_011_00011_0000011; 
        #10;
        //I-type, ld $3,  8($0) (load contents of memory address [1] into $3)
        inst <= 32'b000000001000_00000_011_00011_0000011; 
        #10;
        //I-type, ld $3, 16($0) (load contents of memory address [2] into $3)
        inst <= 32'b000000010000_00000_011_00011_0000011; 
        #10;
        
        //--------NEGATIVE OFFSET--------
        //I-type, ld $3, -40($5) (load contents of memory address [3] into $3) 
        //NOTE: $5 should contain 8 so to 
        inst <= 32'b111111011000_00101_011_00011_0000011; 
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
        
        
        //////////////Setup for Other load instructions//////////////
        
        //------------Insert signed value to $4-------------
        //I-type, addi $4,-64
        inst <= 32'b111111000000_00000_000_00100_0010011; 
        #10;
        
        //------Store value of $4 to memory address 7-------
        //NOP
        inst <= 32'b0;               //set instruction to 0x0 so that we avoid unnecessary operations
        sd_imm  <= 12'b111000;       //set sd byte address 56 (should be memory address 7) for the next clock cycle  
        #10;
        //S-type, sd $5, 56($0) (save contents of $3 into (0x0 + 4))
        inst <= {sd_imm[11:5],5'b100,5'b0 , 3'b011, sd_imm[4:0],7'b0100011};
        #10;
        /////////////////////////////////////////////////////////////////
       
        ////////////////////OTHER LOAD INSTRUCTIONS//////////////////////
        
        //I-type, lw $4,  56($0) (load word contents of memory address [0] into $3)
        inst <= 32'b000000111000_00000_010_00100_0000011; 
        #10;
        
        //I-type, lwu $4,  56($0) (load word (unsigned) contents of memory address [0] into $3)
        inst <= 32'b000000111000_00000_110_00100_0000011; 
        #10;
        
        //I-type, lh $4,  56($0) (load halfword contents of memory address [0] into $3)
        inst <= 32'b000000111000_00000_001_00100_0000011; 
        #10;
        
        //I-type, lhu $4,  56($0) (load halword (unsigned) contents of memory address [0] into $3)
        inst <= 32'b000000111000_00000_101_00100_0000011; 
        #10;
        ////////////////////////////////////////////////////////////////
        
        
        //NOP
        inst <= 32'b0;
        
    end
    
endmodule
