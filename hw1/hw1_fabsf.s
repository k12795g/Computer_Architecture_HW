.data
testcase:    .word 0x1, 0xFFFFFFFF, 0x8FFFFFFF
answer:    .word 0x1, 0x7FFFFFFF, 0x0FFFFFFF
true:    .string "true"
false:    .string "false"
newline: .string "\n"


.text
main:
    li t2, 3
    la t0, testcase
    la t1, answer
testLoop:
    lw a0, 0(t0)
    jal ra, fabsf
    lw t3, 0(t1)
    beq a0, t3, setTrue
    la a0, false
    j print_result
setTrue:
    la a0, true
print_result:
    jal ra printTrueFalse
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, testLoop
    li a7, 10
    ecall
printTrueFalse:
    li a7, 4
    ecall
    la a0, newline
    ecall
    jr ra
fabsf:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    li s0, 0x7FFFFFFF 
    and a0, a0, s0 # bitwise AND with 0x7FFFFFFF to discard the sign bit
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    jr ra