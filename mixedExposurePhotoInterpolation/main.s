#.equ SDRAM, 0x03FBFFFC
.equ SDRAM, 0x03FBFFF4 #new for display
#.equ DISP, 0x03FBFFF8 #display location
.equ ADDR_VGA_BACK, 0x03FC0000
.equ BUFFER, 0xFF203020
.equ TIMER, 0xFF202000
.global _start

_start:
	movia sp, SDRAM
	movia r4, 0x03FBFFF8
	movi r5, 0
	stw r5, 0(r4) # set to zero
	mov r4, r0
	mov r5, r0
	movia r6, 0x0fff0fff
	movia r16, BUFFER
	
	
INIT_BUFFER:
	movia r8, ADDR_VGA_BACK
	stwio r8, 4(r16) #store other pixel buffer address to BACKBUFFER


INIT_TIMER:
	#0x5F5E100 one second
	#0x1DCD6500 five second
	movia r8,TIMER #r8 contains base address of TIMER
	movui r9,%lo(0x5F5E100) #r9 value is lower 16 bits of N (r4)
	stwio r9,8(r8) #set lower 16 bits of period to value of r9
	movui r9,%hi(0x5F5E100) #r9 value is higher 16 bits of N (r4)
	stwio r9,12(r8) #set higher 16 bits of period to value of r9
	stwio r0,0(r8) #clear timer
	
TIMER_START:
	movui r9, 0b111 #0b111 repeats vs. #0b101 only once
	stwio r9,4(r8) #start timer (with interrupts enabled)

	#set interrupt control of NIOS II #Timer is IRQ0
	movi r9,0x1 
	wrctl ctl3,r9

	#enable PIE
	movi r9,0b1
	wrctl ctl0,r9
	
	
Loop:
	br Loop