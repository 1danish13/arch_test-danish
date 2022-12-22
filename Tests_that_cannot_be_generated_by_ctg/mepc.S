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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",mepc)
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	
	
	.attribute stack_align, 16
  	.align	2    
  	
  	
main: 
///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 01 /////////////////////////////////////////////////////////////////////////////
// Cause each type of trap taken to M mode, store mepc to the signature

	ecall   			//execute the ecall instruction to trigger an environment call trap
	csrr a1, mepc
	RVTEST_SIGUPD(x13, a1)		
	nop	
	

	ebreak   			// execute the ebreak instruction to trigger an ebreak trap
	csrr a1, mepc
	RVTEST_SIGUPD(x13, a1)		
	nop
	
// load the address of the misaligned instruction into register a0
	li a1, 0x12345678		// loads the hexadecimal value 0x12345678 into register a1
	lui a0, %hi(0x12345678)	// lui instruction to load the upper 20 bits of the address into register a0
	addi a0, a0, %lo(0x12345678)	// addi instruction to add the lower 12 bits of the address to a0.
	csrr a1, mepc
	RVTEST_SIGUPD(x13, a1)		
	nop
	
	
	lw a0, 0(a0)   		// attempt to load from the non-readable memory location to trigger an access fault trap
	csrr a1, mepc
	RVTEST_SIGUPD(x13, a1)		
	nop
	
	sw x0, 0(a0)   		// attempt to store to the non-writable memory location to trigger a page fault trap
	csrr a1, mepc
	RVTEST_SIGUPD(x13, a1)		
	nop
	
	li a0, 0x12345678		// load the hexadecimal value 0x12345678 into register a0 
	ori a0, a0, 0xffffffff		// "or immediate" (ori) instruction to set all 32 bits of a0 to 1. the ori instruction is a valid opcode and will be executed without issue. However, some processors may treat the instruction as illegal if the immediate value being ORed with the register is too large. In this case, the processor may raise an illegal instruction trap when it encounters the ori instruction.
	csrr a1, mepc
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
