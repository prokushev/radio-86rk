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
	LD	SP, 080H
	DEC	C
	JP	M, WarmBoot		; Функция 0 P_TERMCPM
	LD	HL, BDOSRET
	PUSH	HL			; В стек кладем адрес возврата из BDOS
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
	JP	NC,EmptyString
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
EmptyString:
	INC	HL
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
; ПРОГРАММА СЧИТЫВАНИЯ ФАЙЛА ИЗ ВРЕМЕННОГО БУФЕРА 
; В ТЕКСТОВЫЙ БУФЕР РЕДАКТОРА "МИКРОН". 
LOADROM:
	PHASE	07400H
	LD     HL,4A00H	;НАЧАЛЬНЫЙ АДРЕС 
	LD     DE,2100H	;BPEMEHHOГO БУФЕРА. 
	LD     BC,28FFH	;OБЪEM ФАЙЛА. 
RD1:	LD     A,(HL)   	;ПЕРЕСЛАТЬ
	LD	(DE),A     	;ФАЙЛ 
	INC     HL     	;И3
	INC     DE     	;ВРЕМЕННОГО БУФЕРА 
	DEC     BC     	;B ТЕКСТОВЫЙ БУФЕР 
	LD     A,B   	;С АДРЕСА 2100Н. 
	OR     C     	; 
	JP	NZ,     RD1   	; 
	JP	WarmBoot
	DEPHASE
ENDLOADROM:

	FILE "SAVE$", 07400H, ENDSAVEROM-SAVEROM
; ПРОГРАММА СОХРАНЕНИЯ ФАЙЛА ВО ВРЕМЕННОМ 
; БУФЕРЕ. ЕСЛИ ОБЪЕМ ФАЙЛА ПРЕВЫШАЕТ 28FFH, ТО 
; ОПЕРАЦИЯ ПО ХРАНЕНИЮ НЕ ВЫПОЛНЯЕТСЯ. 

SAVEROM:
	PHASE	07400H
	LD     HL, 2100H
S1:	LD     A,(HL)   	;ПРОВЕРИТЬ РАЗМЕР
	CP     0FFH  	; ФАЙЛА. 
	JP	Z, S2    	;ЕСЛИ ФАЙЛ HE УМЕЩАЕТСЯ 
	INC     HL     	;ВО ВРЕМЕННОМ 
	LD     A, H   	; БУФЕРЕ, ТО 
	CP     4AH   	; 
	JP	NZ,     S1    	;
	LD     HL,SO6 	;СООБЩИТЬ, А ПЕРЕСЫЛКУ 
	CALL	PrintString
	JP     WarmBoot    	;HE ПРОИЗВОДИТЬ.
S2:	LD 	HL,2100H	;ВО ВРЕМЕННЫЙ БУФЕР.
	LD 	DE,4A00H ;
	LD     BC,28FFH	;OБЪEM ФАЙЛА. 
S3:	LD     A,(HL)   	;ПЕРЕСЛАТЬ
	LD	(DE),A     	;ФАЙЛ 
	INC     HL     	;И3
	INC     DE     	;ВРЕМЕННОГО БУФЕРА 
	DEC     BC     	;B ТЕКСТОВЫЙ БУФЕР 
	LD     A,B   	;С АДРЕСА 2100Н. 
	OR     C     	; 
	JP	NZ, S3
	JP	WarmBoot
SO6:	DB 	0DH,"OUT OF BUFFER",0
	DEPHASE
ENDSAVEROM:

	FILE "ZERO$", 07400H, ENDZEROROM-ZEROROM
; ПРОГРАММА ОЧИСТКИ ПАМЯТИ (ЗАПИСЬ "0")
; BO ВСЕ ДОСТУПНЫЕ ПОЛЬЗОВАТЕЛЮ ЯЧЕЙКИ ОЗУ,
; КРОМЕ ЯЧЕЕК, НАЧИНАЯ С 7400Н).
ZEROROM:
	PHASE	07400H
	LD 	HL,0 	;
