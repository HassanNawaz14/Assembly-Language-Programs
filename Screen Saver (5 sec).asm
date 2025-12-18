[org 0x0100]
	JMP start
tickCount:	db	0
oldkb:		dd	0
buffer:		times 2000 dw 0
saver:		db	'SCREEN SAVER', 0
len:		dw 	12
saverState: dw  0

printstr:     push bp 
              mov  bp, sp 
              push es 
              push ax 
              push cx 
              push si 
              push di 
 
              mov  ax, 0xb800 
              mov  es, ax             ; point es to video base 
              mov  al, 80             ; load al with columns per row 
              mul  byte [bp+10]       ; multiply with y position 
              add  ax, [bp+12]        ; add x position 
              shl  ax, 1              ; turn into byte offset 
              mov  di,ax              ; point di to required location 
              mov  si, [bp+6]         ; point si to string 
              mov  cx, [bp+4]         ; load length of string in cx 
              mov  ah, [bp+8] 
			   cld                     ; auto increment mode 
nextchar:     lodsb                   ; load next char in al 
              stosw                   ; print char/attribute pair 
              loop nextchar           ; repeat for the whole string 
 
              pop  di 
              pop  si 
              pop  cx 
              pop  ax 
              pop  es 
              pop  bp 
              ret  10 

timer:
	push ax
	push cs
	pop ds
	
	cmp word[saverState], 1
	je term_timer
	
	inc byte[tickCount]
	
	cmp byte[tickCount], 90
	jne term_timer
	
	mov word[saverState], 1
	mov byte[tickCount], 0
	push ds
	pop es
	mov di, buffer
	mov ax, 0xb800
	mov ds, ax
	mov si, 0
	mov cx, 2000
	rep movsw
	
	push ds
	pop es
	mov di, 0
	mov ax, 0x0720
	mov cx, 2000
	rep stosw
	
	push cs
	pop ds
	mov  ax, 30         
	push ax                 ; push x position  
	mov  ax, 12 
	push ax                 ; push y position  
	mov  ax, 4              ; blue on black attribute 
	push ax                 ; push attribute  
	mov  ax, saver 
	push ax                 ; push address of message 
	push word [len]      ; push message length 
	call printstr
	
	
	term_timer:
	
	mov  al, 0x20 
	out  0x20, al 
	pop ax
	iret
	
kbisr:
	pusha
	push cs
	pop ds
	
	mov ax, 0xB800
	mov es, ax
	
	mov word[saverState], 0
	mov byte[tickCount], 0
	mov si, buffer
	mov di, 0
	mov cx, 2000
	rep movsw
	
	popa
	jmp far [cs:oldkb]
	exit:
		mov  al, 0x20 
		out  0x20, al 
		popa
		iret

start:
	
	mov ax, 0xb800
	mov es, ax
	
	mov ah, 1
	mov al, 'X'
	mov cx, 2000
	mov di, 0
	rep stosw
	
	push ds
	pop es
	mov di, buffer
	mov cx, 2000
	rep stosw

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