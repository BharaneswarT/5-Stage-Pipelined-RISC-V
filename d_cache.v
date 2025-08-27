module d_cache(
	input clk,
	input mem_ready,  //data fetched from main memory is successful
	input mem_read, mem_write,  //control signal for reading and writing in D_cache
	input [31:0] address, //ALU result from EX/MEM,  where to read and write that address we're gettin
	input [31:0] write_data,  //rs2_val from EX/MEM writing the actual data
	input [31:0] mem_data,  //data from main memory when miss
	
	output reg [31:0] read_data,   //read data when mem_read=1
	output reg hit,  // turn 1 if data is there in cache, 
	output reg d_stall   //turns 1 on miss 
	);
	
	reg [31:0] cache_data [0:255];  // 256 entries, 32-bit data. Store cached values. (1Kb cache)
	reg [21:0] cache_tag [0:255]; //one 22 bit tag for 256 line
	reg vaild [0:255];  //one valid bit for each line
	
	wire [7:0] index = address[9:2];  //taking 8bit in 256 lines
	wire [21:0] tag = address [31:10];  //upper bits for matching
	
	always @ (posedge clk) begin
		hit <= valid[index] && (cache_tags[index]==tag);  //check if valid(index) matches with the cache_tags(index)
		
		//load operation
		if(mem_read) begin
			if (hit) read_data <= 	cache_data[index];   //get the cache_data from this 'index' address
			
			else if(mem_ready) begin  //miss but memory ready
				cache_data[index] <= mem_data;  // Why: Fill cache with memory data.
                		cache_tags[index] <= tag;  // Why: Update tag for future hits.
                		valid[index] <= 1'b1;  // Why: Mark as valid.
                		read_data <= mem_data;  // Why: Output to MEM/WB.
                		dcache_stall <= 1'b0;  //clear stall
			end
		end
		
		//write and store operation
		else if (mem_write) begin
			if (hit) cache_data[index] <= write_data;  // Why: Write to cache on hit.
			
            		else if (mem_ready) begin  // Miss but ready (allocate on write)
                		cache_data[index] <= write_data;  // Fill and write.
                		cache_tags[index] <= tag;
                		valid[index] <= 1'b1;
                		dcache_stall <= 1'b0;
            		end
            	 	else dcache_stall <= 1'b1;  // Stall on miss.
        	end
        	else dcache_stall <= 1'b0;  // No mem op, no stall.
    	end
    
    initial begin  // Init on start (all invalid).
        integer i;
        for (i = 0; i < 256; i = i + 1) valid[i] = 1'b0;
    end
endmodule
