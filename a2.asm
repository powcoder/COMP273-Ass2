https://powcoder.com
代写代考加微信 powcoder
Assignment Project Exam Help
Add WeChat powcoder
https://powcoder.com
代写代考加微信 powcoder
Assignment Project Exam Help
Add WeChat powcoder
# TODO: PUT YOUR NAME AND STUDENT NUMBER HERE!!!
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE



# Menu options
# r - read text buffer from file 
# p - print text buffer
# e - encrypt text buffer
# d - decrypt text buffer
# w - write text buffer to file
# q - quit

.data
MENU:              	.asciiz "Commands (read, print, encrypt, decrypt, write, quit):"
REQUEST_FILENAME:  	.asciiz "Enter file name:"
REQUEST_KEY: 	 	.asciiz "Enter key (a integer between -10 and 10):"
ERROR:		 		.asciiz "There was an error.\n"

FILE_NAME: 			.space 256		# maximum file name length, should not be exceeded
TEXT_BUFFER:  		.space 10000 	# pre-allocate some space for the text

##############################################################
.text
	move $s1 $0 	# Keep track of the buffer length (starts at zero)

MainLoop:	
	li $v0 4		# print string
	la $a0 MENU
	syscall
	
	li $v0 12		# read char into $v0
	syscall
	
	move $s0 $v0	# store command in $s0			
	jal PrintNewLine

	beq $s0 'r' read
	beq $s0 'p' print
	beq $s0 'w' write
	beq $s0 'e' encrypt
	beq $s0 'd' decrypt
	beq $s0 'q' exit
	b MainLoop

read:		
	jal GetFileName
	li $v0 13		# open file
	la $a0 FILE_NAME 
	li $a1 0		# flags (read)
	li $a2 0		# mode (set to zero)
	syscall
	
	move $s0 $v0
	bge $s0 0 read2	# negative means error
	li $v0 4		# print string
	la $a0 ERROR
	syscall
	
	b MainLoop
		
read2:		
	li $v0 14		# read file
	move $a0 $s0
	la $a1 TEXT_BUFFER
	li $a2 9999
	syscall
	
	move $s1 $v0	# save the input buffer length
	bge $s0 0 read3	# negative means error
	li $v0 4		# print string
	la $a0 ERROR
	syscall
	
	move $s1 $zero	# set buffer length to zero
	la $t0 TEXT_BUFFER
	sb $0 ($t0) 	# null terminate the buffer 
	b MainLoop
	
read3:		
	la $t0 TEXT_BUFFER
	add $t0 $t0 $s1
	sb $0 ($t0) 	# null terminate the buffer that was read
	li $v0 16		# close file
	move $a0 $s0
	syscall
	la $a0 TEXT_BUFFER
	jal ToUpperCase

print:		
	la $a0 TEXT_BUFFER
	jal PrintBuffer
	b MainLoop	

write:		
	jal GetFileName
	li 	$v0 13			# open file
	la 	$a0 FILE_NAME 
	li 	$a1 1			# flags (write)
	li 	$a2 0			# mode (set to zero)
	syscall
	
	move $s0 $v0
	bge $s0 0 write2	# negative means error
	li $v0 4			# print string
	la $a0 ERROR
	syscall
	b MainLoop
	
write2:	
	li $v0 15			# write file
	move $a0 $s0
	la $a1 TEXT_BUFFER
	move $a2 $s1		# set number of bytes to write
	syscall
	
	bge $v0 0 write3	# negative means error
	li $v0 4			# print string
	la $a0 ERROR
	syscall
	
	b MainLoop
	
write3:
	li $v0 16				# close file
	move $a0 $s0
	syscall
	b MainLoop

encrypt:		
	jal GetKey 				# get number of offset
	move $a1, $v0 			# copy the user input to $s1
	la 	$a0 TEXT_BUFFER 	# load the address of TEXT_BUFFER to $a0
	jal EncryptMessage 		# start encrypt the message
	la 	$a0 TEXT_BUFFER 	# load the address of TEXT_BUFFER to $a0
	jal PrintBuffer 		# print the message
	b 	MainLoop 			# jump back to the main loop

decrypt:		
	jal GetKey				# get number of offset
	move $a1, $v0			# copy the user input to $s1
	la $a0 TEXT_BUFFER 		# load the address of TEXT_BUFFER to $a0
	jal DecryptMessage 		# start decrypt the message
	la $a0 TEXT_BUFFER 		# load the address of TEXT_BUFFER to $a0
	jal PrintBuffer 		# print the message
	b MainLoop 				# jump back to the main loop

exit:	
	li $v0 10 	# exit
	syscall

###########################################################
PrintBuffer:	
	li $v0 4        # print contents of a0
	syscall
	li $v0 11		# print newline character
	li $a0 '\n'
	syscall
	jr $ra

###########################################################
PrintNewLine:	
	li $v0 11	# print char
	li $a0 '\n'
	syscall
	jr $ra

###########################################################
PrintSpace:	
	li $v0 11	# print char
	li $a0 ' '
	syscall
	jr $ra

#######################################################
GetFileName:	
	addi $sp $sp -4
	sw $ra ($sp)
	li $v0 4			# print string
	la $a0 REQUEST_FILENAME
	syscall
	
	li $v0 8			# read string
	la $a0 FILE_NAME  	# up to 256 characters into this memory
	li $a1 256
	syscall
	
	la 	$a0 FILE_NAME 
	jal TrimNewline
	lw 	 $ra ($sp)
	addi $sp $sp 4
	jr $ra

###########################################################
GetKey:		
	addi $sp $sp -4
	sw 	$ra ($sp)
	li 	$v0 4			# print string
	la 	$a0 REQUEST_KEY
	syscall
	
	li $v0 5			# read integer
	syscall
	
	lw $ra ($sp)
	addi $sp $sp 4
	jr $ra

###########################################################
# Given a null terminated text string pointer in $a0, if it contains a newline
# then the buffer will instead be terminated at the first newline
TrimNewline:	
	lb 	$t0 ($a0)
	beq $t0 '\n' TNLExit
	beq $t0 $0 TNLExit	# also exit if find null termination
	addi $a0 $a0 1
	b TrimNewline
		
TNLExit:		
	sb $0 ($a0)
	jr $ra

##################################################
# converts the provided null terminated buffer to upper case
# $a0 buffer pointer
ToUpperCase:	
	lb $t0 ($a0)
	beq $t0 $zero TUCExit
	blt $t0 'a' TUCSkip
	bgt $t0 'z' TUCSkip
	addi $t0 $t0 -32	# difference between 'A' and 'a' in ASCII
	sb $t0 ($a0)
	
TUCSkip:		
	addi $a0 $a0 1
	b ToUpperCase
	
TUCExit:		
	jr $ra





#####################################################################
#                     END OF PROVIDED CODE... 
#####################################################################




#####################################################################
# EncryptMessage
# $a0: the memory address of the message
# $a1: the key (size of the offset chosen by the user) 
# $s1: the number of characters in the message
#===================================================================#



EncryptMessage:	
	
# TODO: Put your implemententation for EncryptMessage here.	
	
	
	
	
	
#===================================================================#
#            DO NOT TOUCH THIS LINE
#===================================================================#
	jr $ra # DO NOT TOUCH THIS LINE

######################################################################
# DecryptMessage
# $a0: the memory address of the message
# $a1: the key (size of the offset chosen by the user) 
# $s1: the number of characters in the message
#===================================================================#



DecryptMessage:	

# TODO: Put your implemententation for DecryptMessage here.

		
			
#===================================================================#
	jr $ra # DO NOT TOUCH THIS LINE
