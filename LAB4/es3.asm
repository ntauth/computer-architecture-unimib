	
	.data
	# Data goes here
max_c:	.word 10
max_i:	.word 4

	.text
	.globl	main
main:	
	xor $t0, $t0, $t0
	xor $t1, $t1, $t1
	lw $s0, max_c
	lw $s1, max_i
loop:	
	seq $t2, $t0, $s0
	bne $t2, $0, zero
	addi $t0, $t0, 1
	j loop_e
zero:
	xor $t0, $t0, $t0
	addi $t1, $t1, 1
	seq $t2, $t1, $s1
	bne $t2, $0, epilog
loop_e:
	j loop
epilog:
	# finisce il programma (syscall exit)
	li	$v0, 10
	syscall
