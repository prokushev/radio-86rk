; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОРы для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52
; ───────────────────────────────────────────────────────────────────────
;  Системные переменные МОНИТОРа по адресам 7600H-76СFH или 3600H-36СFH
; ═══════════════════════════════════════════════════════════════════════

; ──────────────────────────────────────────────
RABADR	EQU	0F800H		; Адрес начала ПЗУ
PPA	EQU	08000H		; Адрес основного ППА
DOPPPA	EQU	0A000H		; Адрес дополнительного ППА
K_ORIG	EQU	1			; если 0, то измененный курсор
	IFNDEF BASE
BASE	EQU	7600H		; размер ОЗУ
	ENDIF
BDOSST	EQU	BASE		; Начало BDOS

; ──────────────────────────────────────────────
;
; Область системных переменных в адресах 7600H-76D0H или 3600H-36СFH
;
; ──────────────────────────────────────────────

POSADDR	EQU	BASE+00H		; 2 FIXED Адрес курсора
POSX	EQU	BASE+02H		; 1 FIXED Координата курсора X
POSY	EQU	BASE+03H		; 1 FIXED Координата курсора Y
ESC_FL	EQU	BASE+04H		; 1 FIXED Флаг текущего статуса обработки Esc-последовательности (0,1,2)
KBDFLG	EQU	BASE+05H		; 1 FIXED если =0, то есть символ в LAST_K
RUSLAT	EQU	BASE+06H		; 1 FIXED допустимо только 0 или FF  !! Адрес должен быть xx06h иначе править SET_RL !!

; ---- нестандарт ----------
XYSTOR	EQU	BASE+07H		; 2 Сохраненные координаты курсора
; ---- нестандарт ----------

LAST_K	EQU	BASE+09H		; 1 FIXED Код последней клавиши
COUNT	EQU	BASE+0AH		; 1 FIXED счётчик опросов (вначале 15)
APVFLG	EQU	BASE+0BH		; 1 FIXED флаг автоповтора
TMPSTK	EQU	BASE+0DH		; 2 FIXED временно храним стек при МГ п/п-ммах

; ---- нестандарт ----------
IDENT	EQU	BASE+0FH		; 1 Флаг обработки Esc-Z
WRPFLG	EQU	BASE+10H		; 1 Вкл/выкл Автоперенос строк
AltChars	EQU	BASE+11H	; 1 Вкл/выкл графрежим
Echo	EQU	BASE+12H		; 1 Вкл/выкл Auto-Copy
CURST	EQU	BASE+13H		; 1 Вкл/выкл курсор

DirectiveHandle	EQU	BASE+14H	; 3 JP DirectiveHandle Для опробации идеи одного цикла и сменного обработчика директив
PrintHandler	EQU	BASE+17H	; 3 JP DefaultPrintHandler
BeepHandler	EQU	BASE+1AH	; 3 JP DefaultBeepHandler
ReadKeyCodeHandler		EQU	BASE+1DH	; 3 JP DefaultReadKeyCodeHandler
TapeInHandler	EQU	BASE+20H	; 3 JP DefaultTapeInHandler
TapeOutHandler	EQU	BASE+23H	; 3 JP DefaultTapeOutHandler

; 1 байт - дырка
; ---- нестандарт ----------

PAR_HL	EQU	BASE+27H		; 2 FIXED Первый параметр
PAR_DE	EQU	BASE+29H		; 2 FIXED Второй параметр
PAR_BC	EQU	BASE+2BH		; 2 FIXED Третий параметр
FLG_P2	EQU	BASE+2DH		; 1 FIXED флаг, что есть параметры 2 или 2,3
INV_MG	EQU	BASE+2EH		; 1 FIXED флаг инверсии магнитофона
KNS_RD	EQU	BASE+2FH		; 1 FIXED Константа чтения
KNS_WR	EQU	BASE+30H		; 1 FIXED константа записи
RAMTOP	EQU	BASE+31H		; 2 FIXED Верхняя граница ОЗУ

COMBUF	EQU	BASE+33H		; 16 FIXED буфер ввода директивы
COMBUFSIZE	EQU	16		;    16 байт из расчета 15 символов на директиву+0dh

;-------BASE+44H --------------------

; ---- нестандарт ----------
MINXY		EQU	BASE+50H	; 2 Левый верхний угол области вывода
MAXXY		EQU	BASE+51H	; 2 Правый нижний угол области вывода
; ---- нестандарт ----------

ListHandler	EQU	BASE+53H	; 3 JP DefaultListHandler

STACK	EQU	BASE+0D0H		; стек монитора (растет в сторону буфера ввода директив)

SA	EQU	BASE+0D0H		; 76D0 начало экранной области
SCBASE  EQU	BASE+01C2H		; 77C2 ЛЕВ.ВЕРХН.УГОЛ ЭКР.

MARGIN_TOP	EQU	3
MARGIN_BOTTOM	EQU	3
MARGIN_LEFT	EQU	8
MARGIN_RIGHT	EQU	8
SC_WIDTH	EQU	78

VG_75   EQU	0C000H
VT_57   EQU	0E000H

PA	EQU	PPA
PB	EQU	PA+1
PC	EQU	PA+2
PU	EQU	PA+3

PDA	EQU	DOPPPA
PDB	EQU	PDA+1
PDC	EQU	PDA+2
PDU	EQU	PDA+3
