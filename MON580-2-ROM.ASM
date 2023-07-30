; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОР-2.00 для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52 и эмулятором CP/M
; ───────────────────────────────────────────────────────────────────────
;  Часть, находящаяся в первых 2к ROM-диска
; ═══════════════════════════════════════════════════════════════════════

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ───────────────────────────────────────────────────────────────────────
;
; Код разбит на блоки по 128 байт. Всего 16 блоков. Каждый блок странсли-
; рован для выполнения по адресу ROMBUF. Вызов кода в блоке осуществляется
; с помощью макроса
;
; FJMP block, label
; 
; здесь block - номер блока, начиная с 0, а label - метка кода;
; ───────────────────────────────────────────────────────────────────────

; ───────────────────────────────────────────────────────────────────────
; Адреса системных вызовов
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"syscalls.inc"

; ───────────────────────────────────────────────────────────────────────
; Адреса прямых вызовов в МОНИТОР (!!! Только для директив МОНИТОР-2.00)
; ───────────────────────────────────────────────────────────────────────

	IF	STUB
	INCLUDE	"stub.inc"
	ELSE
	INCLUDE	"MON580-2.INC"
	ENDIF

; ───────────────────────────────────────────────────────────────────────
; Адреса системных переменных
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"sysvars.inc"


; ──────────────────────────────────────────────
; Дальняя JMP block, label
; ──────────────────────────────────────────────

FJMP	MACRO	block, adr
		CALL	FARJMP
		DB	block
		DB	(adr & 0FFH)
	ENDM

SFJMP	MACRO	block, adr
		RST	16
		DB	block
		DB	(adr & 0FFH)
	ENDM

; ──────────────────────────────────────────────
; Дальняя JP Z, block, label
; ──────────────────────────────────────────────

FJPZ	MACRO	block, adr
		RST	8
		DB	block
		DB	adr & 0FFH
	ENDM


CHK	MACRO	adr, msg
		IF	$>(adr)
			ERROR	msg
		ENDIF
	ENDM

; ───────────────────────────────────────────────────────────────────────
; Блок 0. Инициализация BDOS
; ───────────────────────────────────────────────────────────────────────

	ORG	0
	PHASE	ROMBUF

; ──────────────────────────────────────────────
; Блок защиты загрузки на Орион-128. Выводит
; сообщение, что данный диск предназначен для Радио-86РК.
; ──────────────────────────────────────────────

	PHASE	0B800H			; Адрес загрузки для ORDOS
ORDOSStart:
	LD	HL, MsgRKOnly
	CALL	PrintString
	JP	WarmBoot
MsgRKOnly:
	DB	"|tot ROM-disk prednazna~en dlq radio-86r",'k' + 80H

	DEPHASE

; ──────────────────────────────────────────────
; Инициализация симулятора CP/M
; Размещает точки входа в BIOS и BDOS
; ──────────────────────────────────────────────

	SHARED	INITBDOS
INITBDOS:
	LD	A, 0C3H				; JMP opcode
	
	; CALL 0
	LD	(0), A
	LD	HL, BIOSENTRY+3	; WBOOT
	LD	(0001H), HL

	; CALL 5
	LD	(5), A
	LD	HL, BDOSST
	LD	(0006H), HL

	; BDOS Entry point
	LD	(BDOSST), A
	LD	HL, BDOS
	LD	(BDOSST+1), HL

	; RST 8 (Far Jump if zero)
	LD	(8), A
	LD	HL, FARJZ
	LD	(9), HL

	; RST 16 (Far Jump)
	LD	(16), A
	LD	HL, FARJMP
	LD	(17), HL

	LD	HL, CPMMSG
	CALL	PrintString
	JP	WarmBoot
CPMMSG:
	DB	' s |mulqtorom CP/','M'+80H

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 1 Вход в BDOS
; ───────────────────────────────────────────────────────────────────────

	ORG	080H
	PHASE	ROMBUF

; ──────────────────────────────────────────────
; Блок эмуляции точек входа BDOS
; ──────────────────────────────────────────────
; To make a BDOS call in a CP/M, use:
;
;	LD DE,parameter
;	LD C,function
;	CALL 5
;
; In CP/M 1.x, 8-bit values are returned in A and 
; 16-bit values in BA. In later 8-bit versions,
; they are also returned in L and HL respectively. 
; ──────────────────────────────────────────────

	SHARED	BDOSENTRY
