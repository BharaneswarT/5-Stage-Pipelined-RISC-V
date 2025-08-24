module stage_ID(
    input clk, reset, stall, flush,
    input [31:0] if_id_pc, //pc value passed from IF 
    input [31:0] if_id_instr,  //32 bit instruction
    
    input mem_wb_reg_write,   //control singal say to write into the register
    input [4:0] mem_wb_rd,     //desitination register where to write
    input [31:0] mem_wb_write_data,  //the content/data that should be written into the register
    
    output reg [31:0] id_ex_pc, //current pc
    output reg [31:0] id_ex_rs1_val, id_ex_rs2_val,//the values that we read from the register
    output reg [31:0]  id_ex_imm,//the immediate value which we calculate (i have no idea why this is needed..........................)
    output reg [4:0] id_ex_rd, //destination register number
    output reg [4:0]id_ex_rs1, id_ex_rs2,   //source register
    output reg id_ex_alu_src,//whether imm or rs2 for the ALU
    
    output reg [3:0] id_ex_alu_op, //what operation should ALU perform
    output reg [3:0] id_ex_mem_read, id_ex_mem_write, //memory control signals 
    output reg [3:0] id_ex_reg_write, //signal to whether write back into reg or not 
    output reg [3:0]id_ex_branch, id_ex_jal, id_ex_jalr,//control hazard
    
    output [4:0] id_rs1, id_rs2  // To Stall Controller
);
    
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire alu_src, [3:0] alu_op, mem_read, mem_write, reg_write, branch, jal, jalr;
    wire [31:0] rs1_val, rs2_val, imm;
    
    decoder dec(.instr(if_id_instr), .opcode(opcode), .rd(rd), .rs1(rs1), .rs2(rs2), .funct3(funct3), .funct7(funct7), .alu_src(alu_src), .alu_op(alu_op), .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write), .branch(branch), .jal(jal), .jalr(jalr));
    imm_gen ig(.instr(if_id_instr), .opcode(opcode), .imm(imm));
    register_file rf(.clk(clk), .reg_write(mem_wb_reg_write), .rs1(rs1), .rs2(rs2), .rd(mem_wb_rd), .write_data(mem_wb_write_data), .rs1_val(rs1_val), .rs2_val(rs2_val));
    
    //telling the stall controller that DEI im having the signals that tell you when to work
    assign id_rs1 = rs1; 
    assign id_rs2 = rs2;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // NOP defaults (controls = 0)
            id_ex_pc <= 0;
            id_ex_rs1_val <= 0;
            id_ex_rs2_val <= 0;
            id_ex_imm <= 0;
            id_ex_rd <= 0;
            id_ex_alu_src <= 0;
            id_ex_alu_op <= 0;
            id_ex_mem_read <= 0;
            id_ex_mem_write <= 0;
            id_ex_reg_write <= 0;
            id_ex_branch <= 0;
            id_ex_jal <= 0;
            id_ex_jalr <= 0;
        end
        
        
        else if (flush) begin
            // NOP: zero controls, keep PC
            id_ex_pc <= if_id_pc;
            id_ex_rs1_val <= 0;
            id_ex_rs2_val <= 0;
            id_ex_imm <= 0;
            id_ex_rd <= 0;
            id_ex_alu_src <= 0;
            id_ex_alu_op <= 0;
            id_ex_mem_read <= 0;
            id_ex_mem_write <= 0;
            id_ex_reg_write <= 0;
            id_ex_branch <= 0;
            id_ex_jal <= 0;
            id_ex_jalr <= 0;
        end
        
        
        else if (stall) begin
            // Hold all values
            id_ex_pc <= id_ex_pc;
            id_ex_rs1_val <= id_ex_rs1_val;
            // ... hold all
        end
        
        
        else begin
            // Normal latch
            id_ex_pc <= if_id_pc;
            id_ex_rs1_val <= rs1_val;
            id_ex_rs2_val <= rs2_val;
            id_ex_imm <= imm;
            id_ex_rd <= rd;
            id_ex_rs1 <= rs1;
            id_ex_rs2 <= rs2;
            id_ex_alu_src <= alu_src;
            id_ex_alu_op <= alu_op;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_reg_write <= reg_write;
            id_ex_branch <= branch;
            id_ex_jal <= jal;
            id_ex_jalr <= jalr;
        end
    end
endmodule	
