module pc_register(
	input clk,reset,      //for every clock the operations starts to begun executing and if reset =1, pc starts from 0
	input stall,           // if hazard occurs (data / control / structural) it holds the pc by not incrementing it
	input jump               // what if jump instruction occurs since doing PC = PC+4  makes no sense 
	input[31:0] jmp_tar      //this is primarly to jump to the necessary instructions
	input [31:0] pc_inc,   // this is basically for the adder.. since [PC = PC+4] this value is stored in the next_pc
	output reg [31:0] pc    // essentially the output should be stored nahh	
	);
	
	wire [31:0] next_pc  ;// o/p value of mux
	
	//mux is been created
	assign next_pc = jump ? jmp_tar : pc_inc;
	
	always @ (posedge clk or posedge reset) 
	begin 	
		if(reset) 
			pc <= 32'b0;           // if reset =1 : pc =0
		else if (!stall )
			pc <= next_pc;           // if not stall then pc = next_pc
	end
	
	//this upcoming session is for debugging purpose, just to see what happens during each cycle 
	always @(posedge clk) begin
        if (!reset) $display("Cycle %0t: PC = 0x%h, Next_PC = 0x%h, Jump = %b, Stall = %b", $time, pc, next_pc, jump, stall);
    end
endmodule 
