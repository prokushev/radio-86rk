;.xlist
;  МОНИТОР РК86 для КР580 совместимый с Z80
;  ════════════════════════════════════════

; Last modify: 04.05.2021

; Свободно 310 ячеек

; Звук только на INTE
; В CCP принудительно включается ЛАТ-регистр.
; Удалена директива X. Директива G теперь не имеет второго параметра -
; стоп точки. Зато теперь введён возврат из запуска по G по RET. И можно
; передавать два параметра (второй и третий, они передаются в DE и BC).

CHK	MACRO	adr, msg
		IF	adr-$
			ERROR	msg
		ENDIF
	ENDM

	CPU	8080
	Z80SYNTAX	EXCLUSIVE
	ORG	0F800H

RABADR	EQU	0F800H
DOPPPA	EQU	0A000H

; ──────────────────────────────────────────────
K_ORIG	EQU	1		; если 1, то измененный курсор
VT52	EQU	0		; если 1, то эмулируем VT-52
ALTCHAR	EQU	0		; если 1, то поддерживается альтернативный знакогенератор
TOS	EQU	0		; если 1, то поддерживается расширения GDOS/TOS
CPM	EQU	0		; если 1, то эмулируем CP/M для программ с адреса 100
; ──────────────────────────────────────────────

BASE    EQU	7600H		; ниже D0H байтов - служебные ячейки

EK_ADR  EQU	BASE		; текущий адрес на экране
POSX	EQU	BASE+02H
POSY	EQU	BASE+03H
ESC_FL	EQU	BASE+04H
KBDFLG	EQU	BASE+05H 	; если =0, то есть символ в SYMBUF
RUSLAT	EQU	BASE+06H	; допустимо только 0 или FF  !! Адрес должен быть xx06h иначе править SET_RL !!
LAST_K	EQU	BASE+09H	; эти 2 байта должны следовать подряд
COUNT	EQU	BASE+0AH	; счётчик опросов (вначале 15)
APVFLG	EQU	BASE+0BH	; флаг автоповтора
FRELOC	EQU	BASE+0CH	; эта ячейка не используется

TMPSTK	EQU	BASE+0DH	; временно храним стек при МГ п/п-ммах
POINT	EQU	BASE+14H	; адрес откуда произошёл RST_30H
R_HL	EQU	BASE+16H
R_BC	EQU	BASE+18H
R_SP	EQU	BASE+1CH
R_AF	EQU	BASE+1EH	; ниже откладываются AF,HL,DE,BC
STOP_A  EQU	BASE+23H
TMP_COD EQU	BASE+25H
P_JMP	EQU	BASE+26H	; для байта C3H (JMP)
PAR_HL  EQU	BASE+27H
PAR_DE  EQU	BASE+29H
PAR_BC  EQU	BASE+2BH
FLG_P2	EQU	BASE+2DH	; флаг, что есть параметры 2 или 2,3
INV_MG	EQU	BASE+2EH
KNS_RD	EQU	BASE+2FH
KNS_WR	EQU	BASE+30H
RAMTOP	EQU	BASE+31H
COMBUF	EQU	BASE+33H	; буфер ввода директивы
STACK	EQU	BASE+0D0H	; стек монитора

SA	EQU	076D0H		; 76D0 начало экранной области
SCBASE  EQU	077C2H		; 77C2 ЛЕВ.ВЕРХН.УГОЛ ЭКР.

VG_75   EQU	0C000H
VT_57   EQU	0E000H

PA	EQU	8000H
PB	EQU	PA+1
PC	EQU	PA+2
PU	EQU	PA+3

PDA	EQU	DOPPPA
PDB	EQU	PDA+1
PDC	EQU	PDA+2
PDU	EQU	PDA+3

; ──────────────────────────────────────────────

LOOP	MACRO	ADDR
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,ADDR
	ENDM

; ──────────────────────────────────────────────

	JP	XF800		; +0
	JP	CONIN 		; +3
	JP	LDBYTE		; +6
	JP	COUT_C		; +9
	JP	WRBYTE		; +C
	JP	COUT_C		; +F   это д.быть PRINT
	JP	STATUS		; +12
	JP	HEX_A 		; +15
	JP	MSGH  		; +18
	JP	XF81B 		; +1B
	JP	ASKCUR		; +1E
	JP	RD_SCR		; +21
	JP	RD_BLK		; +24
	JP	WR_BLK		; +27
	JP	CHSUMM		; +2A
	JP	PUSK_VG		; +2D
ASKTOP: LD	HL,(RAMTOP)	; +30
SETTOP:	LD	(RAMTOP),HL	; +33
	RET

; ──────────────────────────────────────────────

AFB86:	LD	C,(HL)			; 10 bytes
	CALL	WRBYTE
	CALL	AF999
	JP	AFB86

; ──────────────────────────────────────────────

