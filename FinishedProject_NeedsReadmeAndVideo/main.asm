
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
	#jal debugLabel
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
	move $a1, $a0    #move $a0 to $a1 to serve as upper bound
	li $a0, 0        #Lower bound 0
	li   $v0, 42       # random int range, range is representative of how big the dictionaryArray is
	syscall
	
	move $v0, $a0	#Move the resultant random number to $v0
	jr $ra
	
########################################
#takes a string at $a0 and reads the length.
#t0 is scanner, t1 is couter, t2 is scanners held value.
#Retuns length in v1 
getLength:
	add $t0, $a0, $zero #scanner
	li $t1, 0 #counter
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
header:		.asciiz "################# Lexathon #################\n"
helloLabel:	.asciiz " ** Welcome to Lexathon, by THE POWER FRIENDS **\n"
#startPrompt:	.asciiz "\n\n Would you like to start a new game?: "


# 	# validateInput.asm variables/strings (Jaimes part - all of this is just something for testing purposes )
getWord: 	.asciiz "\nEnter a word that is between 4 and 9 characters, and contains the center letter of the box: "
		.align 2 
userInput:	.space 10 	#For user's string entry
menuEntry:	.space 2 	#For user's menu option selection
invalidText:    .asciiz "*That word is either incorrect, does not contain the center letter, or has been entered before. Try again!*\n"
		.align 2
validText: 	.asciiz "*Word found! Good job!*\n"	
		.align 2

	# userScore.asm variabels/strings
totalScore: 	.asciiz "\nTotal Score: "
currentScore:   .word 0
correctWords:	.word 0
scoreText:	.asciiz "Current Score: "
wordsFound:	.asciiz "Words Found: "
wordLength:	.word 6

	# importFile.asm variables/strings
#contents: 	.space 50000 # 50K bytes reserved for contents.
#buffer:		.space 500000
wordsCorrect: 	.space 50000
currentWord:	.asciiz "         " # <- 9 spaces..
gottenWords: .space 50000
###################### data needed for dictionary.asm
fileName:
	.asciiz	"  .txt"
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
	.asciiz "Make a choice from the menu:  "
wrongMenuChoiceText:
	.asciiz "\n*Sorry, that is not a correct choice. Please choose one of the menu options.*\n"
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
