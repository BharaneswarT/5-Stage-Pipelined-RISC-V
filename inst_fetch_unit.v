module inst_fetch_unit (
	input clk,reset, bew,bneq,bge,blt,jump,
	input [31:0] imm_address,
	input [31:0] imm_address_jump,
	output reg [31:0] pc, current_pc
	);
