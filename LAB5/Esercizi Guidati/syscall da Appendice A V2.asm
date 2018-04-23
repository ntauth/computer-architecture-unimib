# Questo esempio e' dertivato da Appendice A Sez. A9 - Chiamate di sistema
# pag. A33 /utima edizione italiana)
# ATTENZIONE; guardare bene le istruzioni alla riga 27 e alla riga 37
# per capire cosa vuol dire passare un valore o un indirizzo
 
.data

str:
.asciiz "Il numero e' "

str2:
.asciiz "\nL'indirizzo del numero e' "

numero:
.word 5

.text

li $v0, 4 # Codice della chiamata di sistema per print_str

la $a0, str # Indirizzo della stringa da stampare

syscall # Stampa la stringa

li $v0, 1 # Codice della chiamata di sistema per print_int

lw $a0, numero # Numero intero da stampare (PASSASAGGIO PARAMETRO PER VALORE)

syscall # Stampa il numero

li $v0, 4 # Codice della chiamata di sistema per print_str

la $a0, str2 # Indirizzo della stringa da stampare

syscall # Stampa la stringa

la $a0, numero # VIENE PASSATO L'INDIRIZZO DEL NUMERO

li $v0, 1 # Codice della chiamata di sistema per print_int

syscall # Stampa l'indirizzo del numero

# Provate anche a commentare le due istruzioni che seguono e confrontate
# i messaggi di terminazione con e senza le due istruzioni
li $v0, 17
syscall
