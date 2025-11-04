[org 0x0100]
jmp start
	str1: db 'Hello'
	str2: db 'This is Best for you'
	str3: db 'You are right'
	str4: db 'World Good'
	str5: db 'FAST NUCES'
	len: dw 5

fillScr:
	push ax
	push di
	push es
	
	mov ax,0xb800
	mov es,ax
	mov di,0
	mov cx,2000
	loop5:
		mov word[es:di],0x0720
		add di,2
		loop loop5
		
	mov ax,0xb800
	mov es,ax
	mov di,160
	mov cx,5
	mov si,str1
	mov ah,0x07
	loop1:
		mov al,[si]
		mov [es:di],ax
		add si,1
		add di,2
		loop loop1
	
	mov di,320
	mov cx,20
	mov si,str2
	mov ah,0x07
	loop2:
		mov al,[si]
		mov [es:di],ax
		inc si
		add di,2
		loop loop2
			
	mov di,480
	mov cx,13
	mov si,str3
	mov ah,0x07
	loop3:
		mov al,[si]
		mov [es:di],ax
		inc si
		add di,2
		loop loop3
	mov di,640
	mov cx,10
	mov si,str4
	mov ah,0x07
	loop7:
		mov al,[si]
		mov [es:di],ax
		inc si
		add di,2
		loop loop7
	mov di,1440
	mov cx,10
	mov si,str5
	mov ah,0x07
	loop9:
		mov al,[si]
		mov [es:di],ax
		inc si
		add di,2
		loop loop9
	pop es
	pop di
	pop ax
	ret
	
	
	
start:
	call fillScr
	
	mov dx, ds
	mov ax, 0xb800
	mov es, ax
	mov si, 160
	mov ds, ax
	
	
main_loop:
	cld
	xor cx, cx
	push si
	checkforSpace:
		lodsw
		cmp ax, 0x0720
		je check2ndSpace
		inc cx
		cmp cx, 80
		jne checkforSpace
		
	check2ndSpace:
		mov ax, [ds:si+2]
		cmp ax, 0x0720
		je startSwapig
		inc cx
		jmp checkforSpace
	
	
	startSwapig:
		sub si, 4
		mov di, si
		shl cx, 1
		sub di, cx
		add di, 160
		shr cx, 1 
		push cx
		std
		rep movsw
		;spacing:
		pop cx
		cld
		mov ax, 0x0720
		mov di, si
		add di, 2
		rep stosw

pop si
add si, 160
cmp si, 4000
jb main_loop	
	
	
	
	
	
	
	
exit:
	mov ax,0x4c00
	int 0x21