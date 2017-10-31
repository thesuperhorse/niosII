.global ReadSensors

ReadSensors:
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
	

	movia r4, 0x02 #passsing in parameter
	call WriteOneByteToUART
POLL:
	call ReadOneByteFromUART
	bne r2,r0,POLL #checking for polling
	call ReadOneByteFromUART # returns sensor
	mov r3, r2 #storing the values
	call ReadOneByteFromUART # returns speed
	mov r2, r2
	mov r8,r2
	mov r9,r2
	mov r10,r2
	mov r11,r2
	mov r12,r2
	mov r13,r2
	mov r14,r2
	mov r15,r2
	#r2 is speed (unsigned)
	#r3 is sensors (bitwise)

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
