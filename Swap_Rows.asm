[org 0x0100]
	JMP start
flag: dw 0
temp_row:	times 80 dw 0

start:
	mov ax, 0xB800
	mov es, ax
	
	mov di, 0

	mov bl, '*'
	mov bh, 0x4
	
	l1:
		cmp word[flag], 0
		je even_fill
		jne odd_fill
		
	even_fill:
		mov word[flag], 1
		mov cx, 80
		mov al, '&'
		mov ah, 0x1
		rep stosw
		cmp di, 3998
		jbe l1
		cmp di, 3998
		ja Agay
	odd_fill:
		mov word[flag], 0
		mov cx, 80
		mov al, '*'
		mov ah, 0x4
		rep stosw
		cmp di, 3998
		jbe l1
		cmp di, 3998
		ja Agay
		
		
		
		
	Agay:
	
	
;;;;	swapping even with odd rows:
	
	mov dx, ds;saving ds for later
	mov si, 160

l2:	
	push si
	;odd to temp
	mov ax, dx
	mov es, ax
	mov ax, 0xB800
	mov ds, ax
	;mov si, 160 ;from source (ds:si) [B800:160] to dest (es:di) [DS:temp_row]
	mov di, temp_row
	mov cx, 80
	rep movsw
	
	cld
	;even to odd
	mov ax, 0xB800
	mov es, ax
	mov ds, ax
	
	mov di, si
	sub di, 160
	mov cx, 80
	rep movsw
	
	;temp to even
	mov ds, dx
	mov si, temp_row
	
	mov cx, 80
	rep movsw
	
	pop si
	
add si, 160
cmp si, 4000
jb l2
	
exit:
	mov ax, 0x4c00
	int 0x21
	