
.model small
.stack

.data
    buffer db 128 dup(0)   
    index db 1 dup(5)
    rainhas db 9 dup(0)
    rainhas_x db 9 dup(0)
    rainhas_y db 9 dup(0)
    movement_x db 1 dup(0)
    movement_y db 1 dup(0)
    filename db 'in1a.txt$', 0 ; Name of the file to read

    temp_x db 0
    temp_y db 0

    double_nums db 0

    close_esq db '[ $', 0

    final_output db 'Rainha ', 0
    final_output_1 db ': (', 0
    final_output_2 db ',', 0
    final_output_3 db ')', 0
    
BufferWRWORD	DB	10 DUP(?)	; Para uso dentro de WriteWord


    line dw 1


    ;error message
    error_rainha_nao_reconhecida db ' ] Identificar de rainha nao reconhecido.$', 0
    error_coordenada_y db ' ] Coordenada Y invalida.$', 0
    error_coordenada_x db ' ] Coordenada X invalida.$', 0
    error_redefinicao db ' ] Redefinicao de identificador de rainha.$', 0
    error_same_coordinates_1 db ' ] Rainha $', 0
    error_same_coordinates_2 db ' posicionada nas mesmas coordenadas da rainha $', 0
    error_rainha_nao_posicionada db ' ] Rainha nao posicionada.$', 0
    error_espacos_movimentacao_invalido db ' ] Espacos de movimentacao invalido.$', 0
    error_direcao_invalida db ' ] Direcao de movimentacao invalida.$', 0
    error_fora_tabuleiro db ' saiu do tabuleiro na posicao ($', 0
    error_bloqueada db ' bloqueada pela rainha $', 0

    queen_identifier db -1
    queen_x db -1
    queen_y db -1

.code
.startup

    mov ah, 3Dh          ; open file
    mov al, 0            ; Read mode
    lea dx, filename     
    int 21h              
    mov bx, ax           

    ; Check if file opened 
    cmp ax, 0FFh         ; check 0FFh (error code)
    je exit              

    mov ah, 3Fh          ; read from file
    mov cx, 512          ; Number of bytes to read
    lea dx, buffer       
    int 21h              

    mov ah, 09h          ; Print string function
    lea dx, buffer       
    call Printf         

    call print_rainhas_if_exist

    mov ah, 3Eh          ; Close file
    int 21h     

.exit



Printf	proc	near

    mov si, 0
