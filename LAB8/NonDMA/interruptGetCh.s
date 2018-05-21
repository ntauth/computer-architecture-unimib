# N.B. - per usare il programma e' necessario attivare la modalita'       #
#        mapped I/O dello  Spim E DISABIL. CARICAMENTO FILE TRAP HANDLER  #
#      - per funzionare e' necessario aprire la finestra di Console       #
#        prima di iniziare a digitare                                     #

#Per vostro riferimento: Tipico ciclo di pausa:
# li $t4, 10000
# nomePausa:
#  nop
#  nop
#  nop
#  subu $t4,$t4,1
# bnez $t4,nomePausa


#==========================Sezione Kernel/Gestore Eccezioni
#---------------dati del kernel
	.kdata

s1:	.word 0
s2:	.word 0

aVideo:	.word 0    # memoria buffer per il carattere, a video
daTast:	.word 0    # memoria buffer per il carattere, da tastiera

__punto: .asciiz "."
__virgl: .asciiz ","
#---------------istruzioni del kernel
	.ktext 0x80000180 #punto di entrata di tutte le eccezioni MIPS

    #salvo i registri che usero':
	.set noat
	# Because we are running in the kernel, we can use $k0/$k1 without
	# saving their old values.
	move $k1 $at	# Save $at
	.set at
	sw $v0 s1	# Not re-entrent and we can't trust $sp
	sw $a0 s2

    #prelevo il registro Cause
	mfc0 $k0 $13	# Cause

#Devo riconoscere, e servire, solo gli interrupt:
        andi $a0 $k0 0x7c
        srl $a0 $a0 2	# shift Cause reg
bgtz $a0 esciecc   #branch, se non e' un interrupt

intVideo:
#Devo riconoscere, e servire in modo diverso, l'interrupt Transm.:
        andi $a0 $k0 0xff00
        srl $a0 $a0 8	# shift Cause reg
andi $a0 $a0 4
beq  $a0 $0 intTast#branch, se c'e' un interrupt ma non di Transm.

#Ora ho riconosciuto interrupt Transm. e lo servo in modo diverso:
	la $a0 __virgl
        la $v0 4
        syscall
lw   $a0 aVideo
beq  $a0 $0 intTast#branch, se buffer vuoto (valore 0)

sw   $a0 0xffff000c#invio a video
sw   $0 aVideo     #svuoto il buffer
#E proseguo comunque qui sotto, per esaminare anche la tastiera

intTast:
#Devo riconoscere, e servire in modo diverso, l'interrupt Receiver:
        andi $a0 $k0 0xff00
        srl $a0 $a0 8	# shift Cause reg
andi $a0 $a0 8
beq  $a0 $0 esciecc#branch, se e' interrupt ma non di Receiver

#OK, e' interrupt Receiver, quindi:
	la $a0 __punto
        la $v0 4
        syscall
lw   $a0 0xffff0004	#prelevo il carattere da tastiera
sw   $a0 daTast 	#e lo metto in buffer
#E proseguo comunque qui sotto, per uscire dal gestore eccezioni

esciecc: #coda, comune a tutte le eccezioni
    #ripulisco il registro Cause
	mtc0 $0, $13	# Clear Cause register

    #ripristino i registri salvati
    	lw $v0 s1
	lw $a0 s2
	.set noat
	move $at $k1	# Restore $at
	.set at

    #prelevo l'indirizzo di ritorno, ripristino alcuni flag in Status
    # e salto esattamente all'indirizzo di ritorno (OK per INT, ma trap?..)
	mfc0 $k0 $14	# EPC
	eret		# Return from exception handler
	jr $k0


#==========================Sezione Utente
#---------------dati utente
.data
__mainstr: .asciiz "\nAvvio...\n"

#---------------istruzioni utente
	.text
	.globl __start
# indirizzo speciale per SPIM: qui inizia le esecuzioni:
# ci metto solo le necessarie inizializzazioni,
# poi chiamo come procedura il "main"
# poi chiedo a SPIM di terminare
__start: 

# stampo una stringa di apertura
	la $a0 __mainstr
        la $v0 4
        syscall

# abilita l'hw del video a generare Interrupt
                lw      $t1, 0xffff0008         # leggi attuale Transm. Control
                ori     $t1, $t1,     2         # bit 1 = INT enable 
                sw      $t1, 0xffff0008         # scrivi nuovo Transm. Control

# Abilitazione interrupt della CPU, in registro 12 coprocessore
                mfc0    $t4, $12                # Leggi in $t4 il CPU Status Rg.
                ori     $t4, $t4, 1             # abilita in generale gli INT
                ori     $t4, $t4, 0x800         # abilita il bit INT della tast.
                ori     $t4, $t4, 0x400         # abilita il bit INT del video
                mtc0    $t4, $12

# abilita l'hw della tastiera a generare Interrupt
                lw      $t1, 0xffff0000         # leggi attuale Receiver Control
                ori     $t1, $t1,     2         # bit 1 = INT enable 
                sw      $t1, 0xffff0000         # scrivi nuovo Receiver Control

	jal main

	li $v0 10
	syscall		# syscall 10 (exit)


# Qui inseriamo le istruzioni principali del programma, come procedura

###########################################################################
# Dichiarazione dei dati
.data

InDev:
  .word 0xffff0000    # indirizzo del control register del receiver
                      # l'indirizzo del data registrer del receveir e' 0xffff0004
                      # +4 byte rispetto al control register

