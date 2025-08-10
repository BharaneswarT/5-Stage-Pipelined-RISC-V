module stage_IF(
	input clk, reset,   
	input stall,          // if stall =1 then the current process is put to a hold or holds the current value
	input flush,           //  IF/ID is set to NOP so that the previous executed instruction is been flushed since its not needed. Typically used in JMP instruction
	input [31:0] pc_in,     //instruction from pc_register
	input [31:0] instr_in,    //instruction from cache memory
	
	output reg [31:0] if_id_pc,  //output of the stage_IF
	output reg [31:0] if_id_instr  //to ID stage
	
	);
	
	
	always @ (posedge clk or posedge reset)
	begin 
		if (reset) begin
			if_id_pc <= 32'd0;
			if_id_instr <= 32'h00000013;   // NOP is been set
		end
		
		else if (flush) begin
			if_id_instr <= 32'h00000013;
			if_id_pc <= pc_in;
		end
		
		else if (stall) begin
			if_id_instr <= if_id_instr;           //holds the instruction
			if_id_pc <= if_id_pc;
		end
		
		else begin
			if_id_pc <= pc_in;
			if_id_instr <= instr_in;
		end
	end
endmodule
			
