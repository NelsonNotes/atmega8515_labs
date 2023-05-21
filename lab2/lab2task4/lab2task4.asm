;*********************************************************************
.include "m8515def.inc" ;файл определений для ATmega8515
.def temp = r16 ;временный регистр
.equ sw0 = 0 ;0-й бит порта PA
.equ sw1 = 1 ;1-й бит порта PA
.equ sw_int = 0 ;0-й бит порта PE
.equ led = 0 ;0-й бит порта PB
.org $000
;***Таблица векторов прерываний, начиная с адреса $000***
rjmp INIT ;обработка сброса
.org $00D ;сдвиг по памяти такой, что следующая команда лежит по адресу вектора прерываний для INT2
rjmp handle_button_press ;на обработку запроса INT2
;***Инициализация SP, портов, регистра маски***
INIT: 
ldi temp,$5F ;установка
out SPL,temp ; указателя стека
ldi temp,$02 ; на последнюю
out SPH,temp ; ячейку ОЗУ

ser temp ;инициализация выводов
out DDRB,temp ; порта PB на вывод
out PORTB,temp ;погасить СД

ldi temp,0 ;инициализация регистра 
out DDRA,temp; PA на ввод
ldi temp, 0b00000011; включение подтягивающих
out PORTA,temp; резисторов PA0 и PA1

cbi DDRE,sw_int; инициализация бита PE0 порта PE на ввод
sbi PORTE,sw_int; включение подтягивающего резистора порта PE

ldi temp,(1<<INT2) ;разрешение прерываний
out GICR,temp ; в 5 бите регистра маски GICR
ldi temp,0
out EMCUCR,temp ; обработка INT2 по отрицательному фронту
sei ;глобальное разрешение прерываний

MAIN: nop ;режим ожидания
rjmp MAIN

handle_button_press:
sbis PINA, sw0
rjmp led_on1
sbis PINA, sw1
rjmp led_on2
reti

led_on1:
cbi PORTB,led
rcall delay1
sbi PORTB,led
wait_0: sbis PINA,sw0
rjmp wait_0
reti
led_on2:
cbi PORTB,led
rcall delay2
sbi PORTB,led
wait_1: sbis PINA,sw1
rjmp wait_1
reti
delay1:
;для подпрограммы задержки 1 c
ldi r17,100
d1: ldi r18,101
d2: ldi r19,135
d3: dec r19
brne d3
dec r18
brne d2
dec r17
brne d1
ret
delay2:
;для подпрограммы задержки 2 c
ldi r17,100
d4: ldi r18,105
d5: ldi r19,255
d6: dec r19
brne d6
dec r18
brne d5
dec r17
brne d4
ret