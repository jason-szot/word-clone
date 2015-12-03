# Menu:
# 1. Shuffle letters.
# 2. Guess a word.
# 3. Quit.
menuInput:
	la $t9, wordInBox
	subi $sp, $sp, 4	# move stack pointer
	sw $ra, ($sp)		# save return address to stack
	move $s0, $ra
	####	already asking for choice from menu, read int from user
	#li $v0, 5		# read int returns to $v0
	li $v0, 8
	la $a0, menuEntry
	li $a1, 2
	syscall
	lb $v1, 0($a0)
	li $v0, 11
	li $a0, 10
	syscall
	beq $v1, '1', shuffleJumpLink	# shuffle
	beq $v1, '2', getInput	# temp holder for user input of guess
	beq $v1, '3', quitMenu		# chose to quit, show quit screen and ask play again?
	j wrongMenuInput		# only 3 choices, otherwise its wrong
	
shuffleJumpLink:
	jal shuffleWord
	j menuJumpReturn
	
wrongMenuInput:
	la 	$a0, wrongMenuChoiceText
	li 	$v0, 4
	syscall
	j menuJumpReturn
	
menuJumpReturn:
	lw $ra, ($sp)		# load return address from stack
	addi $sp, $sp, 4	# move stack back
	move $ra, $s0
	jr $ra
