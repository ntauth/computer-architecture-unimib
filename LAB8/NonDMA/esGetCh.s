# N.B. - per usare il programma e' necessario attivare la modalita'       #
#        mapped I/O dello  Spim                                           #
#      - per funzionare e' necessario aprire la finestra di Console       #
#        prima di iniziare a digitare                                     #


###########################################################################
# Dichiarazione dati
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

  #Prologo: SALVO $ra
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
  # IMPLEMENTARE ... (con busy wait/polling)

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

    # Echo a schermo invocando PutCh ????

    # Ctrl fine stringa
    beq   $s1, 10, EndCharRecLoop # se char = "invio" esci dal ciclo
    beq   $s1, 13, EndCharRecLoop # se char = "invio" esci dal ciclo

    # Memorizzazione del char nel buffer
    sb    $s1, 0($s0)             # memorizza char nel buffer
    addi  $s0, 1                  # incrementa indice nel buffer

  j CharRecLoop

                         
EndCharRecLoop:
  sb    $0, 0($s0)                # terminazione della stringa con char '\0'

  # write immediato della stringa invocando WriteStr ????


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

  # Ciclo di attesa che la periferica sia pronta
  lw    $t0, OutDev             # carica indirizzo del control register del transmitter
BusyWaitPutCh:
    lw    $t2, 0($t0)           # carica output control
    andi  $t2, $t2, 1           # maschero tutti i bit di control register tranne il
                                # bit 0 (ready bit del transmitter)
  beqz  $t2, BusyWaitPutCh      # se transmitter non ready ripeti il loop di busy wait

  sb    $a0, 4($t0)             # scrivi il carattere nel data register transmitter

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