BDOSENTRY:
	LD	HL, 0000H		; Сохраняем стек
	ADD	HL, SP
	LD	(TMPSTK), HL
	LD	SP, 080H		; Инициализируем стек

	LD	HL, BDOSRET
	PUSH	HL			; В стек кладем адрес возврата из BDOS

	LD	B, 0
	LD	A, C
	CP	30
	JP	P, NextBDOS
	LD	HL, FTABLE
	ADD	HL, BC
	ADD	HL, BC
	ADD	HL, BC
	JP	(HL)

NextBDOS:
	SFJMP	2, NextBDOSROM

FTABLE:
	SFJMP	5, P_TERMCPM
	SFJMP	2, C_READ
	SFJMP	5, C_WRITE
	SFJMP	5, A_READ
	SFJMP	5, A_WRITE
	SFJMP	5, L_WRITE
	SFJMP	2, C_RAWIO
	SFJMP	5, A_STATIN
	SFJMP	5, A_STATOUT
	SFJMP	2, C_WRITESTR
	SFJMP	2, C_READSTR
	SFJMP	5, C_STAT
	SFJMP	5, S_BDOSVER
	SFJMP	5, DRV_ALLRESET
	SFJMP	5, DRV_SET
	SFJMP	5, F_OPEN
	SFJMP	5, F_CLOSE
	SFJMP	5, F_SFIRST
	SFJMP	5, F_SNEXT
	SFJMP	5, F_DELETE
	SFJMP	5, F_READ
	SFJMP	5, F_WRITE
	SFJMP	5, F_MAKE
	SFJMP	5, F_RENAME
	SFJMP	5, DRV_LOGINVEC
	SFJMP	5, DRV_GET
	SFJMP	5, F_DMAOFF
	SFJMP	5, DRV_ALLOCVEC
	SFJMP	5, DRV_SETRO
	SFJMP	5, DRV_ROVEC

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 2 Функции BDOS
; ───────────────────────────────────────────────────────────────────────

	ORG	0100H
	PHASE	ROMBUF

; ──────────────────────────────────────────────
; Печать строки по адресу DE
; ВХОД:
;	DE	- адрес строки. $ - признак конца
; ВЫХОД:
;	HL	- адрес последнего напечатанного символа
; ИЗМЕНЯЕТ:
;	AF, HL, DE
; ──────────────────────────────────────────────

C_WRITESTR:
	EX	DE, HL
C_WRITESTR_LOOP:
	LD	A,(HL)
	CP	'$'
	RET	Z
	LD	C, A
	CALL	PrintCharFromC
	INC	HL
	JP	C_WRITESTR_LOOP

C_READ:	;EX	(SP),HL		; восстанавливаем HL из стеке
	CALL	InputSymbol	; 6 bytes
	JP	PrintCharFromA

; ──────────────────────────────────────────────
;BDOS function 6 (C_RAWIO) - Direct console I/O
;Supported by: CP/M 1.4 and later, with variations
;Entered with C=6, E=code. Returned values (in A) vary.
;
;E=0FFh
;Return a character without echoing if one is waiting;
; zero if none is available. In MP/M 1, this works like
; E=0FDh below and waits for a character.
;Values of E not supported on a particular system will
; output the character. Under CP/M 2 and lower, direct 
;console functions may interact undesirably with non-direct
; ones, since certain buffers may be bypassed. Do not mix them.
; ──────────────────────────────────────────────

C_RAWIO:
	INC	E		; Test for 0FFH
	JP	NZ,PrintCharFromC
	CALL	GetKeyboardStatus
	RET	Z
	JP	InputSymbol

; ──────────────────────────────────────────────
; Ввод строки в буфер DE (CP/M совместимо)
; ВХОД:
;	DE	- адрес буфера
; ВЫХОД:
;	COMBUF	- введенная строка
; ИЗМЕНЯЕТ:
;	AF, DE, HL, BC
; ──────────────────────────────────────────────

C_READSTR:
	PUSH	DE
	POP	HL
	LD	C, (HL)
	INC	HL
GotoCmdLineBegin:
	XOR	A
	LD	B, A
