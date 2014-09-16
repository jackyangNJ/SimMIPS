.global _reset   
.extern c_entry
.set noat
.set noreorder


_reset:     
	lui     $sp, %hi(stack_top)
    addiu   $sp, $sp, %lo(stack_top)
    la      $t9,(c_entry)
    jr    	$t9
    nop
hang:
    b       hang
    nop


