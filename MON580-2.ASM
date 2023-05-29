; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОР-2.00 для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52 и эмулятором CP/M
; ───────────────────────────────────────────────────────────────────────
;  Часть, находящаяся в ROM по адресам F800H-FFFFH
; ═══════════════════════════════════════════════════════════════════════

	CPU	8080
	Z80SYNTAX	EXCLUSIVE

; ──────────────────────────────────────────────
; Дальняя JMP block, label
; ──────────────────────────────────────────────

FJMP	MACRO	block, adr
		CALL	FARJMP
		DB	block
		DB	(adr & 0FFH)
	ENDM

; ──────────────────────────────────────────────
; Проверка контрольной точки
; ──────────────────────────────────────────────

CHK	MACRO	adr, msg
		IF	adr-$
			ERROR	msg
		ENDIF
	ENDM

; ──────────────────────────────────────────────
; Системные переменные МОНИТОРа
; ──────────────────────────────────────────────

	INCLUDE	"SYSVARS.INC"

; ──────────────────────────────────────────────
; Подпрограммы МОНИТОРа, размещенные на ROM-диске
; ──────────────────────────────────────────────

	INCLUDE	"MON580-2-ROM.INC"

	ORG	RABADR


; ──────────────────────────────────────────────
; Блок векторов МОНИТОРа
; ──────────────────────────────────────────────

	JP	ColdBoot		; F800
	JP	InputSymbol 		; F803
	JP	TapeReadByte		; F806
	JP	PrintCharFromC		; F809
	JP	TapeWriteByte		; F80C
	JP	PrintCharFromC		; F80F   это д.быть PRINT
	JP	GetKeyboardStatus	; F812
	JP	PrintHexByte 		; F815
	JP	PrintString  		; F818
	JP	ReadKeyCode 		; F81B
	JP	GetCursorPos		; F81E
	JP	ReadVideoRAM		; F821
	JP	TapeReadBlock		; F824
	JP	TapeWriteBlock		; F827
	JP	CalcChecksum		; F82A
	JP	InitVideo		; F82D

; ──────────────────────────────────────────────
; Возвращает верхнею границу свободного ОЗУ
; ВХОД:
;	Нет
; ВЫХОД:
;	HL	- адрес последней доступной ячейки ОЗУ
; ИЗМЕНЯЕТ:
;	HL
; ──────────────────────────────────────────────

GetFreeMemAddr:				; F830
	LD	HL,(RAMTOP)		; 3 bytes

; ──────────────────────────────────────────────
; Устанавливает верхнею границу свободного ОЗУ
; ВХОД:
;	HL	- адрес последней доступной ячейки ОЗУ
; ВЫХОД:
;	HL	- адрес последней доступной ячейки ОЗУ
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────

SetFreeMemAddr:				; F833
	LD	(RAMTOP),HL		; 4 bytes

	RET				; F836
; ──────────────────────────────────────────────
; Возврат каретки
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
; 	L
; ОПИСАНИЕ:
;	Курсор перемещается в начало текущей строки.
; ──────────────────────────────────────────────

COD_0D:	LD	L, MARGIN_LEFT		; 3 bytes

; ──────────────────────────────────────────────

	RET				; F839

	NOP
	NOP

	JP	SetCursorPos		; F83C
	JP	Beep			; F83F
Version:
	DB	"V5.x"

	NOP
	NOP
	NOP

; ──────────────────────────────────────────────
; Печать строки по адресу HL
; ВХОД:
;	HL	- адрес строки. 0H - признак конца
;		  или символ больше 7Fh
; ВЫХОД:
;	HL	- адрес последнего напечатанного символа
; ИЗМЕНЯЕТ:
;	AF, HL
; ПРИМЕЧАНИЯ:
; 	Код в ROM-диске ожидает именно такие 4 первые
;	команды. При их изменении нужно править в ROM-диске
; ──────────────────────────────────────────────

PrintString:
	LD	A,(HL)
	CP	0
	RET	Z
	CALL	PrintCharFromA
	INC	HL
	RET	M			; RET if high bit set
	JP	PrintString

; ──────────────────────────────────────────────

; ──────────────────────────────────────────────

LD_BLK:	CALL	TapeReadByteNoSync			; 10 bytes
	LD	(HL),A
	CALL	IncHLAndRetIfEqDE
	JP	LD_BLK

; ──────────────────────────────────────────────
; Возвращает символ в текущих координатах видео ОЗУ
; ВХОД:
;	Нет
; ВЫХОД:
;	A	- символ в текущих координатах
; ИЗМЕНЯЕТ:
;	A
; ──────────────────────────────────────────────

ReadVideoRAM:
	PUSH	HL			; 7 bytes
	CALL	SetCursorPos
	LD	A,(HL)
	POP	HL
	RET

; ──────────────────────────────────────────────

RST_18:	EX	(SP),HL			; 6 bytes
	CALL	PrintString
	EX	(SP),HL
	RET

; ──────────────────────────────────────────────
; "Теплый" старт МОНИТОРа
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Не определено
; ──────────────────────────────────────────────

	CHK	0F86CH, "* Standard subroutine WarmBoot shifted ! *"

WarmBoot:
	LD	SP,STACK

	LD	A,90H
	LD	(PDU),A

	CALL	RST_18
	DB	13,10,'>'+80H

	CALL	InputDirective

	LD	HL,WarmBoot
	PUSH	HL			; в стеке лежит адрес возрата в МОНИТОР

	CALL	ParseParameters
	LD	HL,COMBUF
	LD	A,(HL)
	LD	HL,(PAR_BC)		; Z80: LD BC,(PAR_BC)
	LD	C,L
	LD	B,H
	LD	HL,(PAR_DE)		; Z80: LD DE,(PAR_DE)
	EX	DE,HL

	LD	HL, DIRTABLE-1
DIRLOOP:
	INC	HL
	CP	(HL)
	PUSH	AF
	XOR	A
	CP	(HL)
	JP	Z,SyntaxError
	POP	AF
	INC	HL
	JP	NZ, DIRLOOP
	LD	L, (HL)
	PUSH	HL
	LD	HL,(PAR_HL)
	RET

; ──────────────────────────────────────────────

AFE97:	PUSH	HL			; 27 bytes
	LD	HL,7 << 8 + 1
AFE9C:	LD	A,L
	RRCA
	LD	L,A
	CPL
	LD	(PA),A
	LD	A,(PB)
	CPL
	OR	A
	JP	NZ,AFEB3
	DEC	H
	JP	P,AFE9C
AFEAF:	LD	A,0FFH
	POP	HL
	RET


; ──────────────────────────────────────────────
; Загрузка BC с поиском синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	BC	- загруженные байта
; ИЗМЕНЯЕТ:
;	AF, BC
; ──────────────────────────────────────────────

TapeReadWordSync:
	LD	A, 0FFH			; 14 bytes
	DB	1			; LD BC, ..

; ──────────────────────────────────────────────
; Загрузка BC без поиска синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	BC	- загруженные байта
; ИЗМЕНЯЕТ:
;	AF, BC
; ──────────────────────────────────────────────

TapeReadWordNoSync:
	LD	A, 8

; ──────────────────────────────────────────────
; Загрузка слова в BC
; ВХОД:
;	A=008H	- без поиска синхробайта
;	A=0FFH	- с поиском синхробайта
; ВЫХОД:
;	BC	- загруженные байта
; ИЗМЕНЯЕТ:
;	AF, BC
; ──────────────────────────────────────────────

TapeReadWord:
	CALL	TapeReadByte
	LD	B, A
	CALL	TapeReadByteNoSync
	LD	C, A
	RET

; ──────────────────────────────────────────────
; Чтение блока из ROM-диск в буфер
; ВХОД:
;	A	- номер блока (0-15)
; ВЫХОД:
; ИЗМЕНЯЕТ:
; ──────────────────────────────────────────────

ReadBlock:
	LD	BC, ROMBUF
	LD	L, 0
	LD	E, 080h
	OR	A					; SCF,CCF	; CY=0
	RRA						; A/2
	LD	H, A
	LD	D, A
	JP	NC, skip
	EX	DE, HL					; L<->E
	INC	D
