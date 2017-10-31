.equ RED_LEDS, 0xFF200000   # (Hint: See DESL website for documentation on LEDs/Switches)

.data                  # "data" section for input and output lists

.align 2			#Need to allign to word for storage of large numbers
IN_LIST:               # List of 10 words starting at location IN_LIST
    .word 1
    .word -1
    .word -2
    .word 2
    .word 0
    .word -3
    .word 100
    .word 0xffffff9c
    .word 0x100
    .word 0b1111

.align 2    
IN_LINKED_LIST:           # Used only in Part 3
    A: .word 1,           B
    B: .word -1,          C
    C: .word -2,          E + 8
    D: .word 2,           A - 0x1000
    E: .word 0,           K
    F: .word -3,          G
    G: .word 100,         J
    H: .word 0xffffff9c,  D + 4
    I: .word 0x100,       H
    J: .word 0b1111,      IN_LINKED_LIST + 0x40
    K: .word 1234,        0
    
    
OUT_NEGATIVE:
    .skip 40            # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40            # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for (read-only) code

    # Register allocation:
    #   r0 is zero, and r1 is "assembler temporary". Not used here.
    #   r2  Holds the number of negative numbers in the list
    #   r3  Holds the number of non-negative numbers in the list
    #   r4  A pointer to IN_LINKED_LIST
    #   r5  A pointer to OUT_NEGATIVE
    #   r6  A pointer to OUT_POSITIVE
	#	r7	length of list
	#	r8	full cycle counter
	#	r9  
    #   r16 Register for short-lived temporary values.
	#   r17 Register for short-lived temporary values.
    #   etc...

.global _start
_start:

	mov r2,r0 #initialize number of negative values
	mov r3,r0 #initialize number of positive values
	movia r4,IN_LINKED_LIST # store IN_LINKED_LIST address into r4
	movia r5,OUT_NEGATIVE # store OUT_NEGATIVE address into r5
	movia r6,OUT_POSITIVE # store OUT_POSITIVE address into r6
	mov r7, r4 #store first pointer in linked list
	mov r8, r0 #initialize r8 as counter
	movi r9, 10 #list number
	
    
    # Begin loop to process each number
    
        # Process a number here:
        #    if (number is positive) { 
        #        insert number in OUT_POSITIVE list
        #        increment count of non-negative values (r3)
        #    } else {
        #        insert number in OUT_NEGATIVE list
        #        increment count of negative values (r2)
        #    }
        # Done processing.

LOOP:
	bge r8,r9,LOOP_FOREVER # test for end of IN_LIST
	ldw r17,0(r7) # move value at pointer address r7 into r17
	beq r17, r0, LOOP_FOREVER #if value == 0 program terminates ********PART2*******
	bge r17,r0,POSITIVE # if r17 >= 0 then POSITIVE
	
	# if (negative)
	stw r17, 0(r5) # store r17 value into value at r5
	addi r5,r5,4 # increment list pointer 4 per word
	addi r2,r2,1 # increment number of negative numbers
	br INCREMENT
	
POSITIVE:
	stw r17, 0(r6) # store r17 value into value at r5
	addi r6,r6,4 # increment list pointer 4 per word
	addi r3,r3,1 # increment number of non-negative numbers
	br INCREMENT

INCREMENT:
	ldw r7, 4(r7) #store next pointer in r7
	addi r8,r8,1 # increment index by 1
	br OUTPUT

OUTPUT:
    # After processing each number, output current counts to LEDs.
	# (You'll learn more about I/O in Lab 4.)
    movia  r16, RED_LEDS          # r16 and r17 are temporary values
    ldwio  r17, 0(r16)
    addi   r17, r17, 1
    stwio  r17, 0(r16)
    # Finished output to LEDs.
	br LOOP	
	
LOOP_FOREVER:
    br LOOP_FOREVER                   # Loop forever.
    
#*****Notes*****
	
#bne r6,r0,TryAgain
#if(r6 =/= 0) go to TryAgain

#bgt r9,r3,loop
#if(r9>r3) go to loop (treated as unsigned values)

#beq r8,r5,thenpart (if equal, thenpart)
