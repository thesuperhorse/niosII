.equ TIMER, 0xFF202000
.equ REAL_JTAG, 0xFF201000
.global _start
 
_start:
	#r2 is speed (unsigned)
	#r3 is sensors (bitwise)
	movia sp, 0x03ffffff

	movia r16, 0x1f
	movia r17, 0x1e
	movia r18, 0x1c
	movia r19, 0x0f
	movia r20, 0x07
	movui r21, 40
	
	movi r4,0
	call WriteOneByteToUART
	
	#
	#r11= TIMER
	#r12 = REAL_JTAG
	#r13 = memory of current state
	#0(r13) = thing.,. 4(r13) holds data
	
	INIT_STUFF:
	INIT_TIMER:
movia r11,TIMER #r11 contains base address of TIMER
movui r9,%lo(0x5F5E100) #r9 value is lower 16 bits of N (r4)
stwio r9,8(r11) #set lower 16 bits of period to value of r9
movui r9,%hi(0x5F5E100) #r9 value is higher 16 bits of N (r4)
stwio r9,12(r11) #set higher 16 bits of period to value of r9
stwio r0,0(r11) #clear timer

INIT_JTAG:
movia r12,REAL_JTAG
#set JTAG UART interrupt control to read
movia r9,0x1 #enable read interrupts bit 0 and 1 of JTAG base + 4
stwio r9,4(r12)

#set a memory to hold left (0) or right (1) direction
movia r13, 0x03FFFFFF #0x04000003
movi r10, 0x1 #initialize right = sensors. left = speed
stwio r10, 0(r13)

TIMER_START:
movui r9, 0b111
stwio r9,4(r11) #start timer (with interrupts enabled)

#set interrupt control of NIOS II
#Timer is IRQ0 and JTAG is IRQ8
movi r9,0x101 #0b100000001
wrctl ctl3,r9

#enable PIE
movi r9,0b1
wrctl ctl0,r9
	
		
OnePossibleAlgorithm:
  #use r16-r23 callee-saved registers, functions don't touch these
  #functions can use r8-r15 caller saved registers
  #pass r4 as register argument for set steering
  
  
  call ReadSensors
  ldwio r6,0(r13) #load direction from memory r13 = 0x04000003 
  beq r6,r0,CURR_SPEED 
  
  CURR_SENSORS:
  mov r14,r3
  br DONE_SAVING
  
  CURR_SPEED:
  mov r14,r2
DONE_SAVING:
  
  
  #Keep speed under 40
  bgt r2, r21, SLOW
  movi r4, 127
  call SetSpeed
  br STEER
  
SLOW:
  movi r4, -127
  call SetSpeed

STEER:
  # Decide what to do
  beq r3,r18, HardRight
  beq r3,r20, HardLeft
  beq r3,r17, Right
  beq r3,r19, Left
  beq r3,r16, Straight

Straight:
	movi r4,0
	call SetSteering
	br EndSteering

Right:
	movi r4,100
	call SetSteering
	br EndSteering
	
HardRight:
	movi r4,127
	call SetSteering
	br EndSteering
	
Left:
	movi r4,-100
	call SetSteering
	br EndSteering
	
HardLeft:
	movi r4,-127
	call SetSteering
  	br EndSteering
	
EndSteering:
	
  # Also do something about the speed.
  # Accelerate when steer straight, decelerate for others unless already slow
	br OnePossibleAlgorithm
