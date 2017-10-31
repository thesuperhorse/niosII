.global SetSteering

SetSteering:
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
	
	mov r16, r4 #temp stores parameter passed

	movi r4, 0x05 #sends in 5
	call WriteOneByteToUART
	mov r4, r16 #gets temp parameter
	call WriteOneByteToUART
	
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
