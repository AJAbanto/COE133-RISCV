

////////Opcode Definitions/////////
`define ARITH           7'b0110011
`define ADDI            7'b0010011 
`define COND            7'b1100011
`define JAL             7'b1101111
`define JALR            7'b1100111
`define LOAD            7'b0000011
`define STORE           7'b0100011
///////////////////////////////////


////////Funct3 Definitions/////////
//--------Arithmetic------------
`define ADD_SUB         3'b000
`define AND             3'b111
`define OR              3'b110
`define XOR             3'b100
`define SLT             3'b010
//------Conditional Jump-------
`define BNE             3'b001
//---------Load word----------
`define LD              3'b011
`define LW              3'b010
`define LWU             3'b110
`define LH              3'b001
`define LHU             3'b101
//---------Store word----------
`define SD              3'b011
`define SW              3'b010
`define SH              3'b001
///////////////////////////////////

///////Funct7 Definitions//////////
//------Arithmetic------------
`define SUB             7'b0100000
///////////////////////////////////


///////// ALUOp Definitions////////
`define ALU_add     3'b000
`define ALU_sub     3'b001
`define ALU_and     3'b010
`define ALU_or      3'b011
`define ALU_xor     3'b100
`define ALU_slt     3'b101
///////////////////////////////////