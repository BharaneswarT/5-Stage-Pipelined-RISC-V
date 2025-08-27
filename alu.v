module alu(
	input [31:0] a,   //register rs1
	input [31:0] b,    //register rs2
	input [3:0] alu_op,   // op code from ID_EX latch
	input [2:0] fun3,  
	input [6:0] fun7,
	
	
	output reg [31:0] result,  //computed result
	output zero,   // if result =1 then ,zero =1  for BEQ/BNE branch
	output lt_signed, // 1 if a<b (signed) (BLT/BGE) 
	output lt_unsigned, //1 if a<b (unsigned) BLTU/BGEU
	);
	
	assign zero = (result==0);  //zero flag for BEQ/BNE
	assign lt_signed = $signed(a) < $signed(b);    // for BLT/ BGE
	assign lt_unsigned = a<b ; //for unsigned opr. BLTU/BGEU
	
	always @ (*) begin
		casez ({fun7,fun3,alu_op})    //based on this key, ALU know what to do whether to add or sub, etc...
		
		//arithmetic operatins
		{7'b0000000, 3'b000, 4'b????}: result = a+b;   // ADDITION operatin, "????" <== dont care operation
		{7'b0100000, 3'b000, 4'b????}: result = a-b;  //subtraction
		
		//logical operation
		{7'b0000000, 3'b111, 4'b????}: result = a & b;  // bitwise AND
            	{7'b0000000, 3'b110, 4'b????}: result = a | b;  // bitwise OR
            	{7'b0000000, 3'b100, 4'b????}: result = a ^ b;  // bitwise XOR
            	
            	// Shifts (b[4:0] for amount)
            	{7'b0000000, 3'b001, 4'b????}: result = a << b[4:0];  //Left shift, lower 5 bits is enough to represent 31 which can make shifts posssible, if we use all then same num 
            	{7'b0000000, 3'b101, 4'b????}: result = a >> b[4:0];  // SRL/SRLI Right logical shift
            	{7'b0100000, 3'b101, 4'b????}: result = $signed(a) >>> b[4:0];  // SRA/SRAI Right arithmetic (sign extend) >>> = arithmetic shift (sign-extends) >> = logical shift (fills with 0).
            	
            	// Set Less Than
            	{7'b0000000, 3'b010, 4'b????}: result = lt_signed ? 1 : 0;  // SLT/SLTI Signed compare to 1/0
            	{7'b0000000, 3'b011, 4'b????}: result = lt_unsigned ? 1 : 0;  // SLTU/SLTIU Unsigned

		default: result = 0;
	endcase
	end
endmodule 	
	
	