skip:
	DEC	DE
	JP	DirectiveReadROM			; HL-начальный, DE-конечный, BC-целевой


	; SETSEC
	;	Set Sector.  Saves sector number from <BC>
	;		in @sect for further operations.

SetSec:							; 6 bytes
	ld l,c
	ld h,b
	ld (SECT), HL
	ret

	NOP
	NOP
	NOP
	NOP

; ──────────────────────────────────────────────
; Ввод строки в буфер COMBUF
; ВХОД:
;	Нет
; ВЫХОД:
;	COMBUF	- введенная строка
;	CY	- 1 - есть данные, 0 - пустая строка
; ИЗМЕНЯЕТ:
;	AF, DE, HL, BC
; ──────────────────────────────────────────────

	CHK	0F8EEH, "* Internal subroutine InputDirective shifted ! *"

InputDirective:
	LD	HL,COMBUF-2
	LD	(HL), COMBUFMAX	; Размер буфера
	EX	DE, HL

; ──────────────────────────────────────────────
; Ввод строки в буфер DE (CP/M совместимо)
; ВХОД:
;	DE	- адрес буфера
;	Буффер содержит структуру:
;		DB	?			; Размер буфера
;		DB	?			; Количество введенных символов
;		DB	(Размер буфера) DUP (?)	; Введенные данные
; ВЫХОД:
;	COMBUF	- введенная строка
;	CY	- 1 - есть данные, 0 - пустая строка
; ИЗМЕНЯЕТ:
;	AF, DE, HL, BC
; ──────────────────────────────────────────────

GETLIN2:
	PUSH	DE
	POP	HL
	LD	C, (HL)
	INC	HL
GotoCmdLineBegin:
	XOR	A
	LD	B, A			; B - счетчик введенных символов
	CALL	SET_RL			; Включить латинский регистр
InputNextSymbol:
	CALL	InputSymbol
	CP	7FH
	JP	Z,ProcessBackspace
	CP	03H
	JP	Z,WarmBoot
	INC	HL
	LD	(HL), A
	CALL	PrintCharFromA
	CP	0DH
	JP	Z,Enter
	INC	B			; Увеличим счетчик символов
	LD	A, C
	CP	B
	JP	NZ, InputNextSymbol	; SyntaxError
	LD	B, C			; Буфер кончился
Enter:
	INC	DE			; Адрес байта длины буфера
	EX	DE, HL
	LD	(HL), B
	INC	HL
	EX	DE, HL			; DE на выходе содержит адрес буфера
	LD	A, 0FFH			;
	ADD	A, B			; Установить флаг переполнения, если что-то ввели

	RET


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

DirectiveTransfer:
;	IF	(DirectiveFill & 0FF00H) <> (DirectiveTransfer & 0FF00H)
;		ERROR	"DirectiveGoto and DirectiveTransfer must be in same page"
;	ENDIF
	FJMP	3, DirectiveTransferROM

	NOP
	NOP
	NOP

; ──────────────────────────────────────────────
; Читает аргументы со второй позиции буфера команды в регистры HL, DE, BC
; Разделителями считаются ',' и ' '. Конец данных - CR
; ВХОД:
;	Нет
; ВЫХОД:
;	PAR_HL	- первый аргумент
;	PAR_DE	- первый аргумент, если один параметр в строке, иначе второй аргумент
;	PAR_BC	- третий аргумент
;	При ошибке разбора выходит в МОНИТОР
; ИЗМЕНЯЕТ:
;	AF, HL, DE, BC
; ──────────────────────────────────────────────

	CHK	0F92cH, "* Internal subroutine ParseParameters shifted ! *"

ParseParameters:
	LD	HL,PAR_HL	; Обнуляем параметры
	LD	DE,FLG_P2
	LD	C,0
	CALL	DirectiveFill

	LD	E, (COMBUF+1) & 0FFH; Второй символ в буфере ввода

	CALL	GET_HL
	LD	(PAR_HL),HL
	LD	(PAR_DE),HL
	RET	C
	LD	(FLG_P2),A

	CALL	GET_HL
	LD	(PAR_DE),HL
	RET	C

	CALL	GET_HL
	LD	(PAR_BC),HL
	RET	C
	JP	SyntaxError

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

DirectiveList:

	IF	(DirectiveTransfer & 0FF00H) <> (DirectiveList & 0FF00H)
		ERROR	"DirectiveTransfer and DirectiveList must be in same page"
	ENDIF

	FJMP	3, DirectiveListROM

; ──────────────────────────────────────────────
; Заполняет память с HL по DE байтом C
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
;	C	- байт для записи
; ВЫХОД:
;	HL	- конечный адрес
; ИЗМЕНЯЕТ:
;	AF, HL
; ──────────────────────────────────────────────

DirectiveFill:					; 7 bytes
	IF	(DirectiveFill & 0FF00H) <> (DirectiveTransfer & 0FF00H)
		ERROR	"DirectiveGoto and DirectiveTransfer must be in same page"
	ENDIF

	LD	(HL),C
	CALL	IncHLAndRetIfEqDE
	JP	DirectiveFill

; ──────────────────────────────────────────────

DirectiveInputTape:
	IF	(DirectiveInputTape & 0FF00H) <> (DirectiveTransfer & 0FF00H)
		ERROR	"DirectiveInputTape and DirectiveTransfer must be in same page"
	ENDIF
	LD	A,(FLG_P2)		; 46 bytes
	OR	A
	JP	Z,AFA91
	LD	A,E
	LD	(KNS_RD),A
AFA91:	CALL	TapeReadBlock

	CALL	PrintCRAndHexWordAndSpaceAndCRAndHexWordAndSpace
	EX	DE,HL

	PUSH	BC
	CALL	CalcChecksum
	CALL	PrintCRAndHexWordBCAndSpace
	POP	DE

	CALL	Compare_HL_DE
	RET	Z
	CALL	PrintCRAndHexWordDEAndSpace
SyntaxError:
	CALL	RST_18
	DB	'?'+80H
	JP	WarmBoot

; ──────────────────────────────────────────────
; Выполняет переход по адресу HL
; ВХОД:
;	HL	- адрес
; ВЫХОД:
;	НЕТ
; ИЗМЕНЯЕТ:
;	Не определено
; ОПИСАНИЕ:
;	В стеке содержится адрес WarmBoot
; ──────────────────────────────────────────────

DirectiveGoto:
	IF	(DirectiveGoto & 0FF00H) <> (DirectiveFill & 0FF00H)
		ERROR	"DirectiveGoto and DirectiveFill must be in same page"
	ENDIF
	JP	(HL)			; 1 bytes

; ──────────────────────────────────────────────

	NOP
	NOP
	NOP
	NOP

; ──────────────────────────────────────────────
; Сравнение значений HL и DE
; ВХОД:
;	HL	- первые число
;	DE	- второе число
; ВЫХОД:
;	Z	- числа совпадают
;	NZ	- числа не совпадают
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

	CHK	0F990H, "* Internal subroutine Compare_HL_DE shifted ! *"

Compare_HL_DE:
	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET

; ──────────────────────────────────────────────
; Считывает область памяти ROM-диска с HL по DE в адреса BC ОЗУ
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

DirectiveReadROM:					; 19 bytes
	IF	(DirectiveInputTape & 0FF00H) <> (DirectiveReadROM & 0FF00H)
		ERROR	"DirectiveInputTape and DirectiveReadROM must be in same page"
	ENDIF
; TODO Пустая директива R
;	JP	C, skipdefs
;	LD	HL, 0
;	LD	DE, 07ffh
;	LD	BC, BASE-0800H
skipdefs:
	LD	(PDB),HL
	LD	A,(PDA)
	LD	(BC),A
	INC	BC
	CALL	IncHLAndRetIfEqDE
	JP	skipdefs

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

