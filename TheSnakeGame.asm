org 100h
include "emu8086.inc"  
JMP MENU


; ** Snake properties **

MAX_SNAKE   equ 400           ; capacity in words (enough headroom)
s_size      dw 3              ; runtime snake length (starts at 3)
snake       dw MAX_SNAKE DUP(0)
grow_flag   db 0              ; 1 = just ate; skip tail erase once


tail    dw      ?     ; variable for snake tail position

; Snake movement directions (keyboard arrows, scan codes) 
left    equ     4bh
right   equ     4dh
up      equ     48h
down    equ     50h
  
; Initial movement direction
cur_dir db      right  


x_coord equ 49    ; X coordinate for arena right edge
y_coord db 0      ; Y coordinate for arena bottom edge (depends on difficulty)

; Fruit coordinates
fruitx db 0
fruity db 0               

score db 0 
  
; Macros to print numbers
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
               

; GAME MESSAGES  
 
main    db  09h,09h," |__   __| |           / ____|           | |        ", 0dh,0ah
        db  09h,09h,"    | |  | |__   ___  | (___  _ __   __ _| | _____  ", 0dh,0ah
        db  09h,09h,"    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ ", 0dh,0ah
        db  09h,09h,"    | |  | | | |  __/  ____) | | | | (_| |   <  __/ ", 0dh,0ah
        db  09h,09h,"   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| ", 0dh,0ah
        db  09h,09h,"  / ____|                    | |                    ", 0dh,0ah
        db  09h,09h," | |  __  ____ _ __ ___   ___| |                    ", 0dh,0ah
        db  09h,09h," | | |_ |/ _  | '_ ` _ \ / _ \ |                    ", 0dh,0ah
        db  09h,09h," | |__| | (_| | | | | | |  __/_|                    ", 0dh,0ah
        db  09h,09h,"  \_____|\__,_|_| |_| |_|\___(_)                    ", 0dh,0ah

	    db 0dh,"Welcome to The Snake Game! ", 0dh,0ah
	    
	    
	    db 0dh,0ah,"Rules:", 0dh,0ah	    	
	    db 0FEh,"Press UP, DOWN, LEFT and RIGHT ARROW to move", 0dh,0ah
	    db 0FEh,"Press ESC to exit the game!", 0dh,0ah 
	    db 0FEh,"Eat everything on screen to earn points!!", 0dh,0ah
	     	    
	    db 0dh,0ah ,10h,"Arena1 (1) ",1ah," Arena size: 50x22",0dh,0ah  
	    db 10h,"Arena2 (2) ",1ah," Arena size: 50x19",0dh,0ah
	    db 10h,"Arena3 (3) ",1ah," Arena size: 50x16",0dh,0ah
	    
	    db 0Fh," Choose an arena: ", "$"


modo_facil    db 09h,"ARENA 1 (50x22)",0dh,0ah,"$" 
modo_medio    db 09h,"ARENA 2 (50x19)",0dh,0ah,"$"               
modo_dificil  db 09h,"ARENA 3 (50x16)",0dh,0ah,"$" 
              
; Arena borders & scoreboard text 
COL1          db 0dh,0ah,0c9h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bbh, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"
COL2          db 0dh,0ah,0bah,09h,09h,09h,09h,09h,09h,20h,0bah,09h,0B1H,09h,09h,20h,20h,20h,20h,20h,0B1H ,"$"
COL3          db 0dh,0ah,0c8h,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,0bch, 09h,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,0B1H,"$"

INFO1          db     "---The Snake Game---$" 
INFO2          db 10h," *SCOREBOARD*$"
INFO3          db 10h," Score: $"
INFO4          db 10h,"Good luck! ",02h,"$" 





GAME_OVER     db 0dh,0ah,0ah,0ah,0ah,0ah,0ah,0ah,09h,09h,"  ___   __   _  _  ____     __   _  _  ____  ____ ", 0dh,0ah 
              db 09h,09h,                                " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 0dh,0ah
              db 09h,09h,                                "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 0dh,0ah
              db 09h,09h,                                " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 0dh,0ah     
           
              db 0ah,0ah,09h,09h,09h, "Oops... Looks like you lost!", 0dh,0ah 
              db 0ah,09h,09h,09h,"   Your Score: ",0dh,0ah   
              
              db 0ah,0ah,0ah,09h,09h,"  --- Game created by: Group 5 ---","$"



