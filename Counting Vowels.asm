[org 0x0100]
	JMP start
string:		db	'Hello World', 0
len:		dw	11
vowelCount: times 5 db 0 ;A,E,I,O,U
printing:	db 'A or a: E or e: I or i: O or o: U or u: '



count_vowels:
	pusha
	
	mov si, string
	mov cx, 11
	
	;covert to all small first!
	
	next_compare:
		cmp byte[si], 'a'
		jne cmpE
		
		inc byte [vowelCount]
		jmp nomatch
		
		cmpE:
		cmp byte[si], 'e'
		jne cmpI

		inc byte [vowelCount + 1]
		jmp nomatch
		
		cmpI:
		cmp byte[si], 'i'
		jne cmpO
		
		inc byte [vowelCount + 2]
		jmp nomatch

		cmpO:
		cmp byte[si], 'o'
		jne cmpU
		
		inc byte [vowelCount + 3]
		jmp nomatch

		cmpU:
		cmp byte[si], 'u'
		jne nomatch
		
		inc byte [vowelCount + 4]

		nomatch:
		inc si
		loop next_compare
	
	popa
	ret 4
	
	
print_count:
	pusha
	mov ax, 0xb800
	mov es, ax
	
	mov ax, 0x0720
	mov cx, 2000
	mov di, 0
	rep stosw
	
	
	mov di, 1000
	mov si, printing
	mov bx, 0
	mov cx, 5
	mov ah, 0x1
	outer:
		mov ah, 0x1
		xor dx, dx
		
		inner:
		
		lodsb
		stosw
		
		inc dx
		cmp dx, 8
		jne inner
		
		
	
	mov al, [vowelCount + bx]
	add al, 0x30
	mov ah, 0x4
	mov [es:di], ax
	inc bx
	add di, 144
	loop outer
	
	
	
	popa
	ret


start:
	push string
	push word[len]
	call count_vowels
	call print_count
	
	mov ax, 0x4c00
	int 0x21
	