// Exception bar for the floating point adder. Note: We may 
// actually want to move to where the result is computed.

module exception (Ztype, Invalid, Denorm, ANorm, BNorm, Sub, A, B, op_type);

   input logic [63:0] A;		// 1st input logic operand (op1)
   input logic [63:0] B;		// 2nd input logic operand (op2)
   input logic [2:0] 	op_type;   	// Function opcode
   output logic [3:0] Ztype;		// Indicates type of result (Z)
   output logic 	Invalid;	// Invalid operation exception
   output logic 	Denorm;		// Denormalized input logic
   output logic       ANorm;          // A is not zero or Denorm
   output logic       BNorm;          // B is not zero or Denorm
   output logic       Sub;		// The effective operation is subtraction
   logic		AzeroM;	 	// '1' if the mantissa of A is zero
   logic		BzeroM;		// '1' if the mantissa of B is zero
   logic		AzeroE;	 	// '1' if the exponent of A is zero
   logic		BzeroE;		// '1' if the exponent of B is zero
   logic		AonesE;	 	// '1' if the exponent of A is all ones
   logic		BonesE;		// '1' if the exponent of B is all ones
   logic		ADenorm; 	// '1' if A is a denomalized number
   logic		BDenorm; 	// '1' if B is a denomalized number
   logic		AInf;	 	// '1' if A is infinite
   logic		BInf;	 	// '1' if B is infinite
   logic		AZero;	 	// '1' if A is 0
   logic		BZero;	 	// '1' if B is 0
   logic		ANaN;	 	// '1' if A is a not-a-number
   logic		BNaN; 		// '1' if B is a not-a-number
   logic		ASNaN;	 	// '1' if A is a signalling not-a-number
   logic		BSNaN;	 	// '1' if B is a signalling not-a-number
   logic		ZQNaN;	 	// '1' if result Z is a quiet NaN
   logic		ZPInf;	 	// '1' if result Z positive infnity
   logic		ZNInf;	 	// '1' if result Z negative infnity
   logic    add_sub;	// '1' if operation is add or subtract
   logic 	converts;       // See if there are any converts   
   
   parameter [51:0]  fifty_two_zeros = 52'h0000000000000; // Use parameter?


   // Is this instruction a convert
   assign converts      = ~(~op_type[1] & ~op_type[2]);
   
   // Determine if mantissas are all zeros
   assign AzeroM = (A[51:0] == fifty_two_zeros);
   assign BzeroM = (B[51:0] == fifty_two_zeros);

   // Determine if exponents are all ones or all zeros 
   assign AonesE = A[62]&A[61]&A[60]&A[59]&A[58]&A[57]&A[56]&A[55]&A[54]&A[53]&A[52];
   assign BonesE = B[62]&B[61]&B[60]&B[59]&B[58]&B[57]&B[56]&B[55]&B[54]&B[53]&B[52];
   assign AzeroE = ~(A[62]|A[61]|A[60]|A[59]|A[58]|A[57]|A[56]|A[55]|A[54]|A[53]|A[52]);
   assign BzeroE = ~(B[62]|B[61]|B[60]|B[59]|B[58]|B[57]|B[56]|B[55]|B[54]|B[53]|B[52]);

   // Determine special cases. Note: Zero is not really a special case. 
   assign ADenorm = AzeroE & ~AzeroM;
   assign BDenorm = BzeroE & ~BzeroM;
   assign AInf = AonesE & AzeroM;
   assign BInf = BonesE & BzeroM;
   assign ANaN = AonesE & ~AzeroM;
   assign BNaN = BonesE & ~BzeroM;
   assign ASNaN = ANaN & ~A[51];
   assign BSNaN = BNaN & ~B[51];
   assign AZero = AzeroE & AzeroM;
   assign BZero = BzeroE & BzeroE;

   // A and B are normalized if their exponents are not zero. 
   assign ANorm = ~AzeroE;
   assign BNorm = ~BzeroE;

   // An "Invalid Operation" exception occurs if (A or B is a signalling NaN)
   // or (A and B are both Infinite and the "effective operation" is 
   // subtraction). 
   assign add_sub = ~op_type[2] & ~op_type[1];
   assign Invalid = (ASNaN | BSNaN | 
		     (add_sub & AInf & BInf & (A[63]^B[63]^op_type[0]))) & ~converts;

   // The Denorm flag is set if (A is denormlized and the operation is not integer 
   // conversion ) or (if B is normalized and the operation is addition or  subtraction). 
   assign Denorm = ADenorm&(op_type[2]|~op_type[1]) | BDenorm & add_sub;

   // The result is a quiet NaN if (an "Invalid Operation" exception occurs) 
   // or (A is a NaN) or (B is a NaN and the operation uses B).
   assign ZQNaN = Invalid | ANaN | (BNaN & add_sub);

   // The result is +Inf if ((A is +Inf) or (B is -Inf and the operation is
   // subtraction) or (B is +Inf and the operation is addition)) and (the
   // result is not a quiet NaN).  
   assign ZPInf = (AInf&A[63] | add_sub&BInf&(~B[63]^op_type[0]))&~ZQNaN;

   // The result is -Inf if ((A is -Inf) or (B is +Inf and the operation is
   // subtraction) or (B is -Inf and the operation is addition)) and the
   // result is not a quiet NaN.  
   assign ZNInf = (AInf&~A[63] | add_sub&BInf&(B[63]^op_type[0]))&~ZQNaN;

   // Set the type of the result as follows:
   // (needs optimization - got lazy or was late)
   // Ztype	Result 
   //  0000	Normal
   //  0001	Quiet NaN
   //  0010     Negative Infinity
   //  0011     Positive Infinity
   //  0100     +Bzero and +Azero (and vice-versa)
   //  0101     +Bzero and -Azero (and vice-versa)
   //  1000     Convert SP to DP (and vice-versa)

   assign Ztype[0] = ((ZQNaN | ZPInf) & ~(~op_type[2] & op_type[1])) | 
		     ((AZero & BZero & (A[63]^B[63]^op_type[0])) 
		      & ~converts);
   assign Ztype[1] = ((ZNInf | ZPInf) & ~(~op_type[2] & op_type[1])) | 
		     (((AZero & BZero & A[63] & B[63] & ~op_type[0]) |
		       (AZero & BZero & A[63] & ~B[63] & op_type[0])) 
		      & ~converts);
   assign Ztype[2] = ((AZero & BZero & ~op_type[1] & ~op_type[2]) 
		      & ~converts);
   assign Ztype[3] = (op_type[1] & op_type[2] & ~op_type[0]);

   // Determine if the effective operation is subtraction
   assign Sub = add_sub & (A[63]^B[63]^op_type[0]);

endmodule // exception

