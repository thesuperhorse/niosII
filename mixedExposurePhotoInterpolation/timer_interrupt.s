#Timer interrupt handler
#.equ DISP, 0x03FBFFF8 #display location
.section .data 
.align 1
Snail3:
.incbin "snail3.bin"
Snail4:
.incbin "snail4.bin"
Snail5:
.incbin "snail5.bin"
Snail6:
.incbin "snail6.bin"
Snail7:
.incbin "snail7.bin"
Snail8:
.incbin "snail8.bin"
LOWExp:
.incbin "appleA.bin"
HIGHExp:
.incbin "appleB.bin"

.section .exceptions, "ax"

IHANDLER:
	#determine iterrupt source
	rdctl et,ctl4 #ipending register
	andi et,et,0x01 #see if IRQ0
	bne et,r0, HANDLE_TIMER #Timer is highest priority
	br EXIT_IHANDLER
	
HANDLE_TIMER:
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
	
	movia et, 0x03FBFFF8
	ldw r8, 0(et)
	mov et, r0
	beq r8, et, Title3
	movi et, 1
	beq r8, et, Title4
	movi et, 2
	beq r8, et, Title5
	movi et, 3
	beq r8, et, Title6
	movi et, 4
	beq r8, et, Title7
	movi et, 5
	beq r8, et, Title8
	movi et, 6
	beq r8, et, IMAGEA
	movi et, 7
	beq r8, et, IMAGEA
	movi et, 8
	beq r8, et, IMAGEA
	movi et, 9
	beq r8, et, IMAGEB
	movi et, 10
	beq r8, et, IMAGEB
	movi et, 11
	beq r8, et, IMAGEB
	movi et, 12
	beq r8, et, MATCHUP
	br DONE

Title3:
	movia r4, Snail3
	call bmpDraw
	br DONE
Title4:
	movia r4, Snail4
	call bmpDraw
	br DONE
Title5:
	movia r4, Snail5
	call bmpDraw
	br DONE
Title6:
	movia r4, Snail6
	call bmpDraw
	br DONE
Title7:
	movia r4, Snail7
	call bmpDraw
	br DONE
Title8:
	movia r4, Snail8
	call bmpDraw
	br DONE
IMAGEA:
	movia r4, LOWExp
	call bmpDraw
	br DONE
IMAGEB:
	movia r4, HIGHExp
	call bmpDraw
	br DONE
MATCHUP:
	movia r4, LOWExp
	movia r5, HIGHExp
	call HDR

DONE:
	#popping all caller saved registers
	movia et, 0x03FBFFF8
	ldw r8, 0(et)
	movi et, 13
	beq r8, et, Skip
	addi r8, r8, 1
	movia et, 0x03FBFFF8
	stw r8, 0(et)
Skip:
	ldw r15, 28(sp)
	ldw r14, 24(sp)
	ldw r13, 20(sp)
	ldw r12, 16(sp)
	ldw r11, 12(sp)	
	ldw r10,  8(sp)
	ldw r9,   4(sp)
	ldw r8,   0(sp)
	addi sp, sp, 32
	
	movia et, 0xFF202000 #ack timer
	stwio r0, 0(et) #clear timeout
	
	br EXIT_IHANDLER
	
EXIT_IHANDLER:
	subi ea,ea,4
	eret