DirectiveSearch:
	IF	(DirectiveSearch & 0FF00H) <> (DirectiveReadROM & 0FF00H)
		ERROR	"DirectiveReadROM and DirectiveSearch must be in same page"
	ENDIF
	FJMP	3, DirectiveSearchROM

; ──────────────────────────────────────────────

DirectiveCompare:
	IF	(DirectiveCompare & 0FF00H) <> (DirectiveFill & 0FF00H)
		ERROR	"DirectiveCompare and DirectiveFill must be in same page"
	ENDIF

	FJMP	3, DirectiveCompareROM

	NOP
	NOP
; ──────────────────────────────────────────────

	CHK	0F9B0H, "* Internal subroutine PrintCR shifted ! *"

PrintCR:
	CALL	RST_18
	DB	13,10 + 80H
	RET

DirectiveDump:
	IF	(DirectiveSearch & 0FF00H) <> (DirectiveDump & 0FF00H)
		ERROR	"DirectiveDump and DirectiveSearch must be in same page"
	ENDIF
	FJMP	3, DirectiveDumpROM

DirectiveModify:

	IF	(DirectiveSearch & 0FF00H) <> (DirectiveModify & 0FF00H)
		ERROR	"DirectiveModify and DrectiveSearch must be in same page"
	ENDIF

	FJMP	3, DirectiveModifyROM

; ──────────────────────────────────────────────
DIRTABLE:				; 23 bytes
	IF	(DIRTABLE & 0FF00H) <> (DirectiveDump & 0FF00H)
		ERROR	"DirectiveDump and DIRTABLE must be in same page"
	ENDIF

	DB	'C', DirectiveCompare & 0FFH
	DB	'D', DirectiveDump & 0FFH
	DB	'F', DirectiveFill & 0FFH
	DB	'G', DirectiveGoto & 0FFH
	DB	'I', DirectiveInputTape & 0FFH
	DB	'L', DirectiveList & 0FFH
	DB	'M', DirectiveModify & 0FFH
	DB	'O', DirectiveOutputTape & 0FFH
	DB	'R', DirectiveReadROM & 0FFH
	DB	'S', DirectiveSearch & 0FFH
	DB	'T', DirectiveTransfer & 0FFH
	DB	'U', DirectiveU & 0FFH
	DB	'Z', DirectiveStart & 0FFH
	DB	0

; ──────────────────────────────────────────────

DirectiveU:			; 15 bytes
	IF	(DirectiveGoto & 0FF00H) <> (DirectiveU & 0FF00H)
		ERROR	"DirectiveGoto and DirectiveU must be in same page"
	ENDIF
	LD	HL, 07E00H
	LD	DE, 07FFFH
	LD	BC, BASE-0200H
	CALL	DirectiveReadROM
	JP	BASE-0200H

; ──────────────────────────────────────────────
; Выполняет переход по адресу 07400H
; ВХОД:
; ВЫХОД:
;	НЕТ
; ИЗМЕНЯЕТ:
;	Не определено
; ОПИСАНИЕ:
;	В стеке содержится адрес WarmBoot
; ──────────────────────────────────────────────

DirectiveStart:
	IF	(DirectiveStart & 0FF00H) <> (DirectiveFill & 0FF00H)
		ERROR	"DirectiveStart and DirectiveFill must be in same page"
	ENDIF
	JP	BASE-03H

; ──────────────────────────────────────────────

DirectiveOutputTape:

	IF	(DIRTABLE & 0FF00H) <> (DirectiveOutputTape & 0FF00H)
		ERROR	"DirectiveOutputTape and DIRTABLE must be in same page"
	ENDIF
	FJMP	3, DirectiveOutputTapeROM


; ──────────────────────────────────────────────

AFF3B:	LD	A,L			; 23 bytes
	AND	2FH
	LD	L,A
AFF3F:	LD	A,L
	CP	40H
	POP	HL
	RET	P
	PUSH	HL
	LD	L,A
	AND	00FH
	CP	00CH
	LD	A,L
	JP	M,AFF50
	XOR	10H
AFF50:	POP	HL
	RET

; ──────────────────────────────────────────────
; Расчет контрольной суммы блока памяти с HL по DE
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
; ВЫХОД:
;	HL	- конечный адрес источника
;	BC	- контрольная сумма
; ИЗМЕНЯЕТ:
;	AF, BC, HL
; ──────────────────────────────────────────────

CalcChecksum:
	LD	BC,0			; 23 bytes
AFB19:	LD	A,(HL)
	ADD	A,C
	LD	C,A
	PUSH	AF
	CALL	Compare_HL_DE
	JP	Z,POPAF
	POP	AF
	LD	A,B
	ADC	A,(HL)
	LD	B,A
	CALL	IncHLAndRetIfEqDE
	JP	AFB19

; ──────────────────────────────────────────────
; Ввод символа без ожидания с проверкой нажатия Ctrl-C. 
; При нажатии Ctrl-C выход в МОНИТОР с переинцициализацией ВГ.
; ВХОД:
;	Нет
; ВЫХОД:
;	A=0FFH - не нажата
;	A=0FEH - РУС/ЛАТ
;	A - код клавиши
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

ReadKeyCodeChkBrk:
	CALL	ReadKeyCode			; 12 bytes
	CP	3
	RET	NZ
	CALL	InitVideo
	JP	SyntaxError

TapeWriteBlock:
	FJMP	4, TapeWriteBlockROM

SetDMA:						; 6 bytes
	ld l,c
	ld h,b
	ld (DMA), HL
	ret

SecTran:					; 11 bytes
	ld l,c
	ld h,b
	ld a,d
	or e
	ret z
	ex hl, de
	add hl,bc
	ld l,(hl)
	ld h,0
	ret

; ──────────────────────────────────────────────

TABK2:	DB	09,0AH,0DH,7FH,08H,19H,18H,1AH	; 8 bytes

Home:
	ld	bc, 0				; same as set track zero


	; SETTRK
	;	Set Track. Saves track address from <BC> 
	;		in @TRK for further operations.

SetTrk:
	ld	l,c
	ld	h,b
	LD	(TRK), HL
	RET

	DB	15H DUP (0)

	CHK	0FA68H, "* Internal subroutine ReadROM shifted ! *"
ReadROM:
	JP	DirectiveReadROM

ProcessBackspace:
	LD	A,B			; 15 bytes
	OR	A			; начало буфера ввода ?
	JP	Z,GotoCmdLineBegin	; GotoCmdLineBegin
	DEC	B
	DEC	HL
	CALL	RST_18
	DB	8,' ',8+80H
	JP	InputNextSymbol

; ──────────────────────────────────────────────

BYTE3:	LD	A, C			; 9 bytes
	SUB	20H-MARGIN_TOP
	LD	H, A
	LD	A, 3
	JP	SETESC

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	IF	0
BYTE3:	LD	A,C			; 18 bytes
	SUB	20H
	LD	C,A
AFD77:	DEC	C
	LD	A,3
	JP	M,SETESC
	PUSH	BC
	CALL	CursorDown
	POP	BC
	JP	AFD77
	endif

; ──────────────────────────────────────────────
; Увеличивает HL и вызывает второй RET, если равен DE
; При нажатии Brk выходит с ошибкой в МОНИТОР
; ВХОД:
;	HL	- текущий адрес
;	DE	- целевой адрес
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────
	SHARED	IncHLAndRetIfEqDEWithBrk
IncHLAndRetIfEqDEWithBrk:
	CALL	ReadKeyCodeChkBrk		; 11 bytes

; ──────────────────────────────────────────────
; Увеличивает HL и вызывает второй RET, если равен DE
; ВХОД:
;	HL	- текущий адрес
;	DE	- целевой адрес
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, HL
; ──────────────────────────────────────────────
	SHARED	IncHLAndRetIfEqDE
IncHLAndRetIfEqDE:
	CALL	Compare_HL_DE
	INC	HL
	RET	NZ
	DEC	HL
POPAF:	POP	AF
	RET
	

; ──────────────────────────────────────────────
; Ввод символа без ожидания. 
; ВХОД:
;	Нет
; ВЫХОД:
;	A=0FFH - не нажата
;	A=0FEH - РУС/ЛАТ
;	A - код клавиши
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

