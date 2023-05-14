;Соединения на плате STK500: SW0-PA0, SW1-PA1, LED0-PB0
;*********************************************************************
.include "m8515def.inc" ;файл определений для ATmega8515
.def temp = r16 ;временный регистр
.equ led = 0 ;0-й бит порта PB
.equ sw0 = 0 ;0-й бит порта PA
.equ sw1 = 1 ;1-й бит порта PA
.org $000
rjmp INIT ;обработка сброса
;***Инициализация МК***
INIT: 
  ldi temp,$5F ;установка
  out SPL,temp ; указателя стека
  ldi temp,$02 ; на последнюю
  out SPH,temp ; ячейку ОЗУ
  ser temp ;инициализация выводов
  out DDRB,temp ; порта PB на вывод
  out PORTB,temp ;погасить LED
  clr temp ;инициализация
  out DDRA,temp ; порта PA на ввод
  ldi temp,0b00000011 ;включение подтягивающих
  out PORTA,temp ; резисторов порта PA
test_sw0: 
  sbic PINA,sw0 ;проверка состояния
  rjmp test_sw1 ; кнопки sw0
  cbi PORTB, led
  rcall delay1
  sbi PORTB,led
wait_0: 
  sbis PINA,sw0
  rjmp wait_0
test_sw1: 
  sbic PINA,sw1 ;проверка состояния
  rjmp test_sw0 ; кнопки sw1
  cbi PORTB,led
  rcall delay2
  sbi PORTB,led
wait_1: 
  sbis PINA,sw1
  rjmp wait_1
  rjmp test_sw0
delay1: ; подпрограмма 1 с
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
delay2: ; подпрограмма 2 с
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
