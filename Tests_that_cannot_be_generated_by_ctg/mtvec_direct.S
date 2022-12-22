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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",mtvec_direct)
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
main: 

///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 02 /////////////////////////////////////////////////////////////////////////////
// Cause each type of trap (exception and interrupt) in direct mode for each privilege level.


	li     t0, 0				// Set the mtvec CSR to direct mode
	csrw   mtvec, t0

	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an interrupt
	csrr   t0, mip
	li t1, 8				// Set the pending bit for the machine timer interrupt in the MIP register
	or t0, t0, t1
	csrw   mip, t0
	
	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an exception
	li t0, 5				// Causing a load access fault
	csrr	t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop	


///////////////////////////////////////////////////////////////////////////////////////////// Switch to S-mode //////////////////////////////////////////////////////////////////////

	csrw satp, zero                // Disable address translation.
	LI(t2, -1)
	csrw pmpaddr0, t2		// Updated pmpaddr0 to define PMP region consisting
					// of whole physical memory
	csrr t0, pmpaddr0		// Verify its value by reading back
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	nop				// Added nop in case of trap
	LI(a5, PMP_L| PMP_R| PMP_W | PMP_X | PMP_TOR)		// LOCKED BIT IS SET
	csrw pmpcfg0, a5
	RVTEST_GOTO_LOWER_MODE	Smode	// GO into S mode	
///////////////////////////////////////////////////////////////////////////////////////////////// Repeating TEST 02 /////////////////////////////////////////////////////////////////////////////
// IN S mode now
	
	
	li     t0, 0b00			// Set the mtvec CSR to direct mode
	csrw   mtvec, t0
	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an interrupt
	csrr   t0, mip
	li t1, 8
	or t0, t0, t1
	csrw   mip, t0
	
	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an exception
	li t0, 5				// Causing a load access fault
	csrr	t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop	
	
	
///////////////////////////////////////////////////////////////////////////////////////////// Switch back to M-mode //////////////////////////////////////////////////////////////////////
	RVTEST_GOTO_MMODE

  	csrr a4, mstatus		// VERIFICATION of M-mode
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,a4)
	
///////////////////////////////////////////////////////////////////////////////////////////// Switch to U-mode //////////////////////////////////////////////////////////////////////
	csrw satp, zero                 // Disable address translation.
	LI(t2, -1)
	csrw pmpaddr0, t2		// Updated pmpaddr0 to define PMP region consisting
					// of whole physical memory
	csrr t0, pmpaddr0		// Verify its value by reading back
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,t0)
	nop				// Added nop in case of trap
	LI(a5, PMP_L| PMP_R| PMP_W | PMP_X | PMP_TOR)		// LOCKED BIT IS SET
	csrw pmpcfg0, a5
	
	RVTEST_GOTO_LOWER_MODE	Umode	
///////////////////////////////////////////////////////////////////////////////////////////////// Repeating TEST 02 /////////////////////////////////////////////////////////////////////////////
// IN U-mode now

	li     t0, 0b00			// Set the mtvec CSR to direct mode
	csrw   mtvec, t0
	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an interrupt
	csrr   t0, mip
	li t1, 8
	or t0, t0, t1
	csrw   mip, t0
	
	csrr    t1, mtvec    			
	RVTEST_SIGUPD(x13, t1)			// Putting updated value in signature file
	nop

// Cause an exception
	li t0, 5				// Causing a load access fault
	csrr	t1, mtvec    			
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
