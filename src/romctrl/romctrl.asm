; ═══════════════════════════════════════════════════════════════════════
; ПРОГРАММА УПРАВЛЕНИЯ ROM-DISK/32K ДЛЯ КОМПЬЮТЕРА 
; "РАДИО-86РК" С OБЪEMOM ОЗУ ПОЛЬЗОВАТЕЛЯ 16К/32К.
; ПРОГРАММА УПРАВЛЕНИЯ ЗАФИКСИРОВАНА В ПЗУ 
; ПО АДРЕСАМ 7E00H-7FFFH. УКАЗАННУЮ ОБЛАСТЬ ПЗУ 
; ЗАПРЕЩЕНО ИСПОЛЬЗОВАТЬ ПОД ROM-DISK. 
; ПРОГРАММА ИЗ ПЗУ В ОЗУ ПЕРЕНОСИТСЯ ЗАГРУЗЧИКОМ, 
; (В MONITORE) ПО ДИРЕКТИВЕ "U" или "R" И ЗАНИМАЕТ 
; ВЕРХНИЕ АДРЕСА ОЗУ, НАЧИНАЯ С 7400Н.
; ═══════════════════════════════════════════════════════════════════════

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ───────────────────────────────────────────────────────────────────────
; Адреса системных вызовов
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"syscalls.inc"

PCALL	MACRO	ADDR
	LD	HL, RETADDR-BaseAddress
	ADD	HL, DE
	PUSH	HL
	LD	HL, ADDR-BaseAddress
	ADD	HL, DE
	JP	(HL)
RETADDR	EQU	$
	ENDM

PJP	MACRO	ADDR
	LD	HL, ADDR-BaseAddress
	ADD	HL, DE
	JP	(HL)
	ENDM

PLDHL	MACRO	ADDR
	LD	HL, ADDR-BaseAddress
	ADD	HL, DE
	ENDM
	
	ORG	BASE-0200H

Stack:
	LD	HL, (0)
	EX	DE, HL			; DE=(0)
	LD	HL, 0E9E1H		; POP HL ! JP(HL)
	LD	(0), HL
	RST	0
BaseAddress:
	EX	DE, HL			; DE=BaseAddress, HL=(0)
	LD	(0), HL

	PLDHL	Stack
	LD	SP, Stack

	PLDHL	SO1
	CALL	PrintString
	LD	B, 0FFH

	PCALL	SEARCHS

	LD	C, '>'
	CALL	PrintCharFromC
	CALL	InputSymbol
	LD	C, A
	CALL	PrintCharFromC
	CP	03h
	JP	Z,WarmBoot
	SUB	30H
	LD	B, A
	LD	HL, FUNC+1
	LD	(HL), EXECN & 0ffh
	INC	HL
	LD	(HL), EXECN >> 8
	CALL	SEARCHS
	JP	WarmBoot

SEARCHS:
	LD	HL, 0800H		; Начало ROM-диска
	LD	C, L			; LD C, 0
SEARCH:

	PUSH	HL			; (1)
	LD	DE, (8+2+2)-1
	ADD	HL, DE
	EX	HL, DE
	POP	HL			; (1)

	PUSH	HL			; (2)
	
	PUSH	BC			; (3)

	LD	BC, T
	PUSH	BC			; (4)
	CALL	ReadROM
	POP	HL			; (4)

	POP	BC			; (3)

	LD	A, (HL)
	CP	0FFH

	POP	DE			; (2)

	RET	Z

FUNC:	CALL	PRINTN

	PUSH	DE			; (5)
;---------------------
	LD	HL, (T+8+2)
	LD	A, L			; высчитываем начало следующей записи
	OR	A			; оканчивается на ноль
	JP	Z, SKIP
	OR	0fh
	LD	L, A
	INC	HL
SKIP:
	LD	DE, 10h
	ADD	HL, DE
;---------------------
	POP	DE			; (5)
	
	ADD	HL, DE
	INC	C
	JP	SEARCH

PRINTN:
	PUSH	HL
	PUSH	BC

	LD	A, C			; Печатаем порядковый номер
	ADD	A, 30H
	LD	C, A
	CALL	PrintCharFromC
	LD	C, ' '
	CALL	PrintCharFromC

	LD	B, 8
	LD	HL, T
PLOOP:	LD	A, (HL)			; Печатаем имя
	CP	"$"
	CALL	Z, PrintCOM
	LD	C, A
	CALL	PrintCharFromC
	INC	HL
	DEC	B
	JP	NZ, PLOOP

	INC	HL
	LD	C, ' '			; Печатаем стартовый адрес
	CALL	PrintCharFromC
	LD	A, (HL)
	CALL	PrintHexByte
	DEC	HL
	LD	A, (HL)
	CALL	PrintHexByte

	INC	HL
	INC	HL
	INC	HL
	LD	C, 			; Печатаем размер
	CALL	PrintCharFromC
	LD	A, (HL)
	CALL	PrintHexByte
	DEC	HL
	LD	A, (HL)
	CALL	PrintHexByte

	LD	HL, SO2			; Печатаем перевод строки
	CALL	PrintString
	POP	BC
	POP	HL
	RET

PrintCOM:
	PUSH	HL
	LD	HL, SO0
	CALL	PrintString
	POP	HL
	RET

EXECN:
	LD	A, C
	SUB	B
	RET	NZ
	
	LD	HL, 010H
	ADD	HL, DE		; DE - это адрес на ROM-диске
	EX	DE, HL

	LD	SP, T+8		; ИСПОЛЬЗУЯ СТЕК,
	POP	BC		; start
	POP	HL		; size

	ADD	HL, DE
	EX	DE, HL

	PUSH	BC		; Читаем в ОЗУ
	CALL	ReadROM
	RET			; POP HL! JP (HL) ;И ЗАПУСТИТЬ ПРОГРАММУ.

T:	DB	8+2+2 DUP 0			;

SO0:	DB	".COM", ' '+80H
SO1:	DB 	0AH,0DH,"*ROM-DISK/32K* V3.0-23"
	DB 	0AH,0AH,0DH,"DIRECTORY:"
SO2:	DB	0AH,0DH+80H

	DB	BASE-3-$ DUP (0FFH)

	; Вход по директиве Z
	JP	BASE-0200H
