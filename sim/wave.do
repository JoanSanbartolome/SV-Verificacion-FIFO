onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /FIFO_tb/interfaz1/clk
add wave -noupdate -radix binary /FIFO_tb/interfaz1/rst_a
add wave -noupdate -radix binary /FIFO_tb/interfaz1/rst_s
add wave -noupdate -radix binary /FIFO_tb/interfaz1/lleno
add wave -noupdate -radix binary /FIFO_tb/interfaz1/vacio
add wave -noupdate -radix binary /FIFO_tb/interfaz1/rd_en
add wave -noupdate -radix binary /FIFO_tb/interfaz1/wr_en
add wave -noupdate -format Analog-Step -height 74 -max 32.0 -radix unsigned /FIFO_tb/interfaz1/use_dw
add wave -noupdate -radix unsigned /FIFO_tb/duv/g_duv/duv/USE_DW
add wave -noupdate -radix unsigned /FIFO_tb/interfaz1/data_in
add wave -noupdate -radix unsigned /FIFO_tb/interfaz1/data_out
add wave -noupdate -radix unsigned /utilidades_pkg::RCSG_base__1::use_dw
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/CLOCK
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/RESET_N
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/CLEAR_N
add wave -noupdate -radix unsigned /FIFO_tb/duv/g_duv/duv/DATA_IN
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/READ
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/WRITE
add wave -noupdate -radix unsigned /FIFO_tb/duv/g_duv/duv/DATA_OUT
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/F_EMPTY_N
add wave -noupdate -radix binary /FIFO_tb/duv/g_duv/duv/F_FULL_N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6130015 ps} 0}
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
WaveRestoreZoom {5791249 ps} {10060871 ps}
