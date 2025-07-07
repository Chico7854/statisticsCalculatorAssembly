; Write a program which reads 5 numbers into an array and prints the smallest and largest
; number and their location in the array.
; If the user enters 7, 13, -5, 10, 6 then your program should print
; “Smallest number -5 was found at location 2”.
; “Largest number 13 was found at location 1”.

section .data
array_size: dq 5
a: dq 0
sum: dq 0
average: dq 0.0
ind: dq 0
cnt: dq 0
cnt2: dq 0
min_pos: dq 0
max_pos: dq 0
fmt: db "%lld ",10,0
fmt_in_int: db "%lld", 0
fmt_out_input_array_size: db "Digite o tamanho do array: ", 0
fmt_out_min: db "O menor número é: %lld ", 10, 0
fmt_out_max: db "O maior número é: %lld ", 10, 0
fmt_out_average: db "A média é: %lf", 10, 0
fmt_out_variancia_desvio_padrao: db "Variância: %lf", 10
								db "Desvio Padrão: %lf", 10, 0
fmt_out_menu_prompt: db "Escolha uma opção:", 10
				db "1. Definir tamanho do array", 10
				db "2. Inserir array", 10
				db "3. Encontrar valor máximo", 10
				db "4. Encontrar valor mínimo", 10
				db "5. Calcular média", 10
				db "6. Calcular variância/desvio padrão", 10
				db "7. Sair", 10
				db "Opção: ", 0
fmt_out_error_msg: db "Entrada inválida! Tente novamente.", 10, 0
fmt_out_input_msg: db "Digite o número: ", 0

section .bss
array resq 21
input_int resq 1
min resq 1
max resq 1
variancia resq 1
desvio resq 1

section .text
global main
extern printf, scanf, getch

main:
	push RBP

	mov RAX, 0
	mov RCX, 0
	mov RBX, 0

MAIN_MENU:
	mov RDI, fmt_out_menu_prompt
	call printf
	mov RDI, fmt_in_int
	mov RSI, input_int
	call scanf

	cmp byte [input_int], 1
		je DEFINE_ARRAY_SIZE
	cmp byte [input_int], 2
		je INPUT_ARRAY
	cmp byte [input_int], 3
		je PRINT_MAX
	cmp byte [input_int], 4
		je PRINT_MIN
	cmp byte [input_int], 5
		je PRINT_AVERAGE
	cmp byte [input_int], 6
		je VARIANCIA
	cmp byte [input_int], 7
		je END

	; Opção inválida
	mov RDI, fmt_out_error_msg
	call printf
	jmp MAIN_MENU

DEFINE_ARRAY_SIZE:
	mov RDI, fmt_out_input_array_size
	call printf
	mov RDI, fmt_in_int
	mov RSI, array_size
	call scanf
	jmp MAIN_MENU

INPUT_ARRAY: 
	mov RCX, [cnt]
	cmp RCX, [array_size]
	jz DONE
	mov RDI, fmt_out_input_msg
	call printf

	mov RAX, 0
	mov RDI, fmt_in_int
	mov RSI, a
	call scanf
	mov RAX, [a]
	mov RCX, [cnt]
	mov [array+RCX*8], RAX
	add RBX, [a]
	inc RCX
	mov [cnt], RCX
	jmp INPUT_ARRAY

DONE:
	mov RAX, 0
	mov RCX, 0
	mov RBX, 0
	mov qword [cnt], 0
	mov qword [variancia], 0
	mov qword [sum], 0

LOOP:
	cmp RCX, [array_size]
	je calculate_average

	mov RAX, [array + RCX*8]
	add [sum], RAX

	cmp RCX, 0
	jne skip_first_min_max
	mov [min], RAX
	mov [max], RAX
	
	skip_first_min_max:
	cmp RAX, [min]
	jl update_min
	jmp skip_min

	update_min:
	mov [min], RAX

	skip_min:
	cmp RAX, [max]
	jg update_max
	jmp skip_max

	update_max:
	mov [max], RAX

	skip_max:
	inc RCX
	jmp LOOP

	calculate_average:
	cvtsi2sd xmm0, [sum]
	cvtsi2sd xmm1, [array_size]

	divsd xmm0, xmm1
	movsd [average], xmm0

	xor RCX, RCX
	jmp MAIN_MENU

PRINT_MAX:
	mov RDI, fmt_out_max
	mov RSI, [max]
	call printf
	jmp MAIN_MENU

PRINT_MIN:
	mov RDI, fmt_out_min
	mov RSI, [min]
	call printf
	jmp MAIN_MENU

PRINT_AVERAGE:
	mov RDI, fmt_out_average
	movsd xmm0, [average]
	mov RAX, 1
	call printf
	jmp MAIN_MENU

VARIANCIA:
	mov RAX, [array + RCX*8]
	cvtsi2sd xmm0, RAX
	subsd xmm0, [average]
	mulsd xmm0, xmm0

	movsd xmm1, [variancia]
	addsd xmm1, xmm0
	movsd [variancia], xmm1

	inc RCX
	cmp RCX, [array_size]
	jl VARIANCIA

	; divisao
	movsd xmm0, [variancia]
	cvtsi2sd xmm1, [array_size]
	divsd xmm0, xmm1
	movsd [variancia], xmm0

DESVIO_PADRAO:
	sqrtsd xmm0, xmm0
	movsd [desvio], xmm0

	; printf
	movsd xmm0, [variancia]
	movsd xmm1, [desvio]
	mov RDI, fmt_out_variancia_desvio_padrao
	mov RAX, 1
	call printf

	xor RCX, RCX
	jmp MAIN_MENU

END:
	mov RAX, 0
    pop RBP
ret
