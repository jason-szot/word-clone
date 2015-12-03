# main.asm
# this will be the file that the user opens, assembles to run the program and play the game.
# variables and necessary labels are at the bottom under .data to use in each of the included files.
		.text 
		.globl main
		
		.include "macro.asm"	
		.include "dictionary.asm"
		.include "useful.asm"
		.include "compareWords.asm"
		.include "validateInput.asm"
		.include "setup.asm"
		.include "printBox.asm"

main:
	
playGame:
	sw  $s7, currentScore    	# stores current score in (will be $s7) - start of game score is 0
	la  $t9, totalPossibleWords     # jason is using $t9 for the possible words 
	li  $t0, 60			# 60 seconds into $t0 for the timer
	jal gameSetup			# jump and link to gameSetup (saves $ra)
	jal printWordBox		# print out the word box
startGame:
	addi $sp, $sp, -4	# make room on the stack
	sw   $ra, 0($sp)	# saves the return address
exitGame:
	li $v0, 10		# system call for end program. 
	syscall



############################################################
################	data for program	############
############################################################
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
#fileName: 	.asciiz "C:\\Users\\coope_000\\Desktop\\Lexathon\\A.txt"
contents: 	.space 50000 # 50K bytes reserved for contents.
buffer:		.space 500000
wordsCorrect: 	.space 50000
currentWord:	.asciiz "         " # <- 9 spaces..
wordArray:	.space 10000

###################### data needed for dictionary.asm
fileName:
	.asciiz	"    "
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

##################### for printBox.asm
gridLong:
	.asciiz "\n\t|---+---+---|\t\t"
gridLeft:
	.asciiz "\t| "
gridMiddle:
	.asciiz " | "
gridRight:
	.asciiz " |\t\t"

###################### Prints for when the program is loading certain aspects of operation
loadingFilePrint:
	.asciiz "Reading dictionary file ... "
loadingIntoMemoryPrint:
	.asciiz "Loading words into memory ... "

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
