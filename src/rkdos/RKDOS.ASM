RKDOS.ASM.xlist
; TODO: Планируется выбросить кое-какие вещи и запользовать их
; из МОНИТОРа, используя "псевдостандартные" точки входа.
; Возможно, дополнить поддержкой РОМ-Диска.
; ОРИГИНАЛ и самый простой варианта адаптации RKDOS для Z80

; Там где надо менять помечено ***
; Там где забит принтер отмечено ^^^
; Ошибка Е.Седова помечена ### и исправлена

	.Z80
	aseg
	ORG	100H

include	ROM.INC

W_OUT	EQU	1		; если не 0, то транслируется полный оригинал
ORD	EQU	0		; если не 0, то создаётся ORD-файл

if	ROM
	RKDOS	EQU     0E000H
    else
	RKDOS	EQU     06000H		; 0B000H
endif

PORT    EQU	0F000H
KBDPPA	EQU	8000H
DOPPPA	EQU	0A000H	; 0F100H	; при печати на принтере портится упр-е 8400
VG75	EQU	0C000H

NTRKS	equ	160
WPRMSK  EQU	8
RDYMSK  EQU	10H
TR0MSK  EQU	20H
IDXMSK  EQU	40H
           	
STACK	EQU	076CFH

BASE	EQU	7500H
DRIVE   EQU     BASE+40H
OPDRV   EQU     BASE+41H
TTRK    EQU     BASE+42H
TSKT    EQU     BASE+43H
BEGS    EQU     BASE+44H
LENGTS  EQU     BASE+46H
KS      EQU     BASE+48H
Y754A   EQU     BASE+4AH
ERRORS  EQU     BASE+4BH
NWR	EQU	BASE+4CH
NRD     EQU     BASE+4DH
TCAT    EQU     BASE+4EH
FLAG    EQU     BASE+50H	; флаг разрешения шаблонов имён
BREAK   EQU     BASE+51H
ADRNM   EQU     BASE+53H
ADBUF   EQU     BASE+55H
ENDNAM  EQU     BASE+57H
FLEXT   EQU     BASE+59H	; флаг, что в имени было расширение
SPCDIR  EQU     BASE+5AH
SPCTRK  EQU     BASE+5CH
SPCSKT  EQU     BASE+5DH
BOOTA   EQU     BASE+5EH
BOOTV   EQU     BASE+60H
RIPERR  EQU     BASE+62H
KANALW  EQU     BASE+64H
OPKANW  EQU     BASE+66H
KANALR  EQU     BASE+68H
OPKANR  EQU     BASE+6AH
Y756C   EQU     BASE+6CH
CLOFLG  EQU     BASE+6EH	; close file flag, =FF if close, or =OPDRV
Y756F   EQU     BASE+6FH
Y7571   EQU     BASE+71H
Y7573   EQU     BASE+73H
Y7575   EQU     BASE+75H
Y7577   EQU     BASE+77H
Y7579   EQU     BASE+79H
Y757B   EQU     BASE+7BH
Y757D   EQU     BASE+7DH
Y757F   EQU     BASE+7FH
Y7581   EQU     BASE+81H
Y7583   EQU     BASE+83H
Y7585   EQU     BASE+85H
Y7587   EQU     BASE+87H
Y7589   EQU     BASE+89H
Y758A   EQU     BASE+8AH
Y758B   EQU     BASE+8BH
KSTRT   EQU     BASE+8CH
BATF    EQU     BASE+8DH
NPOS    EQU     BASE+8FH
BEGFL   EQU     BASE+90H
ENDFL   EQU     BASE+92H
Y7594   EQU     BASE+94H
MEMTOP	equ	BASE+0C0H		; RAMTOP

CONIN   EQU     0F803H
COUT    EQU     0F809H
MSSG    EQU     0F818H
STAT	EQU	0F812H

;────────────────────────────────────────────

if	ORD	
if	W_OUT
	defb	'RKD_ORIG'
    else
	defb	'RKDOSNEW'
endif
	DW	000,LENGTH,000,000
endif

	.phase	RKDOS

;────────────────────────────────────────────
; "Холодный" старт ДОС
;────────────────────────────────────────────
	XOR	A

;────────────────────────────────────────────
; Вызов функций ДОС
; 13 байт
;────────────────────────────────────────────

BDOS:	PUSH	HL
	LD	HL, ATABLE
	ADD	A, A
	ADD	A, L
	LD	L, A
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	EX	(SP), HL
	RET	

;────────────────────────────────────────────
; Таблица адресов функций
; 90 байт
;────────────────────────────────────────────
ATABLE:	DW	START		; Холодный старт
	DW	START2		; Теплый старт
	DW	VHOD2		; Запуск CCP
	DW	DIR		; Вывод каталога диска
	DW	TYPE		; Вывод файла
	DW	SAVE		; Запись файла
	DW	LOAD		; Чтение файла
	DW	OPFREE		; Очистка буферов
	DW	WRSKT		; Запись сектора
	DW	RDSKT		; Чтение сектора
	DW	OPWR		; Подготовка файла к записи
	DW	OPRD		; Подготовка файла к чтению
	DW	KANR		; Открытие канала на чтение
	DW	KANW		; Открытие канала на запись
	DW	SAVE2		; Запись файла на диск после подготовки к записи
	DW	LOCVT		; Резервирование сектора
	DW	CMP_3B		; Сравнение трех символов в памяти
	DW	FRSVT		; Освобождение сектора
	DW	DELF		; Удаление файла
	DW	RDCAT		; Чтение карты диска и первого каталога
	DW	RCAT		; Чтение последующего каталога
	DW	ANSTR		; Поиск первой записи в каталоге
	DW	ANEXT		; Поиск последующей записи в каталоге
	DW	CONTLD		; Чтение файла с диска после подготовки к чтению
	DW	KOMM		; Поиск первого файла на лиске
	DW	KOM2		; Поиск последующего файла на диске
	DW	SELBUF		; Запрос области памяти
	DW	FREBUF		; Освобождение области памяти
	DW	RAMTOP		; Запрос верхней границы памяти
	DW	OPENR		; Открыть файл на чтение
	DW	OPENW		; Открыть файл на запись
	DW	APPEND		; Открыть файл на дозапись
	DW	READ		; Считать один байт
	DW	WRITE		; Записать один байт
	DW	CLOSER		; Закрыть файл, открытый на чтение
	DW	CLOSEW		; Закрыть файл, открытый на запись
	DW	INKAN		; Ввод байта из канало
	DW	OUTKAN		; Вывод байта в канал
	DW	PUSK		; Выбрать диск
	DW	OSTANOV		; Освободить диск
	DW	COPYING		; Копирование блока памяти
	DW	ERRMAN		; Обработка ошибок
	DW	ADDRES		; Получение следующего адреса программы
	DW	LD1		; Загрузка
	DW	BX3		; Запуск команды
	
;────────────────────────────────────────────

START:	LD	HL, OUTCON
	LD	(KANALW), HL
	
	LD	HL, AECF9
	LD	(KANALR), HL
	
if	W_OUT
	LD	HL, PRNOUT		; ^^^
    else
	LD	HL,COUT
endif
	LD	(Y7594), HL
	
	LD	HL, TITR
	CALL	MSSG
	
	LD	(DRIVE), A 
	DEC	A
	LD	(CLOFLG), A
	LD	(Y7579), A
	
	CALL	AE178
	
	LD	A, 82H

if	W_OUT
	OUT	(0F3H),	A		; ***
    else
	LD      (PORT+3),A
endif

	CALL	PUSK
	CALL	TRACK0
START2:	LD	SP, STACK

	CALL	AE178
	
	LD	B, 40H
	LD	H, -40H + high BASE	; 35H
	CALL	FREBUF
	
	LD	HL, KSTRT
	LD	A, 0DDH
	LD	(RIPERR), A
	CP	(HL)
	LD	(HL), A
	LD	HL, T_AUTO
	JP	NZ, RUN
	
	XOR	A
	LD	(FLAG), A	; флаг разрешения шаблонов имён
	
	LD	A, (DRIVE)
	ADD	A, 'A'
	LD	C, A
	CALL	COUT
	LD	C, '>'
	CALL	COUT
VHOD2:	CALL	GETLIN
	CALL	OUT_13
	LD	HL, BASE
BX3:	CALL	USTDRV
	JP	NZ, AE0D9
	LD	A, C
	LD	(DRIVE), A
