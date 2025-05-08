module SPI_RAM(din, rx_valid, clk, rst_n, tx_valid, dout);
parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;

input [9:0]din;
input clk, rst_n, rx_valid;
output reg [7:0]dout;
output reg tx_valid;

reg [ADDR_SIZE-1:0]mem [MEM_DEPTH-1:0];
reg [7:0]wr_add;
reg [7:0]rd_add;

always @(posedge clk) begin
    if(!rst_n) begin
        tx_valid <= 0;
        dout <= 0;
        wr_add <= 0;
        rd_add <= 0; 
    end
    else begin
        tx_valid <= 0;
        if(rx_valid) begin
            if(din[9:8] == 2'b00) 
                wr_add <= din[7:0];
            if(din[9:8] == 2'b01)
                mem[wr_add] <= din[7:0];
            if(din[9:8] == 2'b10)
                rd_add <= din[7:0];
            if(din[9:8] == 2'b11) begin
                dout <= mem[rd_add];
                tx_valid <= 1;
            end
        end
    end
end
endmodule