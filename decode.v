module decode (
	input [31:0] instr,   //instruction which we've to decode
	
	output reg [6:0] opcode,   //opcode of 7 bits
	output reg [4:0] rd, rs1,rs2,   //register files of 5 bit
	output reg [2:0] fun3,    //function 3 of 3 bits
	output reg [7:0] fun7,    //function of 8 bits
	
	//i need to tell ALU what are you going to perfrom whether its add or sub or something like that.
	//THE UPCOMIN OUTPUT ARE NOTHING BUT CONTROL SINGALS 
	output reg alu_src,     // whether to use immediate value or rs2  1 = imm else 0 = rs2
	output reg [3:0] alu_op,  // what operation should ALU perform
	
	output reg mem_read, mem_write,   //wheter to read or write 
	output reg reg_write,                 // whether to write in register file
	
	//making the control hazards
	output reg branch, jal, jar
	);
	
	assign opcode = instr[6:0];
	assign rd = instr[11:7];
	assign rs1 = instr[14:12];
	assign rs2 = instr[19:15];
	assign fun3 = instr[24:20];
	assign fun7 = instr[31:25];
	
	always @ (*) begin
		//when no cntrol signals are triggered
		alu_src = 0; alu_op = 0; mem_read = 0; mem_write = 0; reg_write = 0; branch = 0; jal = 0; jalr = 0;

		//since RISC V operationof 6 basic instruction R,I,S,B,U,J which is decode from opcode, we now use case statements to decode that
		
		case (opcode)
			
			//pray to god that you read the correct pages from the open source 
			7'b0110011: begin  // R-type instruction (regiester)
				alu_scr =0;
				reg_write =1;
				
				case({func7, func3})
    					{7'b0000000, 3'b000}: alu_op = 4'b0010;  // ADD
    					{7'b0100000, 3'b000}: alu_op = 4'b0110;  // SUB
				endcase
				
			end
			
			// I-type instrcutions (immediate)
			7'b0010011: begin  // I-type (addi/slli/etc.)
                		alu_src = 1; reg_write = 1;
                		case(funct3)
                    			3'b000: alu_op = 4'b0010;  // ADDI
                    			// need to add more stuffs
                		endcase
            		end		
            		
            		//load instructions  (lw/lb/etc.)
            		7'b0000011: begin  
                		alu_src = 1; 
                		mem_read = 1; 
                		reg_write = 1; 
                		alu_op = 4'b0010;  // Add for address and more are ther
            		end
            		
            		//Store instructions (sw/sb)
            		7'b0100011: begin  
                		alu_src = 1; mem_write = 1; alu_op = 4'b0010;
            		end
            		
            		//Branch instructions beq bneq
            		7'b1100011: begin  // Branch (beq/bne/etc.)
                		branch = 1; alu_src = 0; alu_op = 4'b0110;  // Sub for compare
            		end
            		
            		7'b1101111: jal = 1;  // JAL
            		7'b1100111: jalr = 1;  // JALR
            		default: ;  
       		 endcase
    end
endmodule

				
				
	
