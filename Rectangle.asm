[org 0x0100]
	JMP start
	
x1:		dw 	7
y1:		dw 	8
x2:     dw 	10
y2:     dw 	11

start:
	mov ax, x1
	cmp ax, [x2]
	jb exit
	
	mov ax, y1
	cmp ax, [y2]
	jb exit
	
	
	mov ax, 0xB800
	mov es, ax
	
	mov di, 0
	mov cx, 2000
	mov ax, 0x7020
	rep stosw
	
	mov di, 160
	mov cx, [x2]
	sub cx, [x1]; cx = h, dx = w
	mov dx, [y2]
	sub dx, [y1]; cx = h, dx = w
	
	shl dx, 1
	mov al, '$'
	mov ah, 0x71

	l1:
		mov [es:di], ax
		
		push di
		add di, dx 
		mov [es:di], ax
		pop di
		
		add di, 160
		dec cx
		cmp cx, 0
		jne l1

	mov cx, [x2]
	sub cx, [x1]
	dec cx
	mov ax, 160
	mul cx
	mov cx, ax
	mov al, '$'
	mov ah, 0x71
	mov dx, [y2]
	sub dx, [y1]
	
	mov di, 160
	l2:
		mov [es:di], ax
		
		push di
		
		add di, cx 
		mov [es:di], ax
		pop di
		
		add di, 2
		dec dx
		cmp dx, 0
		jne l2
	
exit:
	mov ax, 0x4c00
	int 0x21
	