InputNextSymbol:
	CALL	InputSymbol		; используется в DirectiveModify
	CP	7FH
	JP	Z,ProcessBackspace
	INC	HL
	LD	(HL), A
	CALL	PrintCharFromA
	CP	13
	JP	Z,L00B2H
	CP	03
	JP	Z,WarmBoot
	INC	B
	LD	A, C
	CP	B
	JP	NZ, InputNextSymbol;	SyntaxError
	LD	B, C
L00B2H:	INC	DE
	EX	DE, HL
	LD	(HL), B
	RET

ProcessBackspace:
	LD	A,B			; 15 bytes
	OR	A			; начало буфера ввода ?
	JP	Z,GotoCmdLineBegin	; GotoCmdLineBegin
	DEC	B
	DEC	HL
	PUSH	HL
	LD	HL, BkSp
	CALL	PrintString
	pop	HL
	JP	InputNextSymbol

BkSp:	DB	8,' ',8+80H

NextBDOSROM:
	SUB	30
	LD	C, A
	LD	HL, FTABLE2
	ADD	HL, BC
	ADD	HL, BC
	ADD	HL, BC
	JP	(HL)

FTABLE2:
	SFJMP	5, F_ATTRIB
	SFJMP	5, DRV_DPB
	SFJMP	5, F_USERNUM
	SFJMP	5, F_READRAND
	SFJMP	5, F_WRITERAND
	SFJMP	5, F_SIZE
	SFJMP	5, F_RANDREC
	SFJMP	5, DRV_RESET

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 3 Внешние директивы МОНИТОРа
; ───────────────────────────────────────────────────────────────────────

	ORG	0180H
	PHASE	ROMBUF

	SHARED	DirectiveModifyROM
DirectiveModifyROM:
	CALL	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace			; 22 bytes
	PUSH	HL
	CALL	InputDirective
	POP	HL
	JP	NC,EmptyString
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
EmptyString:
	INC	HL
	JP	DirectiveModifyROM

	if	0
; ──────────────────────────────────────────────
; Дамп области памяти с HL по DE
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
; ВЫХОД:
;	HL	- конечный адрес источника
; ИЗМЕНЯЕТ:
;	AF, HL		!!TODO!! проверить подпрограммы на изменение
; ──────────────────────────────────────────────

	SHARED	DirectiveDumpROM
DirectiveDumpROM:
	CALL	PrintCRAndHexWordAndSpace			; 18 bytes
AF9C8:	CALL	PrintHexByteFromMemAndSpace
	CALL	IncHLAndRetIfEqDEWithBrk
	LD	A,L
	AND	0FH
	JP	Z,DirectiveDumpROM
	JP	AF9C8
	endif

; ──────────────────────────────────────────────
; Вывод дампа и текста области памяти с HL по DE
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
; ВЫХОД:
;	HL	- конечный адрес источника
; ИЗМЕНЯЕТ:
;	AF, HL
; ──────────────────────────────────────────────

	SHARED	DirectiveDumpROM
DirectiveDumpROM:
	CALL	PrintCRAndHexWordAndSpace
	PUSH	HL
	LD	BC,808H
DIRL1:	CALL	PrintHexByteFromMemAndSpace
	DEC	C
	INC	HL
	JP	NZ,DIRL1
	POP	HL
DIRL2:	LD	A,(HL)
	OR	A
	JP	M,AFA15
	CP	20H
	JP	NC,AFA17
AFA15:	LD	A,'.'
AFA17:	CALL	PrintCharFromA
	CALL	Compare_HL_DE
	RET	Z
	DEC	B
	INC	HL
	JP	NZ,DIRL2
	JP	DirectiveDumpROM

	IF	0
; ──────────────────────────────────────────────
; Вывод текста области памяти с HL по DE
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
; ВЫХОД:
;	HL	- конечный адрес источника
; ИЗМЕНЯЕТ:
;	AF, HL		!!TODO!! проверить подпрограммы на изменение
; ──────────────────────────────────────────────

	SHARED	DirectiveListROM
DirectiveListROM:
	CALL	PrintCRAndHexWordAndSpace			; 30 bytes
AFA0B:	LD	A,(HL)
	OR	A
	JP	M,AFA15
	CP	20H
	JP	NC,AFA17
