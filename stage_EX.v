module stage_EX(
	input clk, reset,
	input stall, flush,   
	
	//from ID_EX latch
	input [31:0] id_ex_pc,    //PC from ID/EX for branch target (pc + imm) or JAL link (pc + 4).
    	input [31:0] id_ex_rs1_val,  // rs1 value from regs, ALU operand A or JALR base.
    	input [31:0] id_ex_rs2_val,  // rs2 value, ALU operand B or store data (latched to MEM).
    	input [31:0] id_ex_imm,  // immediate, for ALU B (if alu_src=1) or branch/jump offset.
    	input [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd,  //  Reg numbers. For forwarding checks and latch rd to WB.
    	input id_ex_alu_src,  // 1=use imm for ALU B, 0=rs2. For I-type (addi/load) vs R-type (add).
    	input [3:0] id_ex_alu_op,  // base ALU control. Selects add/sub/etc.
    	input id_ex_mem_read, id_ex_mem_write, id_ex_reg_write,  // Controls. Pass to MEM/WB (load/store).
    	input id_ex_branch, id_ex_jal, id_ex_jalr,  // Branch/jump types.Enable branch/jump logic.
    	input [2:0] id_ex_funct3,  // For branch (BEQ/BNE) or shifts/compares. Subtype selection.
    	input [6:0] id_ex_funct7,  
    	
    	//from forwarding unit
    	input [31:0] ex_mem_alu_result,  //result from EX_MEM unit 
    	input [31:0] mem_wb_data,  //result from MEM_WB unit 
    	input [4:0] ex_mem_rd, mem_wb_rd,    //compare with rs1 or rs2 for forwarding
    	input ex_mem_reg_write, mem_wb_reg_write,  //control singal for whether writing is done or not
    	
    	
    	output reg [31:0] ex_mem_pc,  //latched pc
    	output reg [31:0] ex_mem_alu_result,   //ALU result is latched
    	output reg [31:0] ex_mem_rs2_val,    //data to stored in latch
    	output reg [4:0] ex_mem_rd,   //for WB register write
    	output reg ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write, //control signals for  MEM_EX latch
    	
    	//output for stall control
    	output reg branch_taken,  //turns 1 when branch is take, so that we could flush the IF and ID stages
    	output reg jump_out,   //to stall
    	output reg [31:0] jmp_tar,   //new pc target
    	);
    	
    	
    	wire [1:0] forward_a, forward_b;         //this connect to the ALU
    	wire [31:0] alu_a, alu_b, alu_result_temp;  //stores result 
    	wire alu_zero, alu_lt_signed, alu_lt_unsigned;   //has the signals
    	
    	//Forwarding unit connections
	forwarding_unit  fwd ( .id_ex_rs1 (id_ex_rs1), .id_ex_rs2(id_ex_rs2), .ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd), 
	.ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write ), .forward_a(forward_a), .forward_b(forward_b)
	);
	
	
	assign alu_a = forward_a == 2'b01) ? ex_mem_alu_result : (forward_a == 2'b10) ? mem_wb_data : id_ex_rs1_val;  // Forwarded rs1
	assign alu_b = id_ex_alu_src ? id_ex_imm : (forward_b == 2'b01) ? ex_mem_alu_result : (forward_b == 2'b10) ? mem_wb_data : id_ex_rs2_val;  //alu_src chooses, then forward
	
	//ALU conntections
	alu alu_inst( .a(alu_a), .b(alu_b), .alu_op(id_ex_alu_op), .fun3(id_ex_funct3), .fun7(id_ex_funct7), .result(alu_result_temp), .zero(alu_zero), .lt_signed(alu_lt_signed), 
	.lt_unsigned(alu_lt_unsigned) );
	
	//branch or jump logic 
	reg [31:0] temp_alu_result; 
    	always @(*) begin
        	temp_alu_result = alu_result_temp;  // Default ALU result.
        	
        	//logic for branch detection 
        	branch_taken = 	id_ex_branch ? (
        		(id_ex_funct3 == 3'b000 && alu_zero) ||  // BEQ
            		(id_ex_funct3 == 3'b001 && !alu_zero) ||  // BNE
            		(id_ex_funct3 == 3'b100 && alu_lt_signed) ||  // BLT
            		(id_ex_funct3 == 3'b101 && !alu_lt_signed) ||  // BGE
            		(id_ex_funct3 == 3'b110 && alu_lt_unsigned) ||  // BLTU
            		(id_ex_funct3 == 3'b111 && !alu_lt_unsigned)    // BGEU
       		 ) : 0;
       		 
       		 jump_out = branch_taken || id_ex_jal || id_ex_jalr;  // Why: Overall redirect signal.

        	 // Target
        	 jmp_tar = id_ex_jalr ? (alu_a + id_ex_imm) & ~1 : id_ex_pc + id_ex_imm;  // JALR uses rs1 + imm (clear LSB for word align), others pc + imm.

                 // JAL/JALR link: override result with pc + 4
         	 if (id_ex_jal || id_ex_jalr) temp_alu_result = id_ex_pc + 4;  // rd gets return address.
     	 end

    	 // EX/MEM Latch
    	 always @(posedge clk or posedge reset) begin  	 	
        	if (reset) begin
        		ex_mem_pc <= 0; ex_mem_alu_result <= 0; ex_mem_rs2_val <= 0; ex_mem_rd <= 0;
            		ex_mem_mem_read <= 0; ex_mem_mem_write <= 0; ex_mem_reg_write <= 0;
         	end else if (flush) begin
         		ex_mem_pc <= 0; ex_mem_alu_result <= 0; ex_mem_rs2_val <= 0; ex_mem_rd <= 0;
            		ex_mem_mem_read <= 0; ex_mem_mem_write <= 0; ex_mem_reg_write <= 0;
        	end else if (stall) begin
            		// Hold all values
            		ex_mem_pc <= ex_mem_pc;
            	 	ex_mem_alu_result <= ex_mem_alu_result; 
        	end else begin
            		ex_mem_pc <= id_ex_pc;
            		ex_mem_alu_result <= temp_alu_result;  // with link override if jump.
            		ex_mem_rs2_val <= id_ex_rs2_val;  // not forwarded, as stores need original rs2.
            		ex_mem_rd <= id_ex_rd;
            		ex_mem_mem_read <= id_ex_mem_read;
            		ex_mem_mem_write <= id_ex_mem_write;
            		ex_mem_reg_write <= id_ex_reg_write;
        	end
    	end
endmodule
        
        
        
        
        
        
        
        
        
        
        
        























