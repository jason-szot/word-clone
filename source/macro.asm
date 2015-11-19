######### macros for the program ##########

# WordArray
# %x is register to save pointer location to
# %y is array[0] location
# %z is a number to get an entry ( array[z] )
.macro WordArray (%x, %y, %z)
sll $t8, %z, 2		# num = num / 4
add $t8, %y, %t8	# %t8 = array[num]
lw %x, ($t7)		# pointer = array[num]
.end_macro