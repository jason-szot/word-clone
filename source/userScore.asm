# method to track/update players score based on words matched upon input
# file userScore.asm
# variables :
#	$s7 is the saved score
#
#

getScore:
	move $a0, $s7 		# move the current score into $a0 to update
updateScore:
	# calculate the score
	addi $s7, $s7, 5 	# just adds 5 points to the current score
outputScore:
	la $a0, scoreText	# system call for print string (Score label)
	li $v0, 4
	syscall
	
	la $a0, ($s7)		# system call for print integer (numeric score).
	li $v0, 1		# print the score
	syscall
	 
	jr $ra	# jump return address  
	