Z1:	LD 	(HL),0 	;ОЧИСТИТЬ
	INC 	HL 	; ПАМЯТЬ.
	LD 	A,H 	;
	CP 	74H 	;ЕСЛИ АДРЕС БОЛЬШЕ
	JP	NZ, 	Z1 	; 7400Н, ТО ВЫЙТИ
	JP 	WarmBoot 	;В МЕНЮ.
	DEPHASE
ENDZEROROM:

	FILE "TEST$", 00100H, ENDTESTROM-TESTROM

TESTROM:
	PHASE	00100H
TESTLOOP:
	LD	C, 9				; C_WRITESTR
	LD	DE, WelcomeMsg
	CALL	5				; BDOS

	LD	C, 1				; C_READ
	CALL	5				; BDOS

	CP	"A"
	CALL	Z, MONITORTest
	CP	"B"
	CALL	Z, CPMTest
	CP	"0"
	JP	NZ, TESTLOOP

	RST	0				; Возврат в CP/M
WelcomeMsg:
	DB	0dh,0ah,"* analiz sowmestimosti *",0dh,0ah
	DB	"wyberite komponent:", 0dh, 0ah
	DB	"A monitor", 0dh,0ah
	DB	"B CP/M", 0dh,0ah
	DB	"0 wyhod iz programmy", 0dh,0ah
	DB	">"
	DB	"$"

; ───────────────────────────────────────────────────────────────────────
; Подпрограмма тестировани МОНИТОРа на совместимость
; ───────────────────────────────────────────────────────────────────────

MONITORTest:
	PUSH	AF
	PUSH	HL

MONITORTestLoop:
	LD	HL, MONITORMsg
	CALL	0F818H		; Вывод строки

	CALL	0F803H		; Ожидание ввода

	CP	"A"
	CALL	Z, MONITORStdTest
	CP	"B"
	CALL	Z, MONITORNonStdTest
	CP	"0"
	JP	NZ, MONITORTestLoop

	POP	HL
	POP	AF

	RET


; ───────────────────────────────────────────────────────────────────────
; Подпрограмма тестировани стандартных подпрограмм МОНИТОРа на совместимость
; ───────────────────────────────────────────────────────────────────────

MONITORStdTest:
	PUSH	AF
	PUSH	HL

MONITORStdTestLoop:
	LD	HL, MONITORStdMsg
	CALL	0F818H		; Вывод строки

	CALL	0F803H		; Ожидание ввода

	CP	"A"
	CALL	Z, MTESTF800
	CP	"B"
	CALL	Z, MTESTF803
	CP	"C"
	CALL	Z, MTESTF806
	CP	"D"
	CALL	Z, MTESTF809
	CP	"E"
	CALL	Z, MTESTF80C
	CP	"F"
	CALL	Z, MTESTF80F
	CP	"G"
	CALL	Z, MTESTF812
	CP	"H"
	CALL	Z, MTESTF815
	CP	"I"
	CALL	Z, MTESTF818
	CP	"J"
	CALL	Z, MTESTF81B
	CP	"K"
	CALL	Z, MTESTF81E
	CP	"L"
	CALL	Z, MTESTF821
	CP	"M"
	CALL	Z, MTESTF824
	CP	"N"
	CALL	Z, MTESTF827
	CP	"O"
	CALL	Z, MTESTF82A
	CP	"P"
	CALL	Z, MTESTF82D
	CP	"Q"
	CALL	Z, MTESTF830
	CP	"R"
	CALL	Z, MTESTF833
	CP	"S"
	CALL	Z, MTESTF836
	CP	"T"
	CALL	Z, MTESTF839
	CP	"U"
	CALL	Z, MTESTF83C
	CP	"V"
	CALL	Z, MTESTF83F
	CP	"0"
	JP	NZ, MONITORStdTestLoop
	
	POP	HL
	POP	AF

	RET


MTESTF800:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF800Msg
	CALL	0F818H		; Вывод строки

	CALL	0F803H		; Ожидание ввода

	CALL	0F800H		; "Холодный" старт системы

	POP	HL
	POP	AF
	RET

