module Top_Module(clk, rst_n, MOSI, MISO, SS_n);
input clk, rst_n, MOSI, SS_n;
output MISO;

wire [9:0]rx_data; 
wire [7:0]tx_data;
wire tx_valid, rx_valid;

SPI_Slave MASTER(MOSI, MISO, SS_n, clk, rst_n, rx_data, rx_valid, tx_data, tx_valid);
SPI_RAM RAM(rx_data, rx_valid, clk, rst_n, tx_valid, tx_data);

endmodule