[org 0x0100]
	JMP start
EnterFlag:		dw		0
tickCount:		dw		0
printShapeFlag:	dw		0 ; 0:sq, 1:rect

init_screen:
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, 0
	mov cx, 2000
	mov ax, 0x1720
	rep stosw
	
	
	mov di, 1920
	mov cx, 80
	mov al, '*'
	mov ah, 0x4
	rep stosw	
	
	
	popa
	ret
	
print_sq: ;attr and di vales (position (screen 1/2))
	push bp
	mov bp, sp
	pusha


	mov di, [bp + 4] ;pos
	mov ah, [bp + 6] ;attr
	mov al, '*'
	mov cx, 5
	
	draw_rows:
		mov [es:di], ax
		mov [es:di + 5*160], ax
		add di, 2
		loop draw_rows
		
	mov di, [bp + 4]
	mov cx, 6
	
	draw_cols:
		mov [es:di], ax
		mov [es:di + 10], ax
		add di, 160
		loop draw_cols
		
	
	popa
	pop bp
	ret 4


print_rect: ;attr and di vales (position (screen 1/2))
	push bp
	mov bp, sp
	pusha


	mov di, [bp + 4] ;pos
	mov ah, [bp + 6] ;attr
	mov al, '*'
	mov cx, 11
	
	draw_rows_rect:
		mov [es:di], ax
		mov [es:di + 7*160], ax
		add di, 2
		loop draw_rows_rect
		
	mov di, [bp + 4]
	mov cx, 8
	
	draw_cols_rect:
		mov [es:di], ax
		mov [es:di + 22], ax
		add di, 160
		loop draw_cols_rect
		
	
	popa
	pop bp
	ret 4
	
clrBlink:
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, 0
	mov ax, 0x1720
	mov cx, 920
	rep stosw
	
	popa
	ret
	
clrDisp:
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, 2160
	mov ax, 0x1720
	mov cx, 920
	rep stosw
	
	popa
	ret
	
	
timer:
	pusha
	
	mov ax, 0xb800
	mov es, ax
	
	;mov word[es:160], 0x0701
	
	inc word[cs:tickCount]
	cmp word[cs:tickCount], 18
	jne terminate_timer
	
	mov word[tickCount], 0
	
	cmp word[printShapeFlag], 0
	jne changeToRect

	mov word[printShapeFlag], 1
	call clrBlink
	mov ax, 0x4
	push ax
	mov ax, 556
    push ax	
	call print_sq
	jmp terminate_timer
	
	changeToRect:
	mov word[printShapeFlag], 0
	call clrBlink
	mov ax, 0x2
	push ax
	mov ax, 390
    push ax	
	call print_rect
	
	terminate_timer:
        mov  al, 0x20 
        out  0x20, al           ; send EOI to PIC 
		popa
		iret
		
kbisr:
	pusha
	
	in al, 0x60
	
	cmp al, 0x1
	je escape
	
	cmp al, 0x39
	jne terminate_kbisr
	
	cmp word[printShapeFlag], 0
	jne printRect

	call clrDisp
	mov ax, 0x2
	push ax
	mov ax, 2470
    push ax	
	call print_rect
	jmp terminate_kbisr
	
	printRect:
	call clrDisp
	mov ax, 0x4
	push ax
	mov ax, 2636
    push ax	
	call print_sq
	
	terminate_kbisr:
		mov  al, 0x20 
		out  0x20, al
		popa
		iret
	
	escape:
		mov ax, 0x4c00
		int 0x21


start:

	call init_screen

	xor  ax, ax 
	mov  es, ax             ; point es to ivt base 
	cli                     ; disable interrupts 
	mov  word [es:9*4], kbisr ; store offset at n*4 
	mov  [es:9*4+2], cs     ; store segment at n*4+2 
	mov  word [es:8*4], timer ; store offset at n*4 
	mov  [es:8*4+2], cs     ; store segment at n*4+
	sti                     ; enable interrupts 
	
	jmp $

end	
	mov ax, 0x4c00
	int 0x21