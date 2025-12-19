[org 0x0100]
	JMP start
num1:	db	0
num2:	db	0
oprd:	db	0
res:	dw	0

printnum:     push bp 
              mov  bp, sp 
              push es 
              push ax 
              push bx 
              push cx 
              push dx 
              push di 
              mov  ax, 0xb800 
              mov  es, ax             ; point es to video base 
              mov  ax, [bp+4]         ; load number in ax 
              mov  bx, 10             ; use base 10 for division 
              mov  cx, 0              ; initialize count of digits 
nextdigit:    mov  dx, 0              ; zero upper half of dividend 
              div  bx                 ; divide by 10 
              add  dl, 0x30           ; convert digit into ascii value 
              push dx                 ; save ascii value on stack 
              inc  cx                 ; increment count of values  
              cmp  ax, 0              ; is the quotient zero 
              jnz  nextdigit          ; if no divide it again 
              mov  di, [bp+6]  
              nextpos:      pop  dx                 ; remove a digit from the stack 
              mov  dh, 0x4           ; use normal attribute 
              mov [es:di], dx         ; print char on screen 
              add  di, 2              ; move to next screen location 
              loop nextpos            ; repeat for all digits on stack
 
              pop  di 
              pop  dx 
              pop  cx 
              pop  bx 
              pop  ax 
              pop  es 
              pop  bp 
              ret  4 

	
start:
	
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0
	int 0x16
	sub al, 0x30
	
	mov [num1], al
	
	
	mov ax, 0
	int 0x16
	
	cmp al, '0'
	jb MovetoOpt
	cmp al, '9'
	ja MovetoOpt
	
	sub al, 0x30
	mov bl, al
	
	mov al, [num1]
	mov dl, 10
	mul dl
	add al, bl
	mov [num1], al
	
	
	mov ax, 0
	int 0x16
	
	cmp al, '0'
	jb MovetoOpt
	cmp al, '9'
	ja MovetoOpt
	
	sub al, 0x30
	mov bl, al
	
	mov al, [num1]
	mov dl, 10
	mul dl
	add al, bl
	mov [num1], al
	
	
	;Operator:
	mov ax, 0
	int 0x16
	MovetoOpt:
	mov [oprd], al
	
	
	;num2:
	mov ax, 0
	int 0x16
	sub al, 0x30
	
	mov [num2], al
	
	mov ax, 0
	int 0x16
	
	cmp al, 0x0D ;Enter
	je calculation
	
	sub al, 0x30
	mov bl, al
	
	mov al, [num2]
	mov dl, 10
	mul dl
	add al, bl
	mov [num2], al
	
	mov ax, 0
	int 0x16
	
	cmp al, 0x0D ;Enter
	je calculation
	
	sub al, 0x30
	mov bl, al
	
	mov al, [num2]
	mov dl, 10
	mul dl
	add al, bl
	mov [num2], al
	


	calculation:
	
	
	mov ah, 0x1
	
	mov ax, 2000
	push ax
	mov al, [num1]
	xor ah, ah
	push ax
	call printnum
	
	mov ah, 1
	mov al, [oprd]
	mov [es:2010], ax 
	
	mov ax, 2016
	push ax
	mov al, [num2]
	xor ah, ah
	push ax
	call printnum
	
	mov ah, 1
	mov al, '='
	mov [es:2024], ax 
	
	
	cmp word[oprd], '+'
	jne CheckSub

	xor ax, ax
	xor bx, bx
	mov al, [num1]
	mov bl, [num2]
	add ax, bx
	mov [res], ax
	jmp resultPrint
	
	CheckSub:
	cmp word[oprd], '-'
	jne CheckMult
		
	xor ax, ax
	xor bx, bx
	mov al, [num1]
	mov bl, [num2]
	sub ax, bx
	mov [res], al
	jmp resultPrint
	
	CheckMult:
	cmp word[oprd], '*'
	jne CheckDiv
		
	xor ax, ax
	mov al, [num1]
	mov bl, [num2]
	mul bl
	mov [res], ax
	jmp resultPrint
	
	CheckDiv:
	cmp word[oprd], '/'
	jne nomatch
	
	xor ax, ax
	mov al, [num1]
	mov bl, [num2]
	div bl
	mov [res], al
	jmp resultPrint
	
	nomatch:
	mov al, 'E'
	mov ah, 0x4
	mov [es:2160], ax
	jmp exit
	
	
	resultPrint:
	mov ax, 2030
	push ax
	push word[res]
	call printnum
	
	
exit:
	mov ax, 0x4c00
	int 0x21