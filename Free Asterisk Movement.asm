[org 0x0100]
	JMP start
tickCount:	db	0
oldkb:		dd	0
Pos:		dw	2000

timer:
	push ax
	push cs
	pop ds
	
	mov ax, 0xB800
	mov es, ax
	mov ax, 0x0720
	mov di, 0
	mov cx, 2000
	rep stosw
	
	inc byte[tickCount]
	mov al, [tickCount]
	mov [es:160], al
	
	mov di, [Pos]
	mov al, '*'
	mov ah, 0x4
	mov [es:di], ax
	
	call loseCheck
	
	mov  al, 0x20 
	out  0x20, al 
	pop ax
	iret
	
kbisr:
	pusha
	push cs
	pop ds
	
	in al, 0x60
	
	cmp al, 0x48
	jne cmpDown
	
	sub word[Pos], 160
	jmp exit
	
	cmpDown:
	cmp al, 0x50
	jne cmpLeft
	
	add word[Pos], 160
	jmp exit
	
	cmpLeft:
	cmp al, 0x4B
	jne cmpRight
	
	sub word[Pos], 2
	jmp exit
	
	cmpRight:
	cmp al, 0x4D
	jne nomatch

	add word[Pos], 2
	jmp exit
	
	nomatch:
		call loseCheck
	    popa
		jmp far [cs:oldkb]
	
	exit:
		mov  al, 0x20 
		out  0x20, al 
		popa
		iret

loseCheck:
	pusha
	mov ax, 0xB800
	mov es, ax
	
	mov bx, [Pos]
	
	shr bx, 1 ;in bytes
	
	cmp bx, 80
	jbe lost
	cmp bx, 1920
	jae lost	
	
	mov dl, 80
	mov ax, bx
	div dl
	cmp ah, 0
	je lost

	mov dl, 79
	mov ax, bx
	div dl
	cmp ah, 0
	je lost
	
	popa
	ret
	
	lost:
	mov al, 'L'
	mov ah, 1
	mov [es:2000], ax
	mov ax, 0x4c00
	int 0x21

start:
	

	xor  ax, ax 
	mov  es, ax             ; point es to IVT base 
	mov  ax, [es:9*4] 
	mov  [oldkb], ax        ; save offset of old routine 
	mov  ax, [es:9*4+2] 
	mov  [oldkb+2], ax  
	cli
	mov  word [es:9*4], kbisr ; store offset at n*4 
	mov  [es:9*4+2], cs     ; store segment at n*4+2 
	mov  word [es:8*4], timer ; store offset at n*4 
	mov  [es:8*4+2], cs     ; store segment at n*4+ 
	sti  
	
	jmp $
	
	
	mov ax, 0x4c00
	int 0x21