MTESTF803:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF803Msg
	CALL	0F818H		; Вывод строки

	CALL	DumpRegs

	PUSH	HL
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	HL, MTESTF803Msg2
	CALL	0F818H		; Вывод строки
	POP	DE
	POP	BC
	POP	AF
	POP	HL

	CALL	0F803H		; Ожидание ввода

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF806:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF806Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF809:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF809Msg
	CALL	0F818H		; Вывод строки

	LD	C, "*"

	CALL	DumpRegs

	CALL	0F809H		; Вывод символа на экран

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF80C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF80CMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF80F:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF80FMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF812:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF812Msg
	CALL	0F818H		; Вывод строки

	CALL	DumpRegs

	CALL	0F812H		; Опрос состояния клавиатуры

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF815:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF815Msg
	CALL	0F818H		; Вывод строки

	LD	A, "A"

	CALL	DumpRegs

	CALL	0F815H		; Вывод числа на экран в 16-ричном формате

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF818:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF818Msg
	CALL	0F818H		; Вывод строки

	LD	HL, TestMsg
	CALL	DumpRegs

	CALL	0F818H		; Вывод строки

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF81B:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF81BMsg
	CALL	0F818H		; Вывод строки

	CALL	DumpRegs

	CALL	0F81BH		; Опрос клавиатуры

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF81E:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF81EMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF821:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF821Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF824:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF824Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF827:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF827Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF82A:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF82AMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF82D:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF82DMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF830:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF830Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF833:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF833Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF836:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF836Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF839:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF839Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF83C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF83CMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF83F:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF83FMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MONITORNonStdTest:
	RET

DumpRegs:
	PUSH	HL
	PUSH	AF
	PUSH	BC
	PUSH	DE

	LD	(RHL), HL
	PUSH	AF
	POP	HL
	LD	(RAF), HL
	PUSH	BC
	POP	HL
	LD	(RBC), HL
	PUSH	DE
	POP	HL
	LD	(RDE), HL

	LD	HL, RegistersListStr
	CALL	0F818H		; Вывод строки

	LD	HL, (RHL)
	CALL	PrintHexWord

	LD	HL, NextReg
	CALL	0F818H		; Вывод строки

	LD	HL, (RBC)
	CALL	PrintHexWord

	LD	HL, NextReg
	CALL	0F818H		; Вывод строки

	LD	HL, (RDE)
	CALL	PrintHexWord

	LD	HL, NextReg
	CALL	0F818H		; Вывод строки

	LD	HL, (RAF)
	CALL	PrintHexWord

	LD	HL, NextReg
	CALL	0F818H		; Вывод строки

	LD	HL, CRLFMsg
	CALL	0F818H		; Вывод строки

	POP	DE
	POP	BC
	POP	AF
	POP	HL

	RET

PrintHexWord:
	LD	A,H
	CALL	0F815H		; Печать hex-байта 
	LD	A,L
	JP	0F815H		; Печать hex-байта

MONITORMsg:
	DB	0dh, 0ah, "* testirowanie monitora * wyberite podprogrammy: ", 0dh, 0ah
	DB	"A standartnye", 0dh, 0ah
	DB	"B nestandartnye", 0dh, 0ah
	DB	"0 nazad"
	DB	0dh, 0ah,">", 0

MONITORStdMsg:
	DB	0dh, 0ah, "* testirowanie monitora * wyberite podprogrammu: ", 0dh, 0ah
	DB	"A F800", 0dh, 0ah
	DB	"B F803", 0dh, 0ah
	DB	"C F806", 0dh, 0ah
	DB	"D F809", 0dh, 0ah
	DB	"E F80C", 0dh, 0ah
	DB	"F F80F", 0dh, 0ah
	DB	"G F812", 0dh, 0ah
	DB	"H F815", 0dh, 0ah
	DB	"I F818", 0dh, 0ah
	DB	"J F81B", 0dh, 0ah
	DB	"K F81E", 0dh, 0ah
	DB	"L F821", 0dh, 0ah
	DB	"M F824", 0dh, 0ah
	DB	"N F827", 0dh, 0ah
	DB	"O F82A", 0dh, 0ah
	DB	"P F82D", 0dh, 0ah
	DB	"Q F830", 0dh, 0ah
	DB	"R F833", 0dh, 0ah
	DB	"S F836", 0dh, 0ah
	DB	"T F839", 0dh, 0ah
	DB	"U F83C", 0dh, 0ah
	DB	"V F83F", 0dh, 0ah
	DB	"0 nazad"
	DB	0dh, 0ah,">", 0
