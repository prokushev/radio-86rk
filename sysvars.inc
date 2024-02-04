; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОРы для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52 и эмулятором CP/M
; ───────────────────────────────────────────────────────────────────────
;  Системные переменные МОНИТОРа по адресам 7600H-76СFH или 3600H-36СFH
; ═══════════════════════════════════════════════════════════════════════

; ──────────────────────────────────────────────
RABADR	EQU	0F800H		; Адрес начала ПЗУ
PPA		EQU	08000H		; Адрес основного ППА
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

; Первых три байта занимает точка входа в BDOS

;@todo Эти два адреса использует бейсик микрон в команде CUR, надо делать совместимо со стандартным МОНИТОРом
;7600h
;7602h
; Следующие 3 переменные должны иметь указанный порядок, иначе править ColdBoot
RAMTOP	EQU	BASE+03H		; 2 FIXED Верхняя граница ОЗУ
CURST	EQU	BASE+05H		; 1 FIXED Отображать/прятать курсор
RUSLAT	EQU	BASE+06H		; 1 FIXED допустимо только 0 или FF  !! Адрес должен быть xx06h иначе править SET_RL !!
; Эти две переменные должны следовать подряд
COUNT	EQU	BASE+08H		; 1 счётчик опросов (вначале 15)
APVFLG	EQU	BASE+09H		; 1 флаг автоповтора
TMPSTK	EQU	BASE+0AH		; 2 временно храним стек при МГ п/п-ммах и функциях BDOS
XYSTOR	EQU	BASE+0CH		; 2 Сохраненные координаты курсора
LAST_K	EQU	BASE+10H		; 1 
WRPFLG	EQU	BASE+11H		; 1 Автоперенос строк

ESC_FL	EQU	BASE+12H		; 1 Флаг текущего статуса обработки Esc-последовательности (0,1,2)
KBDFLG	EQU	BASE+13H		; 1 если =0, то есть символ в SYMBUF

; Эти две переменные должны идти подряд
POSX	EQU	BASE+16H		; 1 Координаты курсора
POSY	EQU	BASE+17H		; 1
PAR_HL	EQU	BASE+18H		; 2 Первый параметр
PAR_DE	EQU	BASE+1AH		; 2 Второй параметр
PAR_BC	EQU	BASE+1CH		; 2 Третий параметр
FLG_P2	EQU	BASE+1EH		; 1 флаг, что есть параметры 2 или 2,3
INV_MG	EQU	BASE+1FH		; 1 флаг инверсии магнитофона
TRK		EQU	BASE+20H		; 2 Номер трека
SECT	EQU	BASE+22H		; 2 Номер сектора
DMA		EQU	BASE+24H		; 2 Адрес буфера обмена с диском

ListHandler	EQU	BASE+26H	; 3 JP DefaultListHandler

PrintHandler	EQU	BASE+29H	; 3 JP DefaultPrintHandler

BeepHandler	EQU	BASE+2CH	; 3 JP DefaultBeepHandler

; Эти две переменные должны идти подряд. Адреса переменных документированы,
; менять нельзя
KNS_RD	EQU	BASE+2FH		; 1 FIXED Константа чтения
KNS_WR	EQU	BASE+30H		; 1 FIXED константа записи

; Эти три переменные должны подряд для совместимости с CP/M. 
; Адрес COMBUF менять нельзя
BUFSIZ	EQU	BASE+31H		; 1 FIXED Размер буфера ввода
BUFCNT	EQU	BASE+32H		; 1 FIXED Число введенных символов в буфер ввода
COMBUF	EQU	BASE+33H		; COMBUFMAX FIXED буфер ввода директивы

COMBUFMAX	EQU	10H			; Максимальный размер буфера ввода команд

ROMBUF	EQU	COMBUF;+COMBUFMAX		; ROMBUFMAX буфер подкачки кода из ROM-диска
ROMBUFMAX	EQU	80H			; размер буфера подкачки из ROM-диск

STACK	EQU	BASE+0D0H		; стек монитора

SA		EQU	BASE+0D0H		; 76D0 начало экранной области
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
