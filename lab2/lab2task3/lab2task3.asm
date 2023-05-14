;Соединения на плате STK500: sw1-PD2, sw2-PD3, LED0-PB0
; Памятка для работы с INT2:
; - INT2 выплюнет прерывание с 0 бита порта PE;
; - INT2 сработает только на переходы уровня сигнала LH-HL;
; - регистр с MCUCR поменять на EMCUCR, установить ISC2: 0 - отрицательный фронт, 1 - положительный фронт
;*********************************************************************
.include "m8515def.inc" ;файл определений для ATmega8515
.def temp = r16 ;временный регистр
.def led_state = r17 ;регистр управляющего светодиодами слова
.equ sw1 = 3 ;3-й бит порта PD
.equ sw2 = 0 ;0-й бит порта PE
.org $000
;***Таблица векторов прерываний, начиная с адреса $000***
rjmp INIT ;обработка сброса
.org $002
rjmp led_on1 ;на обработку запроса INT1
.org $00D
rjmp led_on2 ;на обработку запроса INT2
;***Инициализация SP, портов, регистра маски***
INIT: 
ldi temp,$5F ;установка
out SPL,temp ; указателя стека
ldi temp,$02 ; на последнюю
out SPH,temp ; ячейку ОЗУ

ldi led_state, 0b11111110 ; инициализация управляющего слова

ser temp ;инициализация выводов
out DDRB,temp ; порта PB на вывод
out PORTB,temp ;погасить СД

cbi DDRD,sw1; инициализация бита PD3 порта PD на ввод
sbi PORTD,sw1; включение подтягивающего резистора порта PD

cbi DDRE,sw2; инициализация бита PE0 порта PE на ввод
sbi PORTE,sw2; включение подтягивающего резистора порта PE


ldi temp,((1<<INT2)|(1<<INT1));разрешение прерываний
out GICR,temp ; в 5,7 битах регистра маски GICR
ldi temp,0
out MCUCR,temp ; обработка INT1 по низкому уровню
out EMCUCR,temp ; обработка INT2 по отрицательному фронту
sei ;глобальное разрешение прерываний

loop: ;основной цикл работы процессора
nop
rjmp loop

led_on1:
out PORTB,led_state
rcall delay1
out PORTB,led_state
wait_0: sbis PIND,sw1
rjmp wait_0
reti
led_on2:
out PORTB,led_state
rcall delay2
out PORTB,led_state
wait_1: sbis PINE,sw2
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
