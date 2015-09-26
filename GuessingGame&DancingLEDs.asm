lui $s1, 0x0040 #Starting address of program
ori $s1, 0x0000
lui $t0, 0x1002 #DIP Address
ori $t0, 0x8001
lui $t1, 0x1002 #LED Address
ori $t1, 0x0001
lw  $t2, 0x7fff($t0) #Load word from Dip switches
lui $t3, 0x1001 #Data memory Address
ori $t3, 0x0000
add $t3, $t3, $t2
lw $t4, 0x0000($t3) #Read from data memory
lui $t5, 0xfefe #Decryption starts
ori $t5, 0xcdcd
mult $t5, $t4
mfhi $t6
mflo $t7
and $t6, $t6, $t7
or $t6, $t6, $t7
lui $t8, 0x0000
ori $t8, 0x0004
sllv $t6, $t6, $t8
addi $t6, $t6, 14 
lui $t7, 0x0000
ori $t7, 0x000f
and $t6, $t6, $t7 #Final decrypted Value
lui $t8, 0xffff #Counter (Negative)
ori $t8, 0xfff1
guess: lw $t9, 0x7fff($t0)
sw $t9, 0xffffffff($t1) #Displaying user input in LEDs
sw $t8, 0xffffffff($t1) #Storing counter in LEDs
and $t9, $t9, $t7
beq $t9, $t6, success
addi $t8, $t8, 1
bgezal $t8, fail
jal guess

success: 
lui $s0, 0x0000
ori $s0, 0x00ff
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
jr $s1

fail:
lui $s0, 0x0000
ori $s0, 0x00aa
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 2
sw  $s0, 0xffffffff($t1)
sll $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
sra $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
srl $s0, $s0, 4
sw  $s0, 0xffffffff($t1)
jr $s1