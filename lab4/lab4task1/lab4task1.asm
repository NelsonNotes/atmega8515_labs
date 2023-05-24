;********************************************************************
;событие - нажатие кнопки SW2.
;Соединения: порт PD2–SW2, шлейфом порт PA-LED
;Светодиоды включаются после четвертого нажатия кнопки SW2
;********************************************************************
;.include "8515def.inc" ;файл определений AT90S8515
.include "m8515def.inc" ;файл определений ATmega8515
.def temp = r16 ;временный регистр
.equ T0_PIN = 0

;***Таблица векторов прерываний
.org $000
rjmp INIT ;обработка сброса
rjmp BTN_CLK ;обработка запроса прерывания INT0 (нажатие кнопки)
.org $007
rjmp T0_OVF ;обработка переполнения таймера T0

;***Инициализация МК
INIT: ldi temp,low(RAMEND) ;установка
out SPL,temp ; указателя стека
ldi temp,high(RAMEND) ; на последнюю
out SPH,temp ; ячейку ОЗУ
clr temp ;инициализация выводов порта PA
out DDRD,temp ; на ввод
ldi temp,(1<<PD2) ;включение ‘подтягивающего’ резистора
out PORTD,temp ; входа PD2
ldi temp, 0x01 ;инициализация PB0
out DDRB,temp ; на вывод
ser temp ;инициализация выводов порта PA
out DDRA,temp ; на вывод
out PORTA,temp ;выключение светодиодов
ldi temp,(1<<INT0) ; разрешение прерываний
out GICR,temp ; в 7 бите регистра маски GICR
clr temp ; обработка прерываний кнопок
out MCUCR,temp ; по низкому уровню
ldi temp,(1<<SE) ;разрешение перехода
out MCUCR,temp ; в режим Idle

;***Настройка таймера Т0 на режим счётчика событий
ldi temp,0x02 ;разрешение прерывания по
out TIMSK,temp ; переполнению таймера Т0
ldi temp,0x07 ;переключение таймера
out TCCR0,temp ; по положительному перепаду напряжения
sei ;глобальное разрешение прерываний
ldi temp,0xFC ;$FC=-4 для
out TCNT0,temp ; отсчёта 4-х нажатий
LOOP: sleep ;переход в режим пониженного
nop ; энергопотребления
rjmp LOOP

;***Обработка прерывания при переполнении таймера T0
T0_OVF: clr temp
out PORTA,temp ;включение светодиодов
rcall DELAY ;задержка
ser temp
out PORTA,temp ;выключение светодиодов
ldi temp,0xFC ;перезагрузка
out TCNT0,temp ; TCNT0
reti

;***Обработка прерывания при нажатии кнопки
BTN_CLK:
rcall DELAY_BTN ;задержка против дребезга при нажатии
BTN_WAIT_RLS: sbis PIND, PD2 ;ожидание
rjmp BTN_WAIT_RLS ;отпускания кнопки
rcall DELAY_BTN ;задержка против дребезга при отпускании
sei ;разрешаем прерывания для счетчика
cbi PORTB, T0_PIN ;дергаем PB0
sbi PORTB, T0_PIN ;чтобы увеличить счетчик
reti

;*** Задержка ***
DELAY: ldi r19,6
ldi r20,255
ldi r21,255
dd: dec r21
brne dd
dec r20
brne dd
dec r19
brne dd
ret

;*** Задержка против дребезга ***
DELAY_BTN: ldi r19,80
ldi r20,255
dd_b: dec r20
brne dd_b
dec r19
brne dd_b
ret