XF800:	LD	HL,BASE-1
	LD	(RAMTOP),HL
	LD	SP,HL

	LD	A,8AH
	LD	(PU),A

	CALL	PUSK_VG

	INC	HL			; LD HL,BASE
	LD	C,L			; 0
	LD	DE,COMBUF+2CH
	CALL	DIR_F

	CALL	RST_18
TITR:	DB	1FH,'radio-86r','k' + 80H

	LD	HL,1D2AH
	LD	(KNS_RD),HL

	CHK	0f86ch, "* Standard subroutine WARMST shifted ! *"
;if	$ ne RABADR + 6CH
;	if1
;	.printx * Standard subroutine WARMST shifted ! *
;	endif
;endif
WARMST:				; Warm_BOOT
	LD	SP,STACK

	LD	A,90H
	LD	(PDU),A

	CALL	RST_18
PROMPT:	DB	13,10,'-','-','>'+128

	CALL	GETLIN

	LD	HL,WARMST
	PUSH	HL

	LD	HL,COMBUF
	LD	A,(HL)

	PUSH	AF
	CALL	GETPRM
	LD	HL,(PAR_BC)		; Z80: LD BC,(PAR_BC)
	LD	C,L
	LD	B,H
	LD	HL,(PAR_DE)		; Z80: LD DE,(PAR_DE)
	EX	DE,HL
	LD	HL,(PAR_HL)
	POP	AF

	SUB	'C'			;CP	'C'
	JP	Z,DIR_C
	DEC	A			;CP	'D'
	JP	Z,DIR_D
	SUB	3			;CP	'G'
	JP	Z,DIR_G
	SUB	2			;CP	'I'
	JP	Z,DIR_I
	SUB	3			;CP	'L'
	JP	Z,DIR_L
	DEC	A			;CP	'M'
	JP	Z,DIR_M
	SUB	2			;CP	'O'
	JP	Z,DIR_O
	SUB	3			;CP	'R'
	JP	Z,DIR_R
	DEC	A			;CP	'S'
	JP	Z,DIR_S
	DEC	A			;CP	'T'
	JP	Z,DIR_T
	ADD	A, 'T'-'F'		;CP	'F'
	JP	NZ,ERROR

; ──────────────────────────────────────────────
; Заполняет область памяти с HL по DE байтом C
; ВХОД:
;	HL	- начальный адрес
;	DE	- конечный адрес
;	C	- байт для записи
; ВЫХОД:

; ИЗМЕНЯЕТ:
;	AF, HL
; ──────────────────────────────────────────────
DIR_F:
	LD	(HL),C
	CALL	AF999
	JP	DIR_F

; ──────────────────────────────────────────────
; ──────────────────────────────────────────────


COD_0D:	LD	A,L			; 13 bytes
	SUB	E
	JP	NC,AFDF9
	DEC	H
AFDF9:	LD	L,A
	LD	BC,8
	LD	E,C
	ADD	HL,BC
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

ASKCUR:	LD	HL,(POSX)		; 4 bytes
	RET

; ──────────────────────────────────────────────


MSGH:	LD	A,(HL)			; 11 bytes
	OR	A			; CP 0
	RET	Z
	CALL	SCOUTA
	INC	HL
	RET	M			; RET if high bit set
	JP	MSGH

; ──────────────────────────────────────────────
	CHK	0F8EEH, "* Internal subroutine GETLIN shifted ! *"

GETLIN:	LD	HL,COMBUF
	LD	D,H
	LD	E,L
AF8F1:
	XOR	A
	LD	B,A		; чтобы на выходе получить флаг пустой строки
	CALL	SET_RL
AF8F3:	CALL	CONIN		; используется в DIR_M
	CP	8
	JP	Z,BAKSTP
	CP	7FH
	JP	Z,BAKSTP
	LD	(HL),A
	CALL	SCOUTA
	CP	13
	JP	Z,AF91A
	CP	'.'
	JP	Z,WARMST
	LD	B,E			; B=76H --> бит D7=0
	LD	A, (COMBUF & 00FFh)+31
	CP	L
	JP	Z,ERROR
	INC	HL
	JP	AF8F3


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
;	AF		 TODO: проверить, что изменяет XF81B и PUSK_VG
; ──────────────────────────────────────────────

CHK_F4:	CALL	XF81B			; 12 bytes
	CP	3
	RET	NZ
	CALL	PUSK_VG
	JP	ERROR

; ──────────────────────────────────────────────

AF91A:	SUB	B			; 2 bytes
	RET

; ──────────────────────────────────────────────

	CHK	0F92cH, "* Internal subroutine GETPRM shifted ! *"
; ──────────────────────────────────────────────
; Читает аргументы со второй позиции буфера команды в регистры HL, DE, BC
; Разделителями считаются ',' и ' '. Конец данных - CR
; ВХОД:
;	Нет
; ВЫХОД:
;	HL	- первый аргумент
;	DE	- первый аргумент, если один параметр в строке, иначе второй аргумент
;	BC	- третий аргумент
;	При ошибке разбора выходит в МОНИТОР
; ИЗМЕНЯЕТ:
;	AF, HL, DE, BC
; ──────────────────────────────────────────────