AE0D9:	LD	A, (HL)
	CP	13
	RET	Z
	CP	2EH
	RET	Z
	LD	DE, CMDTBL
	LD	BC, 7
	CALL	ANSTR
	JP	Z, RUN
	LD	C, 5
	EX	DE, HL
	ADD	HL, BC
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	JP	(HL)

;────────────────────────────────────────────

RUN:	CALL	USTDRV
	CALL	POISK
AE0FB:	CP	4		; 'FILE NOT FOUND'
	JP	Z, PR_ERN
	LD	(ENDNAM), HL
	EX	DE, HL
	LD	C, 0BH
	CALL	AEBD4
	LD	A, (DE)
	CP	2EH
	JP	NZ, AE11C
	INC	DE
	PUSH	HL
	CALL	CMP_3B
	EX	DE, HL
	LD	(ENDNAM), HL
	POP	HL
	JP	NZ, AE13D
AE11C:	PUSH	HL
	LD	DE, T_COM
	CALL	CMP_3B
	POP	HL
	JP	Z, RUNCOM
	PUSH	HL
	LD	DE, TSYS
	CALL	CMP_3B
	POP	DE
	SCF	
	JP	Z, BATSYS
	EX	DE, HL
	LD	DE, TBAT
	CALL	CMP_3B
	JP	Z, BATSYS
AE13D:	LD	C, 21
	CALL	AEBD4
	EX	DE, HL
	LD	HL, (ADBUF)
	CALL	AE538
	JP	AE0FB

;────────────────────────────────────────────

RUNCOM:	CALL	LD1
	JP	AE172

;────────────────────────────────────────────

BATSYS:	PUSH	AF		; Вход: если CY=1 то SYS, иначе BAT
	CALL	OPFREE
	LD	HL, (ADBUF)
	LD	(BATF), HL
	INC	B
	CALL	SELBUF
	POP	AF
	PUSH	HL
	JP	NC, RUNCCP
	CALL	LD1
	JP	AE171

;────────────────────────────────────────────

RUNCCP:	LD	HL, CCPNAM
	CALL	OPRD
AE171:	POP	HL
AE172:	PUSH	HL
	CALL	CONTLD
ADDRES:	POP	HL
	JP	(HL)

;────────────────────────────────────────────

AE178:	LD	HL, START2
	LD	(BREAK), HL
	EX	(SP), HL
	PUSH	HL
	JP	DONEOK

;────────────────────────────────────────────

DIR:	LD	A, 1
	LD	(FLAG), A	; флаг разрешения шаблонов имён
	EX	DE, HL
	CALL	AE4D1
	CP	4
	LD	BC, 0
	JP	Z, AE1E9
	LD	A, (HL)
	CP	13
	JP	Z, AE1A2
	CP	2CH
	INC	HL
	PUSH	BC
	CALL	Z, KANW
	POP	BC
AE1A2:	INC	BC
	PUSH	BC
	LD	C, 14H
	CALL	AEBD4
	LD	A, (HL)
	AND	40H
	JP	NZ, AE1E0
	CALL	OUT2SP
	LD	A, (HL)
	RLA	
	LD	C, 20H
	JP	NC, AE1BB
	LD	C, 2AH
AE1BB:	CALL	OUTKAN
	LD	HL, (ADRNM)
	LD	B, 0AH
	CALL	MSSGN
	CALL	OUT2SP
	INC	HL
	LD	B, 3
	CALL	MSSGN
	CALL	OUT2SP
	LD	BC, 4
	ADD	HL, BC
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	CALL	PR_DEC
	CALL	OUT_13
AE1E0:	CALL	KOM2
	POP	BC
	CP	4
	JP	NZ, AE1A2
AE1E9:	PUSH	BC
	LD	HL, T_WK
	LD	B, 8
	CALL	MSSGN
	EX	(SP), HL
	CALL	PR_DEC
	CALL	OUT2SP
	LD	B, 13
	POP	HL
	CALL	MSSGN
	LD	HL, (BOOTV)
	LD	DE, 0
AE205:	LD	B, 5
	LD	A, (HL)
AE208:	RRCA	
	JP	C, AE20D
	INC	DE
AE20D:	DEC	B
	JP	NZ, AE208	; DJNZ
	INC	L
	LD	A, L
	CP	NTRKS
	JP	C, AE205
	EX	DE, HL
	CALL	PR_DEC
	JP	DONEOK

;────────────────────────────────────────────

MSSGN:	LD	A, (HL)
	OR	A
	LD	C, 20H
	JP	Z, AE227
	LD	C, A
AE227:	CALL	OUTKAN
	INC	HL
	DEC	B
	JP	NZ, MSSGN	; DJNZ
	RET	

;────────────────────────────────────────────

TYPE:	EX	DE, HL
	CALL	KANR
	LD	HL, (ENDNAM)
	LD	A, (HL)
	CP	2CH
	JP	NZ, TYPE1
	INC	HL
	CALL	KANW
TYPE1:	CALL	INKAN
	INC	B
	DEC	B
	JP	NZ, DONEOK
	LD	C, A
	CALL	OUTKAN
	JP	TYPE1

;────────────────────────────────────────────

SAVE:	EX	DE, HL
	CALL	AE605
	CALL	OPWR
	PUSH	BC
	PUSH	HL
	CALL	AE8A0
	CP	13
	LD	A, 5
	JP	NZ, PR_ERN
SAVE2:	CALL	CMPDH
	LD	A, 5
	JP	NC, PR_ERN
	EX	DE, HL
	PUSH	HL
	CALL	RAMTOP
	DEC	HL
	CALL	CMPDH
	JP	C, AE285
	EX	DE, HL
	EX	(SP), HL
	EX	DE, HL
	CALL	CMPDH
	LD	A, 5
	jp	c, PR_ERN
	jp	AE29E

;────────────────────────────────────────────

AE285:	LD	HL, STACK
	CALL	CMPDH
	LD	A, 5
	JP	NC, PR_ERN
	EX	DE, HL
	EX	(SP), HL
	EX	DE, HL
	LD	HL, 7FFFH
	CALL	CMPDH
	LD	A, 5
	JP	C, PR_ERN
AE29E:	POP	HL
	EX	DE, HL
	CALL	HLSUBD
	INC	HL
	EX	(SP), HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	INC	HL
	POP	BC
	EX	(SP), HL
	PUSH	HL
	LD	HL, 1
	PUSH	HL
	PUSH	BC
	PUSH	DE
	CALL	WRSKT
	OR	A
	JP	NZ, PR_ERN
	LD	HL, (BOOTA)
	EX	DE, HL
	LD	B, 6
	CALL	FILL_0
	POP	HL
	POP	DE
	POP	BC
AE2C5:	INC	BC
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL, 200H
	CALL	CMPDH
	JP	C, AE2D3
	EX	DE, HL
AE2D3:	
	LD	(LENGTS), HL
	CALL	LOCVT
	LD	HL, (BOOTA)
	CALL	AE815
	POP	HL
	PUSH	HL
	CALL	AE374
	POP	DE
	LD	HL, (LENGTS)
	EX	DE, HL
	ADD	HL, DE
	EX	(SP), HL
	CALL	HLSUBD
	LD	A, H
	OR	L
	JP	Z, AE2F9
	EX	DE, HL
	POP	HL
	POP	BC
	JP	AE2C5

;────────────────────────────────────────────

AE2F9:	POP	AF
	LD	HL, 512
	LD	(LENGTS), HL
	POP	DE
	POP	BC
	LD	A, B
	PUSH	AF
	PUSH	DE
	LD	HL, (BOOTA)
	CALL	AE374
	LD	HL, (TCAT)
	LD	C, L
	LD	B, H
	LD	HL, (BOOTA)
	PUSH	BC
	CALL	RD_BC
	POP	BC
	POP	DE
	POP	AF
	POP	HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	LD	DE, 0FFFCH
	ADD	HL, DE
	LD	(HL), A
	LD	HL, (BOOTA)
	CALL	AE374
	CALL	WRVTOC
DONEOK:	XOR	A
OP_RET:	LD	(ERRORS), A
	ld	a, (DRIVE)
	ld	(OPDRV), a
	call	CLOSEW
	call	CLOSER
	ld	hl, (KANALW)
	LD	(OPKANW), HL
	LD	HL, (KANALR)
	LD	(OPKANR), HL
	CALL	OSTANOV
	CALL	OUT_13
OPFREE:	LD	HL, (BOOTV)
	LD	B, 1
	CALL	FREBUF
	LD	HL, (BOOTA)
	LD	B, 2
