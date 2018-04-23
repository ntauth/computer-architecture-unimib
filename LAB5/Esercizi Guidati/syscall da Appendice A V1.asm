# Questo esempio è tratto da Appendice A Sez. A9 - Chiamate di sistema
# pag. A33 (utima edizione italiana)
# ATTENZIONE; guardare bene le istruzioi alla riga 22 e alla riga 34 con i relativi commenti.

  # il codice seguente stampa la stringa "La risposta e' 55":

.data

str:
.asciiz "La risposta e' "

.text

li $v0, 4 # Codice della chiamata di sistema per print_str

la $a0, str # Indirizzo della stringa da stampare

syscall # Stampa la stringa

li $v0, 1 # Codice della chiamata di sistema per print_int

la $a0, 5 # Numero intero da stampare..caricato in $a0 come se fosse un indirizzo!!!
# Questa è l'istruzione ripresa da Appendice A Sez. A9 - Chiamate di sistema
# In effetti e' MOLTO DISCUTIBILE: sarebbe piu' corretto usare l'istruzione li
# (riga 36). Funiona perche', in realta', nella la si specifica un "indirizzo" fornito come immediato
# e la istruzione "la" fa esattamente la stessa cosa di una "li" di un valore immediato
# (della serie: i bit son sempre bit...)
# A conferma, guardate il codice generato dall'assemblatore 
# traducendo le pseudo istruzioni la (riga 22) e li (riga 34):
# e' esattamente uguale nei due casi!!!

syscall # Stampa l’intero

li $a0, 5 # Numero intero da stampare

syscall # Stampa di nuovo l’intero (in $v0 c'è ancora 1)

# Provate anche a commentare le due istruzioni che seguono e confrontate
# i messaggi di terminazione con e senza le due istruzioni
li $v0, 17
syscall
