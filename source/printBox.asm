################################################################
#	|---+---+---|		Menu:
#	| 0 | 1 | 2 |		1. Shuffle letters.
#	|---+---+---|		2. Guess a word.
#	| 3 | 4 | 5 |		3. Quit.
#	|---+---+---|		-------------------
#	| 6 | 7 | 8 |		
#	|---+---+---|		Current Score: ####
#	Enter your choice:  
#
################################################################

# tons of syscalls ( yuck!! )
printWordBox:
	la $t0, wordInBox	# load wordInBox to $t0
	la $t1, currentScore	# load score
	
	# start printing box
	#top line
	la 	$a0, gridLong	# |---+---+---|
	li 	$v0, 4
	syscall
	
	################# menuLine1 if wanted, otherwise newline
	la 	$a0, menuLine1
	li 	$v0, 4
	syscall
	
	la 	$a0, gridLeft	# "\t| "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 0($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 1($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 2($t0)
	syscall
	
	la 	$a0, gridRight	# " \\t\t"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	la 	$a0, menuLine2
	li 	$v0, 4
	syscall
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	la 	$a0, menuLine3
	li 	$v0, 4
	syscall
	
	la 	$a0, gridLeft	# "\t| "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 3($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 4($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 5($t0)
	syscall
	
	la 	$a0, gridRight	# " \\t\t"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	la 	$a0, menuLine4
	li 	$v0, 4
	syscall
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	la 	$a0, menuLine5
	li 	$v0, 4
	syscall
	
	la 	$a0, gridLeft	# "\t| "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 6($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 7($t0)
	syscall
	
	la 	$a0, gridMiddle	# " \ "
	li 	$v0, 4
	syscall
	
	li	$v0, 11		# a character
	lb	$a0, 8($t0)
	syscall
	
	la 	$a0, gridRight	# " \\t\t"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	la 	$a0, newLine
	li 	$v0, 4
	syscall
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################ menu line or newline
	la 	$a0, scoreText
	li 	$v0, 4
	syscall

	currentScore
	li	$v0, 1		# a number
	lw	$a0, 0($t1)
	syscall
	
	la 	$a0, newLine
	li 	$v0, 4
	syscall
	
	la 	$a0, menuLineInput	# "Enter your choice:  "
	li 	$v0, 4
	syscall
	
	jr $ra		# return
