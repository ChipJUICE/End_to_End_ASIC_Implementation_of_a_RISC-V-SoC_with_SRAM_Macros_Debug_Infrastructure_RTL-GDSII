.section .text
    .globl _start

_start:
    # x1 = loop counter
    # x2 = loop limit
    li      x1, 0            # ALU
    li      x2, 1000         # ALU

    # x10 = base pointer to our data
    la      x10, data_base   # ALU (expands to AUIPC+ADDI)

loop:
    addi    x1, x1, 1        # ALU

    lw      x3, 0(x10)       # LSU: load
    sw      x3, 4(x10)       # LSU: store

    mul     x4, x1, x3       # MULDIV

    beq     x1, x2, done     # BRANCH (taken once when x1 == 1000)

    jal     x0, loop         # JUMP back to loop

done:
    # Simple spin so the core keeps retiring instructions
    addi    x0, x0, 0        # NOP-ish (ALU)
    jal     x0, done         # JUMP

    .section .data
    .align  2
data_base:
    .word   0x11111111
    .word   0x22222222