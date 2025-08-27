module forwarding_unit (
	input [4:0] id_ex_rs1,   //resut from the ID/EX latch 
	input [4:0] id_ex_rs2.   //result from the ID/EX latch
	input [4:0] ex_mem_rd,   //this is the actual result from ex_mem because we have to check whether the current rs1 or rs2 need the newly executed value (refer notes for better und.)
	input [4:0] mem_wb_rd,  // this is the same as before if "data hazard" occurs where the computed value is stored in last stage, we bring it back to EX thats the logic
	input ex_mem_reg_write   //its a control signal, it turns 1 if forwarding is done from EX_MEM unit
	input mem_wb_reg_write  //same like before, turns 1 if forwarding is done from MEM_Wb unit
	
	output reg [1:0] forward_a,  // this is basically to manipute the MUX
	output reg [1:0] forward_b,
	
	//why do we need a mux??  so that the ALU know whether to take input from rs1/rs2 or immediate value or EX_MEM stage or MEM_WB stage
	);
	
	always @ (*) begin
		 forward_a = 2'b00;   // default '00' take value from ID/EX latch 
		 forward_b =2'b00;  
		 
		 if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) forward_a = 2'b01;  //forward if match and not x0 (x0 is always 0, no need).
        	 if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) forward_b = 2'b01;  // Why: Same for rs2.


        	 // MEM/WB forward (if no EX/MEM match)
        	 if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1) && !(ex_mem_reg_write && (ex_mem_rd == id_ex_rs1))) forward_a = 2'b10;  
        	 if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2) && !(ex_mem_reg_write && (ex_mem_rd == id_ex_rs2))) forward_b = 2'b10;
        end
endmodule  
