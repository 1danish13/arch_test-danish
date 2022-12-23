// -----------
// Copyright (c) 2020. RISC-V International. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// -----------
//
// This is a skeleton test format for virtual memory tests

// inside the "main" symbol it initializes some registers, sets up two page table entries (one with identity mapping and one with non-identity mapping), disables interrupts, sets up the PMP configuration, and switches to supervisor mode.

// In supervisor mode, it performs a store operation to a virtual address that is mapped to a physical address using a previously-defined PTE, and then switches back to machine mode.

// In machine mode, it performs a mode check by executing an "ebreak" instruction, and then updates the signature register.

#define rvtest_strap_routine

#include "model_test.h"
#include "arch_test.h"
RVTEST_ISA("RV32I")

# Test code region
.section .text.init
.globl main
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
  // Initialize some registers
  li t0, 0x80000000  			// Virtual address
  li t2, PTE_V | PTE_X | PTE_A  	// Permissions for PTE for instruction memory
  
  // Set up a page table entry (PTE) with identity mapping
  PTE_SETUP_SV32(t0, x0, t2, 1)
  li t0, 0x812341F0  			// Virtual address
  la t1, signature_x13_1 		// Physical address
  li t2, PTE_V | PTE_R | PTE_W | PTE_D | PTE_A  // Permissions
  
  // Set up a page table entry (PTE) with non-identity mapping
  PTE_SETUP_SV32(t0, t1, t2, 0)
  
  // Disable interrupts
  csrw mie, zero
  
  // Set up the Physical Memory Protection (PMP) configuration
  li t2, -1  				// Whole physical memory as single region
  csrw pmpaddr0, t2
  li t2, 0x8F 				// TOR mode with lock bit on
  csrw pmpcfg0, t2
  
  // Switch to supervisor mode
  csrr t0, mstatus
  SATP_SETUP
  RVTEST_GOTO_LOWER_MODE Smode

s_mode:

  // Perform a store operation to a virtual address mapped to a physical address
  li t0, 0x812341F0
  li t1, 0xcdef
  sw t1, 4(t0)
  
  // Switch back to machine mode
  RVTEST_GOTO_MMODE
  // Perform a mode check
  ebreak
  
  // Update the signature register
  li a4, 0xabab
  RVTEST_SIGUPD(x13, a4)
  
  #endif 
  # ---------------------------------------------------------------------------------------------
    # HALT
RVTEST_CODE_END
RVMODEL_HALT

RVTEST_DATA_BEGIN
.align 3
rvtest_data:
.word 0xdeadcafe
rvtest_sroot_pg_tbl:
    RVTEST_PTE_IDENT_MAP
rvtest_slvl1_pg_tbl:
    RVTEST_PTE_IDENT_MAP
RVTEST_DATA_END

RVMODEL_DATA_BEGIN
signature_x13_0:
    .fill 0*(XLEN/32),4,0x0
signature_x13_1:
    .fill 64*(XLEN/32),4,0xcafebeef

#ifdef rvtest_mtrap_routine
mtrap_sigptr:
    .fill 64*(XLEN/32),4,0xdeadbeef
#endif

#ifdef rvtest_gpr_save
gpr_save:
    .fill 24*(XLEN/32),4,0xc9a8b7f1
#endif
RVMODEL_DATA_END
