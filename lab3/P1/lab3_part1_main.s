# Print ten in octal, hexadecimal, and decimal
# Use the following C functions:
#     printHex ( int ) ;
#     printOct ( int ) ;
#     printDec ( int ) ;

.global main

main:
#Prologue
addi sp, sp, -4
stw ra, 0(sp)
#store ten
movi r4, 10
call printHex
movi r4, 10
call printOct
movi r4, 10
call printDec
#post call
ldw ra, 0(sp)
addi sp, sp, 4


ret	# Make sure this returns to main's caller

