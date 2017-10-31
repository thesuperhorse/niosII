.equ ADDR_VGA_BACK, 0x03FC0000
#0x03FC0000 ­ 0x03FFFFFF
.equ BUFFER, 0xFF203020 #both buffers initiated at 0x08000000
#http://www­ug.eecg.toronto.edu/msl/handouts/DE1­SoC_Computer_Nios.pdf
#page 35
movia r4, ADDR_VGA_BACK
movia r5, BUFFER
stwio r4, 4(r5) #store other pixel buffer address to BACKBUFFER
#for each VGAwrite function
ldwio r4, 4(r5)
#write pixels to this pixel buffer (r4)
POLL_VGA_STATUS:
ldwio r4, 12(r5)
andi r4, r4, 0x1
bne r4, r0, POLL_VGA_STATUS
movi r4, 0x1
stwio r4, 0(r5)