FREBUF:
	LD	A, H
	LD	H, HIGH BASE	; 75H
	SUB	H
	LD	L, A
	LD	C, H
AE361:	LD	(HL), C
	INC	L
	DEC	B
	JP	NZ, AE361	; DJNZ
	RET	

;────────────────────────────────────────────

WRVTOC:	LD	HL, NTRKS
	LD	(LENGTS), HL
	
	LD	HL, (BOOTV)
	LD	BC, 0020H
AE374:	PUSH	BC
	EX	(SP), HL
	LD	(TTRK), HL
	EX	(SP), HL
	LD	(BEGS), HL
	CALL	WRSKT
	POP	BC
	OR	A
	RET	Z
	CP	1
	JP	NZ, PR_ERN
	LD	HL, (BOOTV)
	LD	E, C
	LD	D, H
	PUSH	BC
	PUSH	DE
	LD	BC, 0020H
	CALL	RD_BC
	POP	HL
	POP	BC
	INC	A
AE398:	DEC	B
	JP	M, AE3A0
	RLCA	
	JP	AE398

;────────────────────────────────────────────

AE3A0:	OR	(HL)
	LD	(HL), A
	CALL	WRVTOC
	INC	A
	JP	PR_ERN

;────────────────────────────────────────────

OPWR:	XOR	A
	LD	(SPCDIR), A
	LD	(SPCDIR+1), A
	CALL	KOMM
	CP	4
	JP	NZ, AE3E1
	LD	HL, (SPCDIR)
	LD	A, H
	OR	L
	JP	NZ, AE3CA
	LD	A, B
	OR	C
	LD	A, 6
	JP	Z, PR_ERN
	JP	AE3EE

;────────────────────────────────────────────

AE3CA:	LD	HL, (SPCTRK)
	LD	(TCAT), HL
	LD	B, H
	LD	C, L
	LD	HL, (BOOTA)
	CALL	RD_BC
	LD	HL, (SPCDIR)
	LD	(ADRNM), HL
	JP	AE3EE

;────────────────────────────────────────────

AE3E1:	LD	A, (FLEXT)
	CP	2EH
	LD	A, 7
	JP	NZ, PR_ERN
	CALL	DELF
AE3EE:	LD	HL, (ADRNM)
	EX	DE, HL
	LD	HL, (ADBUF)
	CALL	AE841
	INC	HL
	EX	DE, HL
	LD	C, 0EH
	CALL	AEBD4
	CALL	LOCVT
	LD	(HL), C
	INC	HL
	LD	(HL), 0FFH
	INC	HL
	RET	

;────────────────────────────────────────────

LOAD:	EX	DE, HL
	CALL	AE605
	CALL	OPRD
CONTLD:	LD	(BEGFL), HL
AE412:	LD	A, (DE)
	LD	C, A
	INC	DE
	LD	A, (DE)
	LD	B, A
	OR	C
	JP	Z, DONEOK
	INC	DE
	PUSH	DE
	PUSH	HL
	CALL	RD_BC
	LD	HL, (LENGTS)
	POP	DE
	ADD	HL, DE
	DEC	HL
	LD	(ENDFL), HL
	INC	HL
	POP	DE
	JP	AE412

;────────────────────────────────────────────

; считывает T/S LIST на (BOOTA)
; ВЫХОД:	HL= адрес загрузки
;		DE= указывает на первый сектор из списка
;		BC= длина файла (в секторах)

OPRD:	CALL	KOMM
	CP	4
	JP	Z, PR_ERN
LD1:    LD      C,14		; смещение до трека/сектора T/S_LIST
	CALL	AEBD4		; прибавить к (ADRNM) регистр C
	LD      C,(HL)
	INC	HL
	LD      B,(HL)		; BC= сектор T/S LIST
	INC	HL
	LD      E,(HL)
	INC	HL
	LD      D,(HL)		; DE= адрес загрузки
	INC	HL
	PUSH	DE		; +1 адрес загрузки
	LD      A,(HL)
	INC	HL
	LD      H,(HL)
	LD	L,A		; HL= длина файла (в секторах) 
	EX	(SP),HL		; +1 длина файла (в секторах)
	PUSH	HL		; +2 HL= адрес загрузки
	LD      HL,(BOOTA)
	PUSH	HL		; +3 (BOOTA)
	CALL	RD_BC		; читаем T/S LIST
	POP	DE		; +2 DE= (BOOTA) T/S LIST
	INC	DE
	INC	DE		; указывает на первый сектор из списка
	POP	HL		; +1 HL= адрес загрузки
	POP	BC		; BC= длина файла (в секторах)
	RET

;────────────────────────────────────────────

KANR:	LD	A, 1
	LD	(FLEXT), A
	CALL	SKIP
	PUSH	HL
	LD	DE, TCON
	CALL	CMP_3B
	POP	DE
	JP	NZ, AE475
	LD	(ENDNAM), HL
	LD	HL, AECF9
	LD	(OPKANR), HL
	RET	

;────────────────────────────────────────────

AE475:	EX	DE, HL
	LD	A, (FLAG)	; флаг разрешения шаблонов имён
	PUSH	AF
	CALL	OPENR
	LD	HL, READ
	LD	(OPKANR), HL
	POP	AF
	LD	(FLAG), A
	RET	

;────────────────────────────────────────────

KANW:	LD	(FLEXT), A
	CALL	SKIP
	PUSH	HL
	LD	DE, TCON
	CALL	CMP_3B
	POP	DE
	JP	NZ, AE4A4
	LD	HL, OUTCON
	LD	(OPKANW), HL
	XOR	A
	LD	(Y754A), A
	RET	

;────────────────────────────────────────────

AE4A4:	EX	DE, HL
	PUSH	HL
	LD	DE, TPRN
	CALL	CMP_3B
	POP	HL
	JP	NZ, AE4BE
	LD	HL, (Y7594)
	LD	(OPKANW), HL
	
	LD	HL, 0A003H
	LD	(HL), 81H
	LD	(HL), 0FH
	RET	

;────────────────────────────────────────────

AE4BE:	LD	A, (FLAG)	; флаг разрешения шаблонов имён
	PUSH	AF
	CALL	OPENW
	LD	HL, 0EAA0H
	LD	(OPKANW), HL
	POP	AF
	LD	(FLAG), A
	RET	

;────────────────────────────────────────────

KOMM:	XOR	A
AE4D1:	LD	(FLEXT), A
	CALL	USTDRV
	LD	A, (HL)
	CP	13
	JP	Z, AE4E2
	CP	','
	JP	NZ, AE4F4
AE4E2:	LD	A, (FLEXT)
	OR	A
	LD	A, 5
	JP	Z, PR_ERN
	PUSH	HL
	LD	HL, TJOKER
	CALL	AE4F4
	POP	HL
	RET	

;────────────────────────────────────────────

AE4F4:	CALL	POISK
AE4F7:	CP	4
	RET	Z
	CP	'.'
	LD	(FLEXT), A
	LD	(ENDNAM), HL
	RET	NZ
	INC	HL
	LD	BC, 0BH
	EX	DE, HL
	ADD	HL, BC
	CALL	ANEXT
	JP	Z, AE51E
KOM2:	LD	C, 21
	CALL	AEBD4
	EX	DE, HL
	LD	HL, (ADBUF)
	CALL	AE538
	JP	AE4F7

;────────────────────────────────────────────

AE51E:	EX	DE, HL
	LD	(ENDNAM), HL
	XOR	A
	RET	

;────────────────────────────────────────────

POISK:	LD	(ADBUF), HL
	PUSH	HL
	CALL	RDCAT
	POP	HL
AE52C:	PUSH	HL
	LD	HL, (BOOTA)
	LD	BC, 0007
	ADD	HL, BC
	EX	DE, HL
	POP	HL
	LD	C, 21		; BC=21 шаг поиска
AE538:	CALL	ANSTR
	EX	DE, HL
	LD	(ADRNM), HL
	EX	DE, HL

;	LD      (ADRNM),DE	; заменяет предыдущие строки

	RET	NZ
	PUSH	HL
	LD	HL, (BOOTA)
	LD	BC, 1FEH
	ADD	HL, BC
	CALL	CMPDH
	POP	HL
	LD	A, 4
	RET	NC
	PUSH	HL
	CALL	RCAT
	POP	HL
	OR	A
	JP	Z, AE52C
	RET	

;────────────────────────────────────────────