print_2:
	mov		dl,buffer[si]		; While (*S!='\0') {
    inc		si
    cmp     dl, 0Ah
    jnz   test_if_end
    inc   line
test_if_end:
	cmp		dl,0
	jnz		teste
    
	ret

teste:   
    cmp     dl,'#'
    jz      hashtag_case 

    cmp     dl,':'
    jz      dots_case 

    jmp     print_2

hashtag_case:

    inc     si

    mov queen_identifier, -1
    mov queen_x, -1
    mov queen_y, -1

ini:
    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    call verify_if_rainha

    inc     si

    mov		dl,buffer[si]
    cmp	dl,","
    jz     first

    cmp	dl," "
    jz     first

    jmp error_rainha_nao_reconhecida_func

first:
    inc     si
    mov     dl, ' '       
    int     21h           ; Call DOS interrupt
    mov double_nums, 0

first_loop:
    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    cmp    double_nums, 0
    jz     add_to_double_nums_x

    push ax
    push bx
    mov ax, 0
    mov al, double_nums
    mov bl, 10
    mul bl

    mov double_nums, al

    cmp ah, 0
    jg error_coordenada_x_func
    
    pop bx
    pop ax

add_to_double_nums_x: 
    add double_nums, dl
    sub double_nums, 48 ; ascii code 

    inc     si

    mov		dl,buffer[si]
    cmp	dl,","
    jz     second

    cmp	dl," "
    jz     second

    jmp first_loop


second:   

    cmp double_nums, 65
    JGE error_coordenada_x_func

    push ax

    mov al, double_nums
    mov temp_x, al

    pop ax

    inc     si

    mov     dl, ' '       
    int     21h           ; Call DOS interrupt

    mov double_nums, 0

second_loop:
    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    cmp    double_nums, 0
    jz     add_to_double_nums_y

    push ax
    push bx

    mov ax, 0
    mov al, double_nums
    mov bl, 10
    mul bl

    mov double_nums, al

    cmp ah, 0
    jg error_coordenada_y_func
    
    pop bx
    pop ax

add_to_double_nums_y: 
    add double_nums, dl
    sub double_nums, 48 ; ascii code 

    inc     si

    mov		dl,buffer[si]
    cmp	dl,","
    jz     espaco

    cmp	dl," "
    jz     espaco

    cmp	dl,13
    jz     espaco

    jmp second_loop	


espaco:

    cmp double_nums, 65
    JGE error_coordenada_y_func

    push ax

    mov al, double_nums
    mov temp_y, al

    pop ax

    call verify_unique_coordinates

    push si
    push ax

    mov ax, 0
    mov al, queen_identifier
    mov si, ax


    mov ah, temp_x

    mov rainhas_x[si], ah

    mov ah, temp_y

    mov rainhas_y[si], ah

    pop ax
    pop si

    call pula_linha
    jmp     print_2



dots_case:

    call pula_linha

    inc     si

    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    call   verify_if_rainha_mov

    inc     si

    mov		dl,buffer[si]
    cmp	dl,","
    jz     first_mov

    cmp	dl," "
    jz     first_mov

    jmp error_rainha_nao_reconhecida_func


first_mov:
    inc     si
    mov     dl, ' '       
    int     21h           ; Call DOS interrupt
    mov double_nums, 0

first_mov_loop:
    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    cmp    double_nums, 0
    jz     add_to_double_nums_x_mov

    push ax
    push bx
    mov ax, 0
    mov al, double_nums
    mov bl, 10
    mul bl

    mov double_nums, al

    cmp ah, 0
    jg error_coordenada_y_func
    
    pop bx
    pop ax

add_to_double_nums_x_mov: 
    add double_nums, dl
    sub double_nums, 48 ; ascii code 

    inc     si

    mov		dl,buffer[si]
    cmp	dl,","
    jz     second_mov

    cmp	dl," "
    jz     second_mov

    jmp first_mov_loop


second_mov:   

    cmp double_nums, 127
    Jae error_espacos_movimentacao_invalido_func
    
    inc     si

    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    inc si

    cmp     dl, 'N'
    jz      N_Case
    cmp     dl, 'S'
    jz      S_Case
    cmp     dl, 'L'
    jz      L_Case
    cmp     dl, 'O'
    jz      O_Case

    jmp		error_direcao_invalida_func	


L_Case:
    mov movement_x,1
    mov movement_y,0

    jmp		movementation

O_Case:
    mov movement_x,-1
    mov movement_y,0

    jmp		movementation

N_Case:


    mov        dl,buffer[si]

    inc     si

    cmp     dl, 'E'
    jz      NE_Case
    cmp     dl, 'O'
    jz      NO_Case
N_alone_case:
    mov movement_x,0
    mov movement_y,1
    jmp		movementation

NE_Case:   
    mov movement_x,1
    mov movement_y,1
    jmp		movementation
NO_Case:
    mov movement_x,-1
    mov movement_y,1
    jmp		movementation

S_Case:

    mov        dl,buffer[si]
     
    inc     si
    

    cmp     dl, 'E'
    jz      SE_Case
    cmp     dl, 'O'
    jz      SO_Case
S_alone_case:
    mov movement_x,0
    mov movement_y,-1
    jmp		movementation

SE_Case:   
    mov movement_x,1
    mov movement_y,-1
    jmp		movementation
SO_Case:
    mov movement_x,-1
    mov movement_y,-1
    jmp		movementation

    mov_index dw 0
    is_blocked db 0
    queen_blocked_1 db 0
    queen_blocked_2 db 0
movementation:

    push ax
    mov ax, 0
    mov al, double_nums
    mov mov_index, ax
    mov is_blocked, 0

    pop ax

mov_loop:
    cmp mov_index, 0
    jz print_2

    push si
    push ax

    dec mov_index

    mov ax, 0
    mov al, queen_identifier

    mov si, ax

    push bx

    mov bl, movement_x
    mov bh, movement_y

    add rainhas_x[si], bl
    add rainhas_y[si], bh

    pop bx

    call verify_if_blocked
    cmp is_blocked, 0
    jz  error_treatment

    push bx

    mov bl, movement_x
    mov bh, movement_y

    sub rainhas_x[si], bl
    sub rainhas_y[si], bh

    ;colocar erro do bloqueio vou dormir ta louco

    pop bx

    pop ax
    pop si

    ; call error_blocked

    jmp print_2


error_treatment:
    cmp rainhas_x[si], 0
    JL error_out_table_x_zero
    cmp rainhas_y[si], 0
    JL error_out_table_y_zero

    cmp rainhas_x[si], 15
    JG error_out_table_x_plus
    cmp rainhas_y[si], 11
    JG error_out_table_y_plus

    pop ax
    pop si

    jmp mov_loop
error_out_table_x_zero:
    mov rainhas_x[si], 0
    ; call error_out_table_func

    pop ax
    pop si

    jmp        print_2
error_out_table_y_zero:
    mov rainhas_y[si], 0
    call error_out_table_func

    pop ax
    pop si

    jmp        print_2

error_out_table_x_plus:
    mov rainhas_x[si], 15
    ; call error_out_table_func

    pop ax
    pop si

    jmp        print_2
error_out_table_y_plus:
    mov rainhas_y[si], 11
    call error_out_table_func

    pop ax
    pop si

    jmp        print_2

Printf	endp



verify_if_blocked proc near
    
    push dx
    push cx
    push bx
    push si
    push ax

    mov cx, si  ; index of the queen

    mov is_blocked, 0

    mov bl, rainhas_x[si] ; x position of the queen
    mov bh, rainhas_y[si] ; y position of the queen

    mov si, 10

verify_if_blocked_loop:
    dec si
    cmp si, 0
    jz return_verify_if_blocked

    cmp cx, si
    jz verify_if_blocked_loop

    cmp rainhas[si], 1
    jnz verify_if_blocked_loop

    cmp bl, rainhas_x[si]
    jnz verify_if_blocked_loop

    cmp bh, rainhas_y[si]
    jnz verify_if_blocked_loop

    push cx
    mov cx, si
    mov queen_blocked_2, cl

    pop cx
    
    mov queen_blocked_1, cl

    ; mov ax, 0
    ; mov al, queen_blocked_1
    ; call WriteWord
    ; mov ax, 0
    ; mov al, queen_blocked_2
    ; call WriteWord

    call error_blocked

    mov is_blocked, 1
    jmp return_verify_if_blocked


return_verify_if_blocked:

    pop ax
    pop si
    pop bx
    pop cx
    pop dx 

    ret


verify_if_blocked endp

;
;--------------------------------------------------------------------
;Função: Converte um valor HEXA para ASCII-DECIMAL
;Entra:  (A) -> AX -> Valor "Hex" a ser convertido
;        (S) -> DS:BX -> Ponteiro para o string de destino
;--------------------------------------------------------------------
HexToDecAscii	proc near

        push cx
        push ax
        push dx
        push si

		mov	cx,0			;N = 0;
H2DA_2:
		or	ax,ax			;while (A!=0) {
		jnz	H2DA_0
		or	cx,cx
		jnz	H2DA_1

H2DA_0:
		mov	dx,0			;A = A / 10
		mov	si,10			;dl = A % 10 + '0'
		div	si
		add	dl,'0'

		mov	si,cx			;S[N] = dl
		mov	[bx+si],dl

		inc	cx				;++N
		jmp	H2DA_2

H2DA_1:
		mov	si,cx			;S[N] = '\0'
		mov	byte ptr[bx+si],0

		mov	si,bx			;i = 0

		add	bx,cx			;j = N-1
		dec	bx

		sar	cx,1			;N = N / 2

H2DA_4:
		or	cx,cx			;while (N!=0) {
		jz	H2DA_3


		mov	al,[si]			;S[i] <-> S[j]
		mov	ah,[bx]
		mov	[si],ah
		mov	[bx],al

		dec	cx				;	--N

		inc	si				;	++i

		dec	bx				;	--j
		jmp	H2DA_4



H2DA_3:
        pop si
        pop dx
        pop ax
        pop cx
		ret

HexToDecAscii	endp


;--------------------------------------------------------------------
;Função: Escreve o valor de AX na tela
;--------------------------------------------------------------------
WriteWord	proc	near

        push si
        push bx
        push ax
        push cx



		lea		bx,BufferWRWORD
		call	HexToDecAscii
		
		lea		bx,BufferWRWORD
		call	WriteString

        pop cx
        pop ax
        pop bx
        pop si

		ret
WriteWord	endp


;
;--------------------------------------------------------------------
;Função:Escrever um string na tela
;Entra: DS:BX -> Ponteiro para o string
;--------------------------------------------------------------------
WriteString	proc	near

WS_2:
		mov		dl,[bx]		; While (*S!='\0') {
		cmp		dl,0
		jnz		WS_1
		ret

WS_1:
		mov		ah,2		; 	Int21(2)
		int		21H

		inc		bx			; 	++S
		jmp		WS_2		; }

WriteString	endp

error_rainha_nao_reconhecida_func:

    lea dx, error_rainha_nao_reconhecida
    call error_func

    jmp exit

error_coordenada_x_func:
    lea dx, error_coordenada_x
    call error_func

    jmp exit


error_coordenada_y_func:
    lea dx, error_coordenada_y
    call error_func

    jmp exit

error_redefinicao_func:
    lea dx, error_redefinicao
    call error_func

    jmp exit


error_rainha_nao_posicionada_func:
    lea dx, error_rainha_nao_posicionada
    call error_func

    jmp exit

error_espacos_movimentacao_invalido_func:

    lea dx, error_espacos_movimentacao_invalido
    call error_func

    jmp exit

error_direcao_invalida_func:
    lea dx, error_direcao_invalida
    call error_func

    jmp exit


error_out_table_func proc near
    ; call pula_linhanear


    ; push si
     push ax
    ; push bx
    ; push cx
     push dx


    MOV AH,09H 
    lea dx, close_esq
    int 21H

    mov    ax, line
    call WriteWord

    MOV AH,09H 
    lea dx, error_same_coordinates_1
    int 21H

    mov ax, si
    mov al, queen_identifier
    call WriteWord

    MOV AH,09H 
    lea dx, error_fora_tabuleiro
    int 21H

    mov ax, 0

    mov al, rainhas_x[si]
    call WriteWord

    lea bx, final_output_2
    call WriteString

    mov ax, 0

    mov al, rainhas_y[si]
    call WriteWord

    lea bx, final_output_3
    call WriteString

    pop dx 
    ; pop cx
    ; pop bx
    pop ax
    ; pop si
    
    ; call pula_linha
    
    ret

error_out_table_func endp



error_blocked proc near
    ; call pula_linhanear

    ; push si
     push ax
    ; push bx
    ; push cx
     push dx


    MOV AH,09H 
    lea dx, close_esq
    int 21H

    mov    ax, line
    call WriteWord

    MOV AH,09H 
    lea dx, error_same_coordinates_1
    int 21H

    mov ax, 0
    mov al, queen_blocked_1
    call WriteWord

    MOV AH,09H 
    lea dx, error_bloqueada
    int 21H

    mov ax, 0
    mov al, queen_blocked_2
    call WriteWord

    pop dx 
    ; pop cx
    ; pop bx
    pop ax
    ; pop si
    
    ; call pula_linha
    
    ret

error_blocked endp



error_same_coordinates_func proc near

    push si
    push ax
    push bx
    push cx
    push dx

    call pula_linha

    MOV AH,09H 
    lea dx, close_esq
    int 21H

    mov    ax, line
    call WriteWord

    MOV AH,09H 
    lea dx, error_same_coordinates_1
    int 21H

    mov ax, 0
    mov al, queen_identifier
    call WriteWord

    MOV AH,09H 
    lea dx, error_same_coordinates_2
    int 21H

    mov ax, si
    call WriteWord

    mov rainhas[si], 0

    mov ax, 0
    mov al, queen_identifier

    mov si, ax

    mov rainhas[si], 0

    pop dx 
    pop cx
    pop bx
    pop ax
    pop si
    
    call pula_linha
    
    ret

error_same_coordinates_func endp


pula_linha proc near

    push dx

    mov     dl, 0Dh       ; ASCII code for carriage return (CR)
    int     21h           ; Call DOS interrupt
    mov     dl, 0Ah       
    int     21h           ; Call DOS interrupt

    pop dx

    ret
pula_linha endp

error_func proc near

    push ax
    push dx

    mov		ah,2			; Envia CRLF
	mov		dl,13
	int		21H
	mov		ah,2
	mov		dl,10
	int		21H

    MOV AH,09H 
    lea dx, close_esq
    int 21H

    mov    ax, line
    call WriteWord

    MOV AH,09H 
    pop dx
    int 21H

    pop ax

    ret

error_func endp


verify_unique_coordinates proc near

    push si

    mov si,-1

    mov bx, 0

loop_verify_unique_coordinates:
    cmp si, 10
    jz fim_verify_unique_coordinates

    inc si

    mov bl, rainhas_x[si]

    cmp bl, temp_x
    jnz loop_verify_unique_coordinates

    mov bl, rainhas_y[si]

    cmp bl, temp_y
    jnz loop_verify_unique_coordinates

    call error_same_coordinates_func


fim_verify_unique_coordinates:
    pop si
    ret

verify_unique_coordinates endp






;print 

print_rainhas_if_exist proc near

    call pula_linha
    call pula_linha

    push si

    mov si,-1

    mov bx, 0
    mov ax, 0

loop_print_rainhas_if_exist:
    cmp si, 9
    jz fim_print_rainhas_if_exist

    inc si

    mov al, rainhas[si]

    cmp al, 1
    jnz loop_print_rainhas_if_exist


    lea bx, final_output
    call WriteString

    mov ax, si
    call WriteWord

    lea bx, final_output_1
    call WriteString

    mov ax, 0

    mov al, rainhas_x[si]
    call WriteWord

    lea bx, final_output_2
    call WriteString

    mov ax, 0

    mov al, rainhas_y[si]
    call WriteWord

    lea bx, final_output_3
    call WriteString

    call pula_linha

    jmp loop_print_rainhas_if_exist


fim_print_rainhas_if_exist:
    pop si
    ret

print_rainhas_if_exist endp



verify_if_rainha proc near
    CMP dl, 47      ; Compara DL com codigo ascii do 0
    JLE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    CMP dl, 56      ; Compara DL com codigo ascii do 9
    JGE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    mov queen_identifier, dl
    sub queen_identifier, 48 ;ascii

    push si
    push cx

    mov cx,0
    mov cl, queen_identifier

    mov si, cx

    mov cl , rainhas[si]
    cmp cl, 1
    jz     error_redefinicao_func

    mov rainhas[si], 1

    pop cx
    pop si

    ret

verify_if_rainha endp

verify_if_rainha_mov proc near
    CMP dl, 47      ; Compara DL com codigo ascii do 0
    JLE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    CMP dl, 56      ; Compara DL com codigo ascii do 9
    JGE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    mov queen_identifier, dl
    sub queen_identifier, 48 ;ascii

    push si
    push cx

    mov cx,0

    mov cl, queen_identifier

    mov si, cx

    mov cl , rainhas[si]
    cmp cl, 1
    jnz error_rainha_nao_posicionada_func

    pop cx
    pop si

    ret

verify_if_rainha_mov endp

exit: 
    end
