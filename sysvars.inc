; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОРы для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52 и эмулятором CP/M
; ───────────────────────────────────────────────────────────────────────
;  Системные переменные МОНИТОРа по адресам 7600H-76СFH
; ═══════════════════════════════════════════════════════════════════════

; ──────────────────────────────────────────────
RABADR	EQU	0F800H		; Адрес начала ПЗУ
DOPPPA	EQU	0A000H		; Адрес дополнительного ППА
PPA	EQU	08000H		; Адрес основного ППА
K_ORIG	EQU	1		; если 0, то измененный курсор
BASE    EQU	7600H		; размер ОЗУ
BDOSST	EQU	BASE		; Начало BDOS

; ──────────────────────────────────────────────
;
; Область системных переменных в адресах 7600H-76D0H
;
; ──────────────────────────────────────────────

; Первых три байта занимает точка вызова BDOS
ESC_FL	EQU	BASE+04H		; 1 Флаг текущего статуса обработки Esc-последовательности
KBDFLG	EQU	BASE+05H		; 1 если =0, то есть символ в SYMBUF
RUSLAT	EQU	BASE+06H		; 1 допустимо только 0 или FF  !! Адрес должен быть xx06h иначе править SET_RL !!
LAST_K	EQU	BASE+07H		; 1 эти 2 байта должны следовать подряд
COUNT	EQU	BASE+08H		; 1 счётчик опросов (вначале 15)
APVFLG	EQU	BASE+09H		; 1 флаг автоповтора
TMPSTK	EQU	BASE+0AH		; 2 временно храним стек при МГ п/п-ммах
XYSTOR	EQU	BASE+0CH		; 2 Сохраненные координаты курсора
SASTOR	EQU	BASE+0EH		; 2 Сохраненный адрес курсора
CURST	EQU	BASE+10H		; 1 Отображать/прятать курсор
WRPFLG	EQU	BASE+11H		; 1 Автоперенос строк
RAMTOP	EQU	BASE+12H		; 2 Верхняя граница ОЗУ
EK_ADR  EQU	BASE+14H		; 2 текущий адрес на экране
POSX	EQU	BASE+16H		; 1 Координаты курсора. Порядок важен.
POSY	EQU	BASE+17H		; 1
KNS_WR	EQU	BASE+18H		; 1 константа записи
PAR_HL  EQU	BASE+19H		; 2
PAR_DE  EQU	BASE+1BH		; 2
PAR_BC  EQU	BASE+1DH		; 2
FLG_P2	EQU	BASE+1FH		; 1 флаг, что есть параметры 2 или 2,3
INV_MG	EQU	BASE+20H		; 1 флаг инверсии магнитофона
KNS_RD	EQU	BASE+21H		; 1 Константа чтения
BUFSIZ	EQU	BASE+22H		; 1 Размер буфера ввода
BUFCNT	EQU	BASE+23H		; 1 Число введенных символов в буфер ввода
COMBUF	EQU	BASE+24H		; COMBUFMAX буфер ввода директивы
COMBUFMAX	EQU	29		; Максимальный размер буфера ввода команд
STACK	EQU	BASE+0D0H		; стек монитора

ROMBUF	EQU	BASE+40H		; ROMBUFMAX буфер подкачки кода из ROM-диска (только для МОНИТОРа 2.0)
ROMBUFMAX	EQU	128		; размер буфера подкачки из ROM-диск

SA	EQU	BASE+0D0H		; 76D0 начало экранной области
SCBASE  EQU	BASE+01C2H		; 77C2 ЛЕВ.ВЕРХН.УГОЛ ЭКР.

MARGIN_TOP	EQU	3
MARGIN_BOTTOM	EQU	3		;?
MARGIN_LEFT	EQU	8
MARGIN_RIGHT	EQU	8		;?
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
