;**********************************************************************
;��������� 1.1 ��� ����������������� ATx8515:
;������������ ����������� (��) ��� ������� �� ������ START (SW0),
;����� ������� ������ STOP (SW1) ������������ ������������ �
;�������������� c ����� ��������� ��� ��������� ������� �� ������ START
;**********************************************************************

;.include "8515def.inc" ;���� ����������� ��� AT90S8515
.include "m8515def.inc" ;���� ����������� ��� ATmega8515
.def test = r16 		;������� ��� �������������





.org $000
rjmp init

;***�������������***

INIT: 
ldi test,0xFF 	;11111111

;******;

LOOP:
lsl test
rjmp LOOP