AFA15:	LD	A,'.'
AFA17:	CALL	PrintCharFromA
	CALL	IncHLAndRetIfEqDEWithBrk
	LD	A,L
	AND	0FH
	JP	Z,DirectiveListROM
	JP	AFA0B
	endif

; ──────────────────────────────────────────────
; Перемещает область памяти с HL по DE в адреса BC
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
;	BC	- целевой адрес
; ВЫХОД:
;	HL	- конечный адрес источника
;	BC	- целевой конечный адрес
; ИЗМЕНЯЕТ:
;	AF, HL, BC
; ──────────────────────────────────────────────

	SHARED	DirectiveTransferROM
DirectiveTransferROM:
	LD	A,(HL)			; 9 bytes
	LD	(BC),A
	INC	BC
	CALL	IncHLAndRetIfEqDE
	JP	DirectiveTransferROM

; ──────────────────────────────────────────────
; Ищет байт C в области памяти с HL по DE
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
;	C	- искомый байт
; ВЫХОД:
;	HL	- конечный адрес источника
; ИЗМЕНЯЕТ:
;	AF, HL
; ──────────────────────────────────────────────

	SHARED	DirectiveSearchROM
DirectiveSearchROM:
	LD	A,C			; 11 bytes
	CP	(HL)
	CALL	Z,PrintCRAndHexWordAndSpace
	CALL	IncHLAndRetIfEqDEWithBrk
	JP	DirectiveSearchROM

	SHARED	DirectiveCompareROM
DirectiveCompareROM:
	LD	A,(BC)			; 19 bytes
	CP	(HL)
	JP	Z,AF9E6
	CALL	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace
	LD	A,(BC)
	CALL	PrintHexByteAndSpace
AF9E6:	INC	BC
	CALL	IncHLAndRetIfEqDEWithBrk
	JP	DirectiveCompareROM

	SHARED	DirectiveOutputTapeROM
DirectiveOutputTapeROM:
	LD	A,C
	OR	A
	JP	Z,DefaultConstant
	LD	(KNS_WR),A
DefaultConstant:
	PUSH	HL
	CALL	CalcChecksum
	POP	HL

	FJMP	4, DirectiveOutputTapeROM2

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 4 Внешние директивы МОНИТОРа
; ───────────────────────────────────────────────────────────────────────

	ORG	0200H
	PHASE	ROMBUF

DirectiveOutputTapeROM2:
	CALL	PrintCRAndHexWordAndSpaceAndCRAndHexWordAndSpace
	EX	DE,HL
	

	PUSH	HL
	CALL	PrintCRAndHexWordBCAndSpace
	POP	HL

	SHARED	TapeWriteBlockROM
TapeWriteBlockROM:
	PUSH	BC		; КС

	LD	BC,0		; выводим 256 байтов 00 (пилотон)
AFB4D:	CALL	TapeWriteByte
	EX	(SP),HL 	; это задержка 38 тактов
	EX	(SP),HL
	DEC	B
	JP	NZ,AFB4D

	CALL	TapeWriteSync

	CALL	TapeWriteWord		; выводим НА
	EX	DE,HL
	CALL	TapeWriteWord		; выводим КА

	EX	DE,HL
	CALL	TapeWriteFromHLtoDE		; выводим блок

	LD	HL,0
	CALL	TapeWriteWord		; выводим 2 байта 00

	CALL	TapeWriteSync

	POP	HL
	CALL	TapeWriteWord		; выводим КС

	JP	InitVideo

; ──────────────────────────────────────────────
; Запись слова
; ВХОД:
;	HL	- слово для записи
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	BC
; ──────────────────────────────────────────────

TapeWriteWord:
	LD	C,H
	CALL	TapeWriteByte
	LD	C,L
	DB	06H		; LD B,..

; ──────────────────────────────────────────────
; Запись синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	C
; ──────────────────────────────────────────────

TapeWriteSync:
	LD	C, 0E6H
	JP	TapeWriteByte

; ──────────────────────────────────────────────
; Запись блока с HL по DE на магнитофон
; ВХОД:
;	HL	- начало блока
;	DE	- конец блока
; ВЫХОД:
;	HL	- конец блока
; ИЗМЕНЯЕТ:
;	AF, C, HL
; ──────────────────────────────────────────────

