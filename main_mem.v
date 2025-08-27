module main_mem (
	input clk,
	input mem_read, mem_write,  //control signal for reading and writing
	input [31:0] address,   //addres to where to write or read
	input [31:0] write_data,   //data that should be written
	input [31:0] mem_data,   //Data that should be read
	
	
	output reg mem_ready,  //signal when data is ready
	);
	
	reg[31:0] ram [0:1023];   //4Kb RAM (1024 WORDS) 	
	
	always @(posedge clk) begin
		mem_ready <= 1'b;  //always ready
		if (mem_read) mem_data <= ram[address >> 2];  // read word (>>2 for byte to word addr).
        	if (mem_write) ram[address >> 2] <= write_data;  // Write word.
    	end
    
    	initial begin  // load program (ram[0] = instr1).
        	integer i;
        	for (i = 0; i < 1024; i = i + 1) ram[i] = 0;
    	end
endmodule
