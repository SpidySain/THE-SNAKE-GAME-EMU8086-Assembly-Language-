org 100h
include "emu8086.inc"
jmp menu   

snake_max_length dw 400
size dw 3 
snake dw snake_max_length dup(0)
grow db 0
tail dw ?

left  db 4bh
right db 4dh
up    db 48h 
down  db 50h 


;Initial movement direction 
current_direction db 0

;arena coordinate
x_coor db 49
y_coor db 0   

;food coordinate
foodx    db 0
foody    db 0
score     db 0
              
main db 9,9, " |__   __| |           / ____|           | |        ",13,10  
     db 9,9, "    | |  | |__   ___  | (___  _ __   __ _| | _____  ",13,10
     db 9,9, "    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ",13,10
     db 9,9, "    | |  | | | |  __/  ____) | | | | (_| |   <  __/ ",13,10
     db 9,9, "   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ",13,10
     db 9,9,"  / ____|                    | |                    ", 13,10
     db 9,9," | |  __  ____ _ __ ___   ___| |                    ", 13,10
     db 9,9," | | |_ |/ _  | '_ ` _ \ / _ \ |                    ", 13,10
     db 9,9," | |__| | (_| | | | | | |  __/_|                    ", 13,10
     db 9,9,"  \_____|\__,_|_| |_| |_|\___(_)                    ", 13,10,10,13
     db 9,9,""
     db 13,"Welcome to THE SNAKE GAME!!! ",13,10
     
     db 13,10,"Rules:",13,10
     db 16," Press UP, DOWN, LEFT and RIGHT ARROW to move", 13,10
     db 16," Press ESC to exit the game!", 13,10
     db 16," Eat everything on screen to earn points!!!", 13,10

	 db 13,10,16,"Arena1 (1) ",1ah," Arena size: 50x22",0dh,0ah  
	 db 10h,"Arena2 (2) ",26," Arena size: 50x19",13,10
	 db 10h,"Arena3 (3) ",26," Arena size: 50x16",13,10
	    
	 db 15h," Choose an arena: ", "$"

	 
big    db 9,9,"ARENA 1 (50x22)",13,10,"$"  
medium db 9,9,"ARENA 2 (50x19)",13,10,"$" 
small  db 9,9,"ARENA 3 (50x16)",13,10,"$" 

border1          db 0dh,0ah,0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"
border2         db 0dh,0ah,0bah,09h,09h,09h,09h,09h,09h,20h,0bah,09h,0B1H,09h,09h,20h,20h,20h,20h,20h,0B1H ,"$"
border3          db 0dh,0ah,0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bch, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"  

info1  db  "---The Snake Game---$"
info2  db 16," Scoreboard $"
info3  db 16," Score: $"
info4  db 16,"Good Luck!",2,"$"

 

gameover              db 13,10,10,10,10,10,10,10,9,9,"  ___   __   _  _  ____     __   _  _  ____  ____ ", 13,10 
              db 9,9,                                " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 13,10
              db 9,9,                                "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 13,10
              db 9,9,                                " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 13,10     
           
              db 0ah,0ah,09h,09h,09h, "Oops... Looks like you lost! Better luck next time", 0dh,0ah 
              db 0ah,09h,09h,09h,"   Your Score: ",0dh,0ah   
              
              db 0ah,0ah,0ah,09h,09h,"  --- Game created by: Group 5 ---","$" 
              
              

;-------------------------------------------------- MENU -----------------------------------------------
menu:

lea dx,main
mov ah,9h
int 21h

mov ah,1
int 21h
mov dl,al

mov al,3
mov ah,0
int 16
;jmp area
;-----------------------------ARENA-----------------------------------
arena: 
cmp dl,'1'
je arena1

cmp dl,'2'
je arena2

cmp dl,'3'
je arena3

jne menu
ret

;---------------------------ARENA 1-------------------------------
arena1:

lea dx,big
mov ah,9
int 21h

mov ah,9
lea dx,border1
int 21h

mov cx,20
table1:   

lea dx,border2
mov ah,9      
int 21h
loop table1

lea dx,border3
mov ah,9      
int 21h 

call table
mov cx,1
;mov y_coor,22
;add y_coor,1 
mov byte ptr [y_coor],22



jmp game 
 
 
;---------------------------ARENA 2-------------------------------         

arena2:

lea dx,medium
mov ah,9
int 21h

mov ah,9
lea dx,border1
int 21h

mov cx,17
table2:   

lea dx,border2
mov ah,9      
int 21h
loop table2

lea dx,border3
mov ah,9      
int 21h 

call table
mov cx,1
;mov y_coor,19
;add y_coor,1 
mov byte ptr [y_coor],19


jmp game


;---------------------------ARENA 3-------------------------------         

arena3:

lea dx,small
mov ah,9
int 21h

mov ah,9
lea dx,border1
int 21h

mov cx,14
table3:   

lea dx,border2
mov ah,9      
int 21h
loop table3

lea dx,border3
mov ah,9      
int 21h 

call table
mov cx,1
;mov y_coor,14
;add y_coor,1 
mov byte ptr [y_coor],16


jmp game 

;---COORDINATE-----
coor:
mov dh,10
mov dl,20
mov snake[0], dx

dec cx
call food 


Game:
cmp cx,1
je coor
mov dx,snake[0]
mov ah,2
int 10h

mov al,0b1h
mov bl, 0ch
mov cx,1
        
mov ah,9
int 10h

;Creating a tail for the snake
; tail = snake[(s_size*2) - 2]
;Creating a tail for the snake
; ---- Move first ----
call snake_move

