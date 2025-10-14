org 0x0100

jmp start

; ---- constants / data ----
snake_len   equ 5

cur_attr    db 0Ah        ; snake attribute (green default)
def_attr    db 07h        ; default attribute (light gray)

top     dw 0
bottom  dw 24
leftb   dw 0
rightb  dw 79

rand_seed   dw 1234h      ; seed for random generator

; reserve 2000 words for path_array
path_array: times 2000 dw 0

; ---- start ----
start:
    push cs
    pop  ds

    mov ax, 0B800h
    mov es, ax

    call clear_screen
    call scatter_hashes     ; place random #’s with random colors

    mov word [top], 0
    mov word [bottom], 24
    mov word [leftb], 0
    mov word [rightb], 79

    ; generate spiral into path_array
    call generate_spiral

    ; animate following the precomputed path
    call animate_path

    mov ah, 4Ch
    int 21h

; ----------------------------------------------------------------------------
; random: returns random number in AX (0..65535 approx)
; LCG: seed = (seed * 25173 + 13849) mod 65536
; ----------------------------------------------------------------------------
random:
    mov ax, [rand_seed]
    mov bx, 25173
    mul bx              ; DX:AX = AX * 25173
    add ax, 13849
    mov [rand_seed], ax
    ret

; ----------------------------------------------------------------------------
; scatter_hashes: randomly scatter '#'s with random colors (checks empty cells)
; - Places COUNT hashes (tries until placed)
; - Uses remainder DX after div to get index = rand % 2000
; ----------------------------------------------------------------------------
scatter_hashes:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov cx, 50         ; desired number of hashes to place
    xor bp, bp         ; placed count in BP = 0

.place_loop:
    ; get random number in AX
    call random        ; AX = random value

    ; compute index = AX % 2000 -> remainder in DX
    xor dx, dx
    mov bx, 2000
    div bx             ; DX = remainder (0..1999), AX = quotient

    mov ax, dx         ; AX = remainder (index)
    shl ax, 1          ; byte offset = index * 2
    mov di, ax         ; DI = byte offset into ES (video memory)

    ; check if that cell is empty (space). If not empty, skip placing and retry
    mov al, [es:di]    ; character at cell
    cmp al, ' '
    jne .try_again

    ; place '#'
    mov byte [es:di], '#'

    ; pick color
    call random        ; AX = random
    mov bl, al         ; store AL temporarily? careful: random returns AX, AL contains low byte
    ; better: use AX directly, mask low byte
    mov al, ah         ; use high byte for variety (AX=word, AH has high; AH tends to vary)
    ; but simpler: use AL (low byte)
    ; mask to 0..15
    mov al, al
    and al, 0Fh
    cmp al, 0
    jne .ok_color
    mov al, 0Eh        ; ensure visible color if zero
.ok_color:
    mov [es:di+1], al

    ; increment placed count
    inc bp
    cmp bp, cx
    jb .place_loop

    jmp .scatter_done

.try_again:
    ; just try again without changing placed count
    jmp .place_loop

.scatter_done:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ----------------------------------------------------------------------------
; generate_spiral - fills path_array with offsets (same as your existing code)
; ----------------------------------------------------------------------------
generate_spiral:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor bx, bx
    mov di, path_array

.gen_loop:
    mov dx, [top]
    mov cx, [leftb]
.right_pass:
    cmp bx, 2000
    je gen_done
    cmp cx, [rightb]
    ja .after_right
    push dx
    push cx
    call compute_offset
    pop cx
    pop dx
    mov [di], ax
    add di, 2
    inc bx
    inc cx
    jmp .right_pass
.after_right:
    inc word [top]

    cmp bx, 2000
    je gen_done
    mov cx, [rightb]
    mov dx, [top]
.down_pass:
    cmp bx, 2000
    je gen_done
    cmp dx, [bottom]
    ja .after_down
    push dx
    push cx
    call compute_offset
    pop cx
    pop dx
    mov [di], ax
    add di, 2
    inc bx
    inc dx
    jmp .down_pass
.after_down:
    dec word [rightb]

    cmp bx, 2000
    je gen_done
    mov cx, [leftb]
    mov dx, [bottom]
.up_pass:
    cmp bx, 2000
    je gen_done
    cmp dx, [top]
    jb .after_up
    push dx
    push cx
    call compute_offset
    pop cx
    pop dx
    mov [di], ax
    add di, 2
    inc bx
    dec dx
    jmp .up_pass
.after_up:
    inc word [leftb]
    jmp .gen_loop

gen_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ----------------------------------------------------------------------------
; compute_offset: DX=row, CX=col -> AX = ((row*80)+col)*2
; ----------------------------------------------------------------------------
compute_offset:
    push bx
    push si
    mov ax, dx
    mov bx, ax
    shl bx, 6
    mov si, ax
    shl si, 4
    add bx, si
    add bx, cx
    shl bx, 1
    mov ax, bx
    pop si
    pop bx
    ret

; ----------------------------------------------------------------------------
; animate_path
; ----------------------------------------------------------------------------
animate_path:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, path_array
    xor bx, bx

.anim_loop:
    cmp bx, 2000
    je .anim_done

    mov ax, [si]          
    mov di, ax            

    ; check collision with #
    cmp byte [es:di], '#'
    jne .no_hit
        mov al, [es:di+1]
        mov [cur_attr], al
        ; optionally erase the '#' (uncomment if you want):
        ; mov byte [es:di], ' '
.no_hit:

    ; draw snake head
    mov al, '*'
    mov [es:di], al
    mov al, [cur_attr]
    mov [es:di+1], al

    ; erase tail
    cmp bx, snake_len
    jb .skip_erase
        mov di, si
        sub di, snake_len*2
        mov ax, [di]
        mov di, ax
        mov al, ' '
        mov [es:di], al
        mov al, [def_attr]
        mov [es:di+1], al
.skip_erase:

    call delay_short

    add si, 2
    inc bx
    jmp .anim_loop

.anim_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ----------------------------------------------------------------------------
; clear_screen
; ----------------------------------------------------------------------------
clear_screen:
    push ax
    push bx
    push cx
    push di
    xor di, di
    mov cx, 2000
    mov al, ' '
    mov bl, [def_attr]
.cls_loop:
    mov [es:di], al
    mov [es:di+1], bl
    add di, 2
    loop .cls_loop
    pop di
    pop cx
    pop bx
    pop ax
    ret

; ----------------------------------------------------------------------------
; delay_short
; ----------------------------------------------------------------------------
delay_short:
    push cx
    mov cx, 0F000h
.dloop:
    nop
    dec cx
    jnz .dloop
    pop cx
    ret
