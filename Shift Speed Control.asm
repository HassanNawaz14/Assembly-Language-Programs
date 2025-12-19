[org 0x0100]
	JMP start
Pos:	dw	0
Spd:	dw	2
oldkb:	dd	0	
	
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
	
	mov ax, [Spd]
	add [Pos], ax
	
	mov di, [Pos]
	mov al, '*'
	mov ah, 0x4
	mov [es:di], ax
	
	
	mov al, 0x20
	out 0x20, al
	popa
	iret
	
kbisr:
	pusha
	push cs
	pop ds
	
	in al, 0x60
	
	cmp al, 0x2A
	jne rightCheck
	
	sub word[Spd], 2
	
	rightCheck:
	cmp al, 0x36
	jne exit
	
	add word[Spd], 2
	
exit:
	mov al, 0x20
	out 0x20, al
	popa
	iret
	
	
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
	