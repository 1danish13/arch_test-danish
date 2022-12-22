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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True",mstatus)
RVTEST_SIGBASE( x13,signature_x13_1)
	.option nopic
	.attribute unaligned_access, 0
	.attribute stack_align, 16
  	.align	2    
main: 

///////////////////////////////////////////////////////////////////////////////////////////// IN M-mode (Default) //////////////////////////////////////////////////////////////////////
// test for reading, writing, and checking the mstatus register 

	li a0, 0x12345678   		// a0 = 0x12345678
	li a1, 0x87654321   		// a1 = 0x87654321
	li a2, 0x0          		// a2 = 0x00000000

	csrr a2, mstatus    		// Read the initial value of mstatus	
	csrw mstatus, a0    		// Write the value in a0 to mstatus

	csrr a3, mstatus   		// Read the new value of mstatus

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 01 /////////////////////////////////////////////////////////////////////////////
// Set MBE bits 0 and 1 to 0 in mstatus

	li t0, 0b11			// li (load immediate) instruction to load the value 0b11 (which represents the binary value 11) into the t0 register.
	csrs mstatus, t0		// csrs (control and status register set) instruction to set the MBE bits 0 and 1 in the mstatus register to the value in t0, effectively setting them to 0.
	nop
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
// Set MBE bits 0 and 1 to 1 in mstatus
	li t0, 0b11			// li (load immediate) instruction to load the value 0b11 (which represents the binary value 11) into the t0 register.
	csrc mstatus, t0		// csrc (control and status register clear) instruction to clear the MBE bits 0 and 1 in the mstatus register, effectively setting them to 1.
	nop
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 02 /////////////////////////////////////////////////////////////////////////////
// Set SBE bits 0 and 1 to 0 in mstatus
	li t0, 0b11			//li instruction to load the value 0b11 (which represents the binary value 11) into the t0 register. 		
	csrsi mstatus, 2		//csrsi (control and status register set immediate) instruction to set the SBE bits 0 and 1 in the mstatus register to the value in t0, effectively setting 						// them to 0.
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
//Set SBE bits 0 and 1 to 1 in mstatus
	li t0, 0b11			//li instruction to load the value 0b11 (which represents the binary value 11) into the t0 register. 
	csrci mstatus, 2		//csrci (control and status register clear immediate) instruction to clear the SBE bits 0 and 1 in the mstatus register, effectively setting them to 1.
	csrr a4, mstatus					
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop


///////////////////////////////////////////////////////////////////////////////////////////////// TEST 03 /////////////////////////////////////////////////////////////////////////////
//execute {SRET,MRET} in all modes with both values of TSR
//Set TSR bit to 0 in mstatus
/*	li t0, 0b1			// li (load immediate) and csrs (control and status register set) instructions to set the TSR bit in the mstatus register to 0.
	csrs mstatus, t0


	sret				// Execute SRET in all modes with TSR bit set to 0
	csrr a4, mstatus		// reading the value of mcause on reset				
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop

	mret				// Execute MRET in all modes with TSR bit set to 0
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
	
//Set TSR bit to 1 in mstatus
	li t0, 0b1			//li (load immediate) and csrs (control and status register set) instructions to set the TSR bit in the mstatus register to 1.
	csrc mstatus, t0

	sret				// Execute SRET in all modes with TSR bit set to 1
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop

	mret				// Execute MRET in all modes with TSR bit set to 1
	csrr a4, mstatus						
	RVTEST_SIGUPD(x13, a4)		// Putting updated value in signature file
	nop
*/

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 04 /////////////////////////////////////////////////////////////////////////////
//execute WFI in all modes with both values of TW and no pending interrupt
//Test WFI in user mode with TW=1 and no pending interrupt
	li x1, 0         		// Set x1 to 0 to clear the interrupt pending flag
	li x2, 0         		// Set x2 to 0 to clear the interrupt enable flag
	csrr x3, mstatus    		// Read the mstatus register into x3				
	RVTEST_SIGUPD(x13, x3)		// Putting updated value in signature file
	nop
	andi x3, x3, 0x80   		// Clear the TW bit in the mstatus register
	ori x3, x3, 0x8     		// Set the TW bit in the mstatus register
	csrw mstatus, x3    		// Write the updated mstatus register value back
	wfi                 		// Execute the WFI instruction
	csrr x3, mstatus    		// Read the mstatus register into x3				
	RVTEST_SIGUPD(x13, x3)		// Putting updated value in signature file

//Test WFI in user mode with TW=0 and no pending interrupt
	li x1, 0         		// Set x1 to 0 to clear the interrupt pending flag
	li x2, 0       		// Set x2 to 0 to clear the interrupt enable flag
	csrr x3, mstatus    		// Read the mstatus register into x3				
	RVTEST_SIGUPD(x13, x3)		// Putting updated value in signature file
	nop
	andi x3, x3, 0x80   		// Clear the TW bit in the mstatus register
	csrw mstatus, x3    		// Write the updated mstatus register value back
	wfi                 		// Execute the WFI instruction
	csrr x3, mstatus    		// Read the mstatus register into x3				
	RVTEST_SIGUPD(x13, x3)		// Putting updated value in signature file
	nop

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 05 /////////////////////////////////////////////////////////////////////////////
// {read, write} satp, execute SFENCE.VMA in all modes with both values of TVM

	li a0, 0x12345678   		// Initialize values for the test a0 = 0x12345678
	li a1, 0x87654321  
	li a2, 0x0       

	csrr a2, satp    	 	// Read the initial value of satp; a2 = satp
 	RVTEST_SIGUPD(x13, a2)		// Putting updated value in signature file
	csrw satp, a0    		// Write the value in a0 to satp; satp = a0
			
	csrr a3, satp    		// Read the new value of satp; a3 = satp
	RVTEST_SIGUPD(x13, a3)		// Putting updated value in signature file
	
