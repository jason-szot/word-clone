#	display score, ask to continue or not

# currentScore:   .word 0
# correctWords:	.word 0
# scoreText:	.asciiz "Current Score: "
# wordsFound:	.asciiz "Words Found: "
# newLine:	.asciiz "\n"
quitMenu:
	
	la $a0, newLine
	li $v0, 4
	syscall
	
	la $a0, scoreText
	li $v0, 4
	syscall
	
	la $t0, currentScore
	lw $a0, ($t0)
	li $v0, 1
	syscall
	
	la $a0, newLine
	li $v0, 4
	syscall
	
	##########################################################################################
	##	at this point, any other information wanted to display at quit screen goes below here
	##########################################################################################
	
	
	##########################################################################################
	##	and above here
	##########################################################################################
	
	la $a0, qMenuLine1
	li $v0, 4
	syscall
	
	la $a0, qMenuLine2
	li $v0, 4
	syscall
	
	la $a0, qMenuLine3
	li $v0, 4
	syscall
	
	la $a0, qMenuLine4
	li $v0, 4
	syscall
	
	li $v0, 5		# read int returns to $v0
	syscall
	beq $v0, 1, playAgain	# play again
	beq $v0, 2, endGame	# quit
