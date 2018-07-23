# 
# FILE:   xhandler.s
# AUTHOR: Ayoub Chouak (a.chouak@protonmail.com)
#

.kdata
str_excp0: .asciiz "Exception caught - ExcCode: "
str_excp1: .asciiz " - EPC: "
__crlf__:  .asciiz "\r\n"

.align 2
xframe:
	.space 12

.ktext 0x80000180
prolog:
	sw $at, xframe
	sw $a0, xframe + 4
	sw $v0, xframe + 8
	
hnd:
	mfc0 $k0, $13
	srl $k0, $k0, 2
	andi $k0, 0x1f
	
	# Check the exception type
	bgtz $k0, hnd_except
hnd_interrupt:
	# mfc0 $k1, $12
	# Extract the interrupt mask
	# andi $a0, $k1, 0xFF00
	# Increase the IRQL
	# sll $a0, $a0, 1
	# andi $v0, $k1, 0x?FFFF00FF?
	# or $v0, $v0, $a0
	
	# Enable interrupts and clear EXL
	# mfc0 $k0, $12
	# xori $k0, $k0, 2
	# mtc0 $k0, $12
	
	j epilog
hnd_except:
	# Dump the exception info
	li $v0, 4
	la $a0, str_excp0
	syscall
	li $v0, 1
	move $a0, $k0
	syscall
	li $v0, 4
	la $a0, str_excp1
	syscall
	li $v0, 1
	mfc0 $a0, $14
	syscall
	li $v0, 4
	la $a0, __crlf__
	syscall
epilog:
	# Set the return address
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
	# Clear C0.Cause
	mtc0 $0, $13
	
	# Restore the callee registers
	.set noat
	lw $at, xframe
	lw $a0, xframe + 4
	lw $v0, xframe + 8
	.set at
	
	# Enable interrupts and clear EXL
	mfc0 $k0, $12
	xori $k0, $k0, 2
	mtc0 $k0, $12
	
	eret
	
.text
.globl main
main:
	teqi $0, 0