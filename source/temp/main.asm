	.text
	#########################################################
	#########	Includes for other files	#########
	#########################################################
	
	.include "macros.asm"
	.include "dictionary.asm"
	.include "setup.asm"
	.include "printBox.asm"
	#.include "userInput.asm"
	.include "useful.asm"
	.include "validation.asm"

	#########################################################
	############	Program Main Section	#################
	#########################################################
	.globl main
	
main:
playAgain:
	jal gameSetup		# setup the game
printJumpLink:
	jal printWordBox	# pring grid
	j getInput		# get input and validate


	#########################################################
	#########	Data for all parts of program	#########
	#########################################################
	
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
	.asciiz "A "
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
	.asciiz "\t|---+---+---|\t\t\n"
gridLeft:
	.asciiz "\t| "
gridMiddle:
	.asciiz " | "
gridRight:
	.asciiz " |\t\t\n"
newLine:
	.asciiz "\n"

#################### Logan stuff
userInput: .space 20   #Holds user's entered string
wordArray:
	.align 2
	.space 50000 #Array of correct words that have already been entered by the user
validText: .asciiz "That's a correct word!\n"
invalidText: .asciiz "Sorry, that word was either incorrect or has been used already.\n"

## added to help with validation

correctUserInput:	# compare pointers, not entire words
	.align 2
	.word 0

correctWordCount:	# count of correct words in wordArray
	.align 2
	.word 0