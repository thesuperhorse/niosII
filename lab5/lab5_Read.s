.equ JTAG, 0x10001020

.global ReadOneByteFromUART

ReadOneByteFromUART:
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
	

	movia r8, JTAG #r8 now contains the base address
	READ_POLL:
	ldwio r9, 0(r8) # Load from the JTAG */
	andi  r2, r9, 0x8000 # Mask other bits */
	beq   r2, r0, READ_POLL # If this is 0 (branch true), data is not valid */
	andi  r2, r9, 0x00FF # Data read is now in r10 */
	
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
