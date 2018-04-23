#Esempio elementare di procedura che riceve come parametri due numeri, ne fa la somma e restituisce il risultato.
#SUGGERIMENTO: assemblare e eseguire step by step guadando bene cosa succede a ogni passo. Fatelo anche se vi sembra di aver capito tutto...

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

lw $a0, num1 
#passaggio del primo parametro
#convenzione programmativa: i registri da $a0 a $a3 si usano per passare gli argomenti alla procedura
#ATTENZIONE: questo un passaggio parametri PER VALORE ("by value"). In $a0 viene messo il VALORE del parametro attuale.

lw $a1, num2 

jal somma1 
#l'indirizzo della istruzione successiva viene salvato in $ra e si salta alla procedura. 
#ATTENZIONE: questa NON una convenzione programmativa! E' un fatto definito dall'architattura della macchina MIPS

sw $v0, result1 #memorizzazione del primo risultato

#seconda chiamata della procedura
lw $a0, num3
lw $a1, num4
jal somma1
sw $v0, result2

#Terminazione del programma
#ATTENZIONE: in questo esempio (e in generale) importante inserire la chiamata alla syscall di terminazione.

#SUGGERIMENTO (non essenziale per capire le chiamate a procedura, ma MOLTO utile per chiarirsi le idee:
#provare a togliere le due istruzioni che seguono (basta commentarle) e eseguire step by step...
#IL programma entra in loop e non termina. PERCHE'????
#SUGGERIMENTO: eseguire in step by step e vedere cosa succede.
li $v0, 17
syscall

#Procedura
somma1: #questo l'indirizzo iniziale della procedura

move $t0, $a0 #non indispensabile in casi semplici come questo, ma una buona regola programmativa:
#i parametri vengono copiati in registri temporanei usati localmente dalla procedura
move $t1, $a1
add $v0, $t0, $t1 #convenzione: i registri $v0 e $v1 si usano per restituire il risultato della procedura

jr $ra
