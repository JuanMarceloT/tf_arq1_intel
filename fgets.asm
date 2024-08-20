
.model small
.stack

.data
    buffer db 128 dup(0)   
    index db 1 dup(5)
    rainhas db 9 dup(0)
    rainhas_x db 9 dup(-1)
    rainhas_y db 9 dup(-1)
    movement_x db 1 dup(0)
    movement_y db 1 dup(0)
    filename db 'in1a.txt$', 0 ; Name of the file to read

    double_nums db 0

    close_esq db '[ $', 0
    
BufferWRWORD	DB	10 DUP(?)	; Para uso dentro de WriteWord


    line dw 1


    ;error message
    error_rainha_nao_reconhecida db ' ] Identificar de rainha nao reconhecido.$', 0
    error_coordenada_x db ' ] Coordenada X invalida.$', 0
    error_coordenada_y db ' ] Coordenada Y invalida.$', 0
    error_redefinicao db ' ] Redefinicao de identificador de rainha.$', 0


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

    mov ah, 3Eh          ; Close file
    int 21h     

.exit



Printf	proc	near

    mov si, 0
print_2:
	mov		dl,buffer[si]		; While (*S!='\0') {
    inc		si
    cmp     dl, 13
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

    CMP dl, 47      ; Compara DL com codigo ascii do 0
    JLE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    CMP dl, 56      ; Compara DL com codigo ascii do 9
    JGE error_rainha_nao_reconhecida_func  ; Salta para error_rainha_nao_reconhecida_func

    mov queen_identifier, dl
    sub queen_identifier, 47 ;ascii

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


    call pula_linha
    jmp     print_2



dots_case:

    call pula_linha

    inc     si

    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    mov     dl, ' '       
    int     21h           ; Call DOS interrupt

    inc     si
    inc     si

    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    mov     dl, ' '       
    int     21h           ; Call DOS interrupt

    inc     si
    inc     si

    mov		dl,buffer[si]

	mov		ah,2		
	int		21H

    

    cmp     dl, 'N'
    jz      two_letters_case
    cmp     dl, 'S'
    jz      two_letters_case

    jmp		print_2	

two_letters_case:

    inc     si

    mov        dl,buffer[si]

    cmp     dl, 'E'
    jz      have_two_letters
    cmp     dl, 'O'
    jnz      print_2

have_two_letters:

    mov        ah,2        
    int        21H

    inc     si
	jmp		print_2		
Printf	endp

;
;--------------------------------------------------------------------
;Função: Converte um valor HEXA para ASCII-DECIMAL
;Entra:  (A) -> AX -> Valor "Hex" a ser convertido
;        (S) -> DS:BX -> Ponteiro para o string de destino
;--------------------------------------------------------------------
HexToDecAscii	proc near

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



pula_linha proc near
    mov     dl, 0Dh       ; ASCII code for carriage return (CR)
    int     21h           ; Call DOS interrupt
    mov     dl, 0Ah       
    int     21h           ; Call DOS interrupt

    ret
pula_linha endp

error_func proc near

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

    ret

error_func endp

exit: 
    end
