#THE POWER FRIENDS - Logan Morris, Jason Szot, Jamie Taylor, Eric Cooper
#NOTE: The Mars.jar has to be in the same directory as the dictionary files for it to work


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
###################### Prints for when the program is loading certain aspects of operation, etc.
loadingFilePrint:
	.asciiz "Reading dictionary file ... \n"
loadingIntoMemoryPrint:
	.asciiz "Loading words into memory ... \n"
getWord:
.asciiz "Enter a string between 4 and 9 characters (must contain the center character): "
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

#################### Logan stuff
userInput: .space 10   #Holds user's entered string
wordArray: .space 50000 #Array of correct words that have already been entered by the user
validText: .asciiz "That's a correct word!\n"
invalidText: .asciiz "Sorry, that word was either incorrect or has been used already.\n"
.text


	
# reading the dictionary file

############################################################

# get a file name to load
getFileName:
	li $v0, 42		# 42 is rand int range
	li $a0, 0
	li $a1, 25		#Range is 0-25, because there are 26 letters
	syscall
	addi $a0, $a0, 65	#Add 65 to the random int to get a capital letter
	#divu $t0, $a0, 26	# mod by 26 ( number of letters )
	#mfhi $v0		# move from hi (rand MOD 26)
	#addi $v0, $v0, 'A'	# convert rand mod 26 to capital letter
	la $t1, fileName	# fileName loaded into $t1
	sb $a0, ($t1)		# store letter in fileName[0]
	sb $zero, 1($t1)		# store NULL in fileName[1]
	lb $a0, fileName	#TESTING INSTRUCTION, PRETTY SURE THIS ISN'T NEEDED
	
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
	la $a0, loadingFilePrint #Prints out to the user to show that the file is being read
	syscall
	li $v0, 14
	move $a0, $t9		#Move file descriptor into $a0, so it knows what to read
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
	la $a0, loadingIntoMemoryPrint #Shows the user that the file has been read and is now being stored into memory
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
	#sb $zero, ($a0)		# replace newline with NULL
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
	add $s6, $zero, $zero	#Make sure $s6 is zero before it is worked with
getNineLetLoop:
	lw $a0, lengthOfList	# load length of the word list to $a0 for random number function
	jal randNum		# get a random number returned to $v0
	move $s6, $v0		# store random number in $s6
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
	addi $s4, $s4, 2	# add 2 to the number in $s4  (Moves it to the first word in a partition)           
	la $s5, correctWordsPointerArray	# load address of the words array to $s5
fillCorrectArrayLoop:
	WordArray ($a0, $t9, $s4)	# store letter address in $a0
	lb $t0, ($a0)		# load letter to $t0
	beq $t0, '*', fillCorrectArrayReturn	# end of words for this 9 letter word
	sw $a0, ($s5)		# store letter address to correctWordsPointerArray[i]
	lw $t8, totalPossibleWords	# load wordCount for correct words in $t8
	addi $t8, $t8, 4		#NEW, add 4 to totalPossibleWords
	sw $t8, totalPossibleWords	#NEW, store new value
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
	
	#jr $ra		# return


getInput:
	#addi $sp, $sp, -4	# make room on the stack
	#sw   $ra, 0($sp)	# save the return address
	la   $a0, getWord	
	li   $v0, 4		# system call for print string
	syscall
	
	la   $a0, userInput	# user input is the word being entered 
	la   $a1, userInput	
	li   $v0, 8		# system call for read string
	syscall
	li   $v0, 4		# system call for print string
	syscall
	move $s0, $a0		# move word into $s0
	jal allCapsBegin
	la $a0, userInput
	syscall
	#jr $ra
	j compareWordsBegin
	
#############################
	
 compareWordsBegin:
 lw $t0, totalPossibleWords #get the totalPossibleWords, which is how many words there are multiplied by 4 basically
 add $a0, $t0, $zero	#Move value to $a0
 li $t0, 0		#Set $t0 to 0, because it is a counter
compareWords: 
  add $t1, $zero, $zero                    #reset the offset counter 
  beq $t0, $a0, wrongUserInput             #indicates that the user input was not found in the dictionary
  la $t7, correctWordsPointerArray($t0)        #$t7 points to the index of correctWordsPointerArray that holds the address of a string
  addi $t0, $t0, 4                         #counter for how many words have been checked
  lw $t6, ($t7)                       #$t6 points to the base address of a string