ReadKeyCode:
	LD	A,(PC)		; 30 bytes
	RLA
	LD	A,0FEH
	RET	NC
	XOR	A
	LD	(PA),A
	LD	A,(RUSLAT)
	AND	00000001B
	OR	00000110B	; зажигаем/гасим светодиод
	LD	(PU),A
	LD	A,(PB)
	INC	A
	JP	NZ,AFE97
	DEC	A
	RET

; ──────────────────────────────────────────────

TapeReadBlock:
	CALL	TapeReadWordSync
	PUSH	HL
	ADD	HL,BC
	EX	DE,HL
	CALL	TapeReadWordNoSync
	POP	HL
	ADD	HL,BC
	EX	DE,HL
	PUSH	HL
	CALL	LD_BLK
	CALL	TapeReadWordSync		; с поиском СБ
	POP	HL
	DB	06h		; LD B, ..

	IF	(RUSLAT & 0FFH) <> 6
		ERROR	"RUSLAT low byte must be 06h"
	ENDIF
SET_RL:	LD	(RUSLAT),A		; Т.к. адрес RUSLAT xx06h, то предыдущий трюк с LD B, .. повторится..

	CHK	0FACEH, "* Internal subroutine InitVideo shifted ! *"
InitVideo:			; 1001.0011
				; 1100.0011

	LD	A, (CURST)	; 99H - включен 0A9H - выключен
	PUSH	HL
	LD	HL,VG_75+1
	LD	(HL),0   	; reset command
	DEC	HL       	; адрес VG_75
	LD	(HL),04DH	; 0.1001101  77+1 знакомест
	LD	(HL),01DH	; 00.011101  29+1 строк

	LD	(HL),A		; 1001.1001  9 +1 линия подчерк.
				; 9+1 линий в знакоместе
	if	K_ORIG		;
	LD	(HL),093H
	else
	LD	(HL),0C3H
	endif

	INC	HL		; адрес VG_75+1
	LD	(HL),27H	; start display command
	LD	A,(HL)		; read status
AFAE1:	LD	A,(HL)		; read status
	AND	20H		; mask 'Interrupt request flag'
	JP	Z,AFAE1		; ждем конца строки
	LD	HL,VT_57+8
	LD	(HL),80H
	LD	L,4		; VT_57+04
	LD	(HL),SA & 00FFh ; 0D0H
	LD	(HL),SA>>8	; 076H/036H
	INC	L		; адрес VT_57+5
	LD	(HL),23H
	LD	(HL),49H
	LD	L,8		; VT_57+8
	LD	(HL),0A4H
	POP	HL
	RET

; ──────────────────────────────────────────────────────
; Ввод в HL HEX-число из строки по (DE) до CR
; ВХОД:
;	DE	- адрес строки
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, BС, DE, HL
; ──────────────────────────────────────────────

	SHARED	GET_HL
GET_HL:	LD	HL,0		; 48 bytes
AF95D:	LD	A,(DE)		; Выход: CY=1 если разделитель <ВК>
	INC	DE
	CP	13
	SCF
	RET	Z
	CP	','
	RET	Z
	CP	20H
	JP	Z,AF95D

	LD	BC,SyntaxError
	PUSH	BC

	SUB	'0'
	RET	C		; JP C,SyntaxError

	CP	9+1
	JP	C,AF982

	CP	'A'-'0'
	RET	C		; JP C,SyntaxError

	CP	'F'-'0'+1
	RET	NC		; JP NC,SyntaxError

	SUB	'A'-('9'+1)
AF982:
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	RET	C		; JP C,SyntaxError

	OR	L
	LD	L,A

	POP	AF
	JP	AF95D

; ──────────────────────────────────────────────

NO_ESC:	LD	A,C
	AND	7FH
	LD	C,A
	SUB	1FH		;CP	1FH
	JP	Z,ClearScreen
	ADD	A, 1FH-1BH	;CP	1BH
	JP	Z,EscapeHandlerStart
	INC	A		;CP	1AH
	JP	Z,CursorDown
	INC	A		;CP	19H
	JP	Z,CursorUp
	INC	A		;CP	18H
	JP	Z,CursorRight
	ADD	A, 18H-0DH	;CP	0DH
	JP	Z,COD_0D
	INC	A		;CP	0CH
	JP	Z,CursorHome
	ADD	A, 0CH-0AH	;CP	0AH
	JP	Z,LF
	INC	A		;CP	09H
	JP	NZ,skip_TAB

; ──────────────────────────────────────────────

TAB:	LD	A, L
	ADD	A, 8
	AND	11111000b
	LD	L, A
	RET

; ──────────────────────────────────────────────

TABK1:	DB	0CH,1FH,1BH,0,1,2,3,4,5	  ; 9 bytes

; ──────────────────────────────────────────────

AFEF3:	LD	A,H			; 7 bytes
	LD	HL,TABK1
	JP	AFEFE

	
; ──────────────────────────────────────────────
; Печать перевода строки, числа из HL в 16-ричном формате, пробела,
; перевода строки, числа из BC в 16-ричном формате, пробела
; ВХОД:
;	HL	- число для печати
;	BC	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B, DE, HL
; ──────────────────────────────────────────────

	SHARED	PrintCRAndHexWordAndSpaceAndCRAndHexWordAndSpace
PrintCRAndHexWordAndSpaceAndCRAndHexWordAndSpace:
	CALL	PrintCRAndHexWordAndSpace

; ──────────────────────────────────────────────
; Печать перевода строки, числа из BC в 16-ричном формате и пробела
; ВХОД:
;	BC	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B, DE, HL
; ──────────────────────────────────────────────

	SHARED	PrintCRAndHexWordBCAndSpace
PrintCRAndHexWordBCAndSpace:
	LD	D,B
	LD	E,C

; ──────────────────────────────────────────────
; Печать перевода строки, числа из DE в 16-ричном формате и пробела
; ВХОД:
;	DE	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B, DE, HL
; ──────────────────────────────────────────────

PrintCRAndHexWordDEAndSpace:
	EX	DE,HL

; ──────────────────────────────────────────────
; Печать перевода строки, числа из HL в 16-ричном формате и пробела
; ВХОД:
;	HL	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B
; ──────────────────────────────────────────────

	CHK	0FB78H, "* Internal subroutine PrintCRAndHexWordAndSpace shifted ! *"

PrintCRAndHexWordAndSpace:
	CALL	PrintCR

; ──────────────────────────────────────────────
; Печать числа из HL в 16-ричном формате и пробела
; ВХОД:
;	HL	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

PrintHexWordAndSpace:
	LD	A,H
	CALL	PrintHexByte
	LD	A,L
	JP	PrintHexByteAndSpace


; ──────────────────────────────────────────────

; ──────────────────────────────────────────────

KEY_FE:	LD	A,(PC)			; 17 bytes
	RLA
	JP	NC,KEY_FE		; ждём отпускания РУС/ЛАТ
	LD	A,(RUSLAT)
	CPL
	CALL	SET_RL
	JP	AFE1A


	NOP
	NOP


; ──────────────────────────────────────────────
; Загрузка A без поиска синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	A	- загруженный байт
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

TapeReadByteNoSync:
	LD	A,8

; ──────────────────────────────────────────────
; Загрузка A
; ВХОД:
;	A=008H	- без поиска синхробайта
;	A=0FFH	- с поиском синхробайта
; ВЫХОД:
;	A	- загруженный байт
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

TapeReadByte:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	D,A
AFB9C:	LD	A,80H
	LD	(VT_57+8),A

	LD	HL,0
	LD	C,L
	ADD	HL,SP
	LD	(TMPSTK),HL

	LD	SP,0
	LD	A,(PC)
	RRCA
	RRCA
	RRCA
	RRCA
	AND	1
	LD	E,A
AFBB7:	POP	AF
	LD	A,C
	AND	07FH
	RLCA
	LD	C,A
	LD	H,0