GETPRM:	LD	HL,PAR_HL	; Обнуляем параметры
	LD	DE,FLG_P2
	LD	C,0
	CALL	DIR_F

;if	high (BASE+34H) eq high BASE
	LD	E,34H
;    else
;	.printx *      Wrong BASE (Low BASE need be < 0E0H) !
;endif
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
	JP	ERROR

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

XF81B:	LD	A,(PC)		; 30 bytes
	RLA
	LD	A,0FEH
	RET	NC
AFE7D:
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

	CHK	0F990H, "* Internal subroutine CMPDH shifted ! *"

CMPDH:	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET

; ──────────────────────────────────────────────

BAKSTP:	LD	A,E			; 15 bytes
	CP	L			; начало буфера ввода ?
	JP	Z,AF8F1
	CALL	RST_18
TZABOJ:	DB	8,32,8+128
	DEC	HL
	JP	AF8F3

; ──────────────────────────────────────────────

DIR_S:	LD	A,C			; 11 bytes
	CP	(HL)
	CALL	Z,CHXHL_
	CALL	AF996
	JP	DIR_S

; ──────────────────────────────────────────────

	CHK	0F9B0H, "* Internal subroutine CR shifted ! *"

CR:	CALL	RST_18
	DB	13,10 + 80H
	RET

; ──────────────────────────────────────────────

DIR_I:	LD	A,(FLG_P2)		; 46 bytes
	OR	A
	JP	Z,AFA91
	LD	A,E
	LD	(KNS_RD),A
AFA91:	CALL	RD_BLK

	CALL	JJJ2
	EX	DE,HL

	PUSH	BC
	CALL	CHSUMM
	CALL	DIRK1
	POP	DE

	CALL	CMPDH
	RET	Z
	CALL	CHXDE_
ERROR:	CALL	RST_18
	DB	'?'+80H
	JP	WARMST

; ──────────────────────────────────────────────

DIR_L:	CALL	CHXHL_			; 30 bytes
AFA0B:	LD	A,(HL)
	OR	A
	JP	M,AFA15
	CP	20H
	JP	NC,AFA17
AFA15:	LD	A,'.'
AFA17:	CALL	SCOUTA
	CALL	AF996
	LD	A,L
	AND	0FH
	JP	Z,DIR_L
	JP	AFA0B

; ──────────────────────────────────────────────

; ВХОД: E=POSX, D=POSY
;       HL= экранный адрес

RIGHT:				; 29 bytes
	LD	A,E		; POSX
	INC	HL		; следующий экранный адрес
	INC	E               ; POSX ++
	CP	8+63 		; последняя колонка ?
	RET	NZ              ; если была не последняя колонка
	LD	E,8             ; нач.позиция по X на новой строке
	LD	BC,-64
	ADD	HL,BC           ; Вычесть 64 = экр.поз в начало строки
DOWN:	LD	A,D
	CP	3+24		; последняя строка ?
	LD	BC,78
	JP	NZ,AFDD3        ; если не последняя строка
	LD	D,2             ; если последняя строка, то на первую строку BUG VT52 не двигает на первую строку, остается на последней
	LD	BC,-24*78
AFDD3:	INC	D
	ADD	HL,BC		; вычесть 24*78
	RET

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

CHSUMM:	LD	BC,0			; 23 bytes
AFB19:	LD	A,(HL)
	ADD	A,C
	LD	C,A
	PUSH	AF
	CALL	CMPDH
	JP	Z,POPAF
	POP	AF
	LD	A,B
	ADC	A,(HL)
	LD	B,A
	CALL	AF999
	JP	AFB19

; ──────────────────────────────────────────────

DIR_M:	CALL	JJJ_02			; 22 bytes
	PUSH	HL
	CALL	GETLIN
	POP	HL
	JP	NC,AFA3B
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
AFA3B:	INC	HL
	JP	DIR_M

; ──────────────────────────────────────────────

DIR_R:
AFA6D:	LD	(PDB),HL
	LD	A,(PDA)
	LD	(BC),A
	INC	BC			; 19 bytes
	CALL	AF999
	JP	AFA6D

; ──────────────────────────────────────────────

DIR_D:	CALL	CHXHL_			; 18 bytes
AF9C8:	CALL	LDXHX_
	CALL	AF996
	LD	A,L
	AND	0FH
	JP	Z,DIR_D
	JP	AF9C8

; ──────────────────────────────────────────────

KEY_FE:	LD	A,(PC)			; 17 bytes
	RLA
	JP	NC,KEY_FE		; ждём отпускания РУС/ЛАТ
	LD	A,(RUSLAT)
	CPL
	CALL	SET_RL
	JP	AFE1A

; ──────────────────────────────────────────────

