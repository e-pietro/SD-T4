# sim.do - script para compilar e simular
vlib work
vlog MINHA_FPU.sv MINHA_FPU_tb.sv
vsim -c MINHA_FPU_tb -do "do wave.do; run -all; quit"
