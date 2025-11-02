;This program inserts arr2 in arr1 at implied position(given in start routine):
[org 0x0100]
	JMP start
arr2:   	db	'123456'
arr2_len:	dw	6
arr1:   	db	'abcdef'
arr1_len:	dw	6


insertArr:
	push bp
	mov bp, sp
	
	pusha
	
	;first making space in arr1:
	mov si, [bp + 12] 
	
	mov cx, [bp + 4] ;pos
	mov dx, [bp + 6] ;len of to be ins
	
	add si, cx
	mov di, si
	add di, dx
	
	mov cx, [bp + 8]
	sub cx, [bp + 4] ;left (wrt position) length of arr1
	
	rep movsb
	
	;now copy:
	mov di, [bp + 12]
	mov dx, [bp + 4]
	add di, dx
	
	mov si, [bp + 10]
	mov cx, [bp + 6]
	
	rep movsb
	
	terminteIns:
	popa
	pop bp
	ret 10

start:
	mov ax, arr1
	push ax
	mov ax, arr2
	push ax
	mov ax, [arr1_len]
	push ax
	mov ax, [arr2_len]
	push ax
	mov ax, 3
	push ax
	call insertArr
	
exit:
    mov ax, 0x4c00
    int 0x21