MTESTF800Msg:
	DB	0dh, 0ah, "prowerka F800H", 0dh, 0ah
	DB	"\"holodnyj\" zapusk monitora. pri wyzowe dannoj podprogrammy", 0dh, 0ah
	DB	"osu}estwlqetsq polnyj perezapusk sistemy.", 0dh, 0ah
	DB	"navmite l`bu` klawi{u dlq wyzowa.", 0dh, 0ah, '>', 0
MTESTF803Msg:
	DB	0dh, 0ah, "prowerka F803H", 0dh, 0ah
	DB	"wwod simwola s klawiatury. w registre A wozwra}aetsq kod", 0dh, 0ah
	DB	"wwedennogo simwola."
CRLFMsg:
	DB	0dh, 0ah, 0
MTESTF803Msg2:
	DB	0dh, 0ah, "navmite kaku`-nibudx klawi{u.", 0dh, 0ah, '>', 0
AnyKey:
	DB	0dh, 0ah, "navmite kaku`-nibudx klawi{u dlq prodolveniq.", 0dh, 0ah, '>', 0
TestMsg:
	DB	0dh,0ah,"test",0dh,0ah,0
MTESTF806Msg:
	DB	0dh, 0ah, "prowerka F806H", 0dh, 0ah, '>', 0
MTESTF809Msg:
	DB	0dh, 0ah, "prowerka F809H", 0dh, 0ah
	DB	"wywod simwola iz registra C na |kran.", 0dh, 0ah, '>', 0
MTESTF80CMsg:
	DB	0dh, 0ah, "prowerka F80CH", 0dh, 0ah, '>', 0
MTESTF80FMsg:
	DB	0dh, 0ah, "prowerka F80FH", 0dh, 0ah, '>', 0
MTESTF812Msg:
	DB	0dh, 0ah, "prowerka F812H", 0dh, 0ah, '>', 0
MTESTF815Msg:
	DB	0dh, 0ah, "prowerka F815H", 0dh, 0ah, '>', 0
MTESTF818Msg:
	DB	0dh, 0ah, "prowerka F818H", 0dh, 0ah, '>', 0
MTESTF81BMsg:
	DB	0dh, 0ah, "prowerka F81BH", 0dh, 0ah, '>', 0
MTESTF81EMsg:
	DB	0dh, 0ah, "prowerka F81EH", 0dh, 0ah, '>', 0
MTESTF821Msg:
	DB	0dh, 0ah, "prowerka F821H", 0dh, 0ah, '>', 0
MTESTF824Msg:
	DB	0dh, 0ah, "prowerka F824H", 0dh, 0ah, '>', 0
MTESTF827Msg:
	DB	0dh, 0ah, "prowerka F827H", 0dh, 0ah, '>', 0
MTESTF82AMsg:
	DB	0dh, 0ah, "prowerka F82AH", 0dh, 0ah, '>', 0
MTESTF82DMsg:
	DB	0dh, 0ah, "prowerka F82DH", 0dh, 0ah, '>', 0
MTESTF830Msg:
	DB	0dh, 0ah, "prowerka F830H", 0dh, 0ah, '>', 0
MTESTF833Msg:
	DB	0dh, 0ah, "prowerka F833H", 0dh, 0ah, '>', 0
MTESTF836Msg:
	DB	0dh, 0ah, "prowerka F836H", 0dh, 0ah, '>', 0
MTESTF839Msg:
	DB	0dh, 0ah, "prowerka F839H", 0dh, 0ah, '>', 0
MTESTF83CMsg:
	DB	0dh, 0ah, "prowerka F83CH", 0dh, 0ah, '>', 0
MTESTF83FMsg:
	DB	0dh, 0ah, "prowerka F83FH", 0dh, 0ah, '>', 0

RegistersListStr:
	db 0Dh, 0Ah, "HL-"
	db 0Dh, 0Ah, "BC-"
	db 0Dh, 0Ah, "DE-"
	db 0Dh, 0Ah, "AF-"
	db 19h, 19h, 19h, 0

NextReg:
	DB 08h, 08h, 08h, 08h, 1AH,0

