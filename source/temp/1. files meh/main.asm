
	# lexathon clone for SE 3340 Computer Architecture
	# Team name is THE POWER FRIENDS
	# Team members: Logan Morris, Jason Szot, Jamie Taylor, Eric Cooper
	
	##############################
	#####	Test program	######
	##############################
	
	.text
	
	.globl main
	
	.include "macros.asm"
	.include "setup.asm"
	.include "dictionary.asm"
	.include "printBox.asm"
	.include "menu.asm"
	.include "quitMenu.asm"
	.include "userWordInput.asm"
	
	main:
playAgain:
	jal gameSetup		# set game up
jumpPrintBox:
	jal debugLabel
	jal printWordBox	# print box
	jal menuInput		# user inputs number
	j jumpPrintBox		# loop up
	
	
	
endGame:
	li $v0, 10		# system call for end program. 
	syscall
	
	##############################
	###	useful functions   ###
	##############################
	
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

	##############################
	#####	Data Segment	######
	##############################
	
.data
		# main.asm variables/strings
header:		.asciiz "######## Lexathon #########\n"
helloLabel:	.asciiz " ** Welcome to Lexathon **"
startPrompt:	.asciiz "\n\n Would you like to start a new game?: "


# 	# validateInput.asm variables/strings (Jaimes part - all of this is just something for testing purposes )
getWord: 	.asciiz "\nEnter a word: "
		.align 2 
userInput:	.space 10 
invalidText:    .asciiz "That word isn't correct try again!"
		.align 2
validText: 	.asciiz "Word found! Good job!"	
		.align 2

	# userScore.asm variabels/strings
totalScore: 	.asciiz "\nTotal Score: "
currentScore:   .word 0
correctWords:	.word 0
scoreText:	.asciiz "Current Score: "
wordsFound:	.asciiz "Words Found: "
wordLength:	.word 6

	# importFile.asm variables/strings
contents: 	.space 50000 # 50K bytes reserved for contents.
buffer:		.space 500000
wordsCorrect: 	.space 50000
currentWord:	.asciiz "         " # <- 9 spaces..
wordArray:	.space 10000

###################### data needed for dictionary.asm
fileName:
	.asciiz	"A "
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
	.align	4
	.space 50000
totalPossibleWords:
	.word 0
CenterLetter:
	.byte 'A'
null:
	.byte 0x00

##################### for printBox.asm
gridLong:
	.asciiz "\t|---+---+---|\t\t"
gridLeft:
	.asciiz "\t| "
gridMiddle:
	.asciiz " | "
gridRight:
	.asciiz " |\t\t"
newLine:
	.asciiz "\n"

###################### Prints for when the program is loading certain aspects of operation
loadingFilePrint:
	.asciiz "Reading dictionary file ...\n"
loadingIntoMemoryPrint:
	.asciiz "Loading words into memory ...\n"

##################### Menu lines
menuLine1:
	.asciiz "Menu:\n"
menuLine2:
	.asciiz "1. Shuffle letters.\n"
menuLine3:
	.asciiz "2. Guess a word.\n"
menuLine4:
	.asciiz "3. Quit.\n"
menuLine5:
	.asciiz "-------------------\n"
menuLineInput:
	.asciiz "Enter your choice:  "
wrongMenuChoiceText:
	.asciiz "\nSorry that is not a correct choice\n"
qMenuLine1:
	.asciiz "Play again?\n"
qMenuLine2:
	.asciiz "Enter 1 to play again.\n"
qMenuLine3:
	.asciiz "Enter 2 to quit.\n"
qMenuLine4:
	.asciiz "Enter your choice ( 1 or 2 ): "


####### debugging
DBtext:
	.asciiz "randomize Routine\n"