RDCAT:  LD      B,2		; считать VTOC на (BOOTV)
	CALL    SELBUF		; и первый сектор каталога на (BOOTA)
	LD	(BOOTA), HL
	
	CALL	PUSK
	
	LD	B, 1
	CALL	SELBUF
	LD	(BOOTV), HL
	
	LD	BC, 0020H
	CALL	RD_BC		; читаем VTOC на (BOOTV)
	
	LD	BC, 0120H	; сектор начала каталога
	CALL	STTCAT          ; LD (TCAT),BC          
	
	LD	HL, (BOOTA)
RD_BC:				; BC=TRK/SEC,  HL= куда читать
	PUSH	BC		
	EX	(SP),HL
	LD      (TTRK),HL
	POP	HL		; вернуть HL
	
;	LD      (TTRK),BC	; это заменяет предыдуший фрагмент

	LD      (BEGS),HL
	
	CALL	RDSKT
	RET	Z
PR_ERN:	LD	B, A
ERRMAN:	PUSH	BC
	CALL	OSTANOV
	LD	HL, ERRMSG
	LD	C, B
AE592:	DEC	C
	JP	Z, AE59E
AE596:	CP	(HL)
	INC	HL
	JP	NZ, AE596
	JP	AE592

;────────────────────────────────────────────

AE59E:	LD	A, (RIPERR)
	OR	A
	JP	Z, AE5AB
	CALL	OUT_13
	CALL	MSSG
AE5AB:	DEC	A
	LD	(CLOFLG), A
	LD	(Y7579), A
	LD	B, 40H
	LD	H, -40H + high BASE	; 35H
	CALL	FREBUF
	POP	BC
	LD	A, B
	JP	AE5BF

;────────────────────────────────────────────

AE5BE:	XOR	A
AE5BF:	CALL	OP_RET
	LD	HL, (BREAK)
	JP	(HL)

;────────────────────────────────────────────

RCAT:	CALL	PUSK
	LD	HL, (BOOTA)
	CALL	AE5D8
	OR	A
	RET	NZ
STTCAT:	LD	HL, TCAT
	LD	(HL), C
	INC	HL
	LD	(HL), B
	RET	

;────────────────────────────────────────────

AE5D8:	LD	C, (HL)
	INC	HL
	LD	A, (HL)
	LD	B, A
	OR	C
	LD	A, 4
	RET	Z
	DEC	HL
	PUSH	BC
	CALL	RD_BC
	POP	BC
	RET	

;────────────────────────────────────────────

USTDRV:	CALL	SKIP		; установить OPDRV по имени ф.в строке
	LD	A, (HL)
	SUB	'A'
	LD	C, A		; N привода файла, если указан
	JP	Z, AE5F3
	DEC	A
	RET	NZ
AE5F3:	INC	HL
	LD	A, (HL)
	CP	':'
	DEC	HL
	RET	NZ
	LD	A, C
	LD	(OPDRV), A
	INC	HL
	INC	HL
	PUSH	HL
	CALL	PUSK
	POP	HL
	RET	

;────────────────────────────────────────────

AE605:	LD	A, (HL)
	CP	20H
	LD	A, 5
	JP	NZ, PR_ERN
SKIP:	LD	A, (HL)
	CP	20H
	RET	NZ
	INC	HL
	JP	SKIP

;────────────────────────────────────────────

GETLIN:	LD	HL, BASE

	XOR	A
	LD	(Y754A), A
	LD	E, A		; счётчик введённых символов
	
TE61D:	LD	BC, TE61D
	PUSH	BC
	CALL	INKAN
	LD	C, A
	CP	20H
	JP	C, UPRKOD
	LD	A, E
	CP	61		; 3DH если достигнут конец буфера
	RET	NC		; это JMP TE61D
	LD	(HL), C
	INC	HL
	INC	E
	JP	OUTKAN

;────────────────────────────────────────────

UPRKOD:	CP	8
	JP	NZ, AE647
	INC	E
	DEC	E
	RET	Z
	DEC	E
	DEC	HL
	PUSH	HL
	LD	HL, TZABOJ
	CALL	MSSG
	POP	HL
	RET	

;────────────────────────────────────────────

AE647:	CP	13
	JP	NZ, AE650
	LD	(HL), A
	JP	AE653

;────────────────────────────────────────────

AE650:	DEC	B
	RET	NZ
	POP	BC
AE653:	POP	BC
	LD	A, 1
	LD	(Y754A), A
	RET	

TZABOJ:	DEFB	8,32,8,0            

;────────────────────────────────────────────

ANSTR:	PUSH	HL
	PUSH	DE
	LD	A, (DE)
	INC	A
	JP	NZ, ANSTR1
	EX	DE, HL
	LD	(SPCDIR), HL
	LD	HL, (TTRK)
	LD	(SPCTRK), HL
	JP	TO_NXT

;────────────────────────────────────────────

ANSTR1:	DEC	A
	JP	NZ, ANSTR2
	POP	DE
	POP	HL
	RET	

;────────────────────────────────────────────

ANSTR2:	EX	DE, HL
	PUSH	BC
	LD	C, 10		; длина имени
	CALL	ANSTR3
	POP	BC
	EX	DE, HL
	JP	NZ, TO_NXT
	POP	DE
	POP	AF
	LD	A, (HL)
	OR	A
	RET	

;────────────────────────────────────────────

TO_NXT:	POP	HL
	POP	DE
	ADD	HL, BC
	EX	DE, HL
	JP	ANSTR

;────────────────────────────────────────────

; Возврат с CY=0, если допустимый для имени символ

IS_LET:	CP	40H
	ret	nc
	cp	':'
	ccf	
	RET	C
	CP	'0'
	RET	

;────────────────────────────────────────────

ANEXT:	LD	C, 3
ANSTR3:	LD	B,0		; C= длина строки сравнения
	PUSH	DE		; B это указатель по строке
ANLOOP:	LD	A, (HL)
	CALL	IS_LET
	JP	C, GROUP
	LD	A, (DE)
	CALL	IS_LET
	JP	C, AE6CB
	CP	(HL)
	JP	Z, AE6C2
	LD	A, B
	CP	'*'
	JP	NZ, AE70A
	POP	DE
	PUSH	DE
	INC	DE
	LD	A, (DE)
	CP	(HL)
	JP	Z, AE6C2
	DEC	DE
	INC	C
AE6C2:	DEC	C
	JP	Z, AE70F
	INC	HL
	INC	DE
	JP	ANLOOP

;────────────────────────────────────────────

AE6CB:	LD	A, (FLAG)	; флаг разрешения шаблонов имён
	OR	A
	JP	Z, AE6ED
	LD	A, (DE)
	CP	'?'
	JP	NZ, AE6E1
	LD	A, B
	CP	2AH
	JP	NZ, AE6C2
	JP	AE6E8

;────────────────────────────────────────────

AE6E1:	CP	'*'
	JP	NZ, AE6ED
	DEC	HL
	LD	B, A
AE6E8:	POP	AF
	PUSH	DE
	JP	AE6C2

;────────────────────────────────────────────

AE6ED:	LD	A, B
	CP	'*'
	JP	NZ, AE70A
	POP	DE
	PUSH	DE
	JP	AE6C2

;────────────────────────────────────────────

AE6F8:	INC	DE
GROUP:	LD	A, (DE)
	CALL	IS_LET
	JP	NC, AE70A
	CP	'*'
	JP	Z, AE6F8
	CP	'?'
	JP	NZ, AE724
AE70A:	POP	AF		; это заменяется на JP BADPOP
	LD	A, 1
	OR	A
	RET	

;────────────────────────────────────────────

AE70F:	LD	A, (DE)
	CALL	IS_LET
	JP	NC, AE720
	CP	2AH
	JP	Z, AE720
	CP	3FH
	JP	NZ, AE724
AE720:	INC	DE
	JP	AE70F

;────────────────────────────────────────────

AE724:	POP	AF
	XOR	A
	RET	

;────────────────────────────────────────────

OUT2SP:	LD	C, 20H
	CALL	AE72C
AE72C:	JP	OUTKAN

;────────────────────────────────────────────

CMP_3B:	LD	C, 3
CMPLOO:	LD	A, (DE)
	CP	(HL)
	RET	NZ
	INC	HL
	INC	DE
	DEC	C
	JP	NZ, CMPLOO
	RET	

;────────────────────────────────────────────

PR_DEC:	LD	DE, 100
	LD	B, D
	CALL	AE749
	LD	E, 10
	CALL	AE749
	LD	E, 1
