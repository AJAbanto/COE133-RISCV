#Initialize memory slot 4
addi t3, zero, 32
sd t3, 32(zero)


#Initialize memory slot 5 (using a negative offset)
addi t4, zero, 48  #address of memory slot 6
sd t3, -8(t4)      # -8 byte offset from memory slot 6 (should be memory slot 5)


#Load value from memory slot 5
ld t4, 40(zero)

#Test other load instructions
lw t4, 0(zero)
lh t4, 24(zero)



#Register-immediate 
addi t1, zero, 1
addi t2, zero, 10

#Register-register and branch instruction (bne)
loop:
sub t2, t2, t1
bne zero, t2, loop 

#check other branch instruction (beq)
beq t2, zero, skipped

#if beq doesnt work then t2 == 50
not_skipped:
addi t2, zero, 50
jal t1, continue

#else continue from this
skipped:
add t2, t1,t1

#check slt to instruction
continue:
addi t2, zero, 10
slt t3, t1, t2

#store double word to second memory slot (Note: I had to enable 64-bit architecture option)
sd t2, 8(zero)

#store word to third memory slot
sw t2, 16(zero)

#store halfword to fourth memory slot
sh t2, 24(zero)
