# HSCA_fpadd
Floating-Point Adder/Subtracter Design

Additional final project for High Speed Computer Arthematic.
Directory fpadd is a a working version of an IEEE 754 floating-point adder/subtractor including testbenches. The unit can perform both single (binary32) and double precision (binary64) input operands.  There are also separate DO files to allow testing of each rounding mode.  TestFloat is utilized to provide test vectors (i.e., .tv files) to allow good comprehensive testing.

Summary of Tasks: 
1. Run regression tests on all current tests for both binary32 and binary64.  Report on whether all tests pass or do not pass.
2. Convert all Verilog code to SystemVerilog (testbenches should already be in SystemVerilog).
3. Modify convert_inputs.sv to handle half-precision or binary16 IEEE 754 numbers.
4. Test numbers for IEEE 754 round towards zero or truncation for all IEEE 754 numbers using the provided TestFloat binary16 numbers (see tests-fp subdirectory in the repository).
5. Modify the rounder.sv to support NAN-boxing the result as well as putting the output into the right format.
