;************************************************************************
;Программа тестирования в STK500 двоичных арифметических операций
; сложения, вычитания, умножения, деления
;Порт PD - порт управления для выбора операндов и операций
;Порт PB - порт индикации исходных операндов и результатов операции
;Соединения шлейфами: порт PB-LED, порт PD-SW
;************************************************************************
.include "m8515def.inc" ;файл определений для ATmega8515
;назначение входов порта PD
.equ SW_op_AL = 0 ;кнопка выбора операнда op_AL
.equ SW_op_AH = 1 ;кнопка выбора операнда op_AH
.equ SW_op_BL = 2 ;кнопка выбора операнда op_ВL
.equ SW_ADD = 3 ;кнопка операции сложения res=op_AL+op_ВL
.equ SW_SUB = 4 ;кнопка операции вычитания res=op_AL-op_ВL
.equ SW_MUL = 5 ;кнопка операции умножения shov.res=op_AL x op_ВL
.equ SW_DIV = 6 ;кнопка операции деления res=op_AH.op_AL/op_ВL
.equ SW_SHOW = 7 ;кнопка для просмотра признаков сложения-вычитания,
;старшего байта произведения или остатка при делении
.def op_AL = r16 ;1-й операнд АL
.def op_AH = r17 ;старший байт делимого AH
.def op_BL = r18 ;2-й операнд ВL
.def res = r1 ;результат операции (сумма, разность,
; младший байт произведения или частное)
.def show = r31 ;регистр признаков сложения-вычитания,
; старшего байта произведения или остатка при делении
.def mul_l = r21 ;младший байт произведения
.def mul_h = r22 ;старший байт произведения
.def copy_AH = r23 ;копия старшего байта делимого
.def copy_AL = r24 ;копия младшего байта делимого
.def copy_BL = r25 ;копия множителя
.def temp = r26 ;временный регистр
.def sw_reg = r27 ;регистр состояния кнопок
.def count = r28 ;число операндов в таблице операндов
.def c_bit = r29 ;счетчик циклов умножения (деления)
.macro vvod ;ввод операнда
lpm ;считывание байта из flash-памяти в r0
mov @0,r0 ; и пересылка в регистр операнда
mov res, r0
adiw zl, 1 ;увеличение указателя адреса на 1
dec count
brne exit
ldi ZL,low(tabl_op*2) ;перезагрузка начала таблицы операндов
ldi ZH,high(tabl_op*2) ; в регистр Z
ldi count, 10 ;число заданных операндов в таблице 10
exit: nop
.endmacro
.org $000
;Инициализация стека, портов, адреcного регистра Z
ldi temp,low(RAMEND) ;установка
out SPL,temp ; указателя стека
ldi temp,high(RAMEND) ; на последнюю
out SPH,temp ; ячейку ОЗУ
ser temp ;настройка
out DDRB,temp ; порта PB
out PORTB,temp ; на вывод
clr temp ;настройка
out DDRD,temp ; порта PD
ser temp ; на
out PORTD,temp ; ввод
ldi ZL,low(tabl_op*2) ;загрузка адреса таблицы операндов
ldi ZH,high(tabl_op*2) ; в регистр Z
ldi count,10 ;число операндов 10
;Опрос кнопок и выполнение заданных действий
LOOP: in sw_reg,PIND
sbrs sw_reg,0
rjmp f_op_AL
sbrs sw_reg,1
rjmp f_op_AH
sbrs sw_reg,2
rjmp f_op_BL
sbrs sw_reg,3
rjmp add_bin
sbrs sw_reg,4
rjmp sub_bin
sbrs sw_reg,5
rjmp mul_bin
sbrs sw_reg,6
rjmp div_bin
sbrc sw_reg,7
rjmp loop
mov res,show
rjmp outled
;Выборка 1-го операнда из таблицы операндов
f_op_AL: vvod op_AL
rjmp outled
;Выборка старшего байта 1-го операнда (при делении)
f_op_AH: vvod op_AH
rjmp outled
;Выборка 2-го операнда
f_op_BL: vvod op_BL
rjmp outled
;Сложение 8-разрядных операндов
add_bin: mov res,op_AL
add res,op_BL
in show,SREG ;выборка из регистра SREG
rjmp outled
;Вычитание 8-разрядных операндов
sub_bin: mov res,op_AL
sub res,op_BL
in show,SREG ;выборка из регистра SREG
rjmp outled
;Умножение 8-разрядных операндов
mul_bin: mul op_AL,op_BL
mov show,r1 ;копируем старший и
 mov res,r0 ; младший байт произведения
 rjmp outled
;Деление 16-разрядного числа на 8-разрядное
div_bin: sbrc op_AH,7 ;ошибки исходных данных
rjmp error
sbrc op_BL,7
rjmp error
tst op_BL ;ошибка при делении на 0
breq error
cp op_AH,op_BL ;ошибка при переполнении
brge error
clr res ;обнуляем частное
ldi c_bit,8 ; число итераций
mov copy_AH,op_AH
mov copy_AL,op_AL
L4: clc
rol copy_AL ;сдвиг
rol copy_AH ; делимого
lsl res ;сдвиг частного влево
sub copy_AH,op_BL ;вычитание делителя
brcs recov ;если остаток < 0,переход
inc res ; иначе добавить 1 в частное
rjmp L5
recov: add copy_AH,op_BL ;восстановление остатка
L5: dec c_bit
brne L4
mov show,copy_AH ;пересылка остатка
rjmp outled
error: clr temp ;сигнал об ошибке деления
out PORTB, temp
rcall delay
ser temp
out PORTB, temp
rjmp wait
outled: com res
out portb,res
rcall delay
wait: in sw_reg,PIND ;ждать, пока кнопка не отпущена
com sw_reg
brne wait
rjmp loop
; Задержка
DELAY: ldi r19,10
m1: ldi r20,250
m3: ldi r21,250
m2: dec r21
brne m2
dec r20
brne m3
dec r19
brne m1
ret
; Таблица операндов в шестнадцатеричном представлении
tabl_op: .db 0x80,0x7B,0x70,0x9F,0x2E,0x8F,0x8F,0xC9,0x84,0x6E