AFBBF:	DEC	H
	JP	Z,AFC34
	POP	AF		; Регенерация ОЗУ
	LD	A,(PC)
	RRCA
	RRCA
	RRCA
	RRCA
	AND	1
	CP	E
	JP	Z,AFBBF
	OR	C
	LD	C,A
	DEC	D
	LD	A,(KNS_RD)
	JP	NZ,AFBDC
	SUB	012H
AFBDC:	LD	B,A
AFBDD:	POP	AF		; Регенерация ОЗУ
	DEC	B
	JP	NZ,AFBDD
	INC	D
	LD	A,(PC)
	RRCA
	RRCA
	RRCA
	RRCA
	AND	001H
	LD	E,A
	LD	A,D
	OR	A
	JP	P,AFC0B
	LD	A,C
	CP	0E6H		; ПРЯМОЙ СИНХРО-БАЙТ ?
	JP	NZ,AFBFF
	XOR	A
	LD	(INV_MG),A	; ПРИЗНАК ИНВЕРСИИ МАГНИТОФОНА
	JP	AFC09

; ──────────────────────────────────────────────

AFBFF:	CP	19H		; ОБРАТНЫЙ С/БАЙТ
	JP	NZ,AFBB7	; 58 bytes
	LD	A,0FFH
	LD	(INV_MG),A 	; Tape inverse flag
AFC09:	LD	D,9
AFC0B:	DEC	D
	JP	NZ,AFBB7

	LD	HL,VT_57+4
	LD	(HL), SA & 00FFH		; 0D0H
	LD	(HL), SA >>8		; 076H/036H
	INC	HL
	LD	(HL),023H
	LD	(HL),049H
	LD	A,27H			; start display commando
	LD	(VG_75+1),A
	LD	A,0E0H			; reset count
	LD	(VG_75+1),A
	LD	L,8
	LD	(HL),0A4H

	LD	HL,(TMPSTK)
	LD	SP,HL

	LD	A,(INV_MG)
	XOR	C			; with Tape Inverse flag
	JP	POPREG

; ──────────────────────────────────────────────
; Запись байта C
; ВХОД:
;	C	- байт для записи
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────

TapeWriteByte:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF
	LD	A,80H
	LD	(VT_57+8),A
	LD	HL,0
	ADD	HL,SP		; временно храним стек
	LD	SP,0		; для регенерации
	LD	D,8
AFC58:	POP	AF
	LD	A,C
	RLCA
	LD	C,A
	LD	A,1
	XOR	C
	LD	(PC),A
	LD	A,(KNS_WR)
	LD	B,A
AFC66:	POP	AF
	DEC	B
	JP	NZ,AFC66
	XOR	A
	XOR	C
	LD	(PC),A
	DEC	D
	LD	A,(KNS_WR)
	JP	NZ,AFC7A
	SUB	14
AFC7A:	LD	B,A

AFC7B:	POP	AF		; подъем стека на [рег.B] ячеек
	DEC	B
	JP	NZ,AFC7B
	INC	D
	DEC	D
	JP	NZ,AFC58

	LD	SP,HL
	LD	HL,VT_57+4
	LD	(HL), SA & 00FFh	; 0D0H
	LD	(HL), SA >> 8	; 076H/036H
	INC	HL		; VT_57+5
	LD	(HL),23H
	LD	(HL),49H
	LD	A,27H		; start display command
	LD	(VG_75+1),A	; 001.sss.bb    001.001.11
	LD	A,0E0H		; сброс счетчиков строк и знакомест ???
	LD	(VG_75+1),A
	LD	L,8
	LD	(HL),0A4H	; VT_57+8
POPREGA:
	POP	AF
POPREG: POP	HL
	POP	DE
	POP	BC
	RET

; ──────────────────────────────────────────────
; Печать числа из A в 16-ричном формате
; ВХОД:
;	A	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

PrintHexByte:
	PUSH	AF			; 23 bytes
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	PrintHexNibble
	POP	AF

; ──────────────────────────────────────────────
; Печать числа из младшего нибла A в 16-ричном формате
; ВХОД:
;	A	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

PrintHexNibble:
	AND	0FH
	CP	10
	SBC	A,2FH
	DAA

; ──────────────────────────────────────────────
; Печать символа из A
; ВХОД:
;	A	- символ для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────

	SHARED	PrintCharFromA
PrintCharFromA:
	PUSH	BC		; 
	LD	C,A
	DB	06h		; LD B,..

; ──────────────────────────────────────────────
; Печать символа из C
; ВХОД:
;	C	- символ для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────

;BUG Для эмуляции VT-52 необходимо игнорировать код NUL (00H) и DEL (7FH). С последним проблеммы, т.к. в РК86 это квадрат.

PrintCharFromC:
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF

	CALL	GetKeyboardStatus
	LD	HL,TOBACK
	PUSH	HL
	LD	HL,(POSX)
	LD	A,(ESC_FL)
	DEC	A
	JP	M,NO_ESC	; BUG Для VT-52 факт обработки ESC-последовательности не значит, что он игнорирует контрольные коды
	JP	Z,EscapeHandler	; если второй байт ('Y')
	DEC	A
	JP	Z,BYTE3		; если третий байт
	LD	A,C		; четвёртый байт
	SUB	20H-MARGIN_LEFT
	LD	L,A
	JP	EscapeHandlerEnd
	IF	0
	LD	A,C		; четвёртый байт
	SUB	20H
	LD	C,A
AFCDD:	DEC	C
	JP	M,EscapeHandlerEnd         ; СБРОС ESC_FL И ВЫХОД
	PUSH	BC
	CALL	CursorRight
	POP	BC
	JP	AFCDD
	endif

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP


skip_TAB:
	INC	A		;CP	08H
	JP	Z,CursorLeft
	INC	A		;CP	07H
	JP	Z, Beep
	CALL	SetCursorPos
	LD	(HL),C		; Видимый на экране символ
	LD	HL,(POSX)

; ──────────────────────────────────────────────
; Перемещение курсора вправо
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	DE, HL, AF, BC
; ОПИСАНИЕ:
;	Курсор перемещается на одну позицию вправо. Если курсор был в конце
;	строки, то, в зависимости от флага переноса WRPFLG, он остается на
;	месте или перемещается на новую строку в первую позицию. Символы
;	на экране при перемещении курсора не стираются.
; ──────────────────────────────────────────────

CursorRight:
	LD	A, (WRPFLG);
	INC	A
	LD	A, MARGIN_LEFT+64
	JP	NZ, WRP
	CP	L		; последняя колонка ?
	RET	Z
WRP:	INC	L		; POSX ++
	CP	L		; последняя колонка ?
	RET	NZ
	LD	L,MARGIN_LEFT	; нач.позиция по X на новой строке

; ──────────────────────────────────────────────
; Перевод строки
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
; 	DE, HL, BC, AF
; ОПИСАНИЕ:
;	Курсор перемещается на одну строку вниз в ту же позицию.
;	Если курсор был на нижней строке, то он там и остается,
;	а содержимое экрана сдвигается вверх на одну строку.
;	Информация, находившаяся на первой строке экрана, теряется.
;	Снизу добавляется пустая строка.
; ──────────────────────────────────────────────

LF:	LD	A,H
	CP	MARGIN_TOP+24	; мы на последней строке ?
	JP	NZ, CursorDown	; если не на последней строке

	PUSH	HL		; РОЛИК ЭКРАНА
	LD	DE, SCBASE+78	; откуда
	LD	HL, SCBASE	; куда
	LD	BC, 26*78	; сколько
	CALL	MoveBlock	; МОНИТОР-1.20 использует DirectiveTransfer
	POP	HL
	RET
	
; ──────────────────────────────────────────────

AFEFA:	LD	A,H			; 32 bytes
	LD	HL,TABK2
AFEFE:	ADD	A,L
	LD	L,A
	LD	A,(HL)
	CP	40H
	POP	HL
AFF04:	RET	C
	PUSH	HL
AFF06:	LD	L,A
	LD	A,(PC)
	LD	H,A
	AND	40H
	JP	NZ,AFF1A
	LD	A,L
	CP	40H
	JP	M,AFF3F
	AND	1FH
	POP	HL
	RET

	NOP
	NOP
	NOP

	CHK	0FD27H, "* Standard subroutine Beep shifted ! *"