AE749:	LD	C, D
AE74A:	CALL	CMPDH
	JP	C, AE757
	CALL	HLSUBD
	INC	C
	JP	AE74A

;────────────────────────────────────────────

AE757:	LD	A, C
	OR	B
	JP	NZ, AE75E
	DEC	E
	RET	NZ
AE75E:	LD	A, C
	LD	B, 30H
	OR	B
	LD	C, A
	PUSH	BC
	CALL	OUTKAN
	POP	BC
	RET	

;────────────────────────────────────────────

LOCVT:	PUSH	HL		; найти своб.сектор и занять во VTOC
	LD	HL, (BOOTV)
AE76D:	XOR	A
	LD	B, A
	INC	A
AE770:	LD	C, A
	AND	(HL)
	JP	Z, AE789
	INC	B
	LD	A, C
	ADD	A, A
	CP	20H		; была ошибка: 14H ###
	JP	C, AE770
	INC	L
	LD	A, L
	CP	NTRKS
	JP	C, AE76D
	LD	A, 6		; 'DISK FULL'
	JP	PR_ERN

;────────────────────────────────────────────

AE789:	LD	A, C
	OR	(HL)
	LD	(HL), A
	LD	C, L
	POP	HL
	RET	

;────────────────────────────────────────────

FRSVT:	PUSH	HL
	PUSH	BC
	LD	HL, (BOOTV)
	LD	L, C
	LD	A, 0FEH
AE797:	DEC	B
	JP	M, AE79F
	RLCA	
	JP	AE797

;────────────────────────────────────────────

AE79F:	AND	(HL)
	LD	(HL), A
	POP	BC
	POP	HL
	RET	

;────────────────────────────────────────────

DELF:	LD	HL, (ADRNM)
	LD	A, (HL)
	LD	(HL), 0FFH
	LD	BC, 0AH
	ADD	HL, BC
	LD	(HL), A
	LD	C, 14H
	CALL	AEBD4
	LD	A, (HL)
	RLA	
	LD	A, 8
	JP	C, PR_ERN
	LD	BC, 0FFFAH	;-6
	ADD	HL, BC
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	INC	B
	PUSH	AF
	DEC	B
	PUSH	BC
	LD	HL, (TCAT)
	LD	B, H
	LD	C, L
	LD	HL, (BOOTA)
	CALL	AE374
	POP	BC
	POP	AF
	RET	Z
	JP	AE7DA

;────────────────────────────────────────────

AE7D7:	LD	C, (HL)
	INC	HL
	LD	B, (HL)
AE7DA:	PUSH	BC
	LD	HL, (BOOTA)
	PUSH	HL
	CALL	RD_BC
	POP	HL
	INC	HL
	INC	HL
AE7E5:	LD	C, (HL)
	INC	HL
	LD	A, (HL)
	LD	B, A
	OR	C
	JP	Z, AE803
	INC	HL
	CALL	FRSVT
	LD	A, (BOOTA+1)
	INC	A
	CP	H
	JP	NC, AE7E5
	POP	BC
	CALL	FRSVT
	LD	HL, (BOOTA)
	JP	AE7D7

;────────────────────────────────────────────

AE803:	POP	BC
	CALL	FRSVT
	CALL	WRVTOC
	LD	HL, (TCAT)
	LD	B, H
	LD	C, L
	LD	HL, (BOOTA)
	JP	RD_BC

;────────────────────────────────────────────

AE815:	LD	D, H
	LD	E, L
	INC	D
	INC	D
	DEC	DE
	DEC	DE
	INC	HL
AE81C:	INC	HL
	CALL	CMPDH
	JP	C, AE825
	ADD	A, H
	RET	

;────────────────────────────────────────────

AE825:	LD	A, (HL)
	INC	HL
	OR	(HL)
	JP	NZ, AE81C
	DEC	HL
	LD	(HL), C
	INC	HL
	LD	(HL), B
	INC	HL
	LD	(HL), A
	INC	HL
	LD	(HL), A
	RET	

;────────────────────────────────────────────

FILL_0:	XOR	A
AE835:	LD	(DE), A
	INC	DE
	DEC	B
	JP	NZ, AE835
	RET	

;────────────────────────────────────────────

COPYING:LD	B, 14
	JP	AE843

AE841:	LD	B, 21
AE843:	PUSH	DE
	CALL	FILL_0
	POP	DE
	CALL	AE859
	CP	'.'
	RET	Z
	CP	2CH
	RET	Z
	CP	13
	RET	Z
	LD	A, 5
	JP	PR_ERN

;────────────────────────────────────────────

AE859:	PUSH	DE
	LD	C, 10
	CALL	AE86D
	LD	A, (HL)
	CP	2EH
	POP	DE
	RET	NZ
	LD	BC, 0BH
	EX	DE, HL
	ADD	HL, BC
	EX	DE, HL
	LD	C, 3
	INC	HL
AE86D:	LD	A, (HL)
	CALL	IS_LET
	RET	C
	LD	(DE), A
	INC	DE
	inc	hl
	DEC	C
	JP	NZ, AE86D
AE879:	LD	A, (HL)
	CALL	IS_LET
	RET	C
	INC	HL
	JP	AE879

;────────────────────────────────────────────

GETHEX:	LD	HL, 0
AE885:	LD	A, (DE)
	INC	DE
	CALL	IS_LET
	RET	C
	CP	47H
	RET	NC
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	SUB	30H
	CP	0AH
	JP	C, AE89B
	SUB	7
AE89B:	OR	L
	LD	L, A
	JP	AE885

;────────────────────────────────────────────

AE8A0:	CALL	GETHEX
	CP	2CH
	RET	NZ
	PUSH	HL
	CALL	GETHEX
	EX	DE, HL
	POP	HL
	RET	

;────────────────────────────────────────────

SELBUF:	LD	HL, BASE+100H		; 7600H
	LD	C, L
AE8B1:	PUSH	BC
AE8B2:	DEC	HL
	LD	A, L
	CP	0C0H
	LD	A, 12		; 'NO MEMORY'
	JP	C, PR_ERN
	LD	A, C
	OR	(HL)
	JP	Z, AE8CF
	DEC	B
	JP	NZ, AE8B2
	POP	BC
	PUSH	HL
	CALL	AE361
	POP	HL
AE8CA:	LD	A, L
	ADD	A, H
	LD	H, A
	LD	L, C
	RET
		
;────────────────────────────────────────────

AE8CF:	POP	BC
	JP	AE8B1

;────────────────────────────────────────────

RAMTOP:	LD	HL, MEMTOP
	LD	C, 0
AE8D8:	LD	A, C
	CP	(HL)
	jp	z, AE8CA
	inc	l
	jp	nz, AE8D8
	jp	AE8CA

;────────────────────────────────────────────

OPENR:	LD	A, (CLOFLG)
	INC	A
	LD	A, 10
	JP	NZ, PR_ERN
	LD	B, H
	LD	C, L
	CALL	PUTPRM
	LD	H, B
	LD	L, C
	
	XOR	A
	LD	(FLAG), A	; флаг разрешения шаблонов имён
	
	CALL	OPRD
	EX	DE, HL
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	INC	HL
	PUSH	BC
	LD	(Y7571), HL
	LD	HL, (BOOTA)
	LD	(Y756C), HL
	LD	B, 1
	LD	HL, (BOOTV)
	CALL	FREBUF
	LD	B, 2
	CALL	SELBUF
	LD	(Y7573), HL
	LD	(Y756F), HL
	POP	BC
	CALL	RD_BC
	
	LD	HL, (LENGTS)
	LD	(Y7575), HL
	
	LD	A, (OPDRV)
	LD	(CLOFLG), A
	CALL    VOSST		; не JMP !!!!
	JP	OSTANOV

;────────────────────────────────────────────

READ:	LD	A, (CLOFLG)
	INC	A
	LD	A, 0BH
	JP	Z, PR_ERN
	LD	HL, (Y7573)
	EX	DE, HL
	LD	HL, (BASE+75H)
	ADD	HL, DE
	EX	DE, HL
	LD	HL, (Y756F)
	CALL	CMPDH
	JP	C, AE9AD
	CALL	PUTPRM
	LD	HL, (Y7571)
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	INC	HL
	LD	A, B
	OR	C
	JP	NZ, AE963
	CALL    VOSST		; не JMP !!!!
	LD	B, 9
	RET	

;────────────────────────────────────────────

