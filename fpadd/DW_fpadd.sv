module DW_fpadd ( inst_a, inst_b, inst_rnd, inst_op, z_inst, 
		status_inst );

parameter sig_width = 10;
parameter exp_width = 5;
parameter ieee_compliance = 1;


input logic [sig_width+exp_width : 0] inst_a;
input logic [sig_width+exp_width : 0] inst_b;
input logic [2 : 0] inst_rnd;
input logic inst_op;
output logic [sig_width+exp_width : 0] z_inst;
output logic [7 : 0] status_inst;

   // Instance of DW_fp_addsub
   DW_fp_addsub #(sig_width, exp_width, ieee_compliance)
   U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), 
        .op(inst_op), .z(z_inst), .status(status_inst) );

endmodule // DW_fp_addsub_inst