; ---- Now compute tail index ----
mov bx,[size]
dec bx                 ; use (size-1) always, old size tail
add bx, bx 
sub bx,2
mov ax,[snake+bx]
mov [tail],ax


; --------------------------------------Hide the old tail (skip once if we just ate)-----------------------------
mov al,[grow]
cmp al,0
jne reduce_grow   ; if grow > 0, skip tail erase once

; erase tail
mov dx,[tail]
mov ah,02h
int 10h
mov al,' ' 
mov bl,07h
mov cx,1
mov ah,09h
int 10h
jmp key_check


reduce_grow:
dec byte ptr [grow]   ; decrease grow counter

   
;after_tail_hide

key_check:
   
   mov ah,1
   int 16h
   je no_key
   
   mov ah,0
   int 16h
   cmp al,1bh
   je gameover_screen
   mov [current_direction],ah 
   
no_key:
mov cx,0
jmp game




checkfood:
cmp al,foodx
je  atributeFood
RET

atributeFood:
   mov ah,02h
   mov dl,07h
   int 21h
   
inc score

mov ax,[size]
cmp ax,snake_max_length 
jge no_len
inc ax
mov [size],ax
mov byte ptr [grow], 1   ; <-- grow exactly 1 block


no_len:
mov dl,66
mov dh,12
mov ah,02h
int 10h
mov al,[score]        
mov ah,0
call print_num 
call food
ret
;----------------------
    ; Debug print Y
    mov ah, 2
    mov dl, dh
    add dl, '0'
    int 21h

    ; Debug print separator
    mov dl, ' '
    int 21h

    ; Debug print y_coor
    mov dl, [y_coor]
    add dl, '0'
    int 21h
;---------------------
gameover_screen:

mov al,03h
mov ah,0
int 10h

mov ah,9
lea dx, gameover 
int 21h

mov dl,43
mov dh,15
mov ah,02h
int 10h

mov al,[score]
mov ah,0
call print_num
int 20h

print_num proc
    push ax
    push bx
    push cx
    push dx
    
    mov cx,0
    mov bx,10
    next_digit:
      mov dx,0
      div bx
      push dx
      inc cx
      cmp ax,0
      jne next_digit 
      
    print_loop:
      pop dx
      add dl,30h
      mov ah,02h
      int 21h
      loop print_loop
      
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

food proc
    
    mov ah,02Ch
    int 21h
    
    mov al,dl
    mov ah,0
    mov bx,3
    mov dx,0
    
    div bx
    mov bl,x_coor
    sub bl,2
    sub bl,al
    
    mov foodx,bl
    
    mov ah,02ch
    int 21h
    mov al,dl
    mov ah,0
    mov bx,7
    mov dx,0
    div bx
    
    mov bl,y_coor
    sub bl,2
    sub bl,al
    mov foody,bl
    
    mov dl,foodx
    mov dh,foody
    
    mov ah,02h
    int 10h
    
    mov al,0feh
    mov bl,10
    mov cx,1
    mov ah,9
    int 10h
    
    dec cx
    ret
food endp



table proc 
    ;1st info
    mov dl,57
    mov dh,6       
    mov ah,2
    int 10h    
    lea dx,info1
    mov ah,9
    int 21h
    ;2nd
    mov dl,57
    mov dh,9 
    mov ah,2
    int 10h
    lea dx,info2
    mov ah,9
    int 21h 
    ;3rd
    mov dl,57
    mov dh,12 
    mov ah,2
    int 10h
    lea dx,info3
    mov ah,9
    int 21h   
    ;4th
    mov dl,58
    mov dh,15 
    mov ah,2
    int 10h
    lea dx,info4
    mov ah,9
    int 21h 
    ret
table endp 

snake_move proc
    mov bx, [size]
    dec bx
    add bx, bx
    mov di, bx

    mov cx, [size]
    dec cx
    
move_array:
    mov ax, snake[di - 2]
    mov snake[di], ax
    sub di, 2
    loop move_array

    mov al, [current_direction]
    cmp al, [left]
    je move_left

    cmp al, [right]
    je move_right
    cmp al, [up]
    je move_up

    cmp al, [down]
    je move_down

    jmp after_move

move_left:
    mov dx, [snake]
    dec dl
    cmp dl, 0
    je gameover_screen
    mov [snake], dx
    jmp after_move

move_right:
    mov dx, [snake]
    inc dl
    cmp dl, x_coor
    jge gameover_screen
    mov [snake], dx
    jmp after_move

move_up:
    mov dx, [snake]
    dec dh
    cmp dh, 3           ; top border value
    jl gameover_screen
    mov [snake], dx
    jmp after_move

move_down:
    mov dx, [snake]
    inc dh
    mov al, [y_coor]
    cmp dh, al
    ja gameover_screen
    mov [snake], dx
    jmp after_move

after_move:
    mov ax, [size]
    cmp ax, 4
    jl after_collision_check  ; skip self-collision check if snake too short

    mov ax, snake[0]          ; head position
    mov cx, [size]
    dec cx                    ; number of body segments to check
    
    mov bx, 2                 ; start offset at second segment

check_loop:
    cmp cx, 0
    je after_collision_check

    mov dx, snake[bx]         ; current segment position
    cmp ax, dx
    je gameover_screen        ; collision detected

    add bx, 2                 ; advance to next segment (word size)
    dec cx
    jmp check_loop

after_collision_check:
    ; Check if snake head is on food
    mov ax, snake[0]
    cmp ah, foody
    jne no_food

    cmp al, foodx
    jne no_food

    ; Snake ate the food
    call atributeFood

no_food:
    ret
snake_move endp


                   

END
