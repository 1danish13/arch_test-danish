// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
//
// Testing the mstatus csr
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
    	LI(a2, 0x00000020)	// Any random value to check if previous value gets updated or not.
// IN M-mode (Default)
/////////////////// TEST 01 ////////////////////////////////////////////

// making UBE == 1


	csrr a4, mstatus		// reading the reset value of mstatus
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop

	csrw mstatus, a5
	csrr a4, mstatus		// reading the reset value of mstatus
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
	csrw mstatus, a2		// making UBE == 1
	csrr a4, mstatus		// reading the reset value of mstatus
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
	lw t1, 0(a2) 			// exception # 2 read a word from addr 0x1
	csrr a1, mstatus
	RVTEST_SIGUPD(x13, a1)		// We should get 5 in mcause because of Load access fault
	nop
	
	sw t1, 0(a2) 			// exception # 2 read a word from addr 0x1
	csrr a1, mstatus
	RVTEST_SIGUPD(x13, a1)		// We should get 7 in mcause because of store access fault
	nop

// making UBE == 0
	csrw mstatus, x0		// making UBE == 1
	csrr a4, mstatus		// reading the reset value of mstatus
	nop				// nop in case of trap
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
	lw t1, 0(a2) 			// exception # 2 read a word from addr 0x1
	csrr a1, mstatus
	RVTEST_SIGUPD(x13, a1)		// We should get 5 in mcause because of Load access fault
	nop
	
	sw t1, 0(a2) 			// exception # 2 read a word from addr 0x1
	csrr a1, mstatus
	RVTEST_SIGUPD(x13, a1)		// We should get 7 in mcause because of store access fault
	nop

	
	
	
	



/*	
/////////////////// TEST 02 ////////////////////////////////////////////
	
//Writing all 1s in the mstatus

	csrw mstatus, a5		// writing all 1s
	nop
	csrr a4, mstatus		// reading the csr value
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file	
	
// Writing all 0s in the mstatus

	csrw mstatus, x1		// writing all 1s
	nop
	csrr a4, mstatus		// reading the csr value
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file


	
/////////////////// TEST 03 ////////////////////////////////////////////

//csrrw in every mode


	csrrw a5, mstatus, a2
	nop
	csrr a6, mstatus
	RVTEST_SIGUPD(x13, a2)
	RVTEST_SIGUPD(x13, a6)
	RVTEST_SIGUPD(x13, a5)



//csrrc in every mode
	
	csrrc a5, mstatus, a2
	nop
	csrr a6, mstatus
	RVTEST_SIGUPD(x13, a2)
	RVTEST_SIGUPD(x13, a6)
	RVTEST_SIGUPD(x13, a5)
	
	
//csrrs in every mode
	
	csrrs a5, mstatus, a2
	nop
	csrr a6, mstatus
	RVTEST_SIGUPD(x13, a2)
	RVTEST_SIGUPD(x13, a6)
	RVTEST_SIGUPD(x13, a5)
		

/////////////////// TEST 04 ////////////////////////////////////////////

// Test that SD==(FS==3 || XS==3)

	csrw mstatus, a2
	nop
	csrr a4, mstatus
	RVTEST_SIGUPD(x13, a2)
	RVTEST_SIGUPD(x13, a4)
*/
/////////////////// TEST 05 ////////////////////////////////////////////

// test to check the endianness of loads and stores is correct by Seting MBE 0 and 1 

//	LI(mstatus, 2)






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
