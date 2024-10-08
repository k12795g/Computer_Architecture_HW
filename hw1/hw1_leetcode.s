    .data
    # Test case data arrays
    data1: .word 197, 130, 1          # Expected output: 1 (True)
    size1: .word 3

    data2: .word 235, 140, 4          # Expected output: 0 (False)
    size2: .word 3

    # Storage for results
    result1: .word 0
    result2: .word 0

    .text
    .globl main

main:
    # Test Case 1
    la      a0, data1         # Load address of data1 into a0
    lw      a1, size1         # Load size1 into a1
    jal     ra, validUtf8     # Call validUtf8
    la      t0, result1       # Load address of result1 into t0
    sw      a0, 0(t0)       # Store result in result1
    j       end
    # Test Case 2
    la      a0, data2         # Load address of data2 into a0
    lw      a1, size2         # Load size2 into a1
    jal     ra, validUtf8     # Call validUtf8
    la      t0, result2       # Load address of result2 into t0
    sw      a0, 0(t0)       # Store result in result2

    # End of main function
    j       end

# validUtf8 function
validUtf8:
    # Function prologue
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      s0, 8(sp)
    sw      s1, 4(sp)
    sw      s2, 0(sp)

    mv      s0, a0          # s0 = data pointer
    mv      s1, a1          # s1 = size
    li      s2, 0           # s2 = index
    li      t0, 0           # t0 = remaining_bytes

loop_start:
    bge     s2, s1, loop_end    # if index >= size, exit loop

    # Load byte = data[index]
    slli    t1, s2, 2       # t1 = index * 4
    add     t1, s0, t1      # t1 = address of data[index]
    lw      t2, 0(t1)       # t2 = data[index]
    andi    t2, t2, 0xFF    # t2 = byte & 0xFF

    beq     t0, zero, check_first_byte

    # Process continuation byte
    srli    t3, t2, 6       # t3 = byte >> 6
    li      t4, 0b10        # t4 = 2
    bne     t3, t4, return_false

    addi    t0, t0, -1      # remaining_bytes--
    addi    s2, s2, 1       # index++
    j       loop_start

check_first_byte:
    # Count leading ones in byte
    li      t5, 0           # t5 = leading_ones
    li      t6, 0x80        # t6 = 0b10000000

count_leading_ones:
    and     s3, t2, t6      # s3 = byte & bit_mask
    beq     s3, zero, leading_ones_counted
    addi    t5, t5, 1       # leading_ones++
    srli    t6, t6, 1       # bit_mask >>= 1
    bne     t6, zero, count_leading_ones
    j       return_false

leading_ones_counted:
    beq     t5, zero, increment_index
    li      s4, 2
    blt     t5, s4, return_false
    li      s4, 5
    bge     t5, s4, return_false
    addi    t0, t5, -1      # remaining_bytes = leading_ones - 1
    addi    s2, s2, 1       # index++
    j       loop_start

increment_index:
    addi    s2, s2, 1       # index++
    j       loop_start

loop_end:
    beq     t0, zero, return_true

return_false:
    li      a0, 0
    j       function_end

return_true:
    li      a0, 1

function_end:
    # Function epilogue
    lw      ra, 12(sp)
    lw      s0, 8(sp)
    lw      s1, 4(sp)
    lw      s2, 0(sp)
    addi    sp, sp, 16
    ret

end:
    # Infinite loop to end the program
    j       end
