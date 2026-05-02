vlib work
vlog -f src_files.list +define+SIM +cover -covercells
vsim -voptargs=+acc FIFO_top -cover
run 0
add wave -position insertpoint sim:/FIFO_top/fifo_if/*
add wave -position insertpoint sim:/FIFO_top/dut/*
add wave -position insertpoint sim:/FIFO_top/dut/mem
add wave -position insertpoint sim:/FIFO_top/mon/scbd/fifo_ref
coverage save FIFO_top.ucdb -onexit
run -all
coverage report -detail -code bcesf -instance=/FIFO_top/dut -output code_coverage_report.txt