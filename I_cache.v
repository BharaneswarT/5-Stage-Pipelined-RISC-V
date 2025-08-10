module I_cache(
	input clk,
	input mem_ready,    // the data from main memory is READY or not
	input [31:0] address,   //the PC send the address to cache to find the data required
	input [31:0] mem_Data,  //data from the memory
	output reg [31:0] instr,    //writing the data into the IF
	output reg hit                    //whether the requested instruction is there in CACHE or not  [HIT =0 didn't find the data, HIT =1 found the data]
	);
	
	reg [31:0] cache_data [0:255];     // data in cache 256 instructions of each 32 bit
	reg [21:0] cache_tags [0:255];     // since we know TAGS are of 22bits [The tag is the big label on the data to confirm if it’s really the one you want.]
	reg valid [0:255];             //256 single bit valid [ VALID =0 then its garbage value, if VALID =1 then its the actual data we need]
	
	wire [7:0] index = address [9:2] ;   // since it instructs us to go to the drawer 
	wire [21:0] tag = address [31:10];   // upper bit as tags  of size 21bit
	
	
	always @ (posedge clk) 
	begin
		hit <= (valid[index] && cache_tags[index] == tag)  //
		if (hit)
			instr <= cache_data[index];
		else if (mem_ready)
		begin 
			cache_data[index] <= mem_Data;
			cache_tags[index] <= tag;
			valid[index] <= 1'b1;
			instr<= mem_Data;
		end
		else
			instr <= 32'h00000013;
	end
	
	initial begin
		integer i;
		for (i=0; i<256; i=i+1)
			valid[i] = 1'b0;
	end
endmodule 
	
