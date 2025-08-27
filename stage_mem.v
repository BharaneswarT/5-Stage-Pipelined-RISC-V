module stage_MEM(
	
    	input clk, reset,  // Clock for latching, reset to clear. Why: Sync and init to NOP/0.
    	input stall, flush,  // From Stall_control. Stall holds values, flush sets NOP. Handle hazards (e.g., cache miss or branch).
    	
    	// From EX/MEM latch
    	input [31:0] ex_mem_pc,  //  PC from EX/MEM (optional, for debug or JAL link).  Pass to WB if needed.
    	input [31:0] ex_mem_alu_result,  // ALU result from EX. Why: Address for load/store, or value for WB if no load.
    	input [31:0] ex_mem_rs2_val,  //  rs2 value from EX. Why: Data to write for stores.
    	input [4:0] ex_mem_rd,  //  Destination reg, for WB write.
    	input ex_mem_mem_read,  //  1 for load. Why: Trigger D-cache read, mux wb_data = cache data.
    	input ex_mem_mem_write,  //  1 for store. Why: Trigger D-cache write with rs2_val.
    	input ex_mem_reg_write,  //  1 if write to reg in WB. Pass to WB.
    	
    	// From main memory
    	input mem_ready,  // 1 if main mem data ready on miss. Why: Clear stall.
    	input [31:0] mem_data,  //  Data from main mem on miss. Why: For D-cache fill and load output.
    	
    	
    	// Outputs to MEM/WB latch
    	output reg [31:0] mem_wb_pc,  //  Latched PC (optional). For WB if needed.
    	output reg [31:0] mem_wb_wb_data,  //  Data for WB (cache data if load, alu_result else). To register_file write_data.
    	output reg [4:0] mem_wb_rd,  //  Latched rd. Why: To register_file rd.
    	output reg mem_wb_reg_write,  //  Latched reg_write.  To register_file reg_write.
    	
    	
    	// Output to Stall_control
    	output reg dcache_stall  // 1 on cache miss, to Stall_control to pause pipeline.
	);

    	// Internal wires
    	wire [31:0] cache_read_data;  // From D-cache.
    	wire cache_hit;  // From D-cache.

    	// D-cache instantiation
    	d_cache dcache_inst(
        	.clk(clk),
        	.mem_ready(mem_ready),
        	.mem_read(ex_mem_mem_read),
        	.mem_write(ex_mem_mem_write),
        	.address(ex_mem_alu_result),  
        	.write_data(ex_mem_rs2_val),  
        	.mem_data(mem_data),
        	.read_data(cache_read_data),
        	.hit(cache_hit),
        	.dcache_stall(dcache_stall)  
    	);

    	// Mux for WB data (comb)
    	wire [31:0] temp_wb_data = ex_mem_mem_read ? cache_read_data : ex_mem_alu_result;  //if load, use cache data, else ALU result (for arith ops).

    	// MEM/WB Latch
    	always @(posedge clk or posedge reset) begin
        	if (reset) begin
            		mem_wb_pc <= 0;
            		mem_wb_wb_data <= 0;
            		mem_wb_rd <= 0;
            		mem_wb_reg_write <= 0;
        	end else if (flush) begin
            		mem_wb_pc <= 0;
            		mem_wb_wb_data <= 0;
            		mem_wb_rd <= 0;
            		mem_wb_reg_write <= 0;  // NOP: no write.
        	end else if (stall || dcache_stall) begin  // Hold on any stall.
            		mem_wb_pc <= mem_wb_pc;
            		mem_wb_wb_data <= mem_wb_wb_data;
            		mem_wb_rd <= mem_wb_rd;
            		mem_wb_reg_write <= mem_wb_reg_write;
        	end else begin
            		mem_wb_pc <= ex_mem_pc;
           		mem_wb_wb_data <= temp_wb_data;  // Muxed data.
            		mem_wb_rd <= ex_mem_rd;
            		mem_wb_reg_write <= ex_mem_reg_write;
        	end
    	end	
endmodule







