onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_tb/if_fifo/clk
add wave -noupdate /fifo_tb/if_fifo/rst_a
add wave -noupdate /fifo_tb/if_fifo/rst_s
add wave -noupdate /fifo_tb/if_fifo/lleno
add wave -noupdate /fifo_tb/if_fifo/vacio
add wave -noupdate /fifo_tb/if_fifo/rd_en
add wave -noupdate /fifo_tb/if_fifo/wr_en
add wave -noupdate /fifo_tb/if_fifo/use_dw
add wave -noupdate /fifo_tb/if_fifo/data_in
add wave -noupdate /fifo_tb/if_fifo/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {490970 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {1260105 ps}
