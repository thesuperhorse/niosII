#Turn motor on
#Delay 196666 cycles using the Timer
#Turn motor off
#Delay 196666 cycles using the Timer


#this subroutine is called for pulse width modulation of the motors, pass in N
#register r4 contains value N

#r4 contains value N

#r8 contains timer base address
#r9 temporary register


#movui stands for move unsigned immediate
#%lo and %hi is a maybe a macro which respectively gives lower and higher 16 bits of value
#not sure if you can input with a register rather than a macro (eg. .equ ...)

.global pulse

pulse:

.equ TIMER, 0xFF202000

INIT:
movia r8,TIMER #r8 contains base address of timer
stwio r4,8(r8)
stwio r5,12(r8)
#movui r9,%lo(r4) #r9 value is lower 16 bits of N (r4)
#stwio r9,8(r8) #set lower 16 bits of period to value of r9
#movui r9,%hi(r4) #r9 value is higher 16 bits of N (r4)
#stwio r9,12(r8) #set higher 16 bits of period to value of r9

movui r9, 4
stwio r9,4(r8) #start timer (with continue and interrupts disabled)

POLL:
ldwio r9,0(r8) #load timer status register
andi r9,r9,0x1 #check if timer timed out (r9 = 1 if timed out)
beq r9,r0,POLL #if r9 = 0, then poll again

movui r9,8
stwio r9,4(r8) #stop timer
stwio r0,0(r8) #clear the timer

ret
