	.text

getInput:
	addi $sp, $sp, -4	# make room on the stack
	sw   $ra, 0($sp)	# save the return address
	la   $a0, getWord	
	li   $v0, 4		# system call for print string
	syscall
	
	la   $a0, userInput	# user input is the word being entered 
	la   $a1, userInput	
	li   $v0, 8		# system call for read string
	syscall
	
	move $s0, $v0		# move word into $s0
	jal  getLength		# call the getLength function from useful.asm
wrongUserInput:
	la $a0, invalidText
	li $v0, 4
	syscall
	j getInput
	
rightUserInput:
	la $a0, validText
	li $v0, 4
	syscall 
	
	# call update score since the word entered was correct. 
	
