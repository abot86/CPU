/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */

module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    wire [31:0] FD_PC, DX_PC, PC_plus;
    wire [31:0] FD_IR, DX_IR, XM_IR, MW_IR;
    wire [31:0] A, B, inB;
    wire [31:0] MW_O, XM_O;
    wire [31:0] ALUout;
    wire Cout_PCinc;

// Fetch
	register PC(.q(address_imem), .d(PC_plus), .clk(clock), .en(1'b1), .clr(1'b0));

    adder PCplus(.A(address_imem), .B(32'b0), .Cin(1'b1), .S(PC_plus), .Cout(Cout_PCinc));

// Decode
    // Define FD latch
    register FDPC(.q(FD_PC), .d(PC_plus), .clk(~clock), .en(1'b1), .clr(1'b0));
    register FDIR(.q(FD_IR), .d(q_imem), .clk(~clock), .en(1'b1), .clr(1'b0));

    assign ctrl_writeEnable = 1'b1;
    assign ctrl_writeReg = MW_IR[26:22];
    assign ctrl_readRegA = FD_IR[21:17];
    assign ctrl_readRegB = FD_IR[16:12];
    assign data_writeReg = MW_O;

// Execute
    // Define DX latch
    register DXPC(.q(DX_PC), .d(FD_PC), .clk(~clock), .en(1'b1), .clr(1'b0));
    register DXIR(.q(DX_IR), .d(FD_IR), .clk(~clock), .en(1'b1), .clr(1'b0));
    register DXA(.q(A), .d(data_readRegA), .clk(~clock), .en(1'b1), .clr(1'b0));
    register DXB(.q(B), .d(data_readRegB), .clk(~clock), .en(1'b1), .clr(1'b0));

    // Immediate
    wire I;
    assign I = ~DX_IR[31] & ~DX_IR[30] & DX_IR[29] & ~DX_IR[28] & DX_IR[27];

    wire [31:0] immediate;
    assign immediate [16:0] = DX_IR[16:0];
    assign immediate [31:17] = DX_IR[16] ? 15'b111111111111111 : 15'b0;
    assign inB = I ? immediate : B;

    // Opcode
    wire [4:0] ALUopcode;
    assign ALUopcode = I ? 5'b0 : DX_IR[6:2];

    // Shamt
    wire [4:0] shamt;
    assign shamt = I ? 5'b0 : DX_IR[11:7];

    alu ALU(.data_operandA(A), .data_operandB(inB), 
        .ctrl_ALUopcode(ALUopcode), .ctrl_shiftamt(shamt), 
        .data_result(ALUout), 
        .isNotEqual(), .isLessThan(), .overflow());

// Memory
    // Define XM latch
    register XMIR(.q(XM_IR), .d(DX_IR), .clk(~clock), .en(1'b1), .clr(1'b0));
    register XMO(.q(XM_O), .d(ALUout), .clk(~clock), .en(1'b1), .clr(1'b0));

    
    
// Writeback
    // Define MW latch
    register MWIR(.q(MW_IR), .d(XM_IR), .clk(~clock), .en(1'b1), .clr(1'b0));
    register MWO(.q(MW_O), .d(XM_O), .clk(~clock), .en(1'b1), .clr(1'b0));

endmodule
