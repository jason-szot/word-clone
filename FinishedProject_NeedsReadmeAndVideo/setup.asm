gameSetup:
	li $s7, 0
	
	move $s0, $ra
	
	la $a0, header       #Print introduction/logo thing
	li $v0, 4
	syscall
	
	la $a0, helloLabel
	syscall
	
	jal getFileName		# jump and link to get a random file.
	jal importFile		# jump and link to get a file to import
	jal fillDictionaryArray # fill the array with words
	jal getNineLetter	# gets the 9 letters to fill the box.
	jal randomizeWord	# randomizes them
	jal getCenterLetter	# saves the center letter used during the game (for word validation)
	
	la $t0, correctWords	# set correctWords to zero
	sw $zero, ($t0)
	la $t0, currentScore
	sw $zero, ($t0)		# set currentScore to zero
	
	
	move $ra, $s0
	j jumpPrintBox
	jr $ra


debugLabel:
	la 	$a0, DBtext
	li 	$v0, 4
	syscall
	jr $ra
