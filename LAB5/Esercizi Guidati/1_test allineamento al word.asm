################################################################################
# 		ALLINEAMENTO AL WORD
# Questo esempio serve per capire il concetto di allineamento al word.
# Rifermenti: 
# - lucidi ISA2 slide 6, dove detto "Word (in particolare, istruzioni) 
# 	partono a multipli di 4". In altre parole, questo il concetto di WORD ALIGNMENT.
# - Patterson Cap. 2 Sez. 2.3, Interfaccia hardware/software (pag. 60 ed. 4 italiana):
# 	"Nel MIPS le parole devono sempre iniziare a indirizzi multipli di 4, 
# 	questo requisito si chiama VINCOLO DI ALLINEAMENTO ed comune a molte altre
# 	architetture (il Capitolo 4 spiega perch√ l'allineamento rende
#  	il trasferimento dati pi veloce)".
# - Lezioni del prof. Sorrenti
################################################################################
# 
################################################################################
# 			ESEMPIO
# L'esempio scritto in modo un po' barocco per mtivi didattici.
# Guardatelo bene e leggete con attenzione i commenti
# Approfittatene per capire bene cosa fa l'istruzione "la" ("load address").
# Assemblare ed eseguire l'esempio.
# 
# Si bloccher segnalando un malfunzionamento:
# Error... line 49: Runtime exception at 0x0040001c: fetch address not aligned on word boundary 0x10010001
# 
# Poi provate a resettare ed eseguire step-by-step. 
# Vedrete che esegue correttamente fino all'istruzione alla linea 49
# poi si blocca dando nuovamente il diagnostico.

.data
pippo: .word 45
pluto: .word 0

.text
.globl main
main:
# Carica in $t0 L'INDIRIZZO corrispondente all'etichetta pippo.
# 	(programmando in modo "normale" non occorre farlo, basterebbe fare 
# 	lw $t1, pippo e poi pensa l'assemblatore a tradurre in modo opportuno
# 	la pseudoistruzione lw)
la $t0, pippo
# Carica in $t1 il contenuto della word il cui primo byte all'indirizzo
# ottenuto sommando 0 al contenuto di $t0 (indirizzamewnto con registro base)
lw $t1, 0($t0)

# Memorizza all'indirizzo pluto il contenuto di $t1
sw $t1, pluto

# Fa la stessa cosa di prima...
la $t0, pippo
# ...ma questa volta l'indirizzo calcolato (0x10010001) NON "allineato al word"...
lw $t1, 1($t0)
# ...perci "si rifiuta di farlo" segnalando un'eccezione
#  (tranquilli: delle eccezioni parleremo in seguito).
sw $t1, pluto

# The program is finished. Exit.
li   $v0, 10          # system call for exit
syscall               # Exit!
