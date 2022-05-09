// This module takes as input logics two operands (op1 and op2) 
// the operation type (op_type) and the result precision (P). 
// Based on the operation and precision , it conditionally
// converts single precision values to double precision values
// and modifies the sign of op1. The converted operands are Float1
// and Float2.

module convert_inputs (Float1, Float2, op1, op2, op_type, P);
   
   input logic [63:0]	op1;            // 1st input logic operand (A)
   input logic [63:0]	op2;            // 2nd input logic operand (B)
   input logic [2:0]	op_type;        // Function opcode
   input logic [1:0]	P;              // Result Precision (00 for double, 01 for single, 10 for half)
					// modified for versatillity (1 bit -> 2 bits)

   output logic [63:0] Float1;	// Converted 1st input logic operand
   output logic [63:0] Float2;	// Converted 2nd input logic operand   
  
   logic 	 conv_SP, conv_HP;        // Convert from SP to DP, other is HP to DP
   logic 	 negate;         	 // Operation is negation
   logic 	 abs_val;         	// Operation is absolute value
   logic [11:0]	 HD1;		 	// half -> double op1
   logic [11:0]	 HD2;			// half -> double op2
   logic [11:0]	 SD1;		 	// single -> double op1
   logic [11:0]	 SD2;			// single -> double op2

   // Convert from single precision to double precision if (op_type is 11X
   // and P is 0) or (op_type is not 11X and P is one). 
assign conv_HP = P[1];
assign conv_SP = ((op_type[2]&op_type[1]) ^ P[0]) & ~conv_HP;

// HP --> DP
   assign HD1 = {6'b0,op1[62:58]} + 11'd1008; // 1023-15 in decimal. subtracting the bais. example done in class
   assign HD2 = {6'b0,op2[62:58]} + 11'd1008; // same as above but for operand 2

// SP --> DP
   assign SD1 = {3'b0,op1[62:55]} + 11'd896; // 1023-127
   assign SD2 = {3'b0,op2[62:55]} + 11'd896;

// conditionally convert operand 1 and operand 2
// Lower 29 bits are zero for single precision.
// Lower 42 bits are zero for half precision 
   assign Float1[62:52] = conv_HP? HD1 : (conv_SP? SD1 : op1[62:52]); // expontial 
   assign Float2[62:52] = conv_HP? HD2 : (conv_SP? SD2 : op2[62:52]); // expontial

   assign Float1[51:0] = conv_HP? op1[57:6] : (conv_SP? op1[55:3]: op1[51:0]);// the rest
   assign Float2[51:0] = conv_HP? op2[57:6] : (conv_SP? op2[55:3]: op2[51:0]); // the rest

// Set the sign of Float1 based on its original sign and if the operation
// is negation (op_type = 101) or absolute value (op_type = 100)

   assign negate  = op_type[2] & ~op_type[1] & op_type[0];
   assign abs_val = op_type[2] & ~op_type[1] & ~op_type[0];
   assign Float1[63]  = (op1[63] ^ negate) & ~abs_val;
   assign Float2[63]  = op2[63];

endmodule // convert_input logics

