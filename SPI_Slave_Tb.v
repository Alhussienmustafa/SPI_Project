module SPI_Slave_Tb();
reg clk, rst_n, MOSI, SS_n;
wire MISO;
// reg MISO_Ex;
reg [9:0]rx_add, rx_data, tx_data;
reg [7:0]tx_add;


integer i = 0;

Top_Module DUT(clk, rst_n, MOSI, MISO, SS_n);

initial begin
	clk = 0;
	forever
	#1 clk = ~clk;
end

initial begin
$readmemb("mem.dat", DUT.RAM.mem);
INITIALIZATION;
	//write address
	SS_n = 0;
	 @(negedge clk);
	 @(negedge clk);
	rx_add = 10'b00_0000_0011;
    WRITING(rx_add);
	@(negedge clk);
	SS_n = 1;
	@(negedge clk);
	//write data
	SS_n = 0;
	@(negedge clk);
	MOSI = 0; 
	@(negedge clk);
	rx_data = 10'b01_1111_0000;
    WRITING(rx_data);
	@(negedge clk);
	SS_n = 1;
	@(negedge clk);
	//read address
	SS_n = 0;
	@(negedge clk);
	MOSI = 1; 
	@(negedge clk);
	rx_add = 10'b10_0000_0011;
	WRITING(rx_add);
	@(negedge clk);
	SS_n = 1;
	@(negedge clk);
	//read data
	SS_n = 0;
	@(negedge clk);
	MOSI = 1; 
	@(negedge clk);
	tx_data = 10'b11_0000_0000;
    WRITING(tx_data);
    tx_add = 8'b0000_1111;
	repeat(10) @(negedge clk);
	$display("mem[tx_add] = %b", DUT.RAM.mem[tx_add]);
	SS_n = 1;
	@(negedge clk);
$stop;
end

task INITIALIZATION; begin
rx_data = 0;
tx_data = 0;
rst_n = 1;
rx_add = 0;
tx_add = 0;
end
endtask

task WRITING(input [9:0]Write_data);
for(i = 9; i >= 0; i = i - 1) begin
MOSI = Write_data[i];
@(negedge clk);
end
endtask
endmodule