OutDev:
  .word 0xffff0008    # indirizzo del control register del transmitter
                      # l'indirizzo del data registrer transmitter e' 0xffff000c
                      # +4 byte rispetto al control register

KBbuffer:
  .space 200          # buffer per input da tastiera

eol:  .asciiz "\n"


###########################################################################
# Codice
.text


#####################################
#           Funzione Main           #
#####################################
main:

  #Prologo
  subu  $sp, $sp, 24      # allocazione del record di attivazione
  sw    $ra, 16($sp)      # salva $ra


  #Corpo della Funzione
MainLoop:

  # Legge una stringa
  la    $a0, KBbuffer
  jal   ReadStre

  # Stampa la stringa ...
  la    $a0, KBbuffer
  jal   WriteStr

  # ... con un ritorno a capo
  la    $a0, eol
  jal   WriteStr

  # Test di uscita su stringa nulla
  la    $a0, KBbuffer
  lb    $t0, ($a0)
  bnez  $t0, MainLoop


  # Epilogo
  lw    $ra, 16($sp)      # ripristina $ra
  addu  $sp, $sp, 24      # deallocazione del record di attivazione

jr $ra
#####################################
#             Fine Main             #
#####################################


###############################################
#             Procedura GetCh                 #
#                                             #
# Riceve da tastiera 1 char                   # 
#                                             #
# IN:                                         #
#                                             #
# OUT:                                        #
#   $v0: carattere ricevuto da tastiera       #
###############################################
GetCh:
#>>>DA IMPLEMENTARE, consultare dati predisposti da gestore eccezioni<<<

jr $ra
#####################################
#          Fine GetCh               #
#####################################


###############################################
#             Procedura ReadStre              #
#                                             #
# Legge da tastiera finche' non si preme invio#
# e mette i caratteri in un buffer.           #
# Contemporaneamente scrive la stringa a      #
# schermo (echo).                             #
#                                             #
# IN:                                         #
#   $a0:  addr buffer per la stringa          #
#                                             #
# OUT:                                        #
###############################################
ReadStre:
  # Prologo
  subu  $sp, $sp, 32

  # Salva i registri
  sw    $s0, 16($sp)
  sw    $s1, 20($sp)
  sw    $s2, 24($sp)
  sw    $ra, 28($sp)
  sw    $a0, 32($sp)              # utile solo per il write immediato della stringa (non echo)


  # Corpo della Procedura
  move  $s0, $a0                  # salva $a0 in $s0

  # Ciclo di ricezione dei caratteri
CharRecLoop:
  jal GetCh
  move $s1, $v0


    # Ctrl fine stringa
    beq   $s1, 10, EndCharRecLoop # se char = "invio" esci dal ciclo
    beq   $s1, 13, EndCharRecLoop # se char = "invio" esci dal ciclo

    # Memorizzazione del char nel buffer
    sb    $s1, 0($s0)             # memorizza char nel buffer
    addi  $s0, 1                  # incrementa indice nel buffer

  j CharRecLoop

                         
EndCharRecLoop:
  sb    $0, 0($s0)                # terminazione della stringa con char '\0'

  # Epilogo
  # Ripristina i registri
  lw    $s0, 16($sp)
  lw    $s1, 20($sp)
  lw    $s2, 24($sp)
  lw    $ra, 28($sp)

  addi  $sp, $sp, 32

jr  $ra
###############################################
#                 Fine ReadStre               #
###############################################


###############################################
#             Procedura PutCh                 #
#                                             #
# Scrive a schermo 1 char                     # 
#                                             #
# IN:                                         #
#   $a0:  char da stampare                    #
#                                             #
# OUT:                                        #
###############################################
PutCh:
  lw    $t0, OutDev             # carica indirizzo del control register del transmitter
    lw    $t2, 0($t0)           # carica output control
    andi  $t2, $t2, 1           # maschero tutti i bit di control register tranne il
                                # bit 0 (ready bit del transmitter)
  beqz  $t2, suBuffer      # se transmitter non ready riponi il carattere nel buffer video

  sb    $a0, 4($t0)             # scrivi il carattere nel data register transmitter
  b finePutCh


suBuffer:
  la    $t0, aVideo             # carica indirizzo del buffer video
  sb    $a0, 0($t0)             # scrivi il carattere nel buffer

finePutCh:
jr $ra
###############################################
#                 Fine PutCh                  #
###############################################


###############################################
#             Procedura WriteStr              #
#                                             #
# Stampa una stringa (deve terminare con '\0')#
#                                             #
# IN:                                         #
#   $a0:  addr stringa da stampare            #
#                                             #
# OUT:                                        #
###############################################
WriteStr:
  # Prologo
  subu  $sp, $sp, 32

  # Salva i registri
  sw    $s0, 16($sp)
  sw    $s1, 20($sp)
  sw    $ra, 24($sp)

  move  $s0, $a0                  # salva $a0 in $s0

CharTransmLoop:
    lb    $s1, 0($s0)
    beqz  $s1, EndCharTransmLoop  # se il carattere e' 0 termina ciclo

    # Scrive il char a schermo
    move  $a0, $s1
    jal   PutCh
#pausa?

    addi  $s0, 1                  # incrementa indice della stringa

    b CharTransmLoop              # cicla

EndCharTransmLoop:
  # Epilogo
  # Ripristina i registri
  lw    $s0, 16($sp)
  lw    $s1, 20($sp)
  lw    $ra, 24($sp)

  addi  $sp, $sp, 32

jr $ra
###############################################
#                 Fine WriteStr               #
###############################################
