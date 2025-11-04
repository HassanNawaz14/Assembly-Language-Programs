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
	
	mov ax, [x2]
	sub ax, [x1]
	mov dx, [y2]
	sub dx, [y1]
	
	cmp ax, dx
	jne exit
	
	
	mov ax, 0xB800
	mov es, ax
	
	mov di, 0
	mov cx, 2000
	mov ax, 0x7020
	rep stosw
	
	mov di, 160
	mov cx, dx ;the equal length of hieght and width
	shl cx, 1  ;(cpmaring with dx, in 2x)
	mov dx, 0  ;current row
	mov al, '*'
	mov ah, 0x74

	l1:
		mov [es:di], ax
		push di
		
		
		add di, dx
		mov [es:di], ax
		add dx, 2
		pop di
		
		add di, 160
		cmp dx, cx
		jbe l1
		
	
	sub di, 160
	mov cx, [x2];len again
	sub cx, [x1]
	l2:
		mov [es:di], ax
		add di, 2
		dec cx
		cmp cx, 0
		jne l2
	
exit:
	mov ax, 0x4c00
	int 0x21
	