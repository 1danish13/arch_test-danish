// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//


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
    	LI(a2, 0x80001002)	// Any random value to check if previous value gets updated or not.
// IN M-mode (Default)
	LI(x5, 100)
/////////////////// TEST 01 ////////////////////////////////////////////

	csrr a4, mtvec			// reading the value of mtvec on reset
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop


/*

// 	Cause each type of trap (exception and interrupt) in direct mode.
 	csrr x0, 6			// Illegal instruction exception
 	csrrw t1, 6, x0
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)		
	nop	


	lw t1, 0(t0) 			// load access fault
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)		
	nop
	
	sw t1, 0(t0) 			// store access fault
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)		
	nop
	
	ebreak				//ebreak
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)							
	nop
	
	WFI				//wait for interrupt, since we cannot produce interrupt ourself
	csrr a4, mtvec	
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
*/	

	//testing in the vectored mode
	
//	csrw mtvec, a2
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a1)		// Putting updated value in signature file
	nop	
	
	csrr x0, 6			// Illegal instruction exception
 	csrrw t1, 6, x0
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)		
	nop	


	lw t1, 0(t0) 			// load access fault
	csrr a1, mtvec
	RVTEST_SIGUPD(x13, a1)		
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
