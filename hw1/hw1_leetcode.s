.data
true:    .string "true"
false:   .string "false"
newline: .string "\n"
# Array of test data lengths, corresponding to the byte length of each test case
test_lengths:
    .word 1       # Length of test1    
    .word 2       # Length of test2
    .word 3       # Length of test3
    .word 1       # Length of test4
    .word 2       # Length of test5
    .word 5       # Length of test6

# Corresponding answers array: 1 indicates valid, 0 indicates invalid
answers:
    .byte 1, 1, 1, 0, 1, 0

# Definition of test data
test1:
    .byte 0x41                   # 'A' U+0041, valid one-byte UTF-8 encoding

test2:
    .byte 0xC3, 0xB1             # 'n' U+00F1, valid two-byte UTF-8 encoding

test3:
    .byte 0xE4, 0xB8, 0xAD       # '¤¤' U+4E2D, valid three-byte UTF-8 encoding

test4:
    .byte 0x80                   # Invalid: lone continuation byte

test5:
    .byte 0xC0, 0xAF             # Valid, but in reality, such encoding doesn't occur

test6:
    .byte 0xF8, 0x88, 0x80, 0x80, 0x80  # Invalid: five-byte sequence, UTF-8 supports up to four bytes

# Array of test data, containing six test cases
test_cases:
    .word test1   # Pointer to the first test data
    .word test2   # Pointer to the second test data
    .word test3   # Pointer to the third test data
    .word test4   # Pointer to the fourth test data
    .word test5   # Pointer to the fifth test data
    .word test6   # Pointer to the sixth test data

.text
.globl main

main:
    # Initialize loop counter
    li t0, 0                      # t0 used as index for test_cases
    li t1, 6                      # t1 is the total number of test data

loop_start:
    beq t0, t1, loop_end          # If t0 == t1, exit the loop

    # Load the address of the test data
    la t2, test_cases
    slli t3, t0, 2                # Each address occupies 4 bytes
    add t2, t2, t3
    lw t4, 0(t2)                  # t4 = test_cases[t0]

    # Load the length of the test data
    la t5, test_lengths
    add t5, t5, t3
    lw t6, 0(t5)                  # t6 = test_lengths[t0]

    # Call your UTF-8 validation function here, passing t4 (data address) and t6 (data length)
    mv a0, t4
    mv a1, t6
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)
    jal ra, validation
    # Assume the validation result is stored in a0, where 1 indicates valid, 0 indicates invalid

    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8

    # Compare the result with the value in the answers array
    la s0, answers
    add s0, s0, t0                # Each answer occupies 1 byte
    lb s1, 0(s0)                  # s1 = answers[t0]

    # Your comparison and handling code here
    beq a0, s1, setTrue
    la a0, false
    j print_result
setTrue:
    la a0, true
print_result:
    jal ra, printTrueFalse
    # Increment loop counter
    addi t0, t0, 1
    j loop_start

loop_end:
    # Loop ends, continue with subsequent processing

    # Exit program
    li a7, 93                     # Exit system call number
    ecall

printTrueFalse:
    li a7, 4
    ecall
    la a0, newline
    ecall
    jr ra

validation:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    li s0, 0  # remaining_bytes = 0
    li s1, 0  # index = 0

    mv s6, a0

validation_loop:
    blt s1, a1, process_byte
    # End of data
    beq s0, zero, return_true
    j return_false

process_byte:
    # Load one byte
    add s2, s6, s1
    lb s2, 0(s2)
    addi s1, s1, 1
    andi s2, s2, 0xFF

    # If remaining_bytes == 0
    beq s0, zero, check_leading_ones

    # Else, check continuation byte
    srli s3, s2, 6
    li s4, 0b10
    bne s3, s4, return_false
    addi s0, s0, -1
    j validation_loop

check_leading_ones:
    not s5, s2
    slli s5, s5, 24
    beqz s5, leading_ones_is_8
    mv a0, s5
    jal ra, my_clz
    mv s5, a0
    j leading_ones_Ternary_end

leading_ones_is_8:
    li s5, 8

leading_ones_Ternary_end:
    beq s5, zero, validation_loop  # 1-byte character
    li s3, 2
    blt s5, s3, return_false       # leading_ones < 2, invalid
    li s3, 4
    bgt s5, s3, return_false       # leading_ones > 4, invalid
    addi s0, s5, -1                # remaining_bytes = leading_ones - 1
    j validation_loop

return_false:
    li a0, 0
    j function_end

return_true:
    li a0, 1

function_end:
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

my_clz:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    beq a0, x0, ifInputZero
    addi s0, x0, 0
    li s1, 31
clzFor:
    li s2, 1
    sll s2, s2, s1
    and s3, a0, s2
    bne s3, x0, funciontEnd
    addi s0, s0, 1
    addi s1, s1, -1
    bne s1, x0, clzFor
funciontEnd:
    mv a0, s0
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
    jr ra
ifInputZero:
    li s0, 32
    j funciontEnd
# my_clz end
