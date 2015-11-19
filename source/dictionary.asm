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

