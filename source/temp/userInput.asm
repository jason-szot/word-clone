
getInput:
	#addi $sp, $sp, -4	# make room on the stack
	#sw   $ra, 0($sp)	# save the return address
	la   $a0, getWord	
	li   $v0, 4		# system call for print string
	syscall
	
	la   $a0, userInput	# user input is the word being entered 
	la   $a1, userInput	
	li   $v0, 8		# system call for read string
	syscall
	
	li   $v0, 4		# system call for print string
	#syscall
	move $s0, $a0		# move word into $s0
	jal allCapsBegin
	la $a0, userInput
	syscall
	#jr $ra
	#j compareWordsBegin
	
#############################
	
 compareWordsBegin:
 lw $t0, totalPossibleWords #get the totalPossibleWords, which is how many words there are multiplied by 4 basically
 add $a0, $t0, $zero	#Move value to $a0
 li $t0, 0		#Set $t0 to 0, because it is a counter
compareWords: 
  add $t1, $zero, $zero                    #reset the offset counter 
  beq $t0, $a0, wrongUserInput             #indicates that the user input was not found in the dictionary
  la $t7, correctWordsPointerArray($t0)        #$t7 points to the index of correctWordsPointerArray that holds the address of a string
  addi $t0, $t0, 4                         #counter for how many words have been checked
  lw $t6, ($t7)                       #$t6 points to the base address of a string
#testloop:
#add $t5, $t6, $t1
#lb $t4, ($t5)
#add $a0, $t4, $zero
#li $v0, 11
#syscall
#addi $t1, $t1, 1
#j testloop
comparisonLoop:
  add $t5, $t6, $t1                      #points to the character at the $t1-th spot in the loaded string ($t1 = i in String[i])
  lb $t4, ($t5)                           #loads that character into $t4
  add $s1, $s0, $t1                       #Points to the character in the same position from the user input
  lb $s2, ($s1)                           #Loads the character into $s2
  addi $t1, $t1, 1                         #increment position
  beq $t4, $s2, checkNull                 #If the 2 are the same character, check to see if they are both newline
  bne $t4, $s2, compareWords                #If not, go to the next word in the array, as the user input is not equal to this one



checkNull:
  beq $t4, 10, moveToFoundWords         #Check to see if this word has been entered before, as it is a correct word
  j comparisonLoop

moveToFoundWords: 
  add $t5, $zero, $zero
  add $t4, $zero, $zero
  add $t0, $zero, $zero           #clear counters


#$t5 is the offset for $t3 and $s0
#$t4 contains the character that $t3 is pointing to
#$t3 points to an individual character in the wordArray string
#$t2 points to a base address of a string
#$t1 points to the wordArray offset by $t0
#$t0 is the offset for wordArray
#$s2 contains the character pointed to by $s1
#$s1 points to a character in the user input
#$s0 contains the user input
compareFoundWords: 
  add $t4, $zero, $zero				#Reset $t4
  beq $t0, $s7, addToFoundWords                     #The word was not found in wordArray, so it is a new correct word that must be entered
  la $t1, wordArray($t0)                            #load wordArray[i], where $t0 is i
  addi $t0, $t0, 4                                  #increment wordArray offset
  lw $t2, ($t1)                             	#t2 points to base address of a string
comparisonLoop2:
  add $t3, $t2, $t5                                #Points to character at the $t5-th offset of the string pointed to by $t2
  lb $t4, ($t3)                                     #Load character into $t4
  add $s1, $s0, $t5                                 #Point to character in same position from user input
  lb $s2, ($s1)                                     #Load character into $s2
  addi $t5, $t5, 1                                  #Increment counter
  beq $t4, $s2, checkNull2                          #If they are equal, check to see if they are both '0', that means they are the same string
  bne $t4, $s2, compareFoundWords                   #If not, move on to the next string in the array


checkNull2:
  beq $t4, 10, wrongUserInput                        #If they are the same string, the string has been entered before
  j comparisonLoop2

addToFoundWords:        #$s7 stores the offset needed to find an empty space in the wordArray array. You can store a new word at that offset.
  beq $t0, $s7, addWord 
  addi $t0, $t0, 4                               #Continuously add 4 to $t0 until it equals $s7
addWord:
  lw $t7, ($t7)				#$t7 loads the address that it was previously pointing to
  sw $t7, wordArray($t0)                    # Store this address in the wordArray
  addi $s7, $s7, 4                          # Increment $s7
  j rightUserInput
  
  
  ####################################################################
  wrongUserInput:
	la $a0, invalidText
	li $v0, 4
	syscall #Tell the user that their word was wrong, go back to show the grid again probably
	j printJumpLink
	
rightUserInput:
	la $a0, validText
	li $v0, 4
	syscall #Same thing, but tell them that they were right
	j printJumpLink
