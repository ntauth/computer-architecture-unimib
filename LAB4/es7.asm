#
# Author: Ayoub Chouak
# Brief:  Sequential lookup
#
	.data
array:	.word 1, 2, 3, 80, 5, 6, 10, 7, 9
length: .word 9

	.text
	.globl main
main:
	la $a0, array
	lw $a1, length
	li $a2, 80
	xor $s0, $s0, $s0
	xor $v0, $v0, $v0
loop_beg:
	bge $s0, $a1, epilog
	lw $t0, ($a0)
	seq $v0, $t0, $a2
	bne $v0, 0, epilog
loop_ep:
	addi $a0, $a0, 4
	addi $s0, $s0, 1
	j loop_beg
epilog:	
	# Print result
	la $a0, ($v0)
	li $v0, 1
	syscall
	# Exit
	li	$v0, 10
	syscall
