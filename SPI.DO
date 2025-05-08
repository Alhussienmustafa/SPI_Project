vlib work
vlog Top_Module.v SPI_Slave_Tb.v
vsim -voptargs=+acc work.SPI_Slave_Tb
add wave *
run -all