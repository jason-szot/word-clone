# reading the dictionary file

############################################################

# get a file name to load
getFileName:
	li $v0, 41		# 41 is rand int
	syscall
	divu $t0, $a0, 26	# mod by 26 ( number of letters )
	mfhi $v0		# move from hi (rand MOD 26)
	addi $v0, $v0, 'A'	# convert rand mod 26 to capital letter
	la $t1, fileName	# fileName loaded into $t1
	sb $v0, ($t1)		# store letter in fileName[0]
	sb $zero, 1($t1)		# store NULL in fileName[1]
	jr $ra			# return

############################################################

# import file into dictionary space
importFile:
	li $v0, 13		# 13 is open file
	la $a0, fileName	# file name to open
	li $a1, 0		# open reading mode
	li $a2, 0
	syscall			# open file, file descriptor returned to $v0
	move $t9, $v0		# file descriptor saved in $t9
	####### print reading dictionary file
	li $v0, 4
	la $a0, loadingFilePrint
	syscall
	li $v0, 14		# read from file is 14
	move $a0, $t9		# file descriptor back to $a0
	la $a1, dictionary	# address of dictionary space
	li $a2, 500000		# buffer size ( largest file size is 614kb )
	syscall			# read from the file
	li $v0, 16		# 16 is close file
	move $a0, $t9		# file descriptor back to $a0
	syscall			
	jr $ra			# return


###########################################################
# $a0 is scanner position
# $a1 is i for dictionaryArray[i]
# $v1 is wordCount
# fill the dictionary array of pointers
fillDictionaryArray:
	li $v0, 4
	la $a0, loadingIntoMemoryPrint
	syscall
	la $a0, dictionary	# dictionary space pointer in $a0 ( scanner )
	la $a1, dictionaryArray	# dictionaryArray[0] in $a1
	sw $a0, ($a1)		# store pointer position to dictionaryArray[0]
	li $v1, 0		# wordCount stored in $v1, initialize to 0
	add $v1, $v1, 1		# add 1 to wordCount
	add $a1, $a1, 4		# $a1 i for dictionaryArray[i]
fillDictionaryArrayLoop:
	lb $t0, ($a0)		# load byte from dictionary ( letter )
	beq $t0, 0, fillDictionaryArrayReturn	# return if hit NULL
	bne $t0, 10, fillSkipped	# didnt hit newline, move forward
	#lb $v0, null
	#sb $v0, ($a0)		# replace newline with NULL
	add $a0, $a0, 1		# scanner++
	sw $a0, ($a1)		# dictionaryArray[i] = scanner
	add $a1, $a1, 4		# i++
	add $v1, $v1, 1		# wordCount++
	j fillDictionaryArrayLoop
fillSkipped:		# scanner ++ routine
	add $a0, $a0, 1		# scanner++
	j fillDictionaryArrayLoop
fillDictionaryArrayReturn:	# dictionary array is completely loaded
	sw $v1, lengthOfList	# store wordCount
	jr $ra

#############################################

# get a 9 letter word from the dictionary array
# $s2 - $s6 used in this routine, save on stack and restore before return
getNineLetter:
	subi $sp, $sp, 24	# move stack pointer
	sw $ra, ($sp)		# store return address on the stack
	sw $s2, 4($sp)		# store $s2 in stack
	sw $s3, 8($sp)		# store $s3 on stack
	sw $s4, 12($sp)		# store $s4 on stack
	sw $s5, 16($sp)		# store $s5 on stack
	sw $s6, 20($sp)		# store $s6 to stack
	la $t9, dictionaryArray	# load address of dictionary array into $t9
	li $s6, 0		# set $s6 to zero
getNineLetLoop:
	lw $a0, lengthOfList	# load length of the word list to $a0 for random number function
	jal randNum		# get a random number returned to $v0
	move $s6, $v0		# store random number in $s6
	WordArray ($a0, $t9, $s6)	# picks a random word from the word array, stores in $a0
	jal getLength		# gets length of word in $a0, returns to $v1
	beq $v1, 10, getNineLetReturn	# if $v1 = 10, it found the 9 letter word, jump to return
	addi $s6, $s6, 1	
	j getNineLetLoop	# go back to loop again, look for 9 letter word
getNineLetReturn:
	la $s3, wordInBox	# load address of space to $s3
	move $s4, $s6		# move random number to $s4
	WordArray ($s2, $t9, $s4)	
	li $t0, 0		# store zero in $t0 ( counter )
getNineLetReturnLoop:		# saves the 9 letter word to wordInBox
	beq $t0, 11, fillCorrectArray	# when counter hits 9, jump to filling the array
	lb $t1, ($s2)		# load letter from $s2 into $t1
	sb $t1, ($s3)		# store letter into wordInBox
	add $s3, $s3, 1		# increment wordInBox space by 1
	add $s2, $s2, 1		# increment pointer to letter by 1
	add $t0, $t0, 1		# increment counter
	j getNineLetReturnLoop	# loop
fillCorrectArray:

fillCorrectArrayFindTop:
	addi $s4, $s4, -1	# reduce the randum number by 1
	
	WordArray ($a0, $t9, $s4)	# get a letter from the $s4 position of the list, should be the * character before the 9 letter word
	lb $t0, ($a0)		# load the letter to $t0
	beq $t0, '*', fillCorrectTopFound	# the * is the seperator between word lists
	j fillCorrectArrayFindTop	# loop up, * not found
