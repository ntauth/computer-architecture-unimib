#
# Author: Ayoub Chouak
# Brief: /
#
	.data
cstr:	.asciiz "Ayy there's a dead beef over there!"
	.text
	.globl main
main:
	la $s0, cstr
	li $s1, 0x61 # 'a' token
loop_beg:
	lbu $t0, ($s0)
	beq $t0, $0, epilog
	beq $t0, $s1, replace
	j loop_ep
replace:
	li $t1, 0x65
	sb $t1, ($s0)
loop_ep:
	addi $s0, $s0, 1
	j loop_beg
epilog:	
	# Print modified string
	li $v0, 4
	la $a0, cstr
	syscall
	# Exit
	li	$v0, 10
	syscall
