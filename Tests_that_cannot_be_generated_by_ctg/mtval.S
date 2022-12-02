// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//
// Check for correct value on all traps including:
// hardware breakpoint on {inst fetch, load, store, AMO}
// {address-misaligned, access fault, page fault} on {inst fetch, load, store, AMO}
// illegal instruction
// ecall from each mode, ebreak
// interrupt

#define rvtest_strap_routine
#include "model_test.h"
#include "arch_test.h"
RVTEST_ISA("RV32I")
# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN
#ifdef TEST_CASE_1
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",CSR-access)
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 
	LI(x1,0)
    	LI(a5,-1)		// ALL 1's
    	LI(x2, 0x80001000)	// Any random value to check if previous value gets updated or not.
// IN M-mode (Default)
	LI(x5, 100)
/////////////////// TEST 01 ////////////////////////////////////////////

	csrr a4, mtval			// reading the value of mtval on reset
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
//all the value of csr is 0 at reset


	csrw mtval, a5
	nop				// nop in case of trap
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// Putting updated value in signature file
	nop


 /*	
 	csrr x0, 6			// Illegal instruction
 	csrrw t1, 6, x0
	csrr a1, mtval
	RVTEST_SIGUPD(x13, a1)		// Test failed. For the illegal instruction exception, I am getting non zero values in the spike signature and zero values in the sail signature.   
	nop	
*/

	lw t1, 0(t0) 			// load access fault
	csrr a1, mtval
	RVTEST_SIGUPD(x13, a1)		// mtval contains the virtual address of the portion of the access that caused the fault.
	nop
	
	sw t1, 0(t0) 			// store access fault
	csrr a1, mtval
	RVTEST_SIGUPD(x13, a1)		// mtval contains the virtual address of the portion of the access that caused the fault.
	nop
	
	ebreak
	csrr a1, mtval
	RVTEST_SIGUPD(x13, a1)		// breakpoint occurs on an instruction fetch, load, or store, then mtval contains the faulting 					//virtual address.
	nop

	la t0, label			// instruction access fault
	addi t1, t0, 1
	jalr x0, 0(t1)
	//beq x0, x0, label
	csrr a1, mtval
	RVTEST_SIGUPD(x13, a1)		
	nop
label:
	nop


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