; ──────────────────────────────────────────────
; Подача звукового сигнала
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, BC
; ОПИСАНИЕ:
; ──────────────────────────────────────────────

Beep:	LD	BC,05F0H		; 20 bytes
SND_BC:	LD	A,B
BPLOO1:	EI
	DEC	A
	JP	NZ,BPLOO1
	LD	A,B
BPLOO2:	DI
	DEC	A
	JP	NZ,BPLOO2
	DEC	C
	JP	NZ,SND_BC
	RET

; ──────────────────────────────────────────────

AFEB3:	LD	L,20H			; 47 bytes
AFEB5:	LD	A,(PB)
	CPL
	OR	A
	JP	Z,AFEAF
	DEC	L
	JP	NZ,AFEB5
	LD	L,8
AFEC3:	DEC	L
	RLCA
	JP	NC,AFEC3
	LD	A,H
	LD	H,L
	LD	L,A
	CP	1
	JP	Z,AFEFA
	JP	C,AFEF3
	RLCA
	RLCA
	RLCA
	ADD	A,20H
	OR	H
	CP	5FH
	JP	NZ,AFF06
	LD	A,20H
	POP	HL
	RET

; ──────────────────────────────────────────────

AFE2A:	DEC	H			; в рег.A=код клав, в рег.H- COUNT
	JP	NZ,AFE21		; 39 bytes
	INC	A
	JP	Z,AFE22			; если код FF, то сброс флагов
	INC	A
	JP	Z,KEY_FE		; если код FE (RUSLAT)

	PUSH	BC			; КЛИК
	LD	BC,5003H
	CALL	SND_BC
	POP	BC

	LD	A,(APVFLG)
	LD	H,0E0H
	DEC	A
	LD	(APVFLG),A
	JP	Z,AFE4C
	LD	H,40H
AFE4C:	LD	A,0FFH
	JP	AFE22

; ──────────────────────────────────────────────

; После 15H вызовов GetKeyboardStatus при нажатой клавише выставляется флаг KBDFLG

GetKeyboardStatus:
	LD	A,(PC)		; 38 bytes
	RLA
	JP	NC,AFE0E	; если нажат RUS/LAT
	LD	A,(KBDFLG)
	OR	A
	RET	NZ		; если в SYMBUF уже есть символ
AFE0E:	PUSH	HL
	LD	HL,(LAST_K)
	CALL	ReadKeyCode
	CP	L
	LD	L,A
	JP	Z,AFE2A
AFE1A:	LD	A,1
	LD	(APVFLG),A
	LD	H,15H		; число опросов, чтобы зафиксировать код
AFE21:	XOR	A
AFE22:	LD	(LAST_K),HL
	POP	HL
	LD	(KBDFLG),A
	RET

; ──────────────────────────────────────────────

AFF1A:	LD	A,(RUSLAT)		; 33 bytes
	OR	A
	JP	Z,AFF2A
	LD	A,L
	CP	40H
	JP	M,AFF2A
	OR	20H
	LD	L,A
AFF2A:	LD	A,H
	AND	20H
	JP	NZ,AFF3F
	LD	A,L
	CP	40H
	JP	M,AFF3B
	LD	A,L
	XOR	20H
	POP	HL
	RET


; ──────────────────────────────────────────────

AFC34:	LD	HL,(TMPSTK)		; 18 bytes
	LD	SP,HL
	CALL	InitVideo
	LD	A,D
	OR	A
	JP	P,SyntaxError
	CALL	ReadKeyCodeChkBrk
	JP	AFB9C

; ──────────────────────────────────────────────
; Печать с новой строки знаение HL в 16-м формате, пробела и
; числа из ячейки памяти HL в 16-м формате и пробела
; ВХОД:
;	HL	- адрес байта числа для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────
	SHARED	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace
PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace:
	CALL	PrintCRAndHexWordAndSpace			; 12 bytes

; ──────────────────────────────────────────────
; Печать числа из ячейки памяти HL в 16-м формате и пробела
; ВХОД:
;	HL	- адрес байта числа для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

	SHARED	PrintHexByteFromMemAndSpace
PrintHexByteFromMemAndSpace:
	LD	A,(HL)

; ──────────────────────────────────────────────
; Печать числа из A в 16-м формате и пробела
; ВХОД:
;	A	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

	SHARED	PrintHexByteAndSpace
PrintHexByteAndSpace:
	CALL	PrintHexByte

; ──────────────────────────────────────────────
; Печать пробела
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	A
; ──────────────────────────────────────────────

PrintSpace:
	LD	A,20H
	JP	PrintCharFromA



; ──────────────────────────────────────────────
; Ввод символа с ожиданием. 
; ВХОД:
;	Нет
; ВЫХОД:
;	A - введенный символ
; ИЗМЕНЯЕТ:
;	AF		 TODO: проверить, что изменяет GetKeyboardStatus
; ──────────────────────────────────────────────

InputSymbol:				; 15 bytes
	CALL	GetKeyboardStatus
	OR	A
	JP	Z,InputSymbol
	XOR	A
	LD	(KBDFLG),A
	LD	A,(LAST_K)
	RET




; ──────────────────────────────────────────────
; Обработчик ESC-последовательности
; ВХОД:
;	C=ESC-код
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B, DE, HL
; ОПИСАНИЕ:
;	Поддерживаемые ESC-последовательности:
;		ESC A	- Cursor Up
;		ESC B	- Cursor Down
;		ESC C	- Cursor Right
;		ESC D	- Cursor Left
;		ESC E	- Clear screen (GEMDOS/TOS extension)
;		ESC H	- Cursor Home
;		ESC I	- Reverse Line Feed
;		ESC J	- Erase to End Of Screen
;		ESC K	- Erase to End Of Line
;		ESC L	- Insert line (not VT52)
;		ESC M	- Delete line (not VT52)
;		ESC Y	- Direct Cursor Addressing
;		ESC a	- Disable cursor (M/80K extension)
;		ESC b	- Enable cursor(M/80K extension)
;		ESC e	- Enable cursor (GEMDOS/TOS extension)
;		ESC f	- Disable cursor(GEMDOS/TOS extension)
;		ESC j	- Save cursor (GEMDOS/TOS extension)
;		ESC k	- Restore cursor(GEMDOS/TOS extension)
;		ESC v	- Wrap off (GEMDOS/TOS extension)
;		ESC w	- Wrap on (GEMDOS/TOS extension)
;	Здесь используется немного нестандартная схема выбора обработчика.
;	Обработчики не вызываются для каждого символа отдельно, а встроены
;	непосредственно в логику ветвления. Для этого символ в A
;	уменьшаетя на величину 'w' (максимальный управляющий символ).
;	После чего происходит для каждого символа увеличение на дельту.
;	По JP NZ осуществляется обход кода обработчика, если он нам не нужен.
;	Сам обработчик должен обеспечить только, чтобы регистр A на выходе
;	был меньше, чем 0A0H. Тогда не будет фальш-сработок. При вызове обработчика
;	будет осущетсвляться перебор и обход кода всех обработчисков и в конце будет
;	возврат через EscapeHandlerEnd. Такой метод позволит сэкономить на команде
;	RET для каждого обработчика. Если использовать таблицы, то каждый вызов
;	потребует 3 байта в таблице+RET+код обработки таблицы. Здесь же каждый
;	обработчик потребует 4 байта. Т.е. экономия на размер обработчика таблицы
; ──────────────────────────────────────────────

EscapeHandler:
	LD	A,C
	PUSH	HL
	LD	HL, EscapeHandlerEnd
	EX	(SP), HL
	SUB	'w'		;CP	'w'
	JP	NZ, skip_ESC_w

; ──────────────────────────────────────────────
; Включить автоперенос строки
; ВХОД:
;	E=POSX, D=POSY
;	HL=экранный адрес
; ВЫХОД:
;	E=POSX, D=POSY
;	HL=экранный адрес
; ИЗМЕНЯЕТ:
;	HL, DE, AF, BC
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
WrapOn:	; XOR	A Тут уже 0
	LD	(WRPFLG), A

