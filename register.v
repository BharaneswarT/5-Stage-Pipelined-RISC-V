module register_file(
    input clk,
    input reg_write,     // control signal tells to whether to read or write in register file
    input [4:0] rs1, rs2,        // source register 2^5 =32register 
    input [4:0] rd,       // destination register (where we want to write)
    input [31:0] write_data,      //the data we want to write in rd
    output [31:0] rs1_val, rs2_val  // read values coming out or rs1,rs2
);
    reg [31:0] regs [0:31];  // 32 registers of 32bit width
    assign rs1_val = (rs1 == 0) ? 0 : regs[rs1];    // x0 is always zero, if not giving the respecting values stored in the register 
    assign rs2_val = (rs2 == 0) ? 0 : regs[rs2];
    
    always @(posedge clk) begin
    
   	//writing into register
        if (reg_write && rd != 0) regs[rd] <= write_data;//can't wirte in x0
    end
    
    // sets all the register to 0 initially
    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
        	regs[i] = 0;
        	end
    end
endmodule
