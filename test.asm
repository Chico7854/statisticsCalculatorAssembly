section .data
    ; Strings de menu
    menu_prompt db "Escolha uma opção:", 10
                db "1. Inserir array", 10
                db "2. Calcular média", 10
                db "3. Calcular variância/desvio padrão", 10
                db "4. Encontrar moda", 10
                db "5. Sair", 10
                db "Opção: ", 0
    len_menu equ $ - menu_prompt

    ; Mensagens de input/output
    input_msg db "Digite um número: ", 0
    len_input_msg equ $ - input_msg
    error_msg db "Entrada inválida! Tente novamente.", 10, 0
    len_error_msg equ $ - error_msg
    result_msg db "Resultado: ", 0
    len_result_msg equ $ - result_msg
    array_full_msg db "Array cheio!", 10, 0
    len_array_full equ $ - array_full_msg
    sum_msg db "Soma: ", 0
    len_sum equ $ - sum_msg
    mean_msg db "Média: ", 0
    len_mean equ $ - mean_msg
    variance_msg db "Variância: ", 0
    len_variance equ $ - variance_msg
    stddev_msg db "Desvio Padrão: ", 0
    len_stddev equ $ - stddev_msg
    mode_msg db "Moda: ", 0
    len_mode equ $ - mode_msg
    newline db 10, 0

section .bss
    array resd 10       ; Array de 10 inteiros (32-bit)
    array_size resb 1    ; Tamanho atual do array
    input_buffer resb 12 ; Buffer para leitura de input
    number_buffer resb 12 ; Buffer para conversão numérica

section .text
    global _start

; Função para converter string para inteiro (simplificada)
; Entrada: ECX = ponteiro para string
; Saída: EAX = número
atoi:
    xor eax, eax
    xor ebx, ebx
.convert_loop:
    mov bl, [ecx]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc ecx
    jmp .convert_loop
.done:
    ret

; Função para imprimir inteiro (simplificada)
; Entrada: EAX = número
print_number:
    mov edi, number_buffer + 11
    mov byte [edi], 0
    dec edi
    mov ebx, 10
.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .convert_loop
    inc edi
    mov ecx, edi
    mov edx, number_buffer + 12
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

_start:
    ; Inicialização
    mov byte [array_size], 0

main_menu:
    ; Mostra o menu
    mov eax, 4
    mov ebx, 1
    mov ecx, menu_prompt
    mov edx, len_menu
    int 0x80

    ; Lê a opção do usuário
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 2
    int 0x80

    ; Processa a opção
    cmp byte [input_buffer], '1'
    je insert_array
    cmp byte [input_buffer], '2'
    je calculate_mean
    cmp byte [input_buffer], '3'
    je calculate_variance
    cmp byte [input_buffer], '4'
    je find_mode
    cmp byte [input_buffer], '5'
    je exit_program

    ; Opção inválida
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, len_error_msg
    int 0x80
    jmp main_menu

insert_array:
    ; Verifica se o array está cheio
    cmp byte [array_size], 10
    jb .not_full
    mov eax, 4
    mov ebx, 1
    mov ecx, array_full_msg
    mov edx, len_array_full
    int 0x80
    jmp main_menu

.not_full:
    ; Pede para digitar um número
    mov eax, 4
    mov ebx, 1
    mov ecx, input_msg
    mov edx, len_input_msg
    int 0x80

    ; Lê o número
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 12
    int 0x80

    ; Converte para número
    mov ecx, input_buffer
    call atoi

    ; Armazena no array
    movzx ebx, byte [array_size]
    mov [array + ebx*4], eax

    ; Incrementa o tamanho do array
    inc byte [array_size]

    ; Volta ao menu
    jmp main_menu

calculate_mean:
    ; Verifica se o array está vazio
    cmp byte [array_size], 0
    jne .not_empty
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, len_error_msg
    int 0x80
    jmp main_menu

.not_empty:
    ; Calcula a soma
    xor eax, eax        ; Soma
    xor ebx, ebx        ; Índice
.sum_loop:
    add eax, [array + ebx*4]
    inc ebx
    cmp bl, [array_size]
    jb .sum_loop

    ; Imprime a soma
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, sum_msg
    mov edx, len_sum
    int 0x80
    pop eax
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Calcula a média
    xor edx, edx
    movzx ebx, byte [array_size]
    div ebx

    ; Imprime a média
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, mean_msg
    mov edx, len_mean
    int 0x80
    pop eax
    call print_number
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp main_menu

calculate_variance:
    ; Verifica se o array está vazio
    cmp byte [array_size], 0
    jne .not_empty
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, len_error_msg
    int 0x80
    jmp main_menu

.not_empty:
    ; TODO: Implementar cálculo de variância e desvio padrão
    ; (Implementação mais complexa requer FPU)
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, len_result_msg
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, variance_msg
    mov edx, len_variance
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, stddev_msg
    mov edx, len_stddev
    int 0x80
    jmp main_menu

find_mode:
    ; Verifica se o array está vazio
    cmp byte [array_size], 0
    jne .not_empty
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, len_error_msg
    int 0x80
    jmp main_menu

.not_empty:
    ; TODO: Implementar busca da moda
    ; (Implementação requer contagem de frequências)
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, len_result_msg
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, mode_msg
    mov edx, len_mode
    int 0x80
    jmp main_menu

exit_program:
    ; Sai do programa
    mov eax, 1
    mov ebx, 0
    int 0x80