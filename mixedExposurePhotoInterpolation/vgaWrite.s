.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

#r4 holds x value 0-320
#r5 holds y value 0-240
#r6 holds colour value 0x0 - 0xffff of TWO PIXELS
#r7 is pointer for current pixel buffer to draw to

.global vgaWrite
vgaWrite:
	
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
	
	/* pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032) */
	mov r8, r7
	slli r9, r4, 1  #shift x
	or r8, r8, r9	#add to buffer address
	slli r9, r5, 10	#shift y
	or r8, r8, r9	#add to buffer address
	stwio r6, 0(r8) #store two pixels
	
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