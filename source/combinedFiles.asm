######### macros for the program ##########

# WordArray
# %x is register to save pointer location to
# %y is array[0] location
# %z is a number to get an entry ( array[z] )
.macro WordArray (%x, %y, %z)
sll $t8, %z, 2		# num = num / 4
add $t8, %y, $t8	# %t8 = array[num]
lw %x, ($t8)		# pointer = array[num]
.end_macro

.data
###################### Prints for when the program is loading certain aspects of operation
loadingFilePrint:
	.asciiz "Reading dictionary file ... "
loadingIntoMemoryPrint:
	.asciiz "Loading words into memory ... "
###################### data needed for dictionary.asm
fileName:
	.asciiz"  .txt"
dictionary:
	.space 500000
dictionaryArray:
	.align	2
	.space 368000
lengthOfList:
	.word	0
wordInBox:
	.align	0
	.space 10
correctWordsPointerArray:
	.align	2
	.space 50000
totalPossibleWords:
	.word 0
CenterLetter:
	.byte 'A'

##################### for printBox.asm
gridLong:
	.asciiz "\n\t|---+---+---|\t\t\n"
gridLeft:
	.asciiz "\t| "
gridMiddle:
	.asciiz " | "
gridRight:
	.asciiz " |\t\t\n"
.text


	
# reading the dictionary file

############################################################

# get a file name to load
getFileName:
	li $v0, 42		# 42 is rand int
	li $a0, 0
	li $a1, 25
	syscall
	addi $a0, $a0, 65
	#divu $t0, $a0, 26	# mod by 26 ( number of letters )
	#mfhi $v0		# move from hi (rand MOD 26)
	#addi $v0, $v0, 'A'	# convert rand mod 26 to capital letter
	la $t1, fileName	# fileName loaded into $t1
	sb $a0, ($t1)		# store letter in fileName[0]
	sb $zero, 1($t1)		# store NULL in fileName[1]
	lb $a0, fileName
	
	#jr $ra			# return

############################################################

# import file into dictionary space
importFile:
	li $v0, 13		# 13 is open file
	la $a0, fileName	# file name to open
	li $a1, 0		# open reading mode
	li $a2, 0
	syscall			# open file, file descriptor returned to $v0
	move $t9, $v0		# file descriptor saved in $t9
	li $v0, 4
	la $a0, loadingFilePrint
	syscall
	li $v0, 14
	move $a0, $t9
	la $a1, dictionary	# address of dictionary space
	li $a2, 500000		# buffer size ( largest file size is 614kb ) 500000
	syscall			# read from the file
	li $v0, 16		# 16 is close file
	move $a0, $t9		# file descriptor to close
	syscall
	#jr $ra			# return

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
	#addi $a0, $a0, 1		Something I was using to skip the first *, probably not needed
	sw $a0, ($a1)		# store pointer position to dictionaryArray[0]
	add $v1, $0, $0		# wordCount stored in $v1, initialize to 0
	add $v1, $v1, 1		# add 1 to wordCount
	add $a1, $a1, 4		# $a1 i for dictionaryArray[i]
fillDictionaryArrayLoop:
	lb $t0, ($a0)		# load byte from dictionary ( letter )
	####
	#addi $sp, $sp, -4
	#sw $a0, ($sp)
	#add $a0, $zero, $t0	This printed out words as they were read by the scanner, I was using this for testing
	#li $v0, 11
	#syscall
	#lw $a0, ($sp)
	#addi $sp, $sp, 4
	####
	beq $t0, 0, fillDictionaryArrayReturn	# return if hit NULL
	bne $t0, 10, fillSkipped	# didnt hit newline, move forward
	sb $zero, ($a0)		# replace newline with NULL
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
	#jr $ra

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
	add $s6, $zero, $zero
getNineLetLoop:
	lw $a0, lengthOfList	# load length of the word list to $a0 for random number function
	jal randNum		# get a random number returned to $v0
	move $s6, $v0		# store random number in $t8
	WordArray ($a0, $t9, $s6)	# picks a random word from the word array, stores in $a0
	jal getLength		# gets length of word in $a0, returns to $v1
	beq $v1, 9, getNineLetReturn	# if $v1 = 9, it found the 9 letter word, jump to return
	addi $s6, $s6, 1
	j getNineLetLoop	# go back to loop again, look for 9 letter word
getNineLetReturn:
	la $s3, wordInBox	# load address of space to $s3
	move $s4, $s6		# move random number to $s4
	WordArray ($s2, $t9, $s4)	
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
fillCorrectArrayLoop:
	WordArray ($a0, $t9, $s4)	# store letter address in $a0
	lb $t0, ($a0)		# load letter to $t0
	beq $t0, '*', fillCorrectArrayReturn	# end of words for this 9 letter word
	sw $t0, ($s5)		# store letter address to correctWordsPointerArray[i]
	lw $t8, totalPossibleWords	# load wordCount for correct words in $t8
	addi $s4, $s4, 1		# increment pos for wordArray[pos]
	addi $s5, $s5, 4		# increment correctWordsPointerArray
	j fillCorrectArrayLoop		# loop
fillCorrectArrayReturn:
	
getNineLetReturn2:
	lw $ra, ($sp)		# load return address from stack
	lw $s2, 4($sp)		# load $s2 from stack
	lw $s3, 8($sp)		# load $s3 from stack
	lw $s4, 12($sp)		# load $s4 from stack
	lw $s5, 16($sp)		# load $s5 from stack
	lw $s6, 20($sp)		# load $s6 from stack
	subi $sp, $sp, 20	# move stack pointer
	j randomizeWord
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
	j printWordBox
	jr $ra			# return
	
##########################################################

# shuffle - same algorithm as randomize, but leave spot 4 alone

shuffleWord:
	add $t0, $zero, $zero		# initialize $t0 to zero ( pos to swap )
shuffleWordLoop:
	beq $t0, 9, shuffleWordReturn	# done with shuffle
	beq $t0, 4, shuffleIncreaseCounter	# to save center letter
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

###########################################################################################
#a0 gives the upper limit too use. v0 is the output.
randNum:
	move $a1, $a0    #NEW
	li $a0, 0        #NEW
	li   $v0, 42       # random int
	syscall
	#divu $t0, $a0, $t9   #mod the length        
	#mfhi $v0
	move $v0, $a0
	jr $ra
	
########################################
#takes a string at $a0 and reads the length.
#t0 is scanner, t1 is couter, t2 is scanners held value.
#Retuns length in v1 
getLength:
	add $t0, $a0, $zero
	li $t1, 0
getLengthLoop:	
	lb $t2, ($t0)
	beq $t2, 0, getLengthReturn
	add $t1, $t1, 1 #advance counter
	add $t0, $t0, 1 #advance scanner
	j getLengthLoop
getLengthReturn:
	move $v1, $t1
	jr $ra