TapeWriteFromHLtoDE:
	LD	C,(HL)			; 10 bytes
	CALL	TapeWriteByte
	CALL	IncHLAndRetIfEqDE
	JP	TapeWriteFromHLtoDE

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 5
; ───────────────────────────────────────────────────────────────────────

	ORG	0280H
	PHASE	ROMBUF

P_TERMCPM:
	JP	WarmBoot

C_WRITE:
	JP	PrintCharFromC
C_STAT:
	JP	GetKeyboardStatus

A_READ:
A_WRITE:
L_WRITE:
A_STATIN:
A_STATOUT:
DRV_ALLRESET:
DRV_SET:
F_OPEN:
F_CLOSE:
F_SFIRST:
F_SNEXT;
F_DELETE:
F_READ;
F_WRITE:
F_MAKE:
F_RENAME:
DRV_LOGINVEC:
DRV_GET:
F_DMAOFF:
DRV_ALLOCVEC:
DRV_SETRO:
DRV_ROVEC:
F_ATTRIB:
DRV_DPB:
F_USERNUM:
F_READRAND:
F_WRITERAND:
F_SIZE:
F_RANDREC:
DRV_RESET:
F_WRITEZF:
	LD	B, 00H
	LD	A, 0FFH
	RET

S_BDOSVER:
	LD	A, 20H		; Функция 12 S_BDOSVER
	LD	B, 00H
	RET

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 6
; ───────────────────────────────────────────────────────────────────────

	ORG	0300H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 7
; ───────────────────────────────────────────────────────────────────────

	ORG	0380H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 8
; ───────────────────────────────────────────────────────────────────────

	ORG	0400H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 9
; ───────────────────────────────────────────────────────────────────────

	ORG	0480H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 10
; ───────────────────────────────────────────────────────────────────────

	ORG	0500H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 11
; ───────────────────────────────────────────────────────────────────────

	ORG	0580H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 12
; ───────────────────────────────────────────────────────────────────────

	ORG	0600H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 13
; ───────────────────────────────────────────────────────────────────────

	ORG	0680H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 14
; ───────────────────────────────────────────────────────────────────────

	ORG	0700H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 15
; ───────────────────────────────────────────────────────────────────────

	ORG	0780H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Файловая система в формате ORDOS
; ───────────────────────────────────────────────────────────────────────
	ORG 0800H

FILE	MACRO name, start, size
	DB	(0fff0h-$) & 0fh dup (0)	; выравнивание по границе 16
s	SET	$
	DB	name
	DB	8-($-s) DUP (20H)
	DW	start
	DW	size
	DB	080H
	DB	0,0,0
	ENDM

ENDOFFILES	MACRO
	DB	(0fff0h-$) & 0fh dup (0)	; выравнивание по границе 16
	DB	0FFH
	ENDM

	FILE "DUMP$", 100H, ENDDUMPCOM-DUMPCOM
DUMPCOM:
	BINCLUDE "dump.com"
ENDDUMPCOM:

	FILE "BASIC$", 0, 02000H
BASICROM:
	BINCLUDE "basic.rom"

	FILE "ASM$", 0, 01000H
EDASMROM:
	BINCLUDE "edasm.rom"

	FILE "DDT$", 6400H, 01000H
DPDDTROM:
	BINCLUDE "dpddt.rom"
	
	FILE "SORT$", 0, 0E96H
SORTUTROM:
	BINCLUDE "sortut.rom"

	FILE "LOAD$", 07400H, ENDLOADROM-LOADROM
LOADROM:
	BINCLUDE "load.rom"
ENDLOADROM:

	FILE "SAVE$", 07400H, ENDSAVEROM-SAVEROM
SAVEROM:
	BINCLUDE	"SAVE.ROM"
ENDSAVEROM:

	FILE "TEST$", 00100H, ENDTESTROM-TESTROM
TESTROM:
	BINCLUDE	"TEST.COM"
ENDTESTROM:

	ENDOFFILES

; ───────────────────────────────────────────────────────────────────────
; ПРОГРАММА УПРАВЛЕНИЯ ROM-DISK/32K
; ───────────────────────────────────────────────────────────────────────

	ORG	07E00H

	if BASE=7600H
	BINCLUDE "romctrl32k.rom"
	else
	BINCLUDE "romctrl16k.rom"
	endif

	CHK	08000H, "* Block overflow ! *"
	END 				;