BYTE3:	LD	A,C			; 18 bytes
	SUB	20H
	LD	C,A
AFD77:	DEC	C
	LD	A,3
	JP	M,SETESC
	PUSH	BC
	CALL	DOWN
	POP	BC
	JP	AFD77

; ──────────────────────────────────────────────

RD_SCR: PUSH	HL			; 7 bytes
	LD	HL,(EK_ADR)
	LD	A,(HL)
	POP	HL
	RET

; ──────────────────────────────────────────────

DIR_T:	LD	A,(HL)			; 9 bytes
	LD	(BC),A
	INC	BC
	CALL	AF999
	JP	DIR_T

; ──────────────────────────────────────────────

RST_18:	EX	(SP),HL			; 6 bytes
	CALL	MSGH
	EX	(SP),HL
	RET

; ──────────────────────────────────────────────

RD_BLK:	CALL	LDBCSS
	PUSH	HL
	ADD	HL,BC
	EX	DE,HL
	CALL	LDBCBS
	POP	HL
	ADD	HL,BC
	EX	DE,HL
	PUSH	HL
	CALL	LD_BLK
	CALL	LDBCSS		; с поиском СБ
	POP	HL
	DB	06h		; LD B, ..

SET_RL:	LD	(RUSLAT),A		; Т.к. адрес RUSLAT xx06h, то предыдущий трюк с LD B, .. повторится..

; ──────────────────────────────────────────────

	CHK	0FACEH, "* Internal subroutine PUSK_VG shifted ! *"
PUSK_VG:			; 1001.0011
				; 1100.0011

	PUSH	HL
	LD	HL,VG_75+1
	LD	(HL),0   	; reset commando
	DEC	HL       	; адрес VG_75
	LD	(HL),04DH	; 0.1001101  77+1 знакомест
	LD	(HL),01DH	; 00.011101  29+1 строк

        LD	(HL),99H	; 1001.1001  9 +1 линия подчерк.
        			; 9+1 линий в знакоместе
	if	K_ORIG
	LD	(HL),93H
	else
	LD	(HL),0C3H
	endif

	INC	HL		; адрес VG_75+1
	LD	(HL),27H	; start display commando
	LD	A,(HL)		; read status
AFAE1:	LD	A,(HL)		; read status
	AND	20H		; mask 'Interrupt request flag'
	JP	Z,AFAE1         ; ждем конца строки
	LD	HL,VT_57+8
	LD	(HL),80H
	LD	L,4             ; VT_57+04
	LD	(HL),SA & 00FFh 	; 0D0H
	LD	(HL),SA>>8	; 076H
	INC	L               ; адрес VT_57+5
	LD	(HL),23H
	LD	(HL),49H
	LD	L,8             ; VT_57+8
	LD	(HL),0A4H
	POP	HL
	RET

; ──────────────────────────────────────────────

DIR_O:	LD	A,C
	OR	A
	JP	Z,AFB35
	LD	(KNS_WR),A
AFB35:	PUSH	HL
	CALL	CHSUMM
	POP	HL
	
	CALL	JJJ2
	EX	DE,HL
	
	PUSH	HL
	CALL	DIRK1
	POP	HL
WR_BLK:
	PUSH	BC		; КС

	LD	BC,0		; выводим 256 байтов 00 (пилотон)
AFB4D:	CALL	WRBYTE
	EX	(SP),HL 	; это задержка 38 тактов
	EX	(SP),HL
	DEC	B
	JP	NZ,AFB4D

	LD	C,0E6H  	; выводим синхробайт E6
	CALL	WRBYTE

	CALL	WR_HL		; выводим НА
	EX	DE,HL
	CALL	WR_HL		; выводим КА

	EX	DE,HL
	CALL	AFB86		; выводим блок

	LD	HL,0
	CALL	WR_HL		; выводим 2 байта 00

	LD	C,0E6H  	; снова выводим с/байт E6
	CALL	WRBYTE

	POP	HL
	CALL	WR_HL		; выводим КС

	JP	PUSK_VG


; ──────────────────────────────────────────────

; Вводит в HL HEX-число из строки по (DE) до нажатия ВК

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

	LD	BC,ERROR
	PUSH	BC

	SUB	'0'
	RET	C		; JP C,ERROR

	CP	9+1
	JP	C,AF982

	CP	'A'-'0'
	RET	C		; JP C,ERROR

	CP	'F'-'0'+1
	RET	NC		; JP NC,ERROR

	SUB	'A'-('9'+1)
AF982:
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	RET	C		; JP C,ERROR

	OR	L
	LD	L,A

	POP	AF
	JP	AF95D

; ──────────────────────────────────────────────

JJJ2:	CALL	CHXHL_
DIRK1:	LD	D,B
	LD	E,C
CHXDE_:	EX	DE,HL
	CHK	0FB78H, "* Internal subroutine CHXHL_ shifted ! *"
