[org 0x0100]
	JMP start
tickCount:	dw	0
sec:		dw	0
min:		dw	30
hhh:		dw	12


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
	
timer:
	pusha
	push cs
	pop ds
	
	inc word[tickCount]
	cmp word[tickCount], 18
	jne printTime
	
	mov word[tickCount], 0
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x0720
	mov cx, 2000
	mov di, 0
	rep stosw
	
	inc word[sec]
	cmp word[sec], 60
	jb	printTime
	
	mov word[sec], 0
	inc word[min]
	cmp word[min], 60
	jb	printTime
	
	mov word[min], 0
	inc word[hhh]
	
	printTime:
	mov ax, 1990
	push ax
	mov ax, [hhh]
	push ax
	call printnum
	
	
	mov al, ':'
	mov ah, 0x1
	mov [es:1994], ax
	
	mov ax, 1996
	push ax
	mov ax, [min]
	push ax
	call printnum
	
	mov al, ':'
	mov ah, 0x1
	mov [es:2000], ax
	
	mov ax, 2002
	push ax
	mov ax, [sec]
	push ax
	call printnum
	
	
exit:
	mov al, 0x20
	out 0x20, al
	popa
	iret	
	
start:
	xor  ax, ax 
	mov  es, ax             ; point es to IVT base 
	cli
	mov  word [es:8*4], timer ; store offset at n*4 
	mov  [es:8*4+2], cs     ; store segment at n*4+ 
	sti  
	
	jmp $
	
	mov ax, 0x4c00
	int 0x21
	