PRINT_TABLE proc
    
MOV DL, 57
MOV DH, 6

;Function that sets the cursor position based on the DX register
MOV     AH, 02h  
INT     10h

;INT to write to the points table
MOV AH, 9         
LEA DX, INFO1
INT 21H

;Defining coordinates for the cursor
MOV DL, 57
MOV DH, 9

;Function that sets the cursor position based on the DX register
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO2
INT 21H  

MOV DL, 57
MOV DH, 12

;
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO3
INT 21H


MOV DL, 58
MOV DH, 15

;Function that sets the cursor position based on the DX register
MOV     AH, 02h  
INT     10h   

MOV AH, 9         
LEA DX, INFO4
INT 21H

ret

PRINT_TABLE endp     




      
MENU:


;INT to write to screen
MOV AH, 9         
LEA DX, main
INT 21H   

;Read the selected option regarding difficulty
MOV AH, 1
INT 21H    

MOV DL, AL ;Guardamos o valor do registo AL no registo DL 

;To clear the screen we use the 10h interruption
; Interruption that sets the video mode to TextMode 80x25 chars and 16 colors
MOV AL, 03H
MOV AH, 0
INT 10H	

JMP ARENA   





ARENA:
 
;Compare the value stored in the DL register
;to know which key was pressed. If it wasn't
;any of the desired ones, the menu will be displayed again.
  
CMP DL, '1'
JE ARENA1

CMP Dl, '2'
JE ARENA2

CMP Dl, '3'
JE ARENA3

JNE MENU
RET




;** ARENA 50x22 **

ARENA1: 


;INT para escrever no ecra
MOV AH, 9         
LEA DX, modo_facil
INT 21H  

;Escreve a primeira borda 
MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 20 

TABULEIRO1:

;escreve a segunda coluna
MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO1

;Escreve a ultima coluna 
MOV AH,9
LEA DX,COL3
INT 21H

;funcao para escrever dentro da tabela
call PRINT_TABLE                      


MOV CX, 1;We set 1 in the counter to know that it is 1x that will loop 

 
; Saves the y coordinate of the lower limit of this arena in the y_coord variable

mov y_coord, 22     ; 22 because it is the defined size of the arena

add y_coord, 1      ;  we add 1 because this is the arena offset


JMP GAME  




 
;** ARENA 50x19 **
    
ARENA2:

MOV AH, 9         
LEA DX, modo_medio
INT 21H 
                                       

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 17

TABULEIRO2:
    
MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO2


MOV AH,9
LEA DX,COL3
INT 21H   

call PRINT_TABLE  

MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 19   

add y_coord, 1     


JMP GAME 





;** ARENA 50x16 **

ARENA3:

MOV AH, 9         
LEA DX, modo_dificil
INT 21H 

MOV AH,9
LEA DX,COL1
INT 21H

MOV CX, 14

TABULEIRO3: 

MOV AH,9
LEA DX,COL2
INT 21H

LOOP TABULEIRO3

MOV AH,9
LEA DX,COL3
INT 21H

call PRINT_TABLE  

MOV CX, 1


;Guarda na variavel y_coord a coordenada y do limite baixo desta arena

mov y_coord, 16     

add y_coord, 1      


JMP GAME
 
 



;########################################################
;#                                                      #
;# INSTRUCTION RESPONSIBLE FOR DEFINING THE COORDINATES #
;# WHERE WE WANT THE SNAKE'S HEAD TO BE BORN            #
;#         (ONLY AND EXECUTED ONCE)                     #
;#                                                      #
;########################################################

                                                   
COORD:                                             

;COORDENADAS DESEJADAS

MOV DH, 10
MOV DL, 20   

; WE DECREASE THIS INSTRUCTION SO THAT IT DOESN'T HAPPEN AGAIN
MOV snake[0], DX  



DEC CX 

call fruitgeneration     
   




GAME:


;IF IT IS THE FIRST LOOP OR IN THE ASSIGNMENT OF THE HEAD COORDINATES
;FROM THE JUMP TO COORD   
CMP CX, 1
JE COORD


