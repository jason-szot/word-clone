
gameSetup:

	move $s7, $ra
	jal scoreSetup
	jal getFileName
	jal importFile
	jal fillDictionaryArray
	jal getNineLetter
	jal randomizeWord
	jal getCenterLetter
	move $ra, $s7
	jr $ra
	
scoreSetup:		# set score data to zero
	#### no score data as of yet
	jr $ra
	