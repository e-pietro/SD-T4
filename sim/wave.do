
delete wave *
add wave -divider "Clock & Reset"
add wave -hex clk
add wave -hex reset_n

add wave -divider "Inputs"
add wave -hex Op_A_in
add wave -hex Op_B_in
add wave -bin op_select

add wave -divider "Outputs"
add wave -hex data_out
add wave -bin status_out

add wave -divider "Internal Signals"
add wave -hex /MINHA_FPU_tb/dut/result_mant
add wave -hex /MINHA_FPU_tb/dut/result_exp
add wave -hex /MINHA_FPU_tb/dut/result_sign

wave zoom full
