onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /FIFO_tb/interfaz1/clk
add wave -noupdate /FIFO_tb/interfaz1/rst_a
add wave -noupdate /FIFO_tb/interfaz1/rst_s
add wave -noupdate /FIFO_tb/interfaz1/lleno
add wave -noupdate /FIFO_tb/interfaz1/vacio
add wave -noupdate /FIFO_tb/interfaz1/rd_en
add wave -noupdate /FIFO_tb/interfaz1/wr_en
add wave -noupdate -format Analog-Step -height 74 -max 32.0 -radix hexadecimal /FIFO_tb/interfaz1/use_dw
add wave -noupdate /FIFO_tb/duv/duv/USE_DW
add wave -noupdate /FIFO_tb/interfaz1/data_in
add wave -noupdate /FIFO_tb/interfaz1/data_out
add wave -noupdate /utilidades_pkg::RCSG_base__1::use_dw
add wave -noupdate /FIFO_tb/duv/duv/CLOCK
add wave -noupdate /FIFO_tb/duv/duv/RESET_N
add wave -noupdate /FIFO_tb/duv/duv/CLEAR_N
add wave -noupdate /FIFO_tb/duv/duv/DATA_IN
add wave -noupdate /FIFO_tb/duv/duv/READ
add wave -noupdate /FIFO_tb/duv/duv/WRITE
add wave -noupdate /FIFO_tb/duv/duv/DATA_OUT
add wave -noupdate /FIFO_tb/duv/duv/F_EMPTY_N
add wave -noupdate /FIFO_tb/duv/duv/F_FULL_N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2950000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 291
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {7013852 ps}
