open_project PROJECT_NAME
open_solution solution
export_design -rtl verilog -format ip_catalog -xo XO_NAME.xo

close_project
puts "Pack XO successfully"
exit