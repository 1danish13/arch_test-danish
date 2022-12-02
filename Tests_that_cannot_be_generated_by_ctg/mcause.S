// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//
// Cause each type of trap taken to M mode, make sure the mcause is correct.
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

	csrr a4, mcause		// reading the value of mcause on reset
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
//all the value of csr is 0 at reset

	csrw mcause, a5
	nop				// nop in case of trap
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// Putting updated value in signature file
	nop

 	// Illegal CSRs should error on read or write
 	csrr x0, 6
 	csrrw t1, 6, x0
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 2 in the mcause which is illegal instruction
	nop	

	//All counters should not be writeable
 	csrrwi t1, 0xC00, 0 # cycle
 	nop
 	csrrwi t1, 0xC02, 0 # instret
 	nop
 	csrrwi t1, 0xC80, 0 # cycleh
 	nop
 	csrrwi t1, 0xC82, 0 # instreth
 	nop
 	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 2 in the mcause which is illegal instruction becaue all counters should not be writeable
	nop

	lw t1, 0(t0) 			// exception # 2 read a word from addr 0x1
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 5 in mcause because of Load access fault
	nop
	
	sw t1, 0(t0) 			// exception # 2 read a word from addr 0x1
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 7 in mcause because of store access fault
	nop
	
	lw t1, 3(t0)
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 4 in mcause because of load address misalligned
	nop
	
	sw t1, 3(t0)
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 4 in mcause because of load address misalligned
	nop
	
	ecall
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get b in mcause because of envirnment call from M mode
	nop
	
	ebreak
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 3 in mcause because of breakpoint
	nop


	la t0, label
	addi t1, t0, 1
	jalr x0, 0(t1)
	//beq x0, x0, label
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 0 in mcause because of instruction address misaligned
	nop
label:
	nop
	

	
/////////////////// Switch to S-mode ////////////////////////////////////////////
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
// REPEATING THE SAME TEST //////////////////////////////////////////		
// IN S mode now

	ecall
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 9 in mcause because of envirnment call from S mode
	nop
	
/////////////////// Switch back to M-mode ////////////////////////////////////////////
	RVTEST_GOTO_MMODE

  	csrr a4, mstatus		// VERIFICATION of M-mode
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,a4)
/////////////////// Switch to U-mode ////////////////////////////////////////////
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
// REPEATING THE SAME TEST //////////////////////////////////////////		
// IN U-mode now
/////////////////// TEST 01 ////////////////////////////////////////////

	ecall
	csrr a1, mcause
	RVTEST_SIGUPD(x13, a1)		// We should get 8 in mcause because of envirnment call from U mode
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
