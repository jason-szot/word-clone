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

endGame:
	li $v0, 10		# system call for end program. 
	syscall