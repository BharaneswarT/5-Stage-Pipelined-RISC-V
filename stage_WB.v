module stage_WB(
    input clk, reset,  
    input stall, flush,  
    
    // Inputs from stage_MEM (EX/MEM latched values)
    input [31:0] wb_data_in,  // Input: Value to write (alu_result or loaded data from D-cache). Why: The result to save in regs.
    input [4:0] rd_in,  // Input: Destination register (0-31). Why: Which reg to write to.
    input reg_write_in,  // Input: 1 if write to reg. Why: Enable write (0 for branches/stores).
    
    // Outputs to register_file (latched)
    output reg [31:0] mem_wb_wb_data,  // Output: Latched wb_data_in. Why: Connect to register_file write_data.
    output reg [4:0] mem_wb_rd,  // Output: Latched rd_in. Why: Connect to register_file rd.
    output reg mem_wb_reg_write  // Output: Latched reg_write_in. Why: Connect to register_file reg_write.
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_wb_data <= 32'd0;  // Why: Safe init, no write.
            mem_wb_rd <= 5'd0;  // x0 (always 0).
            mem_wb_reg_write <= 1'b0;  // No write.
        end else if (flush) begin
            mem_wb_wb_data <= 32'd0;  // NOP: nothing to write.
            mem_wb_rd <= 5'd0;
            mem_wb_reg_write <= 1'b0;  // Disable write.
        end else if (stall) begin
            // Hold current values (don't update)
            mem_wb_wb_data <= mem_wb_wb_data;
            mem_wb_rd <= mem_wb_rd;
            mem_wb_reg_write <= mem_wb_reg_write;
        end else begin
            // Normal latch: copy from inputs
            mem_wb_wb_data <= wb_data_in;
            mem_wb_rd <= rd_in;
            mem_wb_reg_write <= reg_write_in;
        end
    end
endmodule






