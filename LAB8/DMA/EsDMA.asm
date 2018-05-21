#----------------------------------------------------------------
# Esempio di codice per trasferimento con tecnica DMA
# ESCLUSIVAMENTE A TITOLO DI SUPPORTO ED ESEMPLIFICAZIONE DELLA
# LEZIONE "TEORICA" sul DMA
# Codice NON UTILIZZABILE, perche' SPIM *NON* implementa il DMA
#
# write_text_transitter_DMA
#
# si tratta del codice di un pezzo di sistema operativo che mette
# a disposizione la funzione di scrittura di sequenze di caratteri
# la tecnica DMA; di fatto effettua la predisposizione del trasferimento
# nascondendo al programmatore in spazio utente i dettagli dei registri
# periferica usati per il trasferimento.
# il codice che chiama questa procedura avrà acquisito lo spazio in
# memoria per i dati e, dal momento che si tratta di un trasderimento
# in uscita, dalla memoria al mondo esterno, li avrà anche caricati
# in questo spazio di memoria (che chiamiamo buffer)
# questa procedura predispone il traferimento e poi lo attiva; dopo
# attiva delle altre procedure di sistema che, essendo fermo il
# programma che aspetta i dati, consente alla CPU di eseguire altre
# attività; cosa avviene in queste altre procedure di sistema non è
# oggetto di questo insegnamento, tranne il fatto che la CPU è in
# effetti libera di eseguire altro codice.
# Al termine del trasferimento, mediante altro codice, incluso il gestore
# delle eccesioni, a livello di sistema il codice che aspettava i dati
# verrà rimesso in esecuzione; a quel punto si uscirà da questa procedura
# e si ritornerà al codice utente che l'ha chiamata.
# parametri di chiamata:
# $a0 = indirizzo del buffer in cui si trovano i caratteri da inviare al
#       Transmitter
# $a1 = numero dei caratteri da inviare al Transmitter
# $a2 = dimensione in bytes del dato (0 = 1 byte, 1 = 4 byte)

.kdata
Transmitter_Base_Address:
	.word 0x80000010

.ktext
write_text_transitter_DMA:
	addiu	$sp, $sp, -32	# alloca il record di attivazione; nota: non sapendo se esista una zona stack per il ktext lasciamo dobbiosamente così, con lo stack di questa procedura di sistema condiviso con lo stack dei programmi utente, del resto si tratta di argomento da sistemi operativi...
	
	sw	$ra, 16($sp)	# salva indirizzo di ritorno
	sw	$t0, 20($sp)	# salva $t0 (NB se servono altri registri oltre ai $k)
	
	#-------------------------------------------------------
	# INIZIO PREDISPOSIZIONE DMA
	#-------------------------------------------------------
	# NB: si suppone che la periferica sia disponibile al trasferimento, nel senso che un eventuale trasferimento precedente deve essere già terminato
	la $k0, Transmitter_Base_Address	# indirizzo reg. stato della periferica => $k0
	# COMPLETARE LA PREDISPOSIZIONE DEL TRASFERIMENTO MEDIANTE TECNICA DMA
	# FINE PREDISPOSIZIONE DMA
	
	# ATTIVAZIONE DEL TRASFERIMENTO MEDIANTE DMA
	# Da questo punto in poi la periferica trasferirà i caratteri dalla memoria al Transmitter in modo AUTOMATICO e TRASPARENTE rispetto alle attività della CPU. Quindi il processore e' LIBERO DI PROSEGUIRE L'ESECUZIONE DI ALTRI PROGRAMMI
	# SI NOTI CHE NON SI SONO FATTE ATTESE A VUOTO (BUSY WAIT), NE' POLLING
	
	# RISPRISTINO REGISTRI 
	lw	$ra, 16($sp)	# ripristina indirizzo di ritorno
	lw	$t0, 20($sp)	# ripristina $t0 (NB se servono altri registri oltre ai $k)
	addiu $sp, $sp, 32
	jr $ra
#
#----------------------------------------------------------------