skip_ESC_w:
	INC	A		;CP	'v'
	JP	NZ, skip_ESC_v

; ──────────────────────────────────────────────
; Выключить автоперенос строки
; ВХОД:
;	E=POSX, D=POSY
;	HL=экранный адрес
; ВЫХОД:
;	E=POSX, D=POSY
;	HL=экранный адрес
; ИЗМЕНЯЕТ:
;	HL, DE, AF, BC
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
WrapOff:
	DEC	A		; LD A, 0FFh Тут 0 на входе
	LD	(WRPFLG), A

skip_ESC_v:
	ADD	A, 'v'-'k'	;CP	'k'
	JP	NZ, skip_ESC_k

; ──────────────────────────────────────────────
; Восстановить сохраненные координаты курсора
; ВХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ВЫХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ИЗМЕНЯЕТ:
;	HL
; ──────────────────────────────────────────────
CursorRestore:
	LD	HL, (XYSTOR)

skip_ESC_k:
	INC	A		;CP	'j'
	JP	NZ, skip_ESC_j

; ──────────────────────────────────────────────
; Сохранить текущие координаты курсора
; ВХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ВЫХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────
CursorSave:
	LD	(XYSTOR), HL

skip_ESC_j:
	ADD	A, 'j'-'f'	;CP	'f'
	JP	NZ, skip_ESC_f

; ──────────────────────────────────────────────
; Скрыть курсор  (ESC+f)
; ВХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ВЫХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────
CursorDisable:
	LD	A, 0A9H
	LD	(CURST), A
	CALL	InitVideo

skip_ESC_f:
	INC	A		;CP	'e'
	JP	NZ, skip_ESC_e

CursorEnable:
; ──────────────────────────────────────────────
; Отобразить курсор (ESC+e)
; ВХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ВЫХОД:
;	L - X координата курсора
;	H - Y координата курсора
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────
	LD	A, 099H
	LD	(CURST), A
	CALL	InitVideo

skip_ESC_e:
	ADD	A, 'e'-'b'	;CP	'b'
	JP	Z, CursorEnable

	INC	A		; CP	'a'
	JP	Z, CursorDisable

	ADD	A, 'a'-'Y'	;CP	'Y'
	JP	NZ, skip_ESC_Y

	;esc_Y
;	CALL	CursorHome
	NOP
	NOP
	POP	BC		; Убираем из стека EscapeHandlerEnd, возвращаемся только на TOBACK
	INC	A		;LD	A,2; ПРИНЯТО 2 БАЙТА ESC,'Y'

; ──────────────────────────────────────────────
; Запуск обработчика ESC-символа
; ВХОД:
;	A=0
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B
; ──────────────────────────────────────────────

EscapeHandlerStart:
	INC	A		; LD A, 1 - для EscapeHandlerStart и LD A, 2 - для EscapeHAndler
	DB	06H		; LD B, ... функционально JP SETESC

; ──────────────────────────────────────────────
; Завершение обработки ESC-последовательности
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

EscapeHandlerEnd:
	XOR	A		; LD A, 0

; ──────────────────────────────────────────────
; Установить режим обработки ESC-последовательности
; ВХОД:
;	A=режим
;		0 - завершить обработку последовательности
;		1 - обработка кода ESC-последовательности
;		2 - обработка первого символа Y-последовательности
;		3 - обработка второго символа Y-последовательности
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Нет
; ──────────────────────────────────────────────

SETESC:	LD	(ESC_FL),A
	RET

skip_ESC_Y:
	ADD	A, 'Y'-'M'	;CP	'M'
	JP	NZ, skip_ESC_M

; ──────────────────────────────────────────────
; Удалить строку
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	HL
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
DeleteLine:

skip_ESC_M:
	INC	A		;CP	'L'
;	JP	NZ, skip_ESC_L

; ──────────────────────────────────────────────
; Вставить строку
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	HL
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
InsertLine:
	JP	Z, RLDN

skip_ESC_L:
	INC	A		;CP	'K'
	JP	NZ, skip_ESC_K

; ──────────────────────────────────────────────
; Очистка от курсора до конца строки
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	AF
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
ClearEOL:
	PUSH	HL
KLOOP:	CALL	PrintSpace
	CALL	GetCursorPos
	LD	A, L
	CP	MARGIN_LEFT+63		; последняя колонка
	JP	NZ, KLOOP
	POP	HL

skip_ESC_K:
	INC	A		;CP	'J'
	JP	NZ, skip_ESC_J

; ──────────────────────────────────────────────
; Очистка до конца экрана
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	AF, BC
; ОПИСАНИЕ:
; ──────────────────────────────────────────────
ClearEOS:
	PUSH	HL
	;PUSH	DE
	;LD	H, A		;LD	H, 0
	CALL	SetCursorPos
CLSLOO:	XOR	A
	LD	(HL),A
	INC	HL
	OR	H
	JP	P,CLSLOO
	;POP	DE
	POP	HL

skip_ESC_J:
	INC	A		;CP	'I'
	JP	NZ, skip_ESC_I

; ──────────────────────────────────────────────
; Обратный перевод строки
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	HL, DE, AF, BC
; ОПИСАНИЕ:
;	Курсор перемещается вверх на одну строку в ту же позицию. Если
;	курсор был на самой верхней строке, то он не перемещается, но
;	вся информация на экране перемещается вниз на одну строку.
;	Информация с нижней строки теряется, а сверху добавляется новая
;	пустая строка.
; ──────────────────────────────────────────────

RLF:	LD	A,H
	CP	MARGIN_TOP	; это первая строка ?
	JP	NZ,CursorUp	; если не на первой строке

RLDN:
	PUSH	HL
	LD	A, 27
	SUB	H
	CALL	CALC
	LD	DE, SCBASE+24*78-1
	LD	BC, SCBASE+25*78-1
RLFLOOP:
	LD	A, (DE)
	LD	(BC), A
	DEC	BC
	DEC	DE
	DEC	HL
	LD	A, H
	OR	L
	JP	NZ, RLFLOOP
	LD	(POSX), A
	JP	KLOOP

skip_ESC_I:
	INC	A		;CP	'H'
	JP	Z, CursorHome
	ADD	A, 'H'-'E'	;CP	'E'
	JP	NZ, skip_ESC_E

; ──────────────────────────────────────────────

ClearScreen:
	LD	H,A
	LD	L,A
	CALL	ClearEOS
CursorHome:
	LD	HL, MARGIN_TOP << 8 +MARGIN_LEFT
skip_ESC_E:
	INC	A		;CP	'D'
	JP	NZ, skip_ESC_D

; ──────────────────────────────────────────────
; Перемещение курсора влево
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	AF, HL, DE
; ОПИСАНИЕ:
;	Курсор перемещается на одну позицию влево. Если курсор в начале строки, то
;	он не перемещается. Символ на экране не стирается.
; ──────────────────────────────────────────────

CursorLeft:
	LD	A,L		; 7 bytes
	CP	MARGIN_LEFT
	JP	Z, skip_ESC_D
	DEC	L		; POSX--

skip_ESC_D:
	INC	A		;CP	'C'
	JP	Z, CursorRight

	INC	A		;CP	'B'
	JP	NZ, skip_ESC_B

; ──────────────────────────────────────────────
; Перемещение курсора вниз
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;
; ОПИСАНИЕ:
; 	Курсор перемещается вниз на одну строку в ту же
;	позицию. Если курсор находится внизу экрана, то
;	курсор остается на той же позиции и скролинг
;	не осуществляется.
; ──────────────────────────────────────────────

CursorDown:
	LD	A,H
	CP	MARGIN_TOP+24	; последняя строка ?
	RET	Z
	INC	H		; POSY++

skip_ESC_B:
	INC	A		; CP	'A'
	RET	NZ

