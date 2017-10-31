#how to debug interrupts
#observe status and ienable registers to see whether interrupts are enabled
#observe ipending register to see if an interrupt is currently being requested
#use a breakpoint at 0x20 to see whether interrupt handler executes

#JTAG UART is different from the car_world JTAG_UART
#make sensors and speed registers global so it can be used in IHANDLER
#read interrupt is used to detect keypress from JTAG terminal
#write interrupt is used to delete and output new characters to the terminal
#JTAG control register normally set to read

#.equ TIMER, 0xFF202000
#.equ JTAG, 0xFF201000

.equ s,0x73
.equ r,0x72
#.equ x,0x78

.section .exceptions, "ax"
IHANDLER:
#	subi sp, sp, 12 #save ea, et, ctl1
#	stw et,0(sp)
#	rdctl et,ctl1
#	stw et,4(sp)
#	stw ea,8(sp)
	
	#determine iterrupt source
	rdctl et,ctl4 #ipending register
	andi et,et,0x01 #see if IRQ0
	bne et,r0,HANDLE_TIMER #Timer is highest priority
	
	rdctl et,ctl4
	andi et,et,0x100 #see if IRQ8
	bne et,r0,HANDLE_JTAG
	
	br EXIT_IHANDLER	

HANDLE_TIMER:
	#actions to handle timer

#ldwio et,0(r13) #load direction from memory r13 = 0x04000003 
#delete current line
#beq et,r0,CURR_SPEED 

#CURR_SENSORS:
#movi et,0x1b
#call EtWriteUART
#movi et,0x5b
#call EtWriteUART
#movi et,0x32
#call EtWriteUART
#movi et,0x4a
#call EtWriteUART
#br PRINT_END #this changes the LEDs

#CURR_SPEED:
#empties terminal
movi et,0x1b
call EtWriteUART
movi et,0x5b
call EtWriteUART
movi et,0x32
call EtWriteUART
movi et,0x4a
call EtWriteUART

PRINT_END:
#load register data from memory
movi r5, 0x09
mov r7, r14
andi et, r7, 0xf0 #storing first 4 bits
srli et, et, 4 #shift 4 right
ble et, r5, OnlyNumber1 #is x<=9?
addi et, et, 0x09 #for letters
OnlyNumber1:
addi et, et, 0x30
call EtWriteUART

andi et, r7, 0xf #storing first 4 bits
ble et, r5, OnlyNumber2 #is x<=9?
addi et, et, 0x09 #for letters
OnlyNumber2:
addi et, et, 0x30
call EtWriteUART

movia et,0xFF202000 #ack timer
stwio r0,0(et) #clear timeout
br EXIT_IHANDLER
	
#READ_JTAG:
	#actions to handle READ_JTAG
	#call EtReadUART
	#data read is now in et
	
#	movia r3,r #change r3 to something safer
#	beq et,r3,Sensors
#	movia r3,s
#	beq et,r3,Speed
#	br EXIT_IHANDLER
	
#Sensors:
	#set a memory to 0 to signify save sensors to memory
#	br EXIT_IHANDLER
	
#Speed:
	#set a memory to 1 to signify save speed to memory
#	br EXIT_IHANDLER

HANDLE_JTAG:

READ_POLL:
  ldwio r7, 0(r12) /* Load from the JTAG */
  andi  et, r7, 0x8000 /* Mask other bits */
  beq   et, r0, READ_POLL /* If this is 0 (branch true), data is not valid */
  andi  et, r7, 0x00FF /* Data read is now in et */
  
movia r7,r
	beq et,r7,RIGHT
	movia r7,s
	beq et,r7,LEFT
RIGHT:
movi et, 0x1
stwio et,0(r13) #save direction to memory
br EXIT_IHANDLER
LEFT:
stwio r0,0(r13) #save direction to memory
br EXIT_IHANDLER


br EXIT_IHANDLER
	
EXIT_IHANDLER:
#	ldw et,0(sp)
#	wrctl ctl1,et
#	ldw et,4(sp)
#	ldw ea,8(sp)
#	addi sp,sp,12
	subi ea,ea,4
	eret
	
EtWriteUART: #r12 holds JTAG
WRITE_POLL:
  ldwio r7, 4(r12) /* Load from the JTAG */
  srli  r7, r7, 16 /* Check only the write available bits */
  beq   r7, r0, WRITE_POLL /* If this is 0 (branch true), data cannot be sent */
  stwio et, 0(r12) /* Write the byte to the JTAG */
  ret
	
	