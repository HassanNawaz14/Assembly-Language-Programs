[org 0x0100]
	JMP start
string:		db	'aaabccddd'
len			dw	9


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


reduceString: ;si, di already pointing the two matching adjecents for this routine!
	pusha
	
	inc si
	dec word[len]
	dec word[len];two will be removed
	mov bx, 0
	
	shift_loop:
		mov al, [si]
		mov [di], al
		
		inc di
		inc si
		inc bx
		cmp bx, [len]
		jbe shift_loop
	
	popa
	ret
	
irreducibleString:
	pusha
	
	push ds
	pop es
	
	mov di, string
	mov si, string
	inc si
	
	mov bx, 0
	
	reduce_loop:
		mov al, [di]
		cmp al, [si]
		jne skinpRemove
		
		call reduceString
		mov di, string
		dec di
	    mov si, string
	    ;inc si
	    mov bx, 0
		
		skinpRemove:
		inc di
		inc si
		inc bx
		cmp bx, [len]
		jbe reduce_loop
	
	
	popa
	ret


start:
	call irreducibleString
	mov  ax, 30         
	push ax                 ; push x position  
	mov  ax, 12 
	push ax                 ; push y position  
	mov  ax, 4              ; blue on black attribute 
	push ax                 ; push attribute  
	mov  ax, string 
	push ax                 ; push address of message 
	push word [len]      ; push message length 
	call printstr
	
	mov ax, 0x4c00
	int 0x21
		
	