AE963:	PUSH	BC
	PUSH	HL
	LD	A, (CLOFLG)
	LD	(OPDRV), A
	CALL	PUSK
	POP	DE
	LD	HL, (Y756C)
	LD	BC, 1FFH
	ADD	HL, BC
	CALL	CMPDH
	EX	DE, HL
	JP	NC, AE993
	LD	HL, (Y7573)
	ADD	HL, BC
	PUSH	HL
	CALL	AE5D8
	OR	A
	POP	HL
	JP	Z, AE991
	POP	BC
	LD	B, 9
	CALL    VOSST		; не JMP !!!!
	RET	
	
;────────────────────────────────────────────

AE991:	INC	HL
	INC	HL
AE993:	LD	(Y7571), HL
	POP	BC
	LD	HL, (Y7573)
	PUSH	HL
	CALL	RD_BC
	CALL	OSTANOV
	
	LD	HL, (LENGTS)
	LD	(Y7575), HL
	
	POP	BC
	CALL    VOSST		; не JMP !!!!
	LD	H, B
	LD	L, C
AE9AD:	LD	A, (HL)
	INC	HL
	LD	(Y756F), HL
	LD	B, 0
	RET	
	
;────────────────────────────────────────────

CLOSER:	LD	HL, CLOFLG
	LD	A, (HL)
	INC	A
	RET	Z
	LD	(HL), 0FFH
	
	LD	HL, (Y756C)
	LD	B, 2
	CALL	FREBUF
	
	LD	HL, (Y7573)
	LD	B, 2
	JP	FREBUF

;────────────────────────────────────────────

OPENW:	LD	A, (Y7579)
	INC	A
	LD	A, 10
	JP	NZ, PR_ERN
	LD	B, H
	LD	C, L
	CALL	PUTPRM

	XOR	A
	LD	H, B
	LD	L, C
	LD	(FLAG), A	; флаг разрешения шаблонов имён

	CALL	OPWR
	LD	A, B
	LD	(Y758B), A
	PUSH	BC
	LD	HL, (TCAT)
	LD	C, L
	LD	B, H
	LD	HL, (BOOTA)
	CALL	AE374
	POP	HL
	LD	(Y757B), HL
	LD	HL, KBDPPA+1		; 8001H
	LD	(Y7589), HL
	LD	HL, (BOOTA)
	LD	(Y7585), HL
	EX	DE, HL
	LD	B, 6
	CALL	FILL_0
	
	LD	HL, (BOOTV)
	LD	(Y757D), HL
	
	LD	B, 2
	CALL	SELBUF
	LD	(Y7583), HL
AEA18:	LD	(Y7581), HL
	LD	HL, (TCAT)
	LD	(Y757F), HL
	LD	HL, (ADRNM)
	LD	(Y7587), HL
	
	LD	A, (OPDRV)
	LD	(Y7579), A
	
	CALL    VOSST		; не JMP !!!!
	JP	OSTANOV

;────────────────────────────────────────────

APPEND:	LD	A, (Y7579)
	INC	A
	LD	A, 0AH
	JP	NZ, PR_ERN
	LD	B, H
	LD	C, L
	CALL	PUTPRM
	
	XOR	A
	LD	H, B
	LD	L, C
	LD	(FLAG), A	; флаг разрешения шаблонов имён
	
	CALL	OPRD
	DEC	BC
	LD	H, B
	LD	L, C
	LD	(Y7589), HL
	
	LD	HL, (BOOTV)
	LD	(Y757D), HL
	
	LD	HL, (ADRNM)
	LD	(TTRK), HL
	
	LD	A, H
	LD	(Y758B), A
AEA60:	LD	(Y757B), HL

	LD	HL, (BOOTA)
	LD	(Y7585), HL
	
	LD	C, (HL)
	INC	HL
	LD	A, (HL)
	LD	B, A
	OR	C
	JP	Z, AEA7A
	PUSH	BC
	DEC	HL
	CALL	RD_BC
	POP	HL
	JP	AEA60

;────────────────────────────────────────────

AEA7A:	INC	HL
	LD	A, (HL)
	INC	HL
	OR	(HL)
	JP	NZ, AEA7A
	DEC	HL
	DEC	HL
	LD	A, (HL)
	DEC	HL
	LD	L, (HL)
	LD	H, A
	LD	(Y7577), HL
	PUSH	HL
	LD	B, 2
	CALL	SELBUF
	LD	(Y7583), HL
	POP	BC
	PUSH	HL
	CALL	RD_BC
	LD	HL, (LENGTS)
	POP	DE
	ADD	HL, DE
	JP	AEA18

;────────────────────────────────────────────

WRITE:	LD	A, (Y7579)
	INC	A
	LD	A, 11
	JP	Z, PR_ERN
	CALL	PUTPRM
	PUSH	BC
	LD	HL, (Y7583)
	EX	DE, HL
	LD	HL, (Y7581)
	CALL	CMPDH
	JP	Z, AEAE6
	INC	D
	INC	D
	CALL	CMPDH
	JP	C, AEB2E
	
	LD	A, (Y7579)
	LD	(OPDRV), A
	
	CALL	PUSK
	
	LD	HL, 200H
	LD	(LENGTS), HL
	
	LD	HL, (Y7577)
	LD	B, H
	LD	C, L
	LD	HL, (Y7583)
	CALL	AE374
	LD	HL, (Y7589)
	INC	HL
	LD	(Y7589), HL
	CALL	OSTANOV
AEAE6:	LD	HL, (Y757D)
	LD	(BOOTV), HL
	CALL	LOCVT
	LD	HL, (Y7585)
	PUSH	HL
	CALL	AE815
	POP	HL
	JP	Z, AEB26
	PUSH	HL
	PUSH	BC
	LD	(HL), C
	INC	HL
	LD	(HL), B
	LD	HL, (Y757B)
	EX	(SP), HL
	LD	(Y757B), HL
	POP	BC
	LD	HL, 200H
	LD	(LENGTS), HL
	CALL	PUSK
	POP	HL
	PUSH	HL
	CALL	AE374
	CALL	OSTANOV
	POP	DE
	PUSH	DE
	LD	B, 14H
	CALL	FILL_0
	CALL	LOCVT
	POP	HL
	CALL	AE815
AEB26:	LD	H, B
	LD	L, C
	LD	(Y7577), HL
	LD	HL, (Y7583)
AEB2E:	POP	BC
	LD	(HL), C
	INC	HL
	LD	(Y7581), HL
	LD	HL, Y758A
	LD	A, (HL)
	AND	7FH
	LD	(HL), A
	CALL    VOSST		; не JMP !!!!
	RET
		
;────────────────────────────────────────────

CLOSEW:	LD	A, (Y7579)
	LD	C, A
	INC	A
	RET	Z
	CALL	PUTPRM
	LD	A, C
	LD	(OPDRV), A
	LD	A, 0FFH
	LD	(Y7579), A
	LD	A, (Y758A)
	OR	A
	JP	M, AEBB9
	
	CALL	PUSK
	
	LD	HL, (Y757D)
	LD	(BOOTV), HL
	
	CALL	WRVTOC
	
	LD	HL, (Y757B)
	LD	B, H
	LD	C, L
	
	LD	HL, 200H
	LD	(LENGTS), HL
	
	LD	HL, (Y7585)
	CALL	AE374
	LD	HL, (Y7577)
	LD	B, H
	LD	C, L
	LD	HL, (Y7583)
	EX	DE, HL
	LD	HL, (Y7581)
	CALL	HLSUBD
	LD	(LENGTS), HL
	EX	DE, HL
	CALL	AE374
	LD	HL, (Y757F)
	LD	B, H
	LD	C, L
	PUSH	BC
	LD	HL, (Y7585)
	CALL	RD_BC
	LD	HL, (Y7587)
	LD	DE, 0FH
	ADD	HL, DE
	LD	A, (Y758B)
	LD	(HL), A
	LD	DE, 3
	ADD	HL, DE
	EX	DE, HL
	LD	HL, (Y7589)
	INC	HL
	EX	DE, HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	LD	HL, (Y7585)
	POP	BC
	CALL	AE374
	CALL	OSTANOV
AEBB9:	LD	HL, (Y7583)
	LD	B, 2
	CALL	FREBUF
	LD	HL, (Y7585)
	LD	B, 2
	CALL	FREBUF
	LD	HL, (BOOTV)
	LD	B, 1
	CALL    VOSST		; не JMP !!!!
	JP	FREBUF

;────────────────────────────────────────────

