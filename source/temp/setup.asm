
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
	la $t0, correctWordCount
	li $t1, 0
	sw $t1, ($t0)
	jr $ra
	
