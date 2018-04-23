#
# AUTHOR: Ayoub Chouak (a.chouak@protonmail.com)
# FILE:   mips_intrins.asm
# BRIEF:  Macros and Intrinsics for MIPS32
#

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