// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------


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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",minstret)		//CSR-access
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 
///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 01 /////////////////////////////////////////////////////////////////////////////
// With both values of mcountinhibit.IR, architecturally execute:
// ecall
// ebreak
// wfi which traps
// wfi which sleeps
// trapping load/store instructions

// Test minstret CSR with mcountinhibit = 0
	li a0, 0         		// Load 0 into a0
	csrs mstatus, a0   		// Set mcountinhibit = 0 in mstatus, when mcountinhibit is set to 0, the minstret CSR is incremented

	ecall				// Execute ecall and ebreak instructions
	ebreak
	csrr a0, minstret			
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,a0)


// Test minstret CSR with mcountinhibit = 1
	li a0, 1         		// Load 1 into a0
	csrs mstatus, a0   		// Set mcountinhibit = 1 in mstatus, When mcountinhibit is set to 1, the minstret CSR is not incremented.
	

// Execute trapping load and store instructions
	li a0, 0x1000    		// Load address into a0
	lw a1, 0(a0)      		// Load word from memory at address in a0
	sw a1, 0(a0)      		// Store word in memory at address in a0
	csrr a0, minstret			
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,a0)
	

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
