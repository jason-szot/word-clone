# reading the dictionary file

############################################################

# get a file name to load
getFileName:
	li $vo, 41		# 41 is rand int
	syscall
	divu $t0, $a0, 26	# mod by 26 ( number of letters )
	mfhi $v0		# move from hi (rand MOD 26)
	addi $vo, $vo, 'A'	# convert rand mod 26 to capital letter
	la $t1, fileName	# fileName loaded into $t1
	sb $v0, ($t1)		# store letter in fileName[0]
	sb $0, 1($t1)		# store NULL in fileName[1]
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
	la $a1, dictionary	# address of dictionary space
	li $a2, 500000		# buffer size ( largest file size is 614kb )
	syscall			# read from the file
	li $v0, 16		# 16 is close file
	move $a0, $t9		# file descriptor to close
	syscall
	jr $ra			# return

###########################################################
# $a0 is scanner position
# $a1 is i for dictionaryArray[i]
# $v1 is wordCount
# fill the dictionary array of pointers
fillDictionaryArray:
	la $a0, dictionary	# dictionary space pointer in $a0 ( scanner )
	la $a1, dictionaryArray	# dictionaryArray[0] in $a1
	sw $a0, (a1)		# store pointer position to dictionaryArray[0]
	add $v1, $0, $0		# wordCount stored in $v1, initialize to 0
	add $v1, $v1, 1		# add 1 to wordCount
	add $a1, $a1, 4		# $a1 i for dictionaryArray[i]
fillDictionaryArrayLoop:
	lb $t0, ($a0)		# load byte from dictionary ( letter )
	beq $t0, 0, fillDictionaryArrayReturn	# return if hit NULL
	bne $t0, 10, fillSkipped	# didnt hit newline, move forward
	sb $zero, ($a0)		# replace newline with NULL
	add $a0, $a0, 1		# scanner++
	sw $a0, (a1)		# dictionaryArray[i] = scanner
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
getNineLetter:
	subi $sp, $sp, 4	# move stack pointer
	sw $ra, ($sp)		# store return address on the stack
	la $t9, dictionaryArray	# load address of dictionary array into $t9
getNineLetLoop:
	lw $a0, lengthOfList	# load length of the word list to $a0 for random number function
	jal randNum		# get a random number returned to $v0
	move $t8, $v0		# store random number in $t8
	WordArray ($a0, $t9, $t8)	# picks a random word from the word array, stores in $a0
	jal getLength		# gets length of word in $a0, returns to $v1
	beq $v1, 10, getNineLetrReturn	# if $v1 = 10, it found the 9 letter word, jump to return
	j getNineLetLoop	# go back to loop again, look for 9 letter word
getNineLetReturn:
	la $s3, wordInBox	# load address of space to $s3
	move $s4, $t8		# move random number to $s4
	WordArray ($s2, $t9, $s2)	
	li $t0, 0		# store zero in $t0 ( counter )
getNineLetReturnLoop:
	beq $t0, 11, fillCorrectArray	# when counter hits 11, jump to filling the array
	lb $t1, ($s2)		# load letter from $s2 into $t1
	sb $t1, ($s3)		# store letter into wordInBox
	add $s3, $s3, 1		# increment wordInBox space by 1
	add $s2, $s2, 1		# increment pointer to letter by 1
	add $t0, $t0, 1		# increment counter
	j getNineLetReturnLoop	# loop
fillCorrectArray:

fillCorrectArrayFindTop:
	addi $s4, $s4, -1	# reduce the randum number by 1
	
	WordArray ($a0, $t9, $s4)	# get a letter from the $s4 position of the list
	lb $t0, ($a0)		# load the letter to $t0
	beq $t0, '*', fillCorrectTopFound	# the * is the seperator between word lists
	j fillCorrectArrayFindTop	# loop up, * not found
fillCorrectTopFound:
	li $t0, 0		# set $t0 to zero
	addi $s4, $s4, 2	# add 2 to the number in $s4
	la $s5, correctWordsPointerArray	# load address of the words array to $s5
fillCorrectArrayloop:
	WordArray ($a0, $t9, $s4)	# store letter address in $a0
	lb $t0, ($a0)		# load letter to $t0
	beq $t0, '*', fillCorrectArrayReturn	# end of words for this 9 letter word
	sw $t0, ($s5)		# store letter address to correctWordsPointerArray[i]
	