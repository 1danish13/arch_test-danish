// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------


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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",mtval)
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 
///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 01 /////////////////////////////////////////////////////////////////////////////
// // Check for correct value on all traps including:
// hardware breakpoint on {inst fetch, load, store, AMO}
// {address-misaligned, access fault, page fault} on {inst fetch, load, store, AMO}
// illegal instruction
// ecall from each mode, ebreak
// interrupt


// check mtval value for hardware breakpoint
	li      t0, 0x00000000  		// load expected value for inst fetch into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop
	
	li      t0, 0x00000001  		// load expected value for load into t0
	csrr    t1, mtval     			// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop
	
	li      t0, 0x00000002 		// load expected value for store into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop
	
	li      t0, 0x00000003  		// load expected value for AMO into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// check mtval value for misaligned address
	li      t0, 0x00000100  		// load expected value for inst fetch misaligned into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

	li      t0, 0x00000101  		// load expected value for load misaligned into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

	li      t0, 0x00000102  		// load expected value for store misaligned into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

	li      t0, 0x00000103  		// load expected value for AMO misaligned into t0
	csrr    t1, mtval       		// read mtval into t1
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
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
