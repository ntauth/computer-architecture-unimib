#
# Author: Ayoub Chouak
# Brief:  Array filler
#
	.data 0x10010000
	.align 2
array:	.space 0x28

	.text
	.globl	main
main:
	li $s0, 20
	li $s1, 30
	la $t0, array
loop_start:
	bgt $s0, $s1, epilog
	sw $s0, ($t0)
	la $t0, 4($t0)
	addi $s0, $s0, 1
	j loop_start
epilog:	
	# Exit
	li	$v0, 10
	syscall
