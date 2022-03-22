open_project kernel3_u250
open_solution solution
export_design -rtl verilog -format ip_catalog -xo polysa.xo

close_project
puts "Pack XO successfully"
exit
