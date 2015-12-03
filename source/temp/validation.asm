
### user input stuff - jason

getInput:	# works fine
	la   $a0, getWord	
	li   $v0, 4		# system call for print string
	syscall
	la   $a0, userInput	# user input is the word being entered 
	li $a1, 20
	li   $v0, 8		# system call for read string
	syscall
	li   $v0, 4		# system call for print string
	move $s0, $a0		# move word into $s0
	jal allCapsBegin
	la $a0, userInput
	
#############################
#	I did it for the LOLZ
#	-Jason
compareWordsBegin:
	la $t0, totalPossibleWords 		#get the totalPossibleWords, which is a correct word count
	lw $a0, ($t0)				#Move value to $a0
	li $t0, 0				#Set $t0 to 0,  using as a counter
compareWords: 
	la $t1, userInput			# user input saved in $t1
	la $s0, correctWordsPointerArray	# address of words array loaded to $s0
compareLoop1:
	sll $t7, $t0, 2
	add $t2, $t7, $s0
	lb $t3, ($t1)				# load character from user input
	lb $t4, ($t2)				# load character from word array
	bne $t3, $t4, mismatchHandler		# characters are different
	beq $t4, 10, correctHandler		# word found ( all characters same and newline is hit )
	add $t1, $t1, 1				# increment user input char pointer
	add $t2, $t2, 1				# increment word array char pointer
	j compareLoop1
	
mismatchHandler:
	beq $t0, $a0, wrongUserInput		# reached the last word, word not found, so wrong
	add $t0, $t0, 1				# incremet $t0
	j compareWords				# jump back to comparing words
	
correctHandler:					# correct word, check if is in wordArray
	la $a0, validText
	li $v0, 4
	syscall #Same thing, but tell them that they were right
	la $v0, correctUserInput		# address to pointer to correct word in correctWordsPointerArray
	lw $v0, ($v0)				# store pointer to the word in $v0
	la $t2, totalPossibleWords		# load address of totalPossibleWords to $t2
	lw $t2, ($t2)				# store value of totalPossibleWords to $t2
	li $t3, 0				# counter = 0
	la $t0, wordArray			# load address of wordArray
	la $v1, correctWordCount
	lw $v1, ($v1)
findInWordArrayloop1:
	WordArray ($a0, $t0, $t3)		# $a0 = address of wordArray[i]
	bne $a0, $v0, wordNotFound		# word not same, handle it
	beq $a0, $v0, wrongUserInput		# word already guessed
wordNotFound:
	beq $t3, $v1, wordNotInList		# word not in the list, add it to it
	add $t3, $t3, 1				# increment counter
	j findInWordArrayloop1
wordNotInList:					# word not in the list, add it to it
	add $t4, $v1, $zero			# copy correctWordCount to $t4
	sll $t4, $t4, 2				# mult by 4 for posistioning
	add $t5, $t4, $t0			# wordArray[max]
	sw $v0, ($t5)				# add it to the end of woordArray
	j rightUserInput			# jump to correct routine

####################################################################
wrongUserInput:
	la $a0, invalidText
	li $v0, 4
	syscall #Tell the user that their word was wrong, go back to show the grid again probably
	j printJumpLink
	
rightUserInput:
	la $a0, validText
	li $v0, 4
	syscall #Same thing, but tell them that they were right
	j printJumpLink
