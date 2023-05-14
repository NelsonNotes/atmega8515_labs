;**********************************************************************
;��������� 1.1 ��� ����������������� ATx8515:
;������������ ����������� (��) ��� ������� �� ������ START (SW0),
;����� ������� ������ STOP (SW1) ������������ ������������ �
;�������������� c ����� ��������� ��� ��������� ������� �� ������ START
;**********************************************************************

;.include "8515def.inc" ;���� ����������� ��� AT90S8515
.include "m8515def.inc" ;���� ����������� ��� ATmega8515
.def temp = r16 		;��������� �������
.def reg_led = r20 		;������� ��������� �����������
.def left_wall = r21	;����� ����
.def right_wall = r22	;������ ����
.equ START = 0 			;0-�� ����� ����� 
.equ STOP = 1 			;1-�� ����� �����
.org $000
rjmp init

;***�������������***

INIT: 
ldi reg_led,0x80 		;����� reg_led.0 ��� ��������� LED0
ldi left_wall,0x00 		;00000000
ldi right_wall,0xFF 	;11111111
sec 					;C=1
clt 					;T=0 � ���� �����������
ser temp 				;������� r20 ������� � ���� - � 11111111
out DDRB,temp 			;������������� � ���� PB �� �����
clr temp				;������� r20 ������� � ���� - � 00000000
out PORTB,temp 			;������ ��
out DDRD,temp 			;������������� ����� PD �� ����
ldi temp,0x03 			;��������� ���������������
out PORTD,temp 			; 	���������� ����� PD (0-�, 1-� �������)
WAITSTART: 				;��������
sbic PIND,START 		; 	�������
rjmp WAITSTART 			; 	������ START
LOOP: out PORTB,reg_led ;����� �� ����������

;***�������� (��� ��������� �����)***

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

sbic PIND,STOP 			;���� ������ ������ STOP,
rjmp RIGHT 				; 	�� �������
rjmp WAITSTART 			; 	��� �������� ������ START
RIGHT: 
brts LEFT 				;�������, ���� ���� T ����������
sec						;C=0 ��� ������������ (����� ����������� ��������� �)
ror reg_led 			;����� reg_led ������ �� 1 ������
cpse reg_led,right_wall 	;������� ��������� T=1, 
rjmp LOOP				;���� ������ 
set 					;7 ���� 
rjmp LOOP 				;������� �� �������� ������� STOP
LEFT:
clc						;C=0 ��� ������������ (����� ����������� ��������� �)
rol reg_led 			;����� reg_led ����� �� 1 ������
cpse reg_led,left_wall ;������� ��������� T=0, 
rjmp LOOP				;���� ������ 
clt 					;1 ���� 
rjmp LOOP
