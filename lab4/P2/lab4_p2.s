.equ ADDR_JP1, 0xFF200060
.equ ON, 45000
.equ OFF, 55000
#r16 = address of JP1
#r17 = temporary register
#r18 = motor0 settings
#r19 = sensor0 value
#r20 = sensor1 value
#r21 = contains value 3
#r22 = contains value 4


#srli = shift right logical immediate
#http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_newlegocontroller2.html
#http://www-ug.eecg.utoronto.ca/desl/manuals/legocontrollerv1.9.pdf
#0 = LEFT, 1 = RIGHT, 0 = COUNTERCLOCKWISE, 1 = CLOCKWISE

.global _start
_start:



INIT:
movia r16, ADDR_JP1 #store address of JP1 into r16
movi r21, 3
movi r22, 5
movi r23, 4
movia r17, 0x07f557ff #the magic number!
stwio r17, 4(r16) #set direction register of JP1 for motors and sensors to output
		#and sensor data register to input
movia r18,0x00000003 #initialize motor settings such that start as motor off

LOOP:

SENSOR0:
movia r17,0xfffffbfc #enable sensor0 at bit 10 with 00 for motor0 bits (c)
or r17,r17,r18 #bitwise or to disable or enable motors
stwio r17,0(r16) #storing this setting into JP1
ldwio r17,0(r16) #check for valid data from sensor
srli r17,r17,11 #bit 11 equals readysensor bit for sensor 0
andi r17,r17,0x1 #mask it to isolate
bne r0,r17,SENSOR0 #if not low, then recheck
ldwio r19,0(r16) #read sensor0 value into r19
srli r19,r19,27 #shift right by 27 bits so that 4 bit sensor value is in lower 4 bits
andi r19,r19,0x0000000f #mask to isolate

ble r19,r21,BIG0 #if really bright, no need for other checks

SENSOR1:
movia r17, 0xffffeffc #enable sensor1 at bit 12 with 00 for motor0 bits (c)
or r17,r17,r18 #bitwise or to disable or enable motors
stwio r17, 0(r16) #storing this setting into JP1
ldwio r17, 0(r16) #check for valid data from sensor
srli r17,r17,13 #bit 13 equals readysensor bit for sensor 0
andi r17,r17,0x1 #mask it to isolate
bne r0,r17,SENSOR1 #if not low, then recheck
ldwio r20,0(r16) #read sensor0 value into r19
srli r20,r20,27 #shift right by 27 bits so that 4 bit sensor value is in lower 4 bits
andi r20,r20,0x0000000f #mask to isolate

ble r20,r23,BIG1 #if really bright, no need for other checks

CHECK:
movia r18,0x00000003 #next time, sensor check will have disabled motor
ble r19,r22,MOTOR_CCW #bright
ble r20,r22,MOTOR_CW #bright
br LOOP #medium bright

BIG0:
movia r18,0x00000002 #next time, sensor check will have enabled motor CCW
br MOTOR_CCW

BIG1:
movia r18,0x00000000 #next time, sensor check will have enabled motor CW
br MOTOR_CW

MOTOR_CCW:
movia r17,0xfffffffe #motor 0 enabled and CCW
stwio r17,0(r16)
br PULSE_MOD


MOTOR_CW:
movia r17,0xfffffffc #motor 0 enabled and CW
stwio r17,0(r16)
br PULSE_MOD

PULSE_MOD:
addi sp, sp, -4
stw ra, 0(sp)	#move ra to stack
movui r4, %lo(ON)
movui r5, %hi(ON)
call pulse

movia r17,0xffffffff #motor 0 disabled
stwio r17,0(r16)

movui r4, %lo(OFF)
movui r5, %hi(OFF)
call pulse
ldw ra, 0(sp)
addi sp, sp, 4

br LOOP