fillCorrectTopFound:
	li $t0, 0		# set $t0 to zero
	addi $s4, $s4, 2	# add 2 to the number in $s4
	la $s5, correctWordsPointerArray	# load address of the words array to $s5
	li $t7, 0		# counter for number of words correct  correct = 0
fillCorrectArrayLoop:
	WordArray ($a0, $t9, $s4)	# store letter address in $a0
	lb $t0, ($a0)		# load letter to $t0
	beq $t0, '*', fillCorrectArrayReturn	# end of words for this 9 letter word
	sw $t0, ($s5)		# store letter address to correctWordsPointerArray[i]
	add $t7, $t7, 1		# counter++
	addi $s4, $s4, 1		# increment pos for wordArray[pos]
	addi $s5, $s5, 4		# increment correctWordsPointerArray
	j fillCorrectArrayLoop		# loop
fillCorrectArrayReturn:
	la $t9, totalPossibleWords	# load address of wordcount to $t9
	sw $t7, ($t9)			# store counter to totalPossibleWords
	
	# load info back from stack
	lw $ra, ($sp)		# load return address from stack
	lw $s2, 4($sp)		# load $s2 from stack
	lw $s3, 8($sp)		# load $s3 from stack
	lw $s4, 12($sp)		# load $s4 from stack
	lw $s5, 16($sp)		# load $s5 from stack
	lw $s6, 20($sp)		# load $s6 from stack
	subi $sp, $sp, 20	# move stack pointer
	jr $ra			# return

##############################################################

# randomize the word to be shown
# rand int mod 9 swap pos 0-8 with rand num mod 9 
# DOES NOT RETAIN CENTER LETTER

# AGAIN DOES NOT RETAIN CENTER LETTER.. USE SHUFFLE FOR THAT

randomizeWord:
	add $t0, $zero, $zero	# initialize counter to zero ( will be pos to swap )
	add $t9, $zero, $zero	# for randomizer counter ( want to run this routine 5 times )
randomWordLoop:
	beq $t9, 5, randomWordDone	# randomized 5 times
	addi $v0, $zero, 30	# get time
	syscall
	addi $v0, $zero, 40	# set seed for random from return of time
	syscall
	addi $v0, $zero, 41	# random int return to $a0
	syscall
	move $t1, $a0		# save rand number to $t1
	addi $t2, $zero, 9	# for mod 9
	divu $t1, $t2		# $t1 mod $t2 ( randint MOD 9
	mfhi $t1		# number saved to $t1
	beq $t0, 8, randomWordReturn	# case to exit
	# swap $t0 letter with $t1 letter
	lb $t3, wordInBox($t0)	# load char at $t0 to $t3
	lb $t4, wordInBox($t1)	# load char at $t1 to $t4
	sb $t3, wordInBox($t1)	# store char from $t3 to $t1
	sb $t4, wordInBox($t0)	# store char from $t4 to $t0
	# characters swapped
	addi $t0, $t0, 1	# counter++
	j randomWordLoop	# loop up
randomWordReturn:
	addi $t9, $t9, 1	# add to random counter
	j randomWordLoop	# randomize again
randomWordDone:
	jr $ra			# return
	
	
##########################################################

# shuffle - same algorithm as randomize, but leave spot 4 alone

shuffleWord:
	add $t0, $zero, $zero		# initialize $t0 to zero ( pos to swap )
shuffleWordLoop:
	beq $t0, 9, shuffleWordReturn	# done with shuffle
	beq $t0, 4, shuffleIncreaseCounter	# to save center letter
	li $v0, 30			# get time
	syscall
	li $v0, 40			# set seed for random from return of time
	syscall
	li $v0, 41			# random int return to $a0
	syscall
	move $t1, $a0		# save rand number to $t1
	li $t2, 9		# for mod 9
	divu $t1, $t2		# $t1 mod $t2 ( randint MOD 9
	mfhi $t1		# number saved to $t1
	bne $t1, 4, shuffleContinue	# saves center letter
	j shuffleWordLoop	# loop up, random number was 4
shuffleContinue:
	beq $t0, $t1, shuffleWordLoop	# same position, wouldnt swap
	# swap characters in $t0 and $t1 positions
	lb $t3, wordInBox($t0)	# load char at $t0 to $t3
	lb $t4, wordInBox($t1)	# load char at $t1 to $t4
	sb $t3, wordInBox($t1)	# store char from $t3 to $t1
	sb $t4, wordInBox($t0)	# store char from $t4 to $t0
	# characters swapped
shuffleIncreaseCounter:
	addi $t0, $t0, 1	# counter += 1
	j shuffleWordLoop	# jump back to loop
shuffleWordReturn:
	jr $ra			# returnn to $ra

################################################################

# get the center letter
# CenterLetter = wordInBox[4]
getCenterLetter:
	la $t0, wordInBox	# load address of 9 letter char array
	lb $t1, 4($t0)		# load character from pos 4
	sb $t1, CenterLetter	# store character in variale CenterLetter
	jr $ra			# return
	
