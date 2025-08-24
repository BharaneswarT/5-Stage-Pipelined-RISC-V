module Stall_control(

	//current instruction in DECODE	
	input [4:0] id_rs1, id_rs2,     
	
	
	//ID/EX instruction currently in EX
	input id_ex_mem_read,   
	input [4:0] id_ex_rd,   
	
	//from EX stage (branch/jump is the output then give this
	input branch,
	input ex_jump,   // JAL JALR to solve this one
	
	
	//for sram and dram 
	input icache_stall,    // IF cannot get the instuctin
	input dcache_stall,     //MEM cannot get the instruction
	
	
	// ;) output raa sammy 
	
	output reg   pc_en,     // stall the PC
  	output reg   if_id_en,   // stall if_id_en
  	output reg   id_ex_en,   //stall id_ex_en
  	output reg   ex_mem_en,   //stall ex 
  	output reg   mem_wb_en,   //stall mem

  	output reg   if_id_flush,   //flush IF/ID latch
  	output reg   id_ex_flush    // flush ID/EX latch
  	);
  	
  	
  	
  	
  	
  	// redirect is to find where the jump or branch instruction is been carried out returns 1 or 0
  	wire redirect = branch | ex_jump;
  	
  	//to find "data dependency timing"===> "LOAD"
  	 wire load = id_ex_mem_read && (id_ex_rd != 5'd0) && ((id_ex_rd == id_rs1) || (id_ex_rd == id_rs2));
  	
  	
  	
  	
  	
  	always @ (*) begin 
  	//initially no hazards is been observer then GOT NO PROBLEM DUDE
  	
  	pc_en =1'b1;
  	if_id_en =1'b1;
  	id_Ex_en =1'b1;
  	ex_mem_en =1'b1;
  	mem_wb_en =1'b1;
  	
  	if_id_flush =1'b1;
  	id_Ex_flush =1'b1;
  	
  	
  	
  	// JUMP or BRANCH instruction is found 
  	if (redirect) begin 
  		if_id_flush =1'b1;	//flush signal is been sent to IF/ID latch
  		id_ex_flush = 1'b1;	//flush singal is been sent to ID/EX latch
  	end
  	
  	
  	// Main memory stall, HOLD the MEM STAGE 
  	else if (dcache_stall) begin 
  		pc_en = 1'b0;
  		if_id_en = 1'b0;
  		id_ex_en = 1'b0;
  		ex_mem_en=1'b0;
  	end
  	
  	//SRAM stall 
  	else if (icache_stall) begin
  		pc_en=1'b0;
  		if_id_en=1'b0;
  	end
  	
  end
 endmodule 
  		