// Test SFENCE.VMA in all modes with both values of TVM in mstatus

	li t0, 0 			// Set t0 to 0
	li t1, 1 			// Set t1 to 1

	csrr t2, mstatus 		// Get the current value of mstatus into t2
	andi t3, t2, ~(1 << 7) 	// Clear the TVM bit in t3

// Test SFENCE.VMA in all modes with TVM = 0
	csrw mstatus, t3 		// Set mstatus to t3, which has TVM = 0
	sfence.vma t0, t1		// Execute SFENCE.VMA; Should not cause an exception

// Test SFENCE.VMA in all modes with TVM = 1
	ori t3, t2, 1 << 7 		// Set the TVM bit in t3=
	sfence.vma t0, t1 		//  Execute SFENCE.VMA; Should not cause an exception

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 06 /////////////////////////////////////////////////////////////////////////////
// -In M mode, execute all legal load/store/AMO instructions with MPRV={0,1} and all legal MPP values. 
// Set MPRV to 0
	csrrw x0, mstatus, x0
//	ori x0, x0, 0b1000000000000
	csrrw x0, mstatus, x0
	
// Set MPP to PRV_U
	csrrw x0, mstatus, x0		
	ori x0, x0, 0b0000000000000000
	csrrw x0, mstatus, x0

// Execute load instructions with MPRV=0, MPP=PRV_U
	lw x1, 0(x2)
	lh x1, 0(x2)
	lb x1, 0(x2)
//	lwu x1, 0(x2)
	lhu x1, 0(x2)

// Execute store instructions with MPRV=0, MPP=PRV_U
	sw x1, 0(x2)
	sh x1, 0(x2)
	sb x1, 0(x2)

///////////////////////////////////////////////////////////////////////////////////////////////// TEST 07 /////////////////////////////////////////////////////////////////////////////
// Set up the MPRV bit in the MSTATUS register
	li t0, MSTATUS_MPRV
	csrs mstatus, t0
	lw t1, 0(t0)			// Perform a misaligned memory access

	csrr t2, mtval			// Check if the MPRV mechanism was triggered by checking the MTVAL register
	RVTEST_SIGUPD(x13, t2)		// Putting updated value in signature file


///////////////////////////////////////////////////////////////////////////////////////////////// TEST 08 /////////////////////////////////////////////////////////////////////////////
// MRET Trap from all modes into M mode
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

	mret				// Execute MRET from a lower privilege mode, such as S mode or U mode. This should trigger an exception and trap into M mode.
	mret 				// In M mode, execute the mret instruction to return to the lower privilege mode.
	wfi				// attempt to execute wfi in lower priviledged mode. This should again trigger an exception and trap into M mode.

	
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
	mret				// Execute MRET from a lower privilege mode, such as S mode or U mode. This should trigger an exception and trap into M mode.
	mret 				// In M mode, execute the mret instruction to return to the lower privilege mode.
	wfi				// attempt to execute wfi in lower priviledged mode. This should again trigger an exception and trap into M mode.
/////////////////// Switch back to M-mode ////////////////////////////////////////////
	RVTEST_GOTO_MMODE

  	csrr a4, mstatus		// VERIFICATION of M-mode
	nop				// Added nop in case of trap
	RVTEST_SIGUPD(x13,a4)
	
///////////////////////////////////////////////////////////////////////////////////////////////// TEST 09 /////////////////////////////////////////////////////////////////////////////
//In all modes, execute all, vector arithmetic, vector load/store, vcsr access and other vector instructions starting from each VS state
/*
	li    t0, 0x300   		// Set the initial VS state in the mstatus register; Set the initial VS state to "VS1"	
	csrrw t1, mstatus, t0

//Perform vector arithmetic instructions
	vadd.vv v0, v1, v2  		// Vector add
	vsub.vv v3, v4, v5  		// Vector subtract
	vmul.vv v6, v7, v8  		// Vector multiply
	vdiv.vv v9, v10, v11 		// Vector divide

//Perform vector load/store instructions
	vld v12, 0(x13)   		// Vector load
	vst v14, 0(x15)   		// Vector store

//Perform vector control and status register (vcsr) access instructions
	vcsrrc v0, vcsr0, x1 		// Read and clear a vcsr bit
	vcsrrs v0, vcsr1, x2 		// Read and set a vcsr bit
	vcsrrw v0, vcsr2, x3 		// Read and write a vcsr bit

//Perform other vector instructions
	vsetvli v0, x1, 0 		// Set vector length and start index
	vmv.v.x v1, x2    		// Move vector from integer register
	vmv.x.v x3, v4    		// Move vector to integer register

*/

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
