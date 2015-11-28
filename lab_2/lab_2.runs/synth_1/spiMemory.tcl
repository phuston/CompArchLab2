# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/swalters/Classes/Fall15/CompArch-Lab2/lab_2/lab_2.cache/wt [current_project]
set_property parent.project_path /home/swalters/Classes/Fall15/CompArch-Lab2/lab_2/lab_2.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
set_property ip_repo_paths /home/swalters/Classes/Fall15/CompArch-Lab2 [current_project]
read_verilog -library xil_defaultlib {
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/datamemory.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/dff.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/shiftregister.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/tristatebuffer.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/fsm.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/inputconditioner.v
  /home/swalters/Classes/Fall15/CompArch-Lab2/verilog/spimemory.v
}
read_xdc /home/swalters/Classes/Fall15/CompArch-Lab2/ZYBO_Master.xdc
set_property used_in_implementation false [get_files /home/swalters/Classes/Fall15/CompArch-Lab2/ZYBO_Master.xdc]

synth_design -top spiMemory -part xc7z010clg400-1
write_checkpoint -noxdef spiMemory.dcp
catch { report_utilization -file spiMemory_utilization_synth.rpt -pb spiMemory_utilization_synth.pb }
