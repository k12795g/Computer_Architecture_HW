.data
testcase:    .word 0x3C00, 0x6FFF, 0x387A
answer:    .word 0x3F800000, 0x45FFE000, 0x3F0F4000
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
    jal ra, fp16_to_fp32
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

fp16_to_fp32:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    slli s0, a0, 16 # s0 = a0 << 16

    li s2, 0x80000000
    and s1, s0, s2 # sign
    li s2, 0x7FFFFFFF
    and s2, s0, s2 # nonsign
    mv a0, s2
    jal ra, my_clz

    mv s3, a0
    li s4, 5
    bgt s3, s4, ifOverflow
    li s3, 0 # renorm_shift
    j overflowEnd

ifOverflow:
    addi s3, s3, -5  # renorm_shift

overflowEnd:
    li s4, 0x04000000
    add s4, s4, s2
    srli s4, s4, 8
    li s5, 0x7F800000
    and s4, s4, s5 # inf_nan_mask
    addi s5, s2, -1
    srli s5, s5, 31 # zero_mask
    sll s2, s2, s3
    srli s2, s2, 3 # (nonsign << renorm_shift >> 3)
    li s6, 0x70
    sub s3, s6, s3
    slli s3, s3, 23 # ((0x70 - renorm_shift) << 23)
    add s2, s2, s3 # ((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23))
    or s2, s2, s4 # ((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask
    not s5, s5 # ~zero_mask
    and s2, s2, s5 # ((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask & ~zero_mask
    or s2, s1, s2 # sign | ((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask & ~zero_mask
    mv a0, s2
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    jr ra
#fp16_to_fp32 end