;DX gets the coordinates of the first position of the snake (head)
MOV DX, snake[0]

;Function that sets the cursor position based on the DX register
MOV     AH, 02h  
INT     10h


; Function that writes the snake's head on the screen at the cursor position.

MOV     AL, 0b1h    ; symbol used for snake's head      
MOV     BL, 0ch     ; determines the color of the snake in this case and light red
MOV     CX, 1       ; number of times you write the symbol

MOV     AH, 09h
INT     10h



;Creating a tail for the snake
MOV     AX, snake[s_size * 2 - 2]   ;

MOV     tail, AX                    ;tail coordinates saved in ax


CALL    move_snake  ; call the move_snake function



;##################################
;                                 #
; ***Hide the old tail  ***       #
;                                 #
;################################## 

MOV     dx, tail

MOV     ah, 02h ;Funcao para definir a posicao do cursor
INT     10h

MOV     al, ' ' ;Escrever '' significa que estamos a esconder a cauda da snake 
MOV     ah, 09h  
MOV     cx, 1   ;numero de vezes que vamos escrever
INT     10h





;Intrucao que verifica se o utilizador pressionou alguma tecla

check_for_key:


;Verificamos se o utilizador carregou em alguma tecla  
MOV     ah, 01h
INT     16h
JZ      no_key ;se zero=1 executa no_key pois o utilizador nao pressionou em nenhuma tecla.
 
 
;Int para receber a tecla pressionada e guarda-la em A
MOV     ah, 00h
INT     16h     


;Se Clicar ESC acaba o jogo 
CMP     al, 1bh     
JE      GameOver   


;Definicao da direcao da snake de acordo com a tecla pressionada que fica guardada em ah
MOV     cur_dir, ah





;Instrucao responsavel por resetar o contado

no_key:  

MOV CX, 0
JMP     GAME   





; *******   Funcao Movimento   ********

; -> Responsavel por movimentar a snake
; -> Criar uma nova cabeca para a snake


move_snake proc 
  
  
; Identificamos a posicao da cauda da snake e guardamos em di  (4)  
MOV   di, s_size * 2 - 2 
   
MOV   cx, s_size-1; contador definido de acordo com o tamanho da cauda da snake  
  
  
  
;Loop para atualizar as coordenadas da snake
 
move_array: 
      
MOV   ax, snake[di-2];guardamos o valor em ax da proxima posicao       snake[2]-> ultimo pedaco da cauda , snake[0]-> cabeca da snake
                                                                        
                                                                                                                                         
MOV   snake[di], ax; e guardamos na posicao anterior essa posicao  
  
SUB   di, 2  ;subtraimos 2 para calcularmos a proxima posicao 
  
LOOP  move_array


;dependendo da tecla que pressionar vai andar numa determinada direcao

CMP     cur_dir, left
  JE    move_left
CMP     cur_dir, right
  JE    move_right
CMP     cur_dir, up
  JE    move_up
CMP     cur_dir, down
  JE    move_down


;quando nenhuma tecla e pressionada:

JMP     stop_move 


 
 ;          ** ESQUERDA **
 ;Movimenta a snake um pedaco a esqueda
move_left: 
  
  ;Decrementar a cabeca da snake em 1 unidade (x--) 
  
  MOV   ax, snake[0] 
  DEC   al
  MOV   b.snake[0], al  
  
  ;Caso tenho tocado na extremidade esquerda da arena (x=0) perde
  
  CMP   al, 0  
  JE    GameOver
  JNE   stop_move         


 
 ;          ** DIREITA **
 ;Movimenta a snake um pedaco a direita 
move_right:   
  
  ;Incrementa a cabeca da snake em 1 unidade (x++)
  
  MOV   ax, snake[0]
  INC   al
  MOV   b.snake[0], al  
  
  ;Caso tenha tocado na extremidade direita definida como coordenada x=49 perde 
  
  CMP al, x_coord
  JE    GameOver
  JNE   stop_move  

  
  
 ;      ** PARA CIMA **
 ;Movimenta a snake um pedaco acima 
