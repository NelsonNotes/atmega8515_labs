;************************************************************************
;Программа 4.4 для МК ATx8515:
;демонстрация работы таймера Т1 в режиме ШИМ
;При нажатии SW0 происходит генерация
;ШИМ-сигналов с порогом сравнения F1
;При нажатии SW1 происходит генерация
;ШИМ-сигналов с порогом сравнения F2
;Соединения: PD5-LED0,PE2-LED1, PD0-SW0,PD1-SW1
;************************************************************************
;.include "8515def.inc" ;файл определений AT90S8515
.include "m8515def.inc" ;файл определений ATmega8515
.def temp = r16 ;временный регистр
;***Выводы порта PD
.equ SW0 = 0
.equ SW1 = 1
.org $000
rjmp INIT ;обработка сброса
;***Инициализация МК
INIT: ldi temp,0x20 ;инициализация PD5
out DDRD,temp ; на вывод
ldi temp,0x03 ;включение ‘подтягивающих’
out PORTD,temp ; резисторов порта PD
ldi temp,0x04 ;/// для ATmega8515 инициализация
out DDRE,temp ;/// PE2 (OC1B) на вывод
cli ;запрещение прерываний
;настройка таймера: 10-разрядный режим ШИМ, на выводе
;OC1A неинвертированный сигнал, OC1B – инвертированный сигнал
ldi temp,0xB3
out TCCR1A,temp
clr temp ; обнуление
out TCNT1H,temp ; счётного
out TCNT1L,temp ; регистра
ldi temp,0x05 ;таймер
out TCCR1B,temp ; запущен с предделителем 1024
F1: sbic PIND,SW0 ;проверка нажатия SW0
rjmp F2
;***Установка порога F1
ldi temp,0x02 ;запись числа в => Уменьшил скважность вдвое (было 0х00)
out OCR1AH,temp ; регистры сравнения,
out OCR1BH,temp ; первым записывается
ldi temp,0x00 ; старший байт => Уменьшил скважность вдвое (было 0х00)
out OCR1AL,temp
out OCR1BL,temp
F2: sbic PIND,SW1 ; проверка нажатия SW1
rjmp F1
;*** Установка порога F2
ldi temp,0x01 ;запись числа в => Увеличил скважность вдвое (было 0х02)
out OCR1AH,temp ; регистры сравнения,
out OCR1BH,temp ; первым записывается
ldi temp,0x7f ; старший байт => Увеличил скважность вдвое (было 0хFF)
out OCR1AL,temp
out OCR1BL,temp
rjmp F1
