[org 0x0100]
	jmp start



start:
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x0720
	mov cx, 2000
	rep stosw 
	
	mov di, 0
	mov ax, 0x21
	mov bx, 0
	mov ah, 1
	mov dx, 0
	
	l1:
		mov di, 0
		call delay_short
		
			; push ax
			; push cx
			; push di
			
			; mov ax, bx
			; mov cx, 0xA0
			; div cx
			
			; mov ah, 0;only needed al=q in cx
			
			; xor di,di
			; mov cx, ax
			; mov ax, 0x0720
			; rep stosw
			
			; pop di
			; pop cx
			; pop ax
		
		l2:
			
			mov [es:di+bx], ax
			inc di
			inc di
			inc di
			inc di
			inc di
			inc di
			
			inc al
			inc al
			inc al
			inc al
			inc al
			inc al
			cmp al, 0x7E
			je ResetAx
			
			; 
			
			cmp di, 160
			jbe l2
			
		
			
		add bx, 160
		cmp bx, 3998
		jb l1
		
		shl ah, 1
		cmp ah, 16
		je ResetAh
			; ;clearing for new:
			; push cx
			; push ax
			
			; mov ax, 0x0720
			; mov cx, 2000
			; rep stosw
			
			; pop ax
			; pop cx
			
		
		mov bx, 0
		inc dx
		cmp dx, 10
		jne l1
		
		
	end:
	mov ax, 0x4c00
	int 0x21
	
	ResetAx:
		mov al, 0x21
		inc di
		inc di
		inc di
		inc di
		inc di
		inc di
		cmp di, 160
		jbe l2
		jmp end
		
	ResetAh:
		mov ah, 1
		add bx, 160
		cmp bx, 3990
		jb l1
		
		mov bx, 0
		inc cx
		cmp cx, 5
		jne l1
		
		jmp end
		
delay_short:
    push cx
    mov cx, 07000h
	.dloop:
		nop
		dec cx
		jnz .dloop
    pop cx
    ret