#testloop:
#add $t5, $t6, $t1
#lb $t4, ($t5)
#add $a0, $t4, $zero
#li $v0, 11
#syscall
#addi $t1, $t1, 1
#j testloop
comparisonLoop:
  add $t5, $t6, $t1                      #points to the character at the $t1-th spot in the loaded string ($t1 = i in String[i])
  lb $t4, ($t5)                           #loads that character into $t4
  add $s1, $s0, $t1                       #Points to the character in the same position from the user input
  lb $s2, ($s1)                           #Loads the character into $s2
  addi $t1, $t1, 1                         #increment position
  beq $t4, $s2, checkNull                 #If the 2 are the same character, check to see if they are both newline
  bne $t4, $s2, compareWords                #If not, go to the next word in the array, as the user input is not equal to this one



checkNull:
  beq $t4, 10, moveToFoundWords         #Check to see if this word has been entered before, as it is a correct word
  j comparisonLoop

moveToFoundWords: 
  add $t5, $zero, $zero
  add $t4, $zero, $zero
  add $t0, $zero, $zero           #clear counters


#$t5 is the offset for $t3 and $s0
#$t4 contains the character that $t3 is pointing to
#$t3 points to an individual character in the wordArray string
#$t2 points to a base address of a string
#$t1 points to the wordArray offset by $t0
#$t0 is the offset for wordArray
#$s2 contains the character pointed to by $s1
#$s1 points to a character in the user input
#$s0 contains the user input
compareFoundWords: 
  add $t4, $zero, $zero				#Reset $t4
  beq $t0, $s7, addToFoundWords                     #The word was not found in wordArray, so it is a new correct word that must be entered
  la $t1, wordArray($t0)                            #load wordArray[i], where $t0 is i
  addi $t0, $t0, 4                                  #increment wordArray offset
  lw $t2, ($t1)                             	#t2 points to base address of a string
comparisonLoop2:
  add $t3, $t2, $t5                                #Points to character at the $t5-th offset of the string pointed to by $t2
  lb $t4, ($t3)                                     #Load character into $t4
  add $s1, $s0, $t5                                 #Point to character in same position from user input
  lb $s2, ($s1)                                     #Load character into $s2
  addi $t5, $t5, 1                                  #Increment counter
  beq $t4, $s2, checkNull2                          #If they are equal, check to see if they are both '0', that means they are the same string
  bne $t4, $s2, compareFoundWords                   #If not, move on to the next string in the array


checkNull2:
  beq $t4, 10, wrongUserInput                        #If they are the same string, the string has been entered before
  j comparisonLoop2

addToFoundWords:        #$s7 stores the offset needed to find an empty space in the wordArray array. You can store a new word at that offset.
  beq $t0, $s7, addWord 
  addi $t0, $t0, 4                               #Continuously add 4 to $t0 until it equals $s7
addWord:
  lw $t7, ($t7)				#$t7 loads the address that it was previously pointing to
  sw $t7, wordArray($t0)                    # Store this address in the wordArray
  addi $s7, $s7, 4                          # Increment $s7
  j rightUserInput
  
  
  ####################################################################
  wrongUserInput:
	la $a0, invalidText
	li $v0, 4
	syscall #Tell the user that their word was wrong, go back to show the grid again probably
	j getInput
	
rightUserInput:
	la $a0, validText
	li $v0, 4
	syscall #Same thing, but tell them that they were right
	j getInput
###########################################################################################
#a0 gives the upper limit too use. v0 is the output.
randNum:
	move $a1, $a0    #NEW
	li $a0, 0        #NEW 
	li   $v0, 42       # random int range, range is representative of how big the dictionaryArray is
	syscall
	#divu $t0, $a0, $t9   #mod the length        
	#mfhi $v0
	move $v0, $a0	#Move the resultant random number to $v0
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
	beq $t2, 10, getLengthReturn
	add $t1, $t1, 1 #advance counter
	add $t0, $t0, 1 #advance scanner
	j getLengthLoop
getLengthReturn:
	move $v1, $t1
	jr $ra
	
######################################
#Makes a string all-caps (string is in $s0
allCapsBegin:
li $t1, 0  #$t1 will be a counter to go through the string with
allCaps:
add $t2, $s0, $t1 #Move $t2 to element of string
lb $t3, ($t2) #Load the character
beq $t3, 10, allCapsReturn #newline = end of string, finish the function
bge $t3, 97, makeCapital #If its 97 or greater, it is a lowercase letter. Make it capital
addi $t1, $t1, 1
j allCaps
makeCapital:
addi $t3, $t3, -32  #lowercase letter - 32 = uppercase letter in ASCII
sb $t3, ($t2)	#Store the uppercase letter
addi $t1, $t1, 1
j allCaps
allCapsReturn:
jr $ra

exit:
