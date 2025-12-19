[org 0x0100]
	JMP start
len			dw	5
Pos:		dw	174
tickCount:	dw	0
Motion:		dw	0 ;0: to right, 1: to left


timer:
	pusha
	push cs
	pop ds
	
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x0720
	mov cx, 2000
	mov di, 0
	rep stosw
	
	mov word[tickCount], 0
	push word[len]
	call MoveX
	
	skipMove:
	push word[len]
	call DrawX
	
	mov  al, 0x20 
	out  0x20, al 
	popa
	iret


MoveX:
    push bp
    mov bp, sp
	pusha
	
	cmp word[Motion], 0
	jne moveLeft
	
	add word[Pos], 2
	jmp checkBounds
	
	moveLeft:
	sub word[Pos], 2
	
	checkBounds:
	mov cx, [bp + 4]
	shl cx, 2
	
	mov ax, [Pos]
	add ax, cx
	
	xor dx, dx
	mov bl, 160
	div bl
	
	cmp ah, 0
	jne noMotionCHange
	
	cmp word[Motion], 0
	jne ToZero
	
	mov word[Motion], 1
	jmp noMotionCHange
	
	ToZero:
	mov word[Motion], 0
	
	noMotionCHange:
	popa
	pop bp
	ret 2


DrawX:
	push bp
	mov bp, sp
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, [Pos]
	mov cx, [bp + 4]
	shl cx, 1 ;upper + lower
	sub cx, 1
	mov ah, 0x4
	
	mov dx, 0
	mov al, '\'
	main_diag:
		mov [es:di], ax
		add di, 162
		inc dx
		cmp dx, cx
		jne main_diag
		
	mov di, [Pos]
	mov bx, cx
	shl bx, 1
	sub bx, 2
	add di, bx
	mov dx, 0
	mov al, '/'
	sec_diag:
		mov [es:di], ax
		add di, 158
		inc dx
		cmp dx, cx
		jne sec_diag
		
		
	mov cx, [bp + 4]
	dec cx
	shl cx, 1
	mov di, [Pos]
	mov ax, cx
	mov bl, 80
	mul bl
	add di, ax
	add di, cx
	
	mov ah, 0x4
	mov al, 'X'
	mov [es:di], ax
	
	popa
	pop bp
	ret 2
	
start:
	
	xor ax, ax
	mov es, ax
	cli
	mov  word [es:8*4], timer ; store offset at n*4 
	mov  [es:8*4+2], cs     ; store segment at n*4+ 
	sti  
	
	jmp $
	
	mov ax, 0x4c00
	int 0x21