move_up:   
  
  ;Decrementamos pois estamos a subir (y--)
  MOV   ax, snake[1]
  DEC   al
  MOV   b.snake[1], al 
  
  ;Caso tenha tocado na extremidade em cima definida como y=2 perde
  
  CMP   al, 2 
  JE    GameOver
  JNE   stop_move 
 
  
   
 ;      ** PARA BAIXO **
 ;Movimenta a snake um pedaco abaixo 
move_down:  
  
  ;incrementamos pois estamos a descer (y++)
  MOV   ax, snake[1]
  INC   al
  MOV   b.snake[1], al
  
  ;Caso tenha tocado na extremidade em baixa definida na selecao da arena perde
  
  CMP al,y_coord
  JE    GameOver
  JNE   stop_move


stop_move:    
  
  ;Enquanto a snake nao morreu vamos comparar as coordenadas
  ;da cabeca da snake com as coordenadas da comida que foi gerada!
  
  MOV   ax, snake[0] 
  
  ;Se a cabeca da snake tiver na mesma coordenada y que da comida da jump
  
  CMP ah, fruity
  JE CheckFood
  
RET
    
move_snake endp




;-------------------------------------------------
;                                                 |
;   **** Funcao que gera comida na arena ****     | 
;_________________________________________________|

fruitgeneration proc 


; ** Numero Randomico para ser a coordenada x da fruta

;get system time 
MOV AH, 02CH
INT 21H


;dividir o valor obtido de DH por 3 uma vez que gera numeros entre 0 a 99
 
MOV AL,DL
MOV AH,0

MOV BX,3

XOR DX, DX; DX=0

DIV BX ; 0-99/ 3 onde o resto fica em AH (numero maximo que pode ser gerado 99/3 = 33  => compativel com todas as arenas

MOV BL, x_coord   ;46  
DEC BL  ; para quando resto for igual a 0 nao spawnar no limite da arena

SUB BL, AL        ;45-resto=x da comid


;Atribuimos esse valor como sendo coordenada x da comida
MOV fruitx, BL
                 
                 
                 
                 
;** Numero Randomico para ser a coordenada y da fruta  

;o y estara entre 4 e 23 logo so podemos gerar esses numeros

;get system time 
MOV AH, 02CH
INT 21H


;dividir o valor obtido de DH por 3 uma vez que gera numeros entre 0 a 99
MOV AL,DL
MOV AH,0          
          
MOV BX,7     ;99/7 (n maximo gerado = 14 => e compativel com todas as arenas

XOR DX, DX; DX=0

DIV BX ; 0-99/ 10 onde o resto fica em AH  

                                                                   
MOV BL, y_coord            
DEC BL

SUB BL, AL       ;46-resto=x da comida

MOV fruity, BL 


;Definicao das coordenadas no registo
MOV DL, fruitx
MOV DH, fruity
                
                
                                  
;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h

MOV     AL, 0feh    ; simbolo usada para representar a comida      
MOV     BL, 0ah     ; cor verde claro
MOV     CX, 1       ; numero de vezes que escreve o simbolo

MOV     AH, 09h
INT     10h


DEC CX

ret 

fruitgeneration endp





;Intrucao complementar para verificar se a cabeca da snake
;se encontra na mesma pos x que a comida

CheckFood:

CMP al, fruitx
JE AtributeFood
RET





;Intrucao que e executada quando a cabeca da snake esta na mesma
;pos que a comida, ou seja, a snake comeu

AtributeFood:  

;beep sound
MOV ah,02
MOV dl,07h
INT 21h   


;incrementa o score
inc score

MOV DL, 66
MOV DH, 9

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h


;Funcao que escreve no ecra score
MOV ah, score 
CALL print_num


;geramos outra comida na arena
CALL fruitgeneration   

RET





;Intrucao que apresenta a mensagem de GameOver
;Ocorre quando o jogador perder ou clicar ESC

GameOver:

;CLEAR SCREEN
MOV AL, 03H
MOV AH, 0
INT 10H	
  
MOV AH,9    
LEA DX,GAME_OVER
INT 21H 

;coordenadas para apresentar o score
MOV DL, 43
MOV DH, 15

;Funcao que define a posicao do cursor com base no registo DX
MOV     AH, 02h  
INT     10h

;Funcao que escreve no ecra o score
MOV ah, score 
CALL print_num

INT 20h 

END         