AEBD4:	LD	HL, (ADRNM)
	LD	B, 0
	ADD	HL, BC
	RET	

;────────────────────────────────────────────

PUTPRM:	POP	DE
	LD	A, (OPDRV)
	PUSH	AF
	LD	HL, (ADRNM)
	PUSH	HL
	LD	HL, (ADBUF)
	PUSH	HL
	LD	HL, (BOOTV)
	PUSH	HL
	LD	HL, (BOOTA)
	PUSH	HL
	LD	HL, (TCAT)
	PUSH	HL
	EX	DE, HL
	JP	(HL)

;────────────────────────────────────────────

VOSST:	POP	DE		; сюда входить только по CALL (не JMP)
	POP	HL
	LD	(TCAT), HL
	POP	HL
	LD	(BOOTA), HL
	POP	HL
	LD	(BOOTV), HL
	POP	HL
	LD	(ADBUF), HL
	POP	HL
	LD	(ADRNM), HL
	POP	AF
	LD	(OPDRV), A
	EX	DE, HL
	JP	(HL)

;────────────────────────────────────────────

TITR:	defb 1FH,'DOS 2.9',10,0  
CCPNAM:	defb 'COMMAND.'           
T_COM:	defb 'COM',13            
T_AUTO:defb 'AUTOEXEC'           
T_WK:	defb  13			
TFILES:	defb 'FILES: '		; длина 8
	defb 'SECTOR FREE: '	; длина 13
	
;────────────────────────────────────────────

ERRMSG:	defb 'I/0 ERR',0          
	defb 'DISK LOCKED',0
	defb 'NO DISK',0
	defb 'FILE NOT FOUND',0
	defb 'SYNT ERR',0
	defb 'DISK FULL',0
	defb 'NO EXT',0
	defb 'FILE LOCKED',0
	defb 'END DATA',0
	defb 'HAVE OPEN',0
	defb 'NO OPEN FILE',0
	defb 'NO MEM',0

;────────────────────────────────────────────

INKAN:	PUSH	HL
	PUSH	DE
	LD	DE, TECC6
	PUSH	DE
	LD	HL, (OPKANR)
	JP	(HL)

;────────────────────────────────────────────

TECC6:	POP	DE
	POP	HL
	RET	

;────────────────────────────────────────────

OUT_13:	LD	C, 13
OUTKAN:	PUSH	HL
	PUSH	DE
	PUSH	AF
	LD	DE, RETADH
	PUSH	DE
	LD	HL, (OPKANW)
	JP	(HL)

;────────────────────────────────────────────

RETADH:	pop	af
	POP	DE
	POP	HL
	RET	

;────────────────────────────────────────────

OUTCON:	CALL	COUT		; здесь для ОРИОНА переделка
	LD	A, C
	CP	13
	RET	NZ
	LD	C, 10
	CALL	COUT
	CALL	STAT
	OR	A
	RET	Z
AECEB:	CALL	CONIN
	CP	20H
	JP	Z, AECEB
	CP	3
	RET	NZ
	JP	AE5BE

;────────────────────────────────────────────

AECF9:	CALL	CONIN
	LD	B, 1
	CP	3
	RET	Z
	DEC	B
	LD	C, A
	LD	A, (Y754A)
	OR	A
	LD	A, C
	RET	Z
	CALL	COUT
	CP	13
	RET	NZ
	LD	C, 10
	JP	COUT

;────────────────────────────────────────────

if	W_OUT

PRNOUT:	LD	A, C			; ^^^
	CP	13
	JP	NZ, AED1F
	CALL	AED1F
	LD	C, 10
AED1F:	LD	HL, DOPPPA+2
AED22:	LD	A, (HL)
	AND	8
	JP	NZ, AED22
	LD	L, A
	LD	(HL), C
	LD	L, 2
	LD	(HL), A
	LD	(HL), 80H
	RET	
endif

;────────────────────────────────────────────

PUSK:	CALL	OSTANOV

	LD	A, (OPDRV)
	OR	A
	JP	NZ, AED3C
	LD	A, 5
AED3C:	ADD	A, 5
	LD	HL, PORT+3
	LD	(HL), A
	LD	(HL), 0FH
READY:
	LD	HL, 0
RDYLOO:

if	W_OUT
	IN	A,(0F1H)		; ***
    else
	LD      A,(PORT+1)
endif

	AND	RDYMSK
	RET	Z
	DEC	HL
	LD	A, H
	OR	L
	JP	NZ, RDYLOO
	LD	A, 3
	JP	PR_ERN

;────────────────────────────────────────────

OSTANOV: LD	A, 7FH

if	W_OUT
	OUT	(0F2H),	A		; ***
    else
	LD      (PORT+2),A
endif
	XOR	A
	RET	

;────────────────────────────────────────────

CHSUM9:	LD	HL, (LENGTS)
	LD	B, H
	LD	C, L
	LD	HL, (BEGS)
	LD	DE, 0
AED68:	LD	A, (HL)
	ADD	A, E
	LD	E, A
	LD	A, D
	ADC	A, 0
	LD	D, A
	INC	HL
	DEC	BC
	LD	A, B
	OR	C
	JP	NZ, AED68
	EX	DE, HL
	LD	(KS), HL
	RET	

;────────────────────────────────────────────

BAKSTP:	DEC	E
	LD	A, E
	RRCA	
	RET	NC
	LD	A, 3
	JP	STEP

;────────────────────────────────────────────

FORWRD:	INC	E
	LD	A, E
	RRCA	
	RET	C
	LD	A, 2		; БИТ D1=0  DIRC НАПРАВЛЕНИЕ (3 НАЗАД)
STEP:
	LD	HL, PORT+3
	LD	(HL), A
	LD	(HL), 8
	LD	A, 2
AED92:	DEC	A
	JP	NZ, AED92
	LD	(HL), 9
				; A=0
AED98:  DEC     A               ; ПАУЗА ПОСЛЕ ШАГА
	JP	NZ, AED98
	RET	

;────────────────────────────────────────────

; ИЩЕТ СЕКТОР НА ДОРОЖКЕ        

POSIT:	LD	A, 4	 	; не менять, одновременно N макс.сект
	LD	(NPOS), A	; и число попыток позиционирования

	LD	HL, TSKT
	CP	(HL)		; сравниваем с 4 (максим N сектора)
	JP	C, BADPOP

AEDA9:	LD	HL, NPOS
	DEC	(HL)
	JP	M, BADPOP
	
	LD	A, (TTRK)
	AND	1
	ADD	A, 4
	LD	BC, PORT+3
	LD	(BC), A
	INC	BC

	LD	A, 25H

if	W_OUT
	OUT	(0C1H),	A		; *** для ВГ75
    else
	LD      (VG75+1),A
endif


	LD	HL, PORT+1
AEDC3:	LD	DE, 3E8H		; 1000 des
AEDC6:	DEC	DE
	LD	A, D
	OR	E
	JP	Z, BADPOP
	
AEDCC:	INC	(HL)
	JP	P, AEDCC
	
	LD	A, (BC)
	SUB	0EAH
	JP	NZ, AEDC6
	
AEDD6:	OR	(HL)
	JP	P, AEDD6
	
	LD	A, (BC)
	SUB	0D3H
	JP	NZ, AEDC6
	
AEDE0:	OR	(HL)
	JP	P, AEDE0
	
	LD	A, (BC)
	LD	E, A
	
AEDE6:	INC	(HL)
	JP	P, AEDE6
	
	LD	A, (BC)
	LD	D, A
	
AEDEC:	INC	(HL)
	JP	P, AEDEC
	
	LD	A, (BC)
	SUB	E
	SUB	D
	JP	NZ, BADPOP
	LD	A, (TTRK)
	SUB	E
	JP	NZ, AEE05
	LD	A, (TSKT)
	CP	D
	JP	NZ, AEDC3
	RET	

;────────────────────────────────────────────

AEE05:	LD	C, A
	JP	C, AEE13
AEE09:	CALL	FORWRD
	DEC	C
	JP	NZ, AEE09
	JP	AEDA9

;────────────────────────────────────────────

AEE13:	CALL	BAKSTP
	INC	C
	JP	NZ, AEE13
	JP	AEDA9

;────────────────────────────────────────────

TRACK0:

if	W_OUT
	IN	A,(0F1H)		; ***
    else
	LD      A,(PORT+1)
endif

	AND	TR0MSK
	JP	Z, BADOP
	LD	A, 3
	CALL	STEP
	JP	TRACK0
	
;────────────────────────────────────────────

