;**********************************************************************
;Программа 1.1 для микроконтроллеров ATx8515:
;переключение светодиодов (СД) при нажатии на кнопку START (SW0),
;после нажатия кнопки STOP (SW1) переключение прекращается и
;возобновляется c места остановки при повторном нажатии на кнопку START
;**********************************************************************

;.include "8515def.inc" ;файл определений для AT90S8515
.include "m8515def.inc" ;файл определений для ATmega8515
.def temp = r16 		;временный регистр
.def reg_led = r20 		;регистр состояния светодиодов
.def left_wall = r21	;левый край
.def right_wall = r22	;правый край
.equ START = 0 			;0-ой вывод порта 
.equ STOP = 1 			;1-ый вывод порта
.org $000
rjmp init

;***Инициализация***

INIT: 
ldi reg_led,0x80 		;сброс reg_led.0 для включения LED0
ldi left_wall,0x00 		;00000000
ldi right_wall,0xFF 	;11111111
sec 					;C=1
clt 					;T=0 – флаг направления
ser temp 				;регистр r20 который в темп - в 11111111
out DDRB,temp 			;инициализация п орта PB на вывод
clr temp				;регистр r20 который в темп - в 00000000
out PORTB,temp 			;зажечь СД
out DDRD,temp 			;инициализация порта PD на ввод
ldi temp,0x03 			;включение ‘подтягивающих’
out PORTD,temp 			; 	резисторов порта PD (0-й, 1-й разряды)
WAITSTART: 				;ожидание
sbic PIND,START 		; 	нажатия
rjmp WAITSTART 			; 	кнопки START
LOOP: out PORTB,reg_led ;вывод на индикаторы

;***Задержка (два вложенных цикла)***

ldi r17,100
d1: ldi r18,101
d2: ldi r19,39
d3: dec r19
brne d3
dec r18
brne d2
dec r17
brne d1

;******;

sbic PIND,STOP 			;если нажата кнопка STOP,
rjmp RIGHT 				; 	то переход
rjmp WAITSTART 			; 	для проверки кнопки START
RIGHT: 
brts LEFT 				;переход, если флаг T установлен
sec						;C=0 бит переполнения (сдвиг заполняется значением С)
ror reg_led 			;сдвиг reg_led вправо на 1 разряд
cpse reg_led,right_wall 	;пропуск установки T=1, 
rjmp LOOP				;если только 
set 					;7 диод 
rjmp LOOP 				;переход на проверку нажатия STOP
LEFT:
clc						;C=0 бит переполнения (сдвиг заполняется значением С)
rol reg_led 			;сдвиг reg_led влево на 1 разряд
cpse reg_led,left_wall ;пропуск установки T=0, 
rjmp LOOP				;если только 
clt 					;1 диод 
rjmp LOOP
