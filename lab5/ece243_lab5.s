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
	
		
OnePossibleAlgorithm:
  #use r16-r23 callee-saved registers, functions don't touch these
  #functions can use r8-r15 caller saved registers
  #pass r4 as register argument for set steering
  
  
  call ReadSensors
  
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
