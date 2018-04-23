#
# AUTHOR: Ayoub Chouak (a.chouak@protonmail.com)
# FILE:   str_replace.asm
# BRIEF:  String replace function implemented for the MIPS32 Instruction Set
#

.include "mips_intrins.s"

# Globals
.globl main

.data
sbrk_len:
	.word 8
src_key:
	.ascii "R"
rplc_key:
	.ascii "D" # Replacement key
test_string:
	.asciiz "REARBEEF"

.text

.macro push($reg)
subu $sp, $sp, 4
sw $reg, ($sp)
.end_macro

.macro pushi($reg)
subu $sp, $sp, 4
sw $reg, ($sp)
.end_macro

.macro pop($reg)
lw $sp, ($reg)
addiu $sp, $sp, 4
.end_macro

.macro pop()
addiu $sp, $sp, 4
.end_macro

main:
	push(2)
	# Allocate memory for the array using sbrk
	li $v0, 9
	lw $t0, sbrk_len
	addiu $a0, $t0, 1 # Account for the null character
	syscall
	
	move $s1, $v0 # Move the starting address of the array to $s1
	beqz $s1, sbrk_failure 	# Null assert
	
	# Initialize the string
	move $t0, $s1
	la   $t1, test_string
	addu $t2, $t1, $a0
str_init_beg:
	bgt  $t1, $t2, str_init_end
	lbu  $t3, ($t1)
	sb   $t3, ($t0)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	j str_init_beg

str_init_end:
	sb  $0, ($t0)
	
	# Print the original string
	move $a0, $s1
	li $v0, 4
	syscall
	li $a0, 0xA # Newline
	li $v0, 11
	syscall
			
	# Invoke str_replace
	move $a0, $s1     # str
	lw $a1, sbrk_len  # str_len
	lb $a2, src_key   # src_key
	lb $a3, rplc_key  # rplc_key
	jal str_replace
	
	# Print the modified string
	move $a0, $s1
	li $v0, 4
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

# DWORD str_replace(CHAR* str, DWORD str_len, CHAR src_key, CHAR rplc_key)
str_replace:
	# Prolog
	subu $sp, $sp, 40
	sw $fp, 32($sp)
	sw $ra, 36($sp)
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $a0, 16($sp)
	sw $a1, 20($sp)
	sw $a2, 24($sp)
	sw $a3, 28($sp)
	addu $fp, $sp, 36
	
	# String replace
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $t0, $s1
	add $t0, $s0, $t0
	
str_rplc_begin:
	bgt $s0, $t0, str_rplc_end
	lbu $t1, ($s0)
	beq $t1, $s2, str_do_rplc
	addiu $s0, $s0, 1
	j str_rplc_thunk
	
str_do_rplc:
	sb $s3, ($s0)
str_rplc_thunk:
	j str_rplc_begin
str_rplc_end:
	j epilog$1
	
epilog$1:
	# Epilog
	lw $a3, 28($sp)
	lw $a2, 24($sp)
	lw $a1, 20($sp)
	lw $a0, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	lw $ra, 36($sp)
	lw $fp, 32($sp)
	addiu $sp, $sp, 40
	jr $ra
