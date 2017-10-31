.section .text
.global HDR

#r4 contains low exposure
#r5 contains high exposure

HDR:
	subi sp, sp, 4 #saving ra
	stw ra, 0(sp)
	subi sp, sp, 32 #saving all callee saved registers
	stw r23, 28(sp)
	stw r22, 24(sp)
	stw r21, 20(sp)
	stw r20, 16(sp)
	stw r19, 12(sp)	
	stw r18,  8(sp)
	stw r17,  4(sp)
	stw r16,  0(sp)
	
	
INIT:
	mov r12, r4	#r12 is low exposure address
	addi  r12, r12, 0x36 #skip the header
	mov r13, r5	#r12 is HDR exposure address
	addi  r13, r13, 0x36 #skip the header
	#load buffer address from global address register
	ldwio r7, 4(r16)
	#bottom left corner
	mov r4, r0			#x-value (0) -> 0
	movui r5, 0xef		#y-value (239) -> ef
 	movui r8, 0x13e  	#max x-value (320) -> 140
	movui r9, 0x0		#min y-value (0) -> 0
	
	
	
LoopY:
	mov r4, r0						#starts at x = 0
LoopX:
	
	#because data is encoded backwards BGR instead of RGB
	#second pixel
	mov r6, r0		#clears r6
	
	ldbu r10, 3(r12) #load first byte B8
	ldbu r11, 3(r13) #load first byte B8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xf8  #1111 1000 B5 mask
	slli r11, r11, 13
	or r6, r6, r11  #place into r6


	ldbu r10, 4(r12) #load second byte G8
	ldbu r11, 4(r13) #load second byte G8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xfc  #1111 1100 G6 mask
	slli r11, r11, 19
	or r6, r6, r11 #place into r6
	

	ldbu r10, 5(r12) #load third byte R8
	ldbu r11, 5(r13) #load third byte R8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xf8  #1111 1000 R5 mask
	slli r11, r11, 24
	or r6, r6, r11 #place into r6

	
	#first pixel
	ldbu r10, 0(r12) #load first byte B8
	ldbu r11, 0(r13) #load first byte B8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xf8  #1111 1000 B5 mask
	srli r11, r11, 3
	or r6, r6, r11 #place into r6
	

	ldbu r10, 1(r12) #load second byte G8
	ldbu r11, 1(r13) #load second byte G8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xfc  #1111 1100 G6 mask
	slli r11, r11, 3
	or r6, r6, r11 #place into r6
	

	ldbu r10, 2(r12) #load third byte R8
	ldbu r11, 2(r13) #load third byte R8
	srli r10, r10, 1 #average
	srli r11, r11, 1
	add r11, r11, r10
	andi r11, r11, 0xf8  #1111 1000 R5 mask
	slli r11, r11, 8
	or r6, r6, r11 #place into r6
	
	
	#saving all caller saved registers
	subi sp, sp, 32
	stw r15, 28(sp)
	stw r14, 24(sp)
	stw r13, 20(sp)
	stw r12, 16(sp)
	stw r11, 12(sp)	
	stw r10,  8(sp)
	stw r9,  4(sp)
	stw r8,  0(sp)
	
	#r7 is buffer address
	#r6 is 2 pixel colour
	#r4 & r5 are the x and y locations
	call vgaWrite
	
	#popping all caller saved registers
	ldw r15, 28(sp)
	ldw r14, 24(sp)
	ldw r13, 20(sp)
	ldw r12, 16(sp)
	ldw r11, 12(sp)	
	ldw r10,  8(sp)
	ldw r9,   4(sp)
	ldw r8,   0(sp)
	addi sp, sp, 32
	
	addi r12, r12, 6	#move 6 bytes over (2pixels)
	addi r13, r13, 6	#move 6 bytes over (2pixels)
	
	beq r4, r8, subY 	#hits maximum x value goes to next y-value
	addi r4, r4, 2 		#else increments x-value by two (prints two pixels)
	br LoopX 			#writes the next pixel value

subY:
	beq r5, r9, POLL_VGA_STATUS		#hits manimum y value ends the function
	subi r5, r5, 1		#else decrements y-value by one
	br LoopY
	
	
POLL_VGA_STATUS:					# poll vga status for ready to swap
	ldwio r11, 12(r16)				#load VGA status
	andi r11, r11, 0x1				#mask all bits but 0
	bne r11, r0, POLL_VGA_STATUS	#if not 0, not ready to swap
	movi r11, 0x1					#0(r16) holds BUFFER
	stwio r11, 0(r16)				#swaps

End:
	ldw r23, 28(sp)
	ldw r22, 24(sp)
	ldw r21, 20(sp)
	ldw r20, 16(sp)
	ldw r19, 12(sp)	
	ldw r18,  8(sp)
	ldw r17,  4(sp)
	ldw r16,  0(sp)
	addi sp, sp, 32 #loading back all callee saved registers
	ldw ra, 0(sp)
	addi sp, sp, 4 #loading back ra
ret