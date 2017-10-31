 #/*********
 # 
 # Write the assembly function:
 #     printn ( char * , ... ) ;
 # Use the following C functions:
 #     printHex ( int ) ;
 #     printOct ( int ) ;
 #     printDec ( int ) ;
 # 
 # Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you don't need to look up ASCII values.
 #********/
 
 #when function first called
 #r4 contains pointer to string of chars
 #r5 first number
 #r6 second number
 #r7 third number
 #r8 number is duplicated, rest in stack
 
 # r8 'D'
 # r9 'H'
 # r10 'O'
 

.global	printn
printn:
	# Prologue
	#throw all parameters into stack
	mov r8, sp #number to keep track of stack shifts
	addi sp, sp, -24
	stw r7, 20(sp)	#more values after
	stw r6, 16(sp)	#values
	stw r5, 12(sp)	#first value
	stw r4,  8(sp)	#text
	stw ra,  4(sp)  #ra
	stw r8,  0(sp)  #first sp
	#1 first sp
	#2 ra 
	#3 text 
	#4 all follow after
	
LOOP:

	ldw r4, 12(sp) #4 stack -> number to output
	ldw r5, 8(sp) #3 stack -> text ptr
	ldw r6, 4(sp) #2 stack -> return address
	ldw r7, 0(sp) #1 stack -> first sp
	ldb r8, 0(r5) #dereference char pointer (text)
	beq r8, r0, END #if == 0 then terminate else
	addi r5, r5, 1 #*(text + 1)
	stw r5, 12(sp) #text -> 4 stack
	stw r6, 8(sp) #return address -> 3 stack
	stw r7, 4(sp) #first sp -> 2 stack
	stw r0, 0(sp) #clear 1 stack
	addi sp, sp, 4 #move stack pointer down
	
	#letter registers to compare
	movi r9, 'D'
	beq r8, r9, PDEC
	movi r9, 'H'
	beq r8, r9, PHEX
	movi r9, 'O'
	beq r8, r9, POCT
	br LOOP

PDEC:
call printDec
br LOOP

PHEX:
call printHex
br LOOP

POCT:
call printOct
br LOOP

END:
	mov ra, r6 #store ra back
	mov sp, r7 #move sp back to original
	ret

