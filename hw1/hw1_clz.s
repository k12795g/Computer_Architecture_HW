.data
testcase:    .word 0x1, 0xFFFFFFFF, 0x3FFF
answer:    .word 31, 0, 18
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
    jal ra, my_clz
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
    

my_clz:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    li s0, 0

    srli s1, a0, 16
    bnez s1, after16
    addi s0, s0, 16
    slli a0, a0, 16
after16:
    srli s1, a0, 24
    bnez s1, after8
    addi s0, s0, 8
    slli a0, a0, 8
after8:
    srli s1, a0, 28
    bnez s1, after4
    addi s0, s0, 4
    slli a0, a0, 4
after4:
    srli s1, a0, 30
    bnez s1, after2
    addi s0, s0, 2
    slli a0, a0, 2
after2:
    srli s1, a0, 31
    bnez s1, after1
    addi s0, s0, 1
    slli a0, a0, 1
after1:
    mv a0, s0
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

#my_clz end