; ──────────────────────────────────────────────
; Перемещение курсора вверх
; ВХОД:
;	L=POSX, H=POSY
; ВЫХОД:
;	L=POSX, H=POSY
; ИЗМЕНЯЕТ:
;	HL, DE, BC, AF
; ОПИСАНИЕ:
;	Курсор перемещается вверх на одну строку в ту же позицию. Если курсор
;	находится в самом верху, то он не перемещается.
; ──────────────────────────────────────────────

CursorUp:
	LD	A,H		; 10 bytes
	CP	MARGIN_TOP	; это первая строка ?
	RET	Z
	DEC	H		; POSY--
	RET

; ──────────────────────────────────────────────
; Возвращает в HL координаты курсора
; ВХОД:
;	Нет
; ВЫХОД:
;	H - Y
;	L - X
; ИЗМЕНЯЕТ:
;	HL
; ──────────────────────────────────────────────

GetCursorPos:
	LD	HL,(POSX)		; 4 bytes
	RET

; ──────────────────────────────────────────────
; Устанавливает курсор в заданные координаты
; ВХОД:
;	H	- номер строки
;	L	- номер позиции
; ВЫХОД:
;	HL	- адрес курсора
; ИЗМЕНЯЕТ:
;	HL
; ──────────────────────────────────────────────

SetCursorPos:
	LD	(POSX),HL

	PUSH	AF
	PUSH	DE		;ЗАПОМНИТЬ 
	PUSH	BC		;РЕГИСТРЫ 

	; Выставляем курсор
	LD	A,80H
	LD	(VG_75+1),A
	LD	A,L
	LD	(VG_75),A
	LD	A,H
	LD	(VG_75),A

	; Вычисляем адрес видеопамяти
	LD	C, L		;ВС КООРДИНАТУ X
	LD	A, H		;В А КООРДИНАТУ Y
	CALL	CALC
PROD:	LD	DE, SA		; ЗАГРУЗИТЬ АДРЕС
	ADD	HL, DE		; КООРДИНАТ 0. 0.
	LD	B, 0		; СЛОЖИТЬ С АДРЕСОМ НАЧАЛА
	ADD	HL, BC		; И ПРИБАВИТЬ X
	POP	BC		; ВОССТАНОВИТЬ
	POP	DE		; РЕГИСТРЫ
	POP	AF
	RET

CALC:
	INC	A
	LD	DE, 78		;В DE ДЛИНУ СТРОКИ
	LD	HL, -78;0	;ВЫЧИСЛЕНИЕ
;	OR	A 		;АДРЕСА ПО
S1:;	RET	Z		;ФОРМУЛЕ:
	ADD	HL, DE		;АДРЕС=78*Y
	DEC	A
	JP	NZ,S1
	RET

; ──────────────────────────────────────────────
; Первичная инициализация МОНИТОРа
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	Не определено
; ──────────────────────────────────────────────

ColdBoot:
	LD	HL,BASE
	LD	SP,HL

	LD	A,8AH
	LD	(PU),A
	
	LD	C,L			; LD C, 0
	LD	DE,COMBUF+COMBUFMAX-1
	CALL	DirectiveFill

	LD	HL, BASE-1
	LD	(RAMTOP),HL

	LD	A, 099H
	LD	(CURST), A
	CALL	InitVideo

	CALL	RST_18
	DB	1Fh,"radio-86r",'k' + 80H

	LD	HL,1D2AH
	LD	(KNS_RD),HL

	; Инициализируем доп ППА
	LD	A,90H
	LD	(PDU),A

	; Проверяем наличие ROM-диска (4-ый байт содержит CDH)
	LD	HL, 3
	LD	(PDB),HL
	LD	A,(PDA)
	CP	0CDH

	JP	NZ, WarmBoot

	FJMP	0, INITBDOS

; ──────────────────────────────────────────────

TOBACK:					; 6 bytes
	CALL	SetCursorPos
	JP	POPREGA

; ──────────────────────────────────────────────
; BC bytes DE->HL
; ──────────────────────────────────────────────
MoveBlock:				; 11 bytes
	LD	A, (DE)
	LD	(HL), A
	INC	HL
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ, MoveBlock
	RET

; ──────────────────────────────────────────────
; Блок эмуляции точек входа BIOS и BDOS
; ──────────────────────────────────────────────
	ORG	0FF70H
	SHARED	BIOSENTRY
BIOSENTRY:
	JP	ColdBoot		; CBOOT Холодный старт
	JP	WarmBoot		; WBOOT Теплый старт
	JP	GetKeyboardStatus	; CONST Статус консоли
	JP	InputSymbol		; CONIN Консольный ввод
	JP	PrintCharFromC		; CONOUT Консольный вывод
	JP	PrintCharFromC		; LIST Печать на принтер. это д.быть PRINT
	JP	TapeWriteByte		; PUNCH/AUXOUT Вывод не перфоратор/магнитофон
	JP	TapeReadByte		; READER/AUXIN Ввод данных с перволенты/магнитофона
	JP	Home			; HOME		;21: Перемещение головки на позицию 0
	JP	0			; SELDSK	;24: Выбор привода
	JP	SetTrk			; SETTRK	;27: Выбор дорожки
	JP	SetSec			; SETSEC	;30: Выбор сектора
	JP	0			; SETDMA	;33: Set DMA address
	JP	0			; READ		;36: Read a sector
	JP	0			; WRITE		;39: Write a sector
	LD	A,0FFH			; LISTST	;42: Status of list device
	RET
	JP	SecTran			; SECTRAN	;45: Sector translation for skewing
	DB	0,0,0			; CONOST	;48: Status of console output
	DB	0,0,0			; AUXIST	;51: Status of auxiliary input
	LD	A,0FFH			; AUXOST	;54: Status of auxiliary output
	RET
	JP	0			; DEVTBL	;57: Address of devices table
	DB	0,0			; DEVINI	;60: Initialise a device
	RET
	JP	0			; DRVTBL	;63: Address of discs table
	JP	0			; MULTIO	;66: Read/write multiple sectors
	JP	0			; FLUSH		;69: Flush host buffers
	JP	MoveBlock		; MOVE		;72: Move a block of memory
	JP	0			; TIME		;75: Real time clock
	DB	0,0,0			; SELMEM	;78: Select memory bank
	DB	0,0,0			; SETBNK	;81: Select bank for DMA operation
	DB	0,0,0			; XMOVE		;84: Preload banks for MOVE
	DB	0,0			; USERF		;87: System-depedent functions
	RET
	JP	0			; RESERV1	;90: Reserved
	JP	0			; RESERV2	;93: Reserved
BIOSENTRYEND:

	SHARED	FARJZ
FARJZ:	EX	(SP), HL
	INC	HL
	INC	HL
	EX	(SP), HL
	RET	NZ
	EX	(SP), HL
	DEC	HL
	DEC	HL
	EX	(SP), HL

	SHARED	FARJMP
FARJMP:	
	EX	(SP), HL		; Сохраняем HL в стек, а в HL адрес возврата
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	A, (HL)			; Номер блока
	INC	HL
	LD	B, (HL)
	LD 	H, ROMBUF>>8
	LD 	L, B			; Адрес перехода
	LD	(PAR_HL), HL
	CALL	ReadBlock		; Считываем блок c ROM-диска
	LD	HL, (PAR_HL)
	POP	DE
	POP	BC
	POP	AF
	EX	(SP), HL		; Восстанавливаем значение HL, а адрес перехода помещеам в стек
	RET				; Вызываем считанную функцию

; ──────────────────────────────────────────────
; Точка вызова функции BDOS
; ──────────────────────────────────────────────
	SHARED	BDOS
BDOS:	FJMP	1, BDOSENTRY		; 5 bytes

; ──────────────────────────────────────────────
; Точка возврата из функции BDOS
; ──────────────────────────────────────────────
	SHARED	BDOSRET
BDOSRET:				; Точка возврата из функции BDOS
	LD	HL, (TMPSTK)		; 7 bytes
	LD	SP, HL
	LD	L, A
	LD	H, B
	RET

	CHK	10000H, "* Size not 2K ! *"

	END