CHXHL_: CALL	CR
HEXHL_:	LD	A,H
	CALL	HEX_A
	LD	A,L
	JP	HEXABL

; ──────────────────────────────────────────────

DIR_C:	LD	A,(BC)			; 19 bytes
	CP	(HL)
	JP	Z,AF9E6
	CALL	JJJ_02
	LD	A,(BC)
	CALL	HEXABL
AF9E6:	INC	BC
	CALL	AF996
	JP	DIR_C

; ──────────────────────────────────────────────

AFEF3:	LD	A,H			; 7 bytes
	LD	HL,TABK1
	JP	AFEFE

; ──────────────────────────────────────────────
; Загрузка A без поиска синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	A	- загруженный байт
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

LDBS:	LD	A,8

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

;	CHK	0FB98H, "* LDBYTE for emulator B2M need be at FB98 ! *"
LDBYTE: PUSH	BC
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
	LD	(HL), SA >>8		; 076H
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


WR_HL:	LD	C,H
	CALL	WRBYTE
	LD	C,L

;	CHK	0FC46H, "* WRBYTE for emulator B2M need be at FC46 ! *"
WRBYTE: PUSH	HL
	PUSH	DE
	PUSH	BC
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
	LD	A, B		;LD	A,0		; XOR A = LD A,B (в данном случае незачем)
	XOR	C
	LD	(PC),A
	DEC	D
	LD	A,(KNS_WR)
	JP	NZ,AFC7A
	SUB	14
AFC7A:	LD	B,A

AFC7B:	POP	AF            ; подъем стека на [рег.B] ячеек
	DEC	B
	JP	NZ,AFC7B
	INC	D
	DEC	D
	JP	NZ,AFC58

	LD	SP,HL
	LD	HL,VT_57+4
	LD	(HL), SA & 00FFh	; 0D0H
	LD	(HL), SA >> 8	; 076H
	INC	HL		; VT_57+5
	LD	(HL),23H
	LD	(HL),49H
	LD	A,27H		; start display commando
	LD	(VG_75+1),A	; 001.sss.bb    001.001.11
	LD	A,0E0H		; сброс счетчиков строк и знакомест ???
	LD	(VG_75+1),A
	LD	L,8
	LD	(HL),0A4H        ; VT_57+8
POPREGA:
	POP	AF
POPREG: POP	HL
	POP	DE
	POP	BC
;	CHK	0FCA4H, "* Internal point 0FCA4H (need for emulator B2M) shifted ! *"
LD_BAK:	RET

; ──────────────────────────────────────────────
; Печать числа из A в 16-ричном формате
; ВХОД:
;	A	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

HEX_A:	PUSH	AF			; 23 bytes
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	NIBBLE
	POP	AF
NIBBLE:	AND	0FH
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

SCOUTA:
	PUSH	BC			; 10 bytes
	LD	C,A
	DB	06h			; LD B,.. ;JP	COUT_C2

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

COUT_C:	PUSH	BC
COUT_C2:
	PUSH	DE
	PUSH	HL
	PUSH	AF

	CALL	STATUS
	LD	HL,TOBACK
	PUSH	HL
	LD	HL,(POSX)
	EX	DE,HL
	LD	HL,(EK_ADR)
	LD	A,(ESC_FL)
	OR	A
	JP	Z,NO_ESC	; BUG Для VT-52 факт обработки ESC-последовательности не значит, что он игнорирует контрольны коды
	DEC	A
	JP	Z,EscapeHandler	; если второй байт ('Y')
	DEC	A
	JP	Z,BYTE3		; если третий байт
	LD	A,C     	; четвёртый байт
	SUB	20H
	LD	C,A
AFCDD:	DEC	C
	JP	M,ESCRES         ; СБРОС ESC_FL И ВЫХОД
	PUSH	BC
	CALL	RIGHT
	POP	BC
	JP	AFCDD

; ──────────────────────────────────────────────

NO_ESC:	LD	A,C
	AND	7FH
	LD	C,A
	SUB	7		;CP	07H
	JP	Z,BEEP
	DEC	A		;CP	08H
	JP	Z,LEFT
	IF	VT52
	DEC	A		;CP	09H
	JP	Z,TAB
	DEC	A		;CP	0AH
	ELSE
	SUB	2		;CP	0AH
	ENDIF
	JP	Z,COD_0A
	SUB	2		;CP	0CH
	JP	Z,HOME
	DEC	A		;CP	0DH
	JP	Z,COD_0D
	SUB	11		;CP	18H
	JP	Z,RIGHT
	DEC	A		;CP	19H
	JP	Z,UP
	DEC	A		;CP	1AH
	JP	Z,DOWN
	DEC	A		;CP	1BH
	JP	Z,COD_1B
	SUB	4		;CP	1FH
	JP	Z,CLS

	LD	(HL),C		; Видимый на экране символ
	CALL	RIGHT		; сместить на следующее знакоместо
	LD	A,D
	CP	3		; мы на первой строке ?
	RET	NZ		; если не на первой строке
	LD	A,E
	CP	8		; мы в первой колонке ?
	RET	NZ		; если не на первой колонке
	CALL	UP