RAF:	DW	?
RHL:	DW	?
RBC:	DW	?
RDE:	DW	?
RSP:	DW	?

; ───────────────────────────────────────────────────────────────────────
; Подпрограмма тестировани CP/M на совместимость
; ───────────────────────────────────────────────────────────────────────

CPMTest:
	PUSH	AF
	PUSH	HL
	PUSH	BC
	PUSH	DE

	LD	C, 9				; C_WRITESTR
	LD	DE, CPMBDOSMsg
	CALL	5				; BDOS

	LD	C, 9				; C_WRITESTR
	LD	DE, CPMBDOSMsg
	CALL	5				; BDOS

	POP	DE
	POP	BC
	POP	HL
	POP	AF
	RET

CPMBIOSMsg:
	DB	"CP/M BIOS", 0dh, 0ah, "CONOUT: ", 0dh, 0ah, "$"

CPMBDOSMsg:
	DB	"CP/M BDOS", 0dh, 0ah, "C_WRITE: ", 0dh, 0ah, "$"

;CONST	EQU	BIOS+3
;CONIN	EQU	BIOS+6
;CONOUT	EQU	BIOS+9
;LIST	EQU	BIOS+12
;PUNCH	EQU	BIOS+15
;AUXOUT	EQU	BIOS+15
;READER	EQU	BIOS+18
;AUXIN	EQU	BIOS+18

; ───────────────────────────────────────────────────────────────────────
; Подпрограмма вывода содержимого регистров
; ───────────────────────────────────────────────────────────────────────

	DEPHASE
ENDTESTROM:

	ENDOFFILES

; ───────────────────────────────────────────────────────────────────────
; ПРОГРАММА УПРАВЛЕНИЯ ROM-DISK/32K ДЛЯ КОМПЬЮТЕРА 
; "РАДИО-86РК" С OБЪEMOM ОЗУ ПОЛЬЗОВАТЕЛЯ 16К/32К.
; ПРОГРАММА УПРАВЛЕНИЯ ЗАФИКСИРОВАНА В ПЗУ 
; ПО АДРЕСАМ 7E00H-7FFFH. УКАЗАННУЮ ОБЛАСТЬ ПЗУ 
; ЗАПРЕЩЕНО ИСПОЛЬЗОВАТЬ ПОД ROM-DISK. 
; ПРОГРАММА ИЗ ПЗУ В ОЗУ ПЕРЕНОСИТСЯ ЗАГРУЗЧИКОМ, 
; (В MONITORE) ПО ДИРЕКТИВЕ "U" И ЗАНИМАЕТ 
; ВЕРХНИЕ АДРЕСА ОЗУ, НАЧИНАЯ С 7400Н.
; ───────────────────────────────────────────────────────────────────────

	ORG	07E00H
	
	PHASE	BASE-0200H

	LD	HL, SO1
	CALL	PrintString
	LD	B, 0FFH
	CALL	SEARCHS

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
	PUSH	DE

	LD	A, C			; Печатаем порядковый номер
	ADD	A, 30H
	LD	C, A
	CALL	PrintCharFromC
	LD	C, ' '
	CALL	PrintCharFromC

	LD	B, 8
	LD	HL, T
PLOOP:	LD	A, (HL)			; Печатаем имя
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
	LD	C, ' '			; Печатаем размер
	CALL	PrintCharFromC
	LD	A, (HL)
	CALL	PrintHexByte
	DEC	HL
	LD	A, (HL)
	CALL	PrintHexByte

	LD	HL, SO2			; Печатаем перевод строки
	CALL	PrintString
	POP	DE
	POP	BC
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
	CALL    ReadROM
	POP	HL

	JP	(HL)          	;И ЗАПУСТИТЬ ПРОГРАММУ.

T:	DB	8+2+2 DUP 0			;

SO1:	DB 	0AH,0DH,"*ROM-DISK/32K* V3.0-23"
	DB 	0AH,0AH,0DH,"DIRECTORY:"
SO2:	DB	0AH,0DH,0

	DEPHASE

	DB	08000H-$ DUP (0FFH)
	CHK	08000H, "* Block overflow ! *"
	END 				;

