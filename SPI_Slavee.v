module SPI_Slave(MOSI, MISO, SS_n, clk, rst_n, rx_data, rx_valid, tx_data, tx_valid);
parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter READ_ADD = 3'b010;
parameter READ_DATA = 3'b011;
parameter WRITE = 3'b100;

input MOSI, SS_n, clk, rst_n;
input [7:0]tx_data;
input tx_valid;
output reg [9:0]rx_data;
output reg rx_valid;
output reg MISO;

reg [2:0]ns, cs;

reg [3:0]counter = 9;
reg Data_OR_ADD = 0;

always @(posedge clk) begin
if(!rst_n) begin
cs <= IDLE;
end
else cs <= ns; 
end

//next logic state
always @(*) begin
case(cs)
IDLE:
if(!SS_n) ns <= CHK_CMD;
CHK_CMD:
if((!SS_n) && (!MOSI)) begin
    ns <= WRITE;
end
else if((!SS_n) && (MOSI) && (!Data_OR_ADD)) begin
ns <= READ_ADD;
end
else if((!SS_n) && (MOSI) && (Data_OR_ADD)) begin
ns <= READ_DATA;
end
WRITE: begin
if(SS_n) ns <= IDLE;
else ns <= WRITE;
end
READ_ADD: begin
if(SS_n) ns <= IDLE;
else ns <= READ_ADD;
end
READ_DATA: begin 
if(SS_n) ns <= IDLE;
else ns <= READ_DATA;
end
default: ns <= IDLE;
endcase
end

//Output Logic
always @(posedge clk) begin
/******WRITE CMD******/
if(!rst_n) begin
MISO <= 0;
rx_valid <= 0;
rx_data <= 0;
end
else begin
if(cs == CHK_CMD) counter <= 9;
if((cs == WRITE) || (cs == CHK_CMD)) begin
// counter <= 9;
case(counter)
9: begin 
    rx_valid <= 0; //stop sharing
    rx_data[counter] <= MOSI;
    counter <= counter - 1;
end
8:  if(!Data_OR_ADD) begin //first or second one for the writing
        rx_data[counter] <= MOSI;
        Data_OR_ADD <= 1; //the coming one is the second
        counter <= counter - 1;
end
    else begin
        rx_data[counter] <= MOSI;
        Data_OR_ADD <= 0; //set to default
        counter <= counter - 1;
end
0: begin
    rx_data[counter] <= MOSI;
    rx_valid <= 1; //start the sharing
end
default: begin
    rx_data[counter] <= MOSI;
    counter <= counter - 1;
end
endcase
    end

/******READ CMD******/
if((cs == READ_ADD) || (cs == READ_DATA)) begin

case(counter)
9: begin
    rx_valid <= 0; //stop sharing
    rx_data[counter] <= MOSI;
    counter <= counter - 1;
end
8: begin
    rx_data[counter] <= MOSI;
    counter <= counter - 1;
    if(MOSI == 1) begin
        Data_OR_ADD <= 1;
        rx_valid <= 1;
    end
    else begin
        Data_OR_ADD <= 0;
    end
end
0: begin
    if(!tx_valid) begin //if any data not valid, so we write address
    rx_data[counter] <= MOSI;
    end
    else MISO <= tx_data[counter];
    if(Data_OR_ADD) rx_valid <= 1; //now share the address
end
default: begin
    if(!tx_valid) begin
    rx_data[counter] <= MOSI;
    counter <= counter - 1;
    end
    else MISO <= tx_data[counter];
            end
        endcase
    end
end
end
endmodule