COD_0A:	LD	A,D
	CP	3+24		; мы на последней строке ?
	JP	NZ,DOWN	; если не на последней строке

	PUSH	HL		; РОЛИК ЭКРАНА
	PUSH	DE
	LD	HL,SCBASE+78
	LD	DE,SCBASE
	LD	BC,25*78
MOVLOO:	LD	A,(HL)          ; пересылка блока размером [BC]
	LD	(DE),A		; (HL) --> (DE)
	INC	HL
	INC	DE
	LOOP	MOVLOO
	POP	DE
	POP	HL
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

; После 15 вызовов STATUS при нажатой клавише выставляется флаг KBDFLG

STATUS:	LD	A,(PC)		; 38 bytes
	RLA
	JP	NC,AFE0E	; если нажат RUS/LAT
	LD	A,(KBDFLG)
	OR	A
	RET	NZ		; если в SYMBUF уже есть символ
AFE0E:	PUSH	HL
	LD	HL,(LAST_K)
	CALL	XF81B
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

; ──────────────────────────────────────────────

LEFT:				; ВХОД: E=POSX, D=POSY
                                ;       HL= экранный адрес

	LD	A,E		; 29 bytes
	DEC	HL
	DEC	E
	CP	8		; были в первой колонке ?
	RET	NZ		; если были не в первой колонке
	LD	E,8+63		; POSX последней колонки  BUG VT52 не перебрасывает на предыдущуюстроку
	LD	BC,64
	ADD	HL,BC		; экр.адрес в последнюю колонку
UP:	LD	A,D
	CP	3		; это первая строка ?
	LD	BC,-78
	JP	NZ,AFDF0
	LD	D,3+25		; BUG VT52 не перебрасывает на последнюю строку
	LD	BC,24*78
AFDF0:	DEC	D
	ADD	HL,BC           ; Вычесть 78 или прибавить 24*28
	RET


; ──────────────────────────────────────────────

AFC34:	LD	HL,(TMPSTK)		; 18 bytes
	LD	SP,HL
	CALL	PUSK_VG
	LD	A,D
	OR	A
	JP	P,ERROR
	CALL	CHK_F4
	JP	AFB9C

; ──────────────────────────────────────────────

CLS:	LD	HL,76D0H		; 17 bytes
CLSLOO:	XOR	A
	LD	(HL),A
	INC	HL
	OR	H
	JP	P,CLSLOO
HOME:	LD	DE,308H
	LD	HL,SCBASE
	RET

; ──────────────────────────────────────────────

JJJ_02:	CALL	CHXHL_			; 12 bytes

; ──────────────────────────────────────────────
; Печать числа из ячейки памяти HL в 16-м формате и пробела
; ВХОД:
;	HL	- адрес байта числа для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

LDXHX_:	LD	A,(HL)

; ──────────────────────────────────────────────
; Печать числа из A в 16-м формате и пробела
; ВХОД:
;	A	- число для печати
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

HEXABL:	CALL	HEX_A

; ──────────────────────────────────────────────
; Печать пробела
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	A
; ──────────────────────────────────────────────

SPACE:	LD	A,20H
	JP	SCOUTA

; ──────────────────────────────────────────────
; Загрузка BC с поиском синхробайта
; ВХОД:
;	Нет
; ВЫХОД:
;	BC	- загруженные байта
; ИЗМЕНЯЕТ:
;	AF, BC
; ──────────────────────────────────────────────

LDBCSS: LD	A, 0FFH			; 14 bytes
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

LDBCBS:	LD	A, 8

; ──────────────────────────────────────────────
; Загрузка BC
; ВХОД:
;	A=008H	- без поиска синхробайта
;	A=0FFH	- с поиском синхробайта
; ВЫХОД:
;	BC	- загруженные байта
; ИЗМЕНЯЕТ:
;	AF, BC
; ──────────────────────────────────────────────

_LD_BC:	CALL	LDBYTE
	LD	B, A
	CALL	LDBS
	LD	C, A
	RET

; ──────────────────────────────────────────────

AF996:	CALL	CHK_F4			; 11 bytes
AF999:	CALL	CMPDH
	INC	HL
	RET	NZ
	DEC	HL
POPAF:	POP	AF
	RET

; ──────────────────────────────────────────────

	IF	VT52==0
	CHK	0FE63H, "* Internal point FE63 (need for emulator emu80) shifted ! *"
	ENDIF

; ──────────────────────────────────────────────
; Ввод символа с ожиданием. 
; ВХОД:
;	Нет
; ВЫХОД:
;	A - введенный символ
; ИЗМЕНЯЕТ:
;	AF		 TODO: проверить, что изменяет STATUS
; ──────────────────────────────────────────────

