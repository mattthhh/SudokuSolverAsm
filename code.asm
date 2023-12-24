; Sudoku Solver in x86 Assembly

section .data
; buffer of 168 bytes
buffer: db 168 dup(0)
buffer_len: equ $-buffer

section .text
global _start
_start:
	; read input
	mov rax, 3
	mov rbx, 0
	mov rcx, buffer
	mov rdx, buffer_len
	int 80h

	; prepare arguments for main loop
	push -1 ; current value
	push 0	; y position
	push 0	; x position
	call start_main_loop
	add rsp, 24

	; print output
	mov rax, 4
	mov rbx, 1
	mov rcx, buffer
	mov rdx, buffer_len
	int 80h

	; exit
	mov rax, 1
	mov rbx, 0
	int 80h

get_value:
	mov rdx, (buffer)
	imul rax, 2
	add rdx, rax
	imul rbx, 9
	imul rbx, 2
	add rdx, rbx
	movzx rax, byte [rdx]
	sub rax, '0'
	mov [rbp+32], rax
	jmp main_loop

start_main_loop:
	push rbp
	mov rbp, rsp
main_loop:
	; get arguments
	mov rax, [rbp+16]	; x
	mov rbx, [rbp+24]	; y
	mov rcx, [rbp+32]	; current value
	
	; check if finish
	cmp rbx, 9
	je finish

	; if don't have value yet
	cmp rcx, -1
	je get_value

	; if value alreadey exists
	cmp rcx, 0
	jg next

	; try values
	jmp try_values

next:
	; go next value in line
	add rax, 1
	; if end of line, go next line
	cmp rax, 9
	jl next_next
	mov rax, 0
	add rbx, 1
next_next:
	mov [rbp+16], rax
	mov [rbp+24], rbx
	mov rcx, -1
	mov [rbp+32], rcx
	jmp main_loop

try_values:
	; try values from 1 to 9
	mov rcx, 0
try_values_loop:
	add rcx, 1
	cmp rcx, 10
	je next ; TODO : backtracking
	push rbx
	push rax
	push rcx
	call check_line
	cmp rax, 1
	je try_values_success
	pop rcx
	pop rax
	pop rbx
	jmp try_values_loop


try_values_success:
	mov rcx, [rsp]
	mov rax, [rsp+8]
	mov rbx, [rsp+16]
	mov rdx, (buffer)
	imul rax, 2
	add rdx, rax
	imul rbx, 9
	imul rbx, 2
	add rdx, rbx
	add rcx, '0'
	mov [rdx], cl
	pop rcx
	pop rax
	pop rbx
	jmp next

check_line:
	push rbp
	mov rbp, rsp
	; for x 0 to 8*2 in line y
	mov rax, 0
check_line_loop:
	cmp rax, 18
	je check_line_success
	mov rcx, [rbp+16]	; value to try
	mov rbx, [rbp+32]	; y
	mov rdx, (buffer)
	imul rbx, 9
	imul rbx, 2
	add rdx, rbx
	add rdx, rax
	movzx rdx, byte [rdx]
	sub rdx, '0'
	cmp rdx, rcx
	je check_line_fail
	add rax, 2
	jmp check_line_loop

check_line_success:
	mov rax, 1
	jmp finish

check_line_fail:
	mov rax, 0
	jmp finish

finish:
	mov rsp, rbp
	pop rbp
	ret
