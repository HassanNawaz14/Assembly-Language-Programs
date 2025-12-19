[org 0x0100]
	JMP start
StdRcd: dw  3, 17, 1234, 3, 5, 8, 10, 17, 4012, 2, 7, 6, 15, 4319, 1, 3
num:	dw	1
asmnt:	dw	4


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
	
	mov si, StdRcd
	mov ax, [si]
	cmp word[num], ax
	ja exit
	
	add si, 2
	mov cx, [num]
	dec cx
	cmp cx, 0
	je skiploop
	
	
	main_loop:
		add si, 4
		mov ax, [si]
		shl ax, 1 ;as dw
		add si, ax
		add si, 2
		loop main_loop
	
	skiploop:	
	add si, 4
	mov ax, [asmnt]
	cmp ax, [si]
	ja exit
	
	shl ax, 1
	
	;add si, 2
	add si, ax
	
	mov ax, 2000
	push ax
	mov ax, [si]
	push ax
	call printnum
	
	exit:
	mov ax, 0x4c00
	int 0x21
	