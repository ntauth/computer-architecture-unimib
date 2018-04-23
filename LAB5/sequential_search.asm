#
# AUTHOR: Ayoub Chouak (a.chouak@protonmail.com)
# FILE:   sequential_search.asm
# BRIEF:  Sequential search implemented for the MIPS32 Instruction Set
#

# Globals
.globl main

.data
sbrk_len:
	.word 32
src_key:
	.word 0xDEADBEEF


.text

.macro push($rimm)
subu $sp, $sp, 4
sw $rimm, ($sp)
.end_macro

.macro pop($reg)
lw $sp, ($reg)
addiu $sp, $sp, 4
.end_macro

.macro pop()
addiu $sp, $sp, 4
.end_macro

main:
	# Allocate memory for the array using sbrk
	li $v0, 9
	lw $a0, sbrk_len
	sll $a0, $a0, 2 # sbrk_len * sizeof(DWORD)
	syscall
	
	move $s1, $v0 # Move the starting address of the array to $s1
	beqz $s1, sbrk_failure 	# Null assert
	
	# Put the key in a random position in the array. @todo: make a proper random impl
	lw $t0, src_key
	sw $t0, 16($s1)
	
	# Invoke the sequential search on the array
	move $a0, $s1
	lw $a1, sbrk_len
	lw $a2, src_key
	jal seq_search
	
	# Print the 
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $s0, 0 # return 0
	j epilog$0
	
sbrk_failure:
	li $s0, -1 # return -1
	
epilog$0:
	# Exit
	li $v0, 17
	move $a0, $s0
	syscall

# DWORD seq_search(DWORD* array, DWORD length, DWORD key)
seq_search:
	# Prolog
	subu $sp, $sp, 32
	sw $fp, 24($sp)
	sw $ra, 28($sp)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $a0, 12($sp)
	sw $a1, 16($sp)
	sw $a2, 20($sp)
	addu $fp, $sp, 28
	
	# Sequential search
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $t0, $s1
	sll $t0, $t0, 2
	add $t0, $s0, $t0
	
seq_src_begin:
	bgt $s0, $t0, key_not_found
	lw $t1, ($s0)
	beq $t1, $s2, key_found
	addu $s0, $s0, 4
	j seq_src_begin
	
key_found:
	sub $v0, $t0, $s0
	sra $v0, $v0, 2
	subu $v0, $s1, $v0
	j epilog_jmp_thunk
key_not_found:
	li $v0, -1
	j epilog_jmp_thunk
	
epilog_jmp_thunk:
	j epilog$1
	
epilog$1:
	# Epilog
	lw $a2, 20($sp)
	lw $a1, 16($sp)
	lw $a0, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	lw $ra, 28($sp)
	lw $fp, 24($sp)
	addiu $sp, $sp, 32
	jr $ra
