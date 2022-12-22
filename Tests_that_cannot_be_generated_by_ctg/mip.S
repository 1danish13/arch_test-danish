// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//
// 

#define rvtest_strap_routine
#define input_wire 0x717
#include "model_test.h"
#include "arch_test.h"
RVTEST_ISA("RV32I")		//32 test
# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN
#ifdef TEST_CASE_1
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",mip)		//CSR-access
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 

///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 01 /////////////////////////////////////////////////////////////////////////////
//In mip for each bit check Readability/writability of the input wire state
	
	li t0, 0x00000001		// Initialize mip register
	csrw mip, t0

	li t1, 0x00000000		// Set input wire to known state (0 in this example)
	csrw input_wire, t1
	csrr t2, mip			// Read mip register and verify input wire state
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t2)
 
	li t3, 0x00000001		// Modify input wire state and verify writability of mip register
	csrw input_wire, t3
	csrr t4, mip
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t4)

	
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 02 /////////////////////////////////////////////////////////////////////////////
// test for mip register for each bit check Readability/writability of the flop

	li a0, 1			// load the value 1 into the MIP register
	csrr t0, mip
	addi t0, a0, 0
	csrr t0, mip			// check that the value of the MIP register can be read correctly
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)

// modify the value of the MIP register by setting the least significant bit to 0
	li a0, 0			
	srli a0, a0, 1
	csrr t0, mip
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	or t0, t0, a0
	csrw mip, t0

// check that the value of the MIP register has been updated correctly
	csrr t0, mip
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)

	
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 03 /////////////////////////////////////////////////////////////////////////////
// test for mip register Taking SSI immediately after mip write

// set the SSI enable bit in the MIP register
	li a0, 1
	slli a0, a0, 3
	csrr t0, mip
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	or t0, t0, a0
	csrw mip, t0

// write a value to the MIP register that causes an SSI to be taken
	li a0, 1
	slli a0, a0, 11
	csrr t0, mip
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	or t0, t0, a0
	csrw mip, t0

// check that the SSI is taken immediately after the write to the MIP register
	csrr t0, mepc
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	

#endif

 # ---------------------------------------------------------------------------------------------
    # HALT
RVTEST_CODE_END
RVMODEL_HALT

RVTEST_DATA_BEGIN
.align 4
rvtest_data:
.word 0xdeadcafe
RVTEST_DATA_END

RVMODEL_DATA_BEGIN
signature_x13_0:
    .fill 0*(XLEN/32),4,0x12345678
signature_x13_1:
    .fill 128*(XLEN/32),4,0xcafebeef

#ifdef rvtest_mtrap_routine
mtrap_sigptr:
    .fill 256*(XLEN/32),4,0xdeadbeef
#endif

#ifdef rvtest_gpr_save
gpr_save:
    .fill 24*(XLEN/32),4,0xc9a8b7f1
#endif
RVMODEL_DATA_END