CONIN:	CALL	STATUS
	OR	A
	JP	Z,CONIN
	XOR	A
	LD	(KBDFLG),A
	LD	A,(LAST_K)
	RET

; ──────────────────────────────────────────────

BEEP:	LD	BC,05F0H		; 20 bytes
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

TABK1:	DB	0CH,1FH,1BH,0,1,2,3,4,5	  ; 9 bytes

; ──────────────────────────────────────────────

TOBACK: LD	(EK_ADR),HL		; 23 bytes
	EX	DE,HL
	LD	(POSX),HL
	LD	A,80H
	LD	(VG_75+1),A
	LD	A,L
	LD	(VG_75),A
	LD	A,H
	LD	(VG_75),A
	JP	POPREGA

; ──────────────────────────────────────────────

DIR_G:	JP	(HL)			; 1 bytes

; ──────────────────────────────────────────────

LD_BLK:	CALL	LDBS			; 10 bytes
	LD	(HL),A
	CALL	AF999
	JP	LD_BLK


; ──────────────────────────────────────────────
; Обработчик ESC-последовательности
; ВХОД:
;	C=ESC-код
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B, DE, HL
; ОПИСАНИЕ:
;	В зависимости от ключа VT52, собирается с полной эмуляцией терминала DEC VT-52 или только с поддержкой
;	позиционирования курсора, как в оригинальном МОНИТОРе. Поддерживаемые ESC-последовательности:
;		ESC A	- Cursor Up
;		ESC B	- Cursor Down
;		ESC C	- Cursor Right
;		ESC D	- Cursor Left
;		ESC E	- Clear screen (GEMDOS/TOS extension)
;		ESC F	- Alternate charset
;		ESC G	- Standard charset
;		ESC H	- Cursor Home
;		ESC I	- Reverse Line Feed
;		ESC J	- Erase to End Of Screen
;		ESC K	- Erase to End Of Line
;		ESC Y	- Direct Cursor Addressing
;		ESC Z	- Identify Terminal Type
;		ESC [	- Enter Hold Screen Mode
;		ESC \	- Exit Hold Screen Mode
; ──────────────────────────────────────────────

EscapeHandler:
	LD	A,C			; 19 bytes (без VT-52 и других расширений)
	IF	VT52
	SUB	'A'			;CP	'A'
	JP	Z, UP
	DEC	A			;CP	'B'
	JP	Z, DOWN
	DEC	A			;CP	'C'
	JP	Z, RIGHT
	DEC	A			;CP	'D'
	JP	Z, LEFT

	IF	TOS
	DEC	A			;CP	'E'
	JP	Z, CLS
	ENDIF

	IF	ALTCHAR
	IF	TOS
	DEC	A			;CP	'F'
	ELSE
	SUB	2			;CP	'F'
	ENDIF
	JP	Z, ESC_F
	DEC	A			;CP	'G'
	JP	Z, ESC_G
	DEC	A			;CP	'H'
	ELSE
	IF	TOS
	SUB	3			;CP	'H'
	ELSE
	SUB	4			;CP	'H'
	ENDIF
	ENDIF
	
	JP	Z, HOME
	DEC	A			;CP	'I'
	JP	Z, ESC_I
	DEC	A			;CP	'J'
	JP	Z, ESC_J
	DEC	A			;CP	'K'
	JP	Z, ESC_K
	SUB	15			;CP	'Z'
	;JP	Z, ESC_Z
	INC	A			;CP	'Y'
	;CP	'['
	;CP	'\'
	ELSE
	SUB	'Y'			;CP	'Y'
	ENDIF
	JP	NZ,ESCRES		; BUG для эмуляции VT-52 при повторном ESC выход из разбора последовательности не происходит
	CALL	HOME
	INC	A			;LD	A,2; ПРИНЯТО 2 БАЙТА ESC,'Y'

; ──────────────────────────────────────────────
; Обработчик ESC-символа
; ВХОД:
;	A=0
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF, B
; ──────────────────────────────────────────────

COD_1B:	INC	A			; LD A,1 - для COD_1B и LD A, 2 - для BYTE2
	DB	06H			; LD B, ... функционально JP	SETESC

; ──────────────────────────────────────────────
; Завершение обработки ESC-последовательности
; ВХОД:
;	Нет
; ВЫХОД:
;	Нет
; ИЗМЕНЯЕТ:
;	AF
; ──────────────────────────────────────────────

ESCRES:	XOR	A			; LD A, 0

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

	IF	VT52

; ──────────────────────────────────────────────

ESC_K:
	LD	A,L
	AND	0C0h
	ADD	A,40h	; конец строки
	LD	B, ' '
LF59A:	LD	(HL),B
	INC	HL
	CP	L
	JP	NZ,LF59A
	JP	ESCRES

; ──────────────────────────────────────────────

ESC_J:
	LD	A,0F0h	; конец экрана
	LD	B, ' '
LF581:	LD	(HL),B
	INC	HL
	CP	H
	JP	NZ,LF581
ESC_F:
ESC_G:
	JP	ESCRES

ESC_I:	CALL	UP
	JP	ESCRES

; ──────────────────────────────────────────────

TAB:
	RET
; ──────────────────────────────────────────────


	ENDIF
	
	IF	CPM
; Блок эмуляции точек входа BIOS
BIOSENTRY:
	JP      BDOS                    ; CBOOT Холодный старт
	JP      WARMST                  ; WBOOT Теплый старт
	JP      0F812H                  ; CONST Статус консоли
	JP      0F803H                  ; CONIN Консольный ввод
	JP      0F809H                  ; CONOUT Консольный вывод	
BIOSENTRYEND:
BDOS:	LD      HL, 0000H               ; Сохраняем стек
	ADD     HL, SP
	LD      (TMPSTK), HL
	LD      SP, STACK
	DEC     C
	JP      M, 0F800H               ; Функция 0 P_TERMCPM
	LD      HL, BDOSRET
	PUSH    HL
	LD      A, C
	LD      C, E
	JP      Z, FUNC01               ; Функция 1 C_READ
	DEC     A
	JP      Z, 0F809H               ; Функция 2 C_WRITE
	DEC     A
	JP      Z, FUNC03               ; Функция 3 A_READ
	DEC     A
	JP      Z, FUNC04               ; Функция 4 A_WRITE
	DEC     A
	JP      Z, FUNC05               ; Функция 5 L_WRITE
	DEC     A
	JP      Z, FUNC06               ; Функция 6 C_RAWIO
	DEC     A
	JP      Z, FUNC07               ; Функция 7 Get IOByte
	DEC     A
	JP      Z, FUNC08               ; Функция 8 Set IOByte
	DEC     A
	JP      Z, FUNC09               ; Функция 9 C_WRITESTR
	DEC     A
	JP      Z, FUNC0A               ; Функция 10 C_READSTR
	DEC     A
	JP      Z, 0F812H               ; Функция 11 C_STAT
	DEC     A
	JP      NZ, 0F800H              ; Функции 13 и выше
	LD      A, 20H                  ; Функция 12
	LD      B, 00H
FUNC03
FUNC04
FUNC05
	RET
	
; Set I/O Status Byte

FUNC08:	LD	(0003H),A ; And save it in RAM and fall through

; Get I/O Status Byte

FUNC07:	LD	A,(0003H) ; Get I/O byte from RAM
	RET

FUNC06:	INC	E		; Test for 0FFH
	JP	NZ,0F809H
	CALL	0F812H
	RET	Z
	JP	0F803H

FUNC09:	EX	DE, HL
FUNC09LP:
	LD	A, (HL)
	CP	'$'
	RET	Z
	CALL	SCOUTA
	INC	HL
	JP	FUNC09LP


FUNC0A:	LD      L, E
	LD      H, D
	LD      C, (HL)
	LD      B, 00H
	INC     HL
L008CH:	CALL    0F803H
	CP      08H
	JP      Z, L00B6H
	CALL	SCOUTA
	CP      0DH
	JP      Z, L00B2H
	CP      0AH
	JP      Z, L00B2H
	CP      03H
	JP      Z, 0F800H
	INC     HL
	LD      (HL), A
	INC     B
	LD      A, C
	CP      B
	JP      NZ, L008CH
	LD      B, C

L00B2H:	INC     DE
	EX      DE, HL
	LD      (HL), B
	RET

L00B6H:	LD	A, B
	OR	A
	JP	Z, L008CH
	DEC	B
	DEC	HL
	PUSH	HL
	CALL	RST_18
	DB	8, ' ', 8+80h		; см. TZABOJ
	POP	HL
	JP	L008CH

FUNC01:	CALL	0F803H
	JP	SCOUTA

BDOSRET:
	LD	HL, (TMPSTK)             ; Точка возврата из функции BDOS
	LD	SP, HL
	LD	L, A
	LD	H, B
	RET

INIT:
	PUSH	HL
	PUSH	DE
	LD	HL, BIOSENTRY
	LD	DE, 0
	LD	BC,
	JP	MOVLOO
	ENDIF
; ──────────────────────────────────────────────

TABK2:	DB	09,0AH,0DH,7FH,08H,19H,18H,1AH	; 8 bytes

; ──────────────────────────────────────────────

;if	RABADR	EQ 0F800H
;  if	$ eq 0
;	if1
;	.printx * Totally fit in 2K size ! *
;	endif
;  endif

;  if	$ ne	0

;      if high $ gt 0F8H
;	@FREE	EQU	1000H - ($ and 0FFFH)
;  	rept	256
;	if	$ ne 0
;	   defb	255
;	endif
;	endm
;      endif
;  endif

;  if	$ ge	1
;	if1
;	  .printx * Code length over 2048 bytes ! *
;	endif
;	@OVER	EQU	$
;  endif

;endif				; RABADR EQ 0F800H

	END

