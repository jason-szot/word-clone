## routines that would be useful to many parts

###########################################################################################
#a0 gives the upper limit too use. v0 is the output.
randNumber:
	move $t9, $a0
	li   $v0, 41       # random int
	syscall
	divu $t0, $a0, $t9   #mod the length        
	mfhi $v0
	jr $ra
	
########################################
#takes a string at $a0 and reads the length.
#t0 is scanner, t1 is counter, t2 is scanners held value.
#Retuns length in v1 
getLength:
	add $t0, $a0, $zero
	li $t1, 0
getLengthLoop:	
	lb $t2, ($t0)
	beq $t2, 0, getLengthReturn
	add $t1, $t1, 1 #advance counter
	add $t0, $t0, 1 #advance scanner
	j getLengthLoop
getLengthReturn:
	move $v1, $t1
	jr $ra
