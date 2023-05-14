;Соединения на плате STK500: SW0-PD2, SW1-PD3, LED0-PB0
;*********************************************************************
.include "m8515def.inc" ;файл определений для ATmega8515
.def temp = r16 ;временный регистр
.equ led = 0 ;0-о бит порта PB
.equ sw0 = 2 ;2-й бит порта PD
.equ sw1 = 3 ;3-й бит порта PD
.org $000
;***Таблица векторов прерываний, начиная с адреса $000***
rjmp INIT ;обработка сброса
rjmp led_on1 ;на обработку запроса INT0
rjmp led_on2 ;на обработку запроса INT1
;***Инициализация SP, портов, регистра маски***
INIT: ldi temp,$5F ;установка
out SPL,temp ; указателя стека
ldi temp,$02 ; на последнюю
out SPH,temp ; ячейку ОЗУ
ser temp ;инициализация выводов
out DDRB,temp ; порта PB на вывод
out PORTB,temp ;погасить СД
clr temp ;инициализация
out DDRD,temp ; порта PD на ввод
ldi temp,0b00001100 ;включение подтягивающих
out PORTD,temp ; резисторов порта PD
ldi temp,((1<<INT0)|(1<<INT1));разрешение прерываний
out GICR,temp ; в 6,7 битах регистра маски GICR
ldi temp,0 ;обработка прерываний
out MCUCR,temp ; по низкому уровню
sei ;глобальное разрешение прерываний
loop: nop ;режим ожиданий
rjmp loop
led_on1:
cbi PORTB,led
rcall delay1
sbi PORTB,led
wait_0: sbis PIND,sw0
rjmp wait_0
reti
led_on2:
cbi PORTB,led
rcall delay2
sbi PORTB,led
wait_1: sbis PIND,sw1
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
