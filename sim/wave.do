# wave.do - script para configurar visualização de ondas
add wave -divider Inputs
add wave -hex -label Op_A_in /MINHA_FPU_tb/Op_A_in
add wave -hex -label Op_B_in /MINHA_FPU_tb/Op_B_in
add wave -bin -label op_select /MINHA_FPU_tb/op_select
add wave -divider Control
add wave -bin -label clk /MINHA_FPU_tb/clk
add wave -bin -label reset_n /MINHA_FPU_tb/reset_n
add wave -divider Outputs
add wave -hex -label data_out /MINHA_FPU_tb/data_out
add wave -bin -label status_out /MINHA_FPU_tb/status_out
add wave -divider Internals
add wave -hex -label result_exp /MINHA_FPU_tb/dut/result_exp
add wave -hex -label result_mant /MINHA_FPU_tb/dut/result_mant
add wave -bin -label result_sign /MINHA_FPU_tb/dut/result_sign

