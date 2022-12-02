// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//
// The events are IMP DEF,

#define rvtest_strap_routine
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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",CSR-access)		//CSR-access
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 
	LI(x1,0)
    	LI(a5,-1)		// ALL 1's
//    	LI(x2, 0x80001000)	// Any random value to check if previous value gets updated or not.
// IN M-mode (Default)
	LI(x5, 1)

	csrr a4, mhpmcounter3		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
//	add t0, x5, x0
	csrw mhpmcounter4, a5		// writing all 1's in mhpmcoutner4 to see if the mhpmevent4 tells which event causes mhpmcounter4 to increment
	nop
	csrr a4, mhpmevent4		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter4		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter5		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter6		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter7		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter8		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter9		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter10		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter11		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter12		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter13		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter14		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter15		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter16		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter17		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter18		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter19		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter20		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter21		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter22		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter23		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter24		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter25		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter26		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter27		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter28		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter29		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter30		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	csrr a4, mhpmcounter31		
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	
	


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
