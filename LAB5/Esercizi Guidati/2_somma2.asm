#IMPORTANTE: confromtare con somma1.
#Esempio di procedura che fa la somma di due numeri e restituisce il risultato.
#Analogo a somma1, ma questa volta i parametri sono passati PER INDIRIZZO

.data
num1: .word 50
num2: .word 14
result1: .word 0
num3: .word 50
num4: .word -66
result2: .word 0

.text
.globl main
main:

#prima chiamata della procedura

la $a0, num1 
#Passaggio parametri per indirizzo ("by reference"). In $a0 si mette l'INDIRIZZO del primo parametro

la $a1, num2

jal somma2 #l'indirizzo della istruzione successiva viene salvato in $ra e si salta alla procedura. 
#ATTENZIONE: questa NON è una convenzione programmativa! E' un fatto definito dall'architattura della macchina MIPS

sw $v0, result1 #memorizzazione del primo risultato

#seconda chiamata della procedura
la $a0, num3
la $a1, num4
jal somma2
sw $v0, result2

#Terminazione del programma
li $v0, 17
syscall

#Procedura
somma2:
lw $t0, 0($a0) #si ripesca attraverso l'indirizzo il valore del primo parametro e si mette in $t0
lw $t1, 0($a1)
add $v0, $t0, $t1 #convenzione: i registri $v0 e $v1 si usano per restituire il risultato della procedura
jr $ra
