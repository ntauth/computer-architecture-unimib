	.data

	.globl	main
	
	.text

main:

	# mettere le istruzioni per caricare i valori 
	# 10 5 20 e 100 rispettivamente nei registri
	# $s0 $s1 $s2 $s3

	# _____________
	# _____________
	# _____________
	# _____________

	add $t0, $s0, $s1
	add $t1, $s2, $s3
	add $t2, $t1, $t0

	# Cosa c'è nel registro $t2? ___________


	# finisce il programma (syscall exit)
	li	$v0, 10
	syscall