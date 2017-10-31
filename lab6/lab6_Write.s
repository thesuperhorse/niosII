.equ JTAG, 0x10001020

.global WriteOneByteToUART

WriteOneByteToUART:
	addi sp, sp, -4 #saving ra
	stw ra, 0(sp)
	addi sp, sp, -32 #saving all callee saved registers
	stw r23, 28(sp)
	stw r22, 24(sp)
	stw r21, 20(sp)
	stw r20, 16(sp)
	stw r19, 12(sp)	
	stw r18,  8(sp)
	stw r17,  4(sp)
	stw r16,  0(sp)
	
	movia r8, JTAG # r8 now contains the base address

	WRITE_POLL:
	ldwio r9, 4(r8) # Load from the JTAG
	srli  r9, r9, 16 # Check only the write available bits
	beq   r9, r0, WRITE_POLL # If this is 0 (branch true), data cannot be sent */
	stwio r4, 0(r8) # Write the byte to the JTAG */

	ldw r23, 28(sp)
	ldw r22, 24(sp)
	ldw r21, 20(sp)
	ldw r20, 16(sp)
	ldw r19, 12(sp)	
	ldw r18,  8(sp)
	ldw r17,  4(sp)
	ldw r16,  0(sp)
	addi sp, sp, 32 #saving all callee saved registers
	
	ldw ra, 0(sp)
	addi sp, sp, 4 #saving ra
	
ret
