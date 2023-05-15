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
; FCALL block, label
; 
; здесь block - номер блока, начиная с 0, а label - метка кода;
; ───────────────────────────────────────────────────────────────────────

; ───────────────────────────────────────────────────────────────────────
; Адреса системных вызовов
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"syscalls.inc"
	IF	STUB
	INCLUDE	"stub.inc"
	ELSE
	INCLUDE	"MON580-2.INC"
	ENDIF

; ───────────────────────────────────────────────────────────────────────
; Адреса системных переменных
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"sysvars.inc"


FCALL	MACRO	block, adr
		CALL	CALLROM
		DB	block
		DB	LOW adr
	ENDM

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
; Блок 0. Инициализация
; ───────────────────────────────────────────────────────────────────────

	ORG	0
	PHASE	ROMBUF

; ──────────────────────────────────────────────
; Блок защиты загрузки на Орион-128. Выводит
; сообщение, что данный диск предназначен для Радио-86РК.
; ──────────────────────────────────────────────
ORDOSStart:
	LD	HL, MsgRKOnly
	CALL	PrintString
	JP	WarmBoot
MsgRKOnly:
	DB	"|tot ROM-disk prednazna~en dlq radio-86r",'k' + 80H

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
; To make a BDOS call in an 8-bit CP/M, use:
;
;    LD  DE,parameter
;    LD  C,function
;    CALL    5
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
	LD	SP, STACK
	DEC	C
	JP	M, WarmBoot		; Функция 0 P_TERMCPM
	LD	HL, BDOSRET
	PUSH	HL
	LD	A, C
	LD	C, E
	FJPZ	2, C_READ		; Функция 1 C_READ
	DEC	A
	JP	Z, PrintCharFromC	; Функция 2 C_WRITE
	SUB	4
	FJPZ	2, C_RAWIO		; Функция 6 C_RAWIO
	SUB	3
	FJPZ	2, C_WRITESTR		; Функция 9 C_WRITESTR
	DEC	A
	FJPZ	2, C_READSTR		; Функция 10 C_READSTR
	DEC	A
	JP	Z, GetKeyboardStatus	; Функция 11 C_STAT
	DEC	A
	JP	NZ, WarmBoot	; Функции 13 и выше не поддерживается
	LD	A, 20H		; Функция 12 S_BDOSVER
	LD	B, 00H
	RET

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
;		  или символ больше 7Fh
; ВЫХОД:
;	HL	- адрес последнего напечатанного символа
; ИЗМЕНЯЕТ:
;	AF, B, HL, DE
; ──────────────────────────────────────────────

C_WRITESTR:
	LD	HL, PrintString+1
	INC	HL
	INC	HL
	PUSH	HL
	EX	DE, HL
	LD	B, '$'
	RET			; JP PrintString+2, т.е. пропустили LD B, 0

C_READ:	EX	(SP),HL		; восстанавливаем HL из стеке
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
	JP	NC,AFA3B
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
AFA3B:	INC	HL
	JP	DirectiveModifyROM

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

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 4
; ───────────────────────────────────────────────────────────────────────

	ORG	0200H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ───────────────────────────────────────────────────────────────────────
; Блок 5
; ───────────────────────────────────────────────────────────────────────

	ORG	0280H
	PHASE	ROMBUF

	DB	80H dup 0ffH

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

	END

