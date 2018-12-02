onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_dnn/err
add wave -noupdate -radix hexadecimal /tb_dnn/clk
add wave -noupdate -radix hexadecimal /tb_dnn/rst_n
add wave -noupdate -divider SLAVE
add wave -noupdate -radix hexadecimal /tb_dnn/slave_address
add wave -noupdate -radix hexadecimal /tb_dnn/slave_read
add wave -noupdate -radix hexadecimal /tb_dnn/slave_write
add wave -noupdate -radix hexadecimal /tb_dnn/slave_writedata
add wave -noupdate -radix hexadecimal /tb_dnn/slave_readdata
add wave -noupdate -radix hexadecimal /tb_dnn/slave_waitrequest
add wave -noupdate -divider DNN
add wave -noupdate -radix hexadecimal /tb_dnn/dut/st
add wave -noupdate -radix hexadecimal /tb_dnn/dut/nst
add wave -noupdate -radix hexadecimal /tb_dnn/dut/operating
add wave -noupdate -radix hexadecimal /tb_dnn/dut/enable
add wave -noupdate -radix hexadecimal /tb_dnn/dut/bias_v_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/weight_m_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/activ_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/out_activ_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/activ_len
add wave -noupdate -radix hexadecimal /tb_dnn/dut/relu
add wave -noupdate -radix hexadecimal /tb_dnn/dut/relu
add wave -noupdate -divider -height 23 DNN_MASTER
add wave -noupdate -radix hexadecimal /tb_dnn/master_waitrequest
add wave -noupdate -radix hexadecimal /tb_dnn/master_address
add wave -noupdate -radix hexadecimal /tb_dnn/master_read
add wave -noupdate -radix unsigned /tb_dnn/master_readdata
add wave -noupdate -radix hexadecimal /tb_dnn/master_readdatavalid
add wave -noupdate -radix hexadecimal /tb_dnn/master_write
add wave -noupdate -radix unsigned /tb_dnn/master_writedata
add wave -noupdate -radix unsigned /tb_dnn/master_writedata
add wave -noupdate -divider in
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/st
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/nst
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/ret_st
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/b_index
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/iterations
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_bias_v_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_weight_m_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_activ_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_out_activ_addr
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_activ_len
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/S_relu
add wave -noupdate -radix unsigned /tb_dnn/dut/master/nxt_weight
add wave -noupdate -radix unsigned /tb_dnn/dut/master/nxt_activ
add wave -noupdate -radix hexadecimal /tb_dnn/dut/master/out_activ
add wave -noupdate -radix unsigned /tb_dnn/dut/master/mult_result
add wave -noupdate -radix unsigned /tb_dnn/dut/master/sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {827 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {785 ps} {885 ps}
