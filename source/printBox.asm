################################################################
#	|---+---+---|		Menu:
#	| 0 | 1 | 2 |		1. Quit
#	|---+---+---|		2. Shuffle letters in box
#	| 3 | 4 | 5 |		3. blah
#	|---+---+---|		4. blah
#	| 6 | 7 | 8 |		5. blah
#	|---+---+---|
#	enter choice here: 
#
################################################################

# tons of syscalls ( yuck!! )
printWordBox:
	la $t0, wordInBox	# load wordInBox to $t0
	
	# start printing box
	#top line
	la 	$a0, gridLong	# |---+---+---|
	li 	$v0, 4
	syscall
	
	################# menuLine1 if wanted, otherwise newline
	
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
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	
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
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################# menu line or newline
	
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
	
	la $a0, gridLong	#  "|---+---+---|"
	li 	$v0, 4
	syscall
	
	################ menu line or newline
	
	jr $ra		# return