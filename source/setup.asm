	.text
gameSetup:
	add $sp, $sp, -4	# make room for items on the stack
	sw  $ra, 0($sp)		# saves the return address
	
	jal getFileName		# jump and link to get a random file.
	jal importFile		# jump and link to get a file to import
	jal fillDictionaryArray # fill the array with words
	jal getNineLetter	# gets the 9 letters to fill the box.
	jal randomizeWord	# randomizes them
	jal getCenterLetter	# saves the center letter used during the game (for word validation)
	
	lw  $ra, 0($sp)		# load the return address
	add $sp, $sp, 4		# restore the stack
	jr $ra