FND_MD:	LD	D, 25		; D= сколько МАКСИМУМ байт до метки данных
AEE2E:	DEC	D
	JP	Z, BADPOP
AEE32:	INC	(HL)
	JP	P, AEE32
	LD	A, (BC)
	SUB	0DDH
	JP	NZ, AEE2E
AEE3C:	OR	(HL)
	JP	P, AEE3C
	LD	A, (BC)
	SUB	0F3H
	RET	Z
	JP	AEE2E

;────────────────────────────────────────────

BADPOP:	POP	AF
BADOP:	XOR	A
	INC	A
	RET	

;────────────────────────────────────────────

HLSUBD:	LD	A, L
	SUB	E
	LD	L, A
	LD	A, H
	SBC	A, D
	LD	H, A
	RET	

;────────────────────────────────────────────

RDSKT:	LD	A, 8
	LD	(NRD), A	; ЧИСЛО ПОПЫТОК ЧТЕНИЯ
AEE57:
	CALL	AEE67
	JP	Z, RET_Z1
	LD	HL, NRD
	DEC	(HL)
	JP	P, AEE57

	JP	TRACK0		; там выход на BADOP

;────────────────────────────────────────────

AEE67:	CALL	POSIT
	CALL	FND_MD
	
AEE6D:	OR	(HL)
	JP	P, AEE6D
	
	LD	A, (BC)
	LD	E, A
	LD	(LENGTS), A
	
AEE76:	INC	(HL)
	JP	P, AEE76
	
	LD	A, (BC)
	LD	D, A
	LD	(LENGTS+1), A
	
AEE7F:	INC	(HL)
	JP	P, AEE7F
	
	LD	A, (BC)		; ?
	
	LD	A, (BEGS)
	LD	C, A
	LD	A, (BEGS+1)
	LD	B, A

AEE8C:	INC	(HL)		; *
	JP	P, AEE8C

if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif

	LD	(BC), A
	INC	BC
	DEC	DE
	LD	A, D
	OR	E
	JP	NZ, AEE8C

AEE9A:	OR	(HL)
	JP	P, AEE9A

if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif

	LD	E, A
	
AEEA1:	INC	(HL)
	JP	P, AEEA1
	
if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif

	LD	D, A
	PUSH	DE
	CALL	CHSUM9
	POP	DE
CHK_KS:
	LD	HL, (KS)
CMPDH:	LD	A, H
	CP	D
	RET	NZ
	LD	A, L
	CP	E
	RET	

;────────────────────────────────────────────

WRSKT:	CALL	READY
	LD	HL, NWR
	LD	(HL), 8

if	W_OUT
	IN	A,(0F1H)		; ***
    else
	LD      A,(PORT+1)
endif
	AND	(HL)
	LD	A, 2
	RET	Z
AEEC4:	CALL	WR_MDN
	JP	NZ, AEEC4
	LD	A, 8
	LD	(NRD), A
AEECF:	CALL	WR_DAT
	JP	Z, RET_Z1
	LD	HL, NRD
	DEC	(HL)
	JP	P, AEECF
	JP	AEEC4

;────────────────────────────────────────────

RET_Z1:	XOR	A
	RET	

;────────────────────────────────────────────

WR_MDN:	LD	HL, NWR
	DEC	(HL)
	JP	M, BADPOP
	
	CALL	CHSUM9
	CALL	POSIT
	
	LD	A, 0CH

if	W_OUT
	OUT	(0F3H),	A		; ***
    else
	LD      (PORT+3),A
endif

AEEF2:	DEC	A		; A=0CH
	JP	NZ, AEEF2	; Задержка (22*12) такта
	
	EX	DE, HL
	LD	HL, (KS)
	LD	A, L
	PUSH	HL
	PUSH	AF
	LD	HL, (BEGS)
	PUSH	HL
	LD	HL, (LENGTS)
	PUSH	HL
	EX	DE, HL
	LD	DE, PORT

	XOR	A

if	W_OUT
	OUT	(0F3H),	A		; ***
    else
	LD      (PORT+3),A
endif

	LD	A, 6
	CALL	ZAP5BT
	
AEF11:	OR	(HL)
	JP	P, AEF11
	
	LD	A, 13
	LD	(DE), A

if	W_OUT
	OUT	(0F3H),	A		; ***
    else
	LD      (PORT+3),A
endif

	XOR	A
	CALL	ZAP5BT
	
AEF1E:	OR	(HL)
	JP	P, AEF1E
	
	LD	A, 0DDH
	LD	(DE), A
	
AEF25:	INC	(HL)
	JP	P, AEF25
	
	LD	A, 0F3H
	LD	(DE), A
	POP	DE
	
AEF2D:	INC	(HL)
	JP	P, AEF2D
	
	LD	A, E

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

AEF34:	INC	(HL)
	JP	P, AEF34
	
	LD	A, D

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

	POP	BC
	
AEF3C:	INC	(HL)
	JP	P, AEF3C
	
	XOR	A

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

AEF43:	INC	(HL)
	JP	P, AEF43
	
	LD	A, (BC)

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

	INC	BC
	DEC	DE
	LD	A, D
	OR	E
	JP	NZ, AEF43
	
AEF51:	OR	(HL)
	JP	P, AEF51
	
	POP	AF

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

	
AEF58:	INC	(HL)
	JP	P, AEF58
	
	POP	AF

if	W_OUT
	OUT	(0F0H),	A		; ***
    else
	LD      (PORT),A
endif

	LD	D, 0F0H
	
AEF61:	INC	(HL)
	JP	P, AEF61
	
	XOR	A
	LD	(DE), A
	CALL	ZAP5BT
	LD	A, 1

if	W_OUT
	OUT	(0F3H),	A		; ***
    else
	LD      (PORT+3),A
endif

	RET	

;────────────────────────────────────────────

ZAP5BT:	LD	C, 5
ZAPCBT:	INC	(HL)
	JP	P, ZAPCBT
	LD	(DE), A
	DEC	C
	RET	Z
	JP	ZAPCBT

;────────────────────────────────────────────

WR_DAT:	CALL	POSIT
	CALL	FND_MD
AEF81:	OR	(HL)
	JP	P, AEF81
	LD	A, (BC)
	EX	DE, HL
	LD	HL, (LENGTS)
	EX	DE, HL
	SUB	E
	RET	NZ
AEF8D:	OR	(HL)
	JP	P, AEF8D
	LD	A, (BC)
	SUB	D
	RET	NZ
	CP	E
	JP	NZ, AEF99
	DEC	D
	
AEF99:	INC	(HL)
	JP	P, AEF99
	
	LD	A, (BC)
	LD	B, H
	LD	C, L
	LD	HL, (BEGS)
	
AEFA3:	LD	A, (BC)
	RLA	
	JP	NC, AEFA3
	
AEFA8:

if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif

	CP	(HL)
	RET	NZ
	INC	HL
	DEC	E
	JP	NZ, AEFA3
	
AEFB1:	LD	A, (BC)
	RLA	
	JP	NC, AEFB1
	
	DEC	D
	JP	P, AEFA8

if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif


	LD	E, A
AEFBD:	LD	A, (BC)
	RLA	
	JP	NC, AEFBD
	

if	W_OUT
	IN	A,(0F4H)		; ***
    else
	LD      A,(PORT+4)
endif

	LD	D, A
	JP	CHK_KS

;────────────────────────────────────────────

CMDTBL:	defb	'DIR  '              
	DW	DIR
	defb	'LOAD '
	DW	LOAD
	defb	'SAVE '
	DW	SAVE
	defb	'TYPE '
	DW	TYPE
	defb	0
          	
;────────────────────────────────────────────

TBAT:	defb	'BAT'                
TSYS:	defb	'SYS'                
TCON:	defb	'CON'                
TPRN:	defb	'PRN'
TJOKER:	defb	'*.*',13
	defb	'sedow V2.95'

if $	gt	0F000H
	if1
	.printx	 *   DOS code size over 4 KB ! *
	endif
	@OVER	EQU	$-0F000H
  else
	if	$ ne 0F000H
  	   @FREE	EQU	0F000H-$
	   if1
	   .printx	 *   Es gibt freie Platz ! *
	   endif
	   rept	@FREE
	   defb	255
	   endm
	  else
	   if1
	   .printx	 *   Totally fit in 4K ! *
	   endif
	endif
endif
	
if	ORD and ($ EQ RKDOS+1000H)
	LENGTH	EQU 1000H
endif
	.dephase
	
	end
