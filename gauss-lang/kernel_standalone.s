# kernel_standalone.s -- 完全独立的同余核 (x86-64, GAS 语法)
# 编译: gcc -nostdlib -static -o gs_kernel kernel_standalone.s
# 运行: ./gs_kernel ; echo $?

.section .data
.globl running
running:    .word 1
.globl sp
sp:         .quad 0
.globl pc
pc:         .word 0

.section .bss
.globl mem
mem:        .space 131072
.globl stk
stk:        .space 8192

.section .text
.globl _start
_start:
    leaq   stk(%rip), %rax
    movq   %rax, sp(%rip)
    movw   $0, pc(%rip)
    movw   $1, running(%rip)

    # 加载测试程序: PUSH 42; HALT
    movw   $0x102A, mem(%rip)
    movw   $0xE000, mem+2(%rip)

main_loop:
    cmpw   $0, running(%rip)
    je     done
    call   step
    jmp    main_loop

done:
    movq   sp(%rip), %rdx
    movzwl -2(%rdx), %edi       # 栈顶结果 (sp 指向空闲位置，结果在 sp-2)
    movl   $60, %eax             # sys_exit
    syscall

.globl step
.type step, @function

step:
    movzwl pc(%rip), %eax
    leaq   mem(%rip), %rdx
    movzwl (%rdx,%rax,2), %eax
    movl   %eax, %ecx
    shrl   $12, %ecx
    andl   $0xF, %ecx
    andl   $0xFFF, %eax
    movzwl pc(%rip), %esi
    addl   $1, %esi
    andl   $0xFFFF, %esi
    movw   %si, pc(%rip)

    cmpl   $1, %ecx
    je     op_push
    cmpl   $3, %ecx
    je     op_add
    cmpl   $8, %ecx
    je     op_jz
    cmpl   $0xE, %ecx
    je     op_halt
    ret

op_push:
    movq   sp(%rip), %rdx
    movw   %ax, (%rdx)
    addq   $2, %rdx
    movq   %rdx, sp(%rip)
    ret

op_add:
    movq   sp(%rip), %rdx
    subq   $2, %rdx
    movzwl (%rdx), %ebx
    subq   $2, %rdx
    movzwl (%rdx), %eax
    addw   %bx, %ax
    movw   %ax, (%rdx)
    addq   $2, %rdx
    movq   %rdx, sp(%rip)
    ret

op_jz:
    movq   sp(%rip), %rdx
    subq   $2, %rdx
    movzwl (%rdx), %ebx
    movq   %rdx, sp(%rip)
    testw  %bx, %bx
    jnz    1f
    movw   %ax, pc(%rip)
1:  ret

op_halt:
    movw   $0, running(%rip)
    ret
