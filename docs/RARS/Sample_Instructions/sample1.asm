#Before anything, test Jalr (since this was a bug raised later on)
addi t1, zero, 100
beq t1 , zero, jalr_working	#this branch should only work after this branch is shown to be working
sub t1, t1, t1
addi t2, zero, 8		#PC address of beq instruction
jalr t5, t2, -4			#go back to beq instruction

#proceed here if working
jalr_working:
addi t1, zero, 0

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

#check slt to instruction (should now work with signed inputs)
continue:
addi t2, zero, -10
addi t1, zero, -5
slt t3, t1, t2

#check if zero register is writable
addi zero, t1, 100

#store double word to second memory slot (Note: I had to enable 64-bit architecture option)
sd t2, 8(zero)

#store word to third memory slot
sw t2, 16(zero)

#store halfword to fourth memory slot
sh t2, 24(zero)

#end of program
end:
addi t5, zero, -500
