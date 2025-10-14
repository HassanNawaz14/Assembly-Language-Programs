[org 0x0100]
	jmp start
max_row: dw	11
mac_col: dw 80

printX:
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	

	mov ax, 0xb800
	mov es, ax
	
	mov cx, 2000
	mov ax, 0x0720
	rep stosw 
	
	;cal di on X, Y
	mov ax , [bp + 6] ;X
	mov dx, 160
	mul dx
	mov dx, [bp + 4] 
	shl dx, 1 ;Y * 2
	add ax, dx ;X * 160 + Y * 2
	;   |
	;   -----
	;		|
	mov di, ax
	mov dx, di
	add dx, 80
	mov si, dx
	mov dh, 4
	mov dl, '*'
	mov cx, 2000
	add cx, di
	
	next_dot:
		mov [es:di], dx
		add di, 166
		
		mov [es:si], dx
		add si, 154
		
		cmp di, cx
		ja exit
		cmp si, cx
		ja exit
		jmp next_dot
		
	exit:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 4
		
		
delay_short:
    push cx
    mov cx, 07000h
	.dloop:
		nop
		dec cx
		jnz .dloop
    pop cx
    ret

start:
	;X: 0->10
	;Y: 0->80 inc wrap around
	mov cx, 0 ;for row
	mov dx, 0 ;for col
	
	next_row:
		mov dx, 0
		
		next_col:
			call delay_short
			mov ax, cx	;X
			push ax
			mov ax, dx	;Y
			push ax
			call printX
			
			inc dx
			cmp dx, 80
			jne next_col
		
		inc cx
		cmp cx, 11
		jne next_row
		

	mov ax, 0x4c00
	int 0x21