; Драйвер "оконного" интерфейса для МОНИТОРа 1.20 на
; базе драйвера, опубликованного в Радио 1990 года №3

	CPU 8080
	Z80SYNTAX EXCLUSIVE
	ORG 0

	include syscalls.inc
	include sysvars.inc
	
	JP 	TEST		;ПЕРЕХОД НА ТЕСТИРОВАНИЕ ДР.
PRINTC:	JP	0F809H		;ВЫВОД СИМВОЛА ЧЕРЕЗ МОНИТОР
PrintCH	EQU	PRINTC+1	; Патч адреса
INPUT:	PUSH	HL
	LD	HL, CURON
	CALL	WRITE
	CALL	0F803H		; ввод символа с клавиатуры 
	PUSH	AF
	LD	HL, CUROFF
	CALL	WRITE		; выключаем курсор
	POP	AF
	POP	HL
	RET
LOADM:	JP	0F821H		;запрос символа над курсором
LDCUR:	JP	0F81EH		;ЗАПРОС ПОЛОЖЕНИЯ КУРСОРА
STATUS:	JP	0F812H		;Состояние клавиатуры
WBOOT:	JP	0F86CH		;Возврат в МОНИТОР
	; ОПИСАНИЕ РАБОЧИХ ПОЛЕЙ ДРАЙВЕРА
BASEAD:	EQU	6000H 		;АДРЕС НАЧАЛА РАБ. ОБЛАСТИ
WPARM:	EQU	BASEAD 		;РАЗМЕР ОКНА (ВЕРТ./ГОРИЭ.>
WHOME:	EQU	WPARM+2 	;ПОЛОЖЕНИЕ ВЕРХ. ЛЕВОГО УГЛА
WCURSR:	EQU	WHOME+2 	;ПОЛОЖЕНИЕ КУРСОРА
NUMWND:	EQU	WCURSR+2	;НОМЕР АКТИВНОГО ОКНА
ADRSP:	EQU	NUMWND+1	; АДРЕС СВОБОДНОЙ ОБЛАСТИ
TXTCUR:	EQU	ADRSP+2 	; РАБОЧИЕ ЯЧ. ДЛЯ УСТ.КУСОРА

INITSP:	DW	TXTCUR+5 	;АДРЕС ОБЛАСТИ СОХРАНЕНИЯ ЭК.


;********************************************
;* RESETW - инициализация драйвера оконного *
;* интерфейса                               *
;********************************************

RESETW:	PUSH HL
	CALL	VT52DETECT	; Определяем наличие VT-52
	OR	A
	JP	NZ, NOTFOUND	; Не нашли
FOUND:	;XOR	A 		; ОБНУЛЕНИЕ НОМЕРА (уже 0)
	LD	(NUMWND),A	; АКТИВНОГО ОКНА 
	LD	HL, (INITSP) 	; ИНИЦИИРУЕМ АДРЕС НАЧАЛА ОЗУ 
	LD	(ADRSP), HL 	; ДЛЯ СОХРАНЕНИЯ ЭКРАНОВ

	; Подготавливаем данные для строки установки координат
	LD	(TXTCUR+4), A	; ПРИЗНАК КОНЦА СТРОКИ 
	LD	HL, ('Y'<<8) | 1Bh
	LD	(TXTCUR), HL	; 1BH 'Y'
	
	; Подключаем нашу процедуру вывода символа
	LD	HL, (PrintHandler+1)
	LD	(PrintCH), HL
	
	LD	HL, WRITEC
	LD	(PrintHandler+1), HL
	
	POP	HL
	RET

NOTFOUND:
	CALL	PRINTI		; Пишем, что не нашли VT-52
	DB	0DH, 0AH, "VT-52 ne najden", 0
	;POP	HL		; Можно не восстанавливать
	JP	WBOOT		; Возвращаемся в МОНИТОР

	Z80SYNTAX OFF
;+++++++++++++++++++++++++++++++++++++++++++++++
;+SAVEW - СОХРАНЕНИЕ ОБЛАСТИ ЭКРАНА ЗАНИМАЕМОЙ +
;+ ПОД ОТКРЫВАЕМОЕ ОКНО                        +
;+ВХОД: H,L- КООРДИНАТЫ ЛЕВОЙ ВЕРШИНЫ ОКНА     +
;+ D,Е- РАЗМЕРЫ ОКНА С РАМКОЙ (СТРК/СТЛБ)      +
SAVEW:	PUSH D 		; СОХРАНЯЕМ РЕГИСТРЫ
	PUSH H
	PUSH H 		;КООРДИНАТЫ ОКНА
	CALL CURIN 	;ЗАГРУЖАЕМ ПОЛОЖЕНИЕ КУРСОРА
	SHLD WCURSR 	;СОХРАНЯЕМ ПОЛОЖЕНИЕ КУРСОРА
	LHLD ADRSP 	;АДРЕС СТЕКА ОБЛАСТИ СОХРАН.
SAW10:	XTHL 		;КООРДИНАТЫ ОКНА В HL
	CALL CUROUT 	;УСТАНАВЛИВАЕМ КУРСОР
	INR H 		;ГОТОВИМ СЛЕДУЮЩУЮ СТРОКУ
	XTHL 		;СОХРАНЯЕМ КООРДИНАТЫ В СТЕКЕ
	MOV B,E 	;РАЗМЕР ОКНА ПО ГОРИЗОНТАЛИ
SAW20:	CALL LOADM 	;БАЙТ ИЗ ЭКРАННОЙ ОБЛАСТИ
	MOV M, A 	;СОХРАНЯЕМ ЕГО В РАБ.ОБЛАСТИ
	INX H 		;УВЕЛИЧИВАЕМ АДРЕС
	MVI C,18H 	;СДВИГАЕМ КУРСОР ВПРАВО
	CALL PRINTC
	DCR B 		;УМЕНЬШАЕМ СЧЕТЧ.ШИРИНЫ ОКНА
	JNZ SAW20 	;ЦИКЛ ПО СИМВОЛАМ СТРОКИ
	DCR D 		;УМЕНЬШАЕМ СЧЕТЧ.ВЫСОТЫ ОКНА
	JNZ SAW10 	;ЦИКЛ ПО СТРОКАМ
	INX SP 		;ПРОПУСКАЕМ КООРДИНАТЫ ОКНА
	INX SP 		;В СТЕКЕ
	XCHG 		;ПЕРЕСЫЛАЕМ АДР.РАБ.ОБЛАСТИ
	LHLD WHOME 	;СОХРАНЯЕМ КООРД. АКТ.ОКНА
	CALL SAVPP 	;В РАБОЧЕЙ ОБЛАСТИ
	LHLD WPARM 	;СОХРАНЯЕМ ПАРАМЕТРЫ ОКНА
	CALL SAVPP
	LHLD WCURSR 	; СОХРАНЯЕМ ПОЗИЦИИ КУРСОРА
	CALL SAVPP
	LHLD ADRSP 	; СОХРАНЯЕМ АДР.НАЧАЛА ОБЛАСТИ
	CALL SAVPP 	;ПОД АКТИВНОЕ ОКНО
	XCHG 		;ОБНОВЛЯЕМ АДРЕС НАЧАЛА
	SHLD ADRSP 	;СВОБОДНОЙ РАБ. ОБЛАСТИ
	LXI H, NUMWND 	;УВЕЛИЧИВАЕМ НОМЕР
	INR M 		;АКТИВНОГО ОКНА
	POP H 		;ВОССТАНАВЛИВАЕМ РЕГИСТРЫ
	POP D
	RET
; SAVPP - ПОДПРОГРАММА ПОМЕЩЕНИЯ ПАРАМЕТРОВ
; ' АКТИВНОГО ОКНА В СТЕК ДРАЙВЕРА
SAVPP:	XCHG 		; АДРЕС ПЕРЕСЫЛАЕМ В HL
	MOV M, E 	; МЛАДШИЙ БАЙТ ПАРАМЕТРА
	INX H
	MOV M, D 	; СТАРШИЙ БАЙТ ПАРАМЕТРА
	INX H
	XCHG 		; ВОССТАНАВЛИВАЕМ АДРЕС В DE
	RET
;+RESTW - СТИРАНИЕ АКТИВНОГО ОКНА И ВОССТА- +
;+ НОВЛЕНИЕ СОДЕРЖИМОГО ЭКРАНА              +
;++++++++++++++++++++++++++++++++++++++++++++
RESTW:	PUSH H
	PUSH D
	PUSH B
	LDA NUMWND 	; ПРОВЕРЯЕМ НОМЕР АКТ. ОКНА 
	DCR A 		; ЕСЛИ ОТКРЫТОГО ОКНА НЕТ, 
	JM RESRET 	; ТО ВЫХОДИМ. ИНАЧЕ УМЕНЬШАЕМ 
	STA NUMWND 	; НОМЕР АКТИВНОГО ОКНА 	
	LHLD ADRSP 	; НАЧИНАЕМ ВОССТАНОВЛЕНИЕ 
	XCHG 		; ПАРАМЕТРОВ ПРЕДПОСЛ. ОКНА 
	CALL RESPP 	; АДРЕС РАБОЧЕЙ ОБЛАСТИ ОКНА 
	SHLD ADRSP 	;
	CALL RESPP 	; ПОЗИЦИЯ КУРСОРА 
	SHLD WCURSR 	; 
	CALL RESPP 	; РАЗМЕРЫ ОКНА 
	PUSH H
	CALL RESPP 	; КООРДИНАТЫ ОКНА PUSH H
	PUSH H
	LHLD WPARM 	; ЗАГРУЖАЕМ РАЗМЕР СТИР. 
	XCHG 		; ОКНА 
	INR D 		; УЧИТЫВАЕМ РАМКУ 
	INR D
	LHLD WHOME 	; ЗАГРУКАЕМ КООРДИНАТЫ 
	DCR H 		; СТИРАЕМОГО ОКНА 
	DCR L 		; И УЧИТЫВАЕМ РАМКУ 
	PUSH H 		; СОХРАНЯЕМ ЕГО В СТЕКЕ 
	LHLD ADRSP 	; АДРЕС ОБЛАСТИ СОХР. ОКНА 
RES10:	XTHL 		; КООРДИНАТЫ ОКНА В (H.L) 
	CALL CUROUT 	; КУРСОР В УГОЛ РАМКИ 
	INR H 		; ГОТОВИМСЯ К СЛЕД.СТРОКЕ 
	XTHL 		; АДРЕС 08Л.СОХР. В (H,L)
	MOV B,E 	; счетчик ширины окна
RES20:	MOV C,M 	; ВОССТАНАВЛИВАЕМ СОДЕРЖ.
	MOV	A, C	; Проверяем на графсимволы
	CPI	20H
	JNC	NOTGRAPH
	Z80SYNTAX EXCLUSIVE
	PUSH	HL
	LD	HL, GRON	; Включаем графрежим
	CALL	WRITE
	LD	A, 5Fh		; Корректируем код графсимвола
	ADD	A, C
	LD	C, A
	CALL	PRINTC
	LD	HL, GROFF	; Выключаем графрежим
	CALL	WRITE
	POP	HL
	JP	NEXT
	Z80SYNTAX OFF
NOTGRAPH:	
	CALL PRINTC 	; ЭКРАНА
NEXT:	INX H 		; УВЕЛИЧИВАЕМ АДРЕС
	DCR B 		; НИКЛ ПО СТРОКЕ
	JNZ RES20
	DCR D 		; ЦИКЛ ПО СТРОКАМ
	JNZ RES10
	INX SP 		; ПРОПУСКАЕМ РАБОЧУЮ
	INX SP 		; ПЕРЕМЕННУЮ В СТЕКЕ
	POP D 		; КООРДИНАТЫ
	POP H 		; И РАЗМЕРЫ ОКНА
	SHLD WPARM 	; ПОМЕЩАЕМ В РАБОЧИЕ
	XCHG 		; ЯЧЕЙКИ ДРАЙВЕРА SHLD WHOME
	SHLD WHOME
	LHLD WCURSR 	; ВОССТАНАВЛИВАЕМ ПОЗИЦИЮ 
	CALL CUROUT 	; КУРСОРА 
RESRET:	POP B 		; ВОССТАНАВЛИВАЕМ РЕГИСТРЫ
	POP D 		; и выход
	POP H 
	RET
; _________________________________________________
; RESPP - ПОДПРОГРАММА ЗАГРУЗКИ ПАРАМЕТРОВ ОКНА
; _________________________________________________
RESPP:	XCHG
	DCX H 		; ЗАГРУЖАЕМ ДВА БАЙТА
	MOV D, M 	; ИЗ ОБЛАСТИ СОХРАНЕНИЯ
	DCX H 		; ПЕРЕСЫЛАЕМ ИХ В (H,L)
	MOV E,M
	XCHG 
	RET 		; ВЫХОД
;+ FRAME - РИСОВАНИЕ РАМКИ ОКНА И ФОРМИРОВАНИЕ +
;+ ПАРАМЕТРОВ ОКНА                             +
;+ ВХОД : H,L- КООРДИНАТЫ OKHA, D, E РАЗМЕРЫ   +
FRAME:	PUSH D 		; СОХРАНЯЕМ РЕГИСТРЫ 
	PUSH H
	LXI H, GRON
	CALL	WRITE	; включаем графрежим
	POP	H
	PUSH	H
	CALL CUROUT 	; КУРСОР В УГОЛ РАМКИ 
	DCR D 		; УМЕНЬШАЕМ ВЫСОТУ РАМКИ 
	DCR D
	MOV B, E 	; ШИРИНУ РАМКИ В СЧЕТЧИК 
	LXI H, FRTEXT 	; АДРЕС ВЕРХНЕЙ ЛИНИИ 
	CALL DRWFR 	; РИСУЕМ ЛИНИЮ И УГОЛ 
	MOV B, D 	; ВЫСОТУ РАМКИ В СЧЕТЧИК
	CALL DRWFR 	; РИСУЕМ ПРАВУЮ ЛИНИИ
	MOV B,E 	; ширину рамки в счетчик
	DCR B
	CALL DRWFR 	; РИСУЕМ НИЖНЮЮ ЛИНИЮ
	MOV B, D 	; ВЫСОТУ РАМКИ В СЧЕТЧИК
	CALL DRWFR 	; РИСУЕМ ЛЕВУЮ ЛИНИЮ И
	CALL CURIN 	; ЗАГРУЖАЕМ КООРДИНАТЫ
	SHLD WHOME 	; ПОЛОЖЕНИЯ НОМЕ ОКНА
	XCHG
	SHLD WPARM 	; ЗАПИСЫВАЕМ РАЗМЕРЫ АКТ.
	LXI H, GROFF
	CALL	WRITE	; выключаем графрежим
	POP H 		; ОКНА
	POP D 		; ВОССТАНАВЛИВАЕМ РЕГИСТРЫ
	RET
;-DRWFR - РИСОВАНИЕ СТОРОНЫ И УГЛА РАМКИ 
;-ВХОД: В - ДЛИНА СТОРОНЫ
DRWFR:	DCR B 		; ЕСЛИ ДЛИНА 1
	JZ DRR20 	; ОБХОДИМ ЦИКЛ ПО ДЛИНЕ СТОР. 
DRW10:	PUSH H 		; РИСУЕМ В-1 СИМВОЛОВ СТОРОНЫ
	CALL WRITE
	POP H
	DCR B
	JNZ DRW10 
DRR20:	CALL WRITE 	; РИСУЕМ ПОСЛЕДНИЙ СИМВОЛ
	INX H
	CALL WRITE 	; ПРОРИСОВЫВАЕМ УГОЛ
	INX H 		; готовим адрес очереди. стор.
	RET
; ДАННЫЕ ДЛЯ ПОСТРОЕНИЯ РАМКИ 
GRON:	DB	1bh, 'F',0	; вкл граф.режим
GROFF:	DB	1bh, 'G',0	; выкл граф.режим
FRTEXT:	DB	03H+5fh, 0		; ВЕРХНЯЯ СТОРОНА
	DB	8,7+5fh,1AH, 8, 0 	; УГОЛ
	DB	06H+5fh, 1AH, 8, 0 	; ПРАВАЯ СТОРОНА
	DB	16h+5fh, 8, 8, 0	; УГОЛ
	DB	14H+5fh, 8, 8, 0	; НИЖНЯЯ СТОРОНА
	DB	18H,15h+5fh, 8,19H,0	; УГОЛ
	DB	11H+5fh, 19H, 8, 0	;ЛЕВАЯ СТОРОНА
	DB	13h+5fh, 1AH,0		; Угол+КУРСОР В ЛЕВЫЙ ВЕРХНИЙ УГОЛ

;WRITE - ВЫВОД ТЕКСТА ЧЕРЕЗ МОНИТОР. +
; АНАЛОГ П/П МОНИТОРА 0F818H )            +
;ВХОД: HL - АДРЕС НАЧАЛА ТЕКСТА.          +
WRITE:	MOV A, M 	; ВЫВОДИМ ВСЕ СИМВОЛЫ
	ORA A 		; ДО НУЛЯ
	JZ WRTRET
	PUSH B
	MOV C, A 	; ЧЕРЕЗ
	CALL PRINTC 	; ПОДПРОГРАММУ F809H
	POP B
	INX H
	JMP WRITE 
WRTRET:	;INX H
	RET

	
;++++++++++++++++++++++++++++++++++++++++++++
; WRITEC - ВЫВОД СИМВОЛА ЧЕРЕЗ ДРАЙВЕР ОКНА +
; АНАЛОГ П/П МОНИТОРА 0F809Н                +
; ВХОД: С - КОД СИМВОЛА                     +
;++++++++++++++++++++++++++++++++++++++++++++
WRITEC:	PUSH PSW
	LDA NUMWND 	; ПРОВЕРЯЕМ НАЛИЧИЕ
	ORA A 		; АКТИВНОГО ОКНА
	JZ WRC30 	; ЕСЛИ НЕТ- ЧЕРЕЗ МОНИТОР
	MOV A, C 	; РЕЗЕРВИРУЕМ ВОЗМОЖНОСТЬ
	ORA A 		; ИЗМЕНЕНИЯ АТРИБУТОВ ВГ-75
	JM WRC30
	CPI 0DH 	; УПРАВЛЯЮШИЕ СИМВОЛЫ
	JNZ WRC10 	; 0Dн
	CALL WR0D
	JMP WRCRET 
WRC10:	CPI 0CH 	; 0CH
	JNZ WRC20
	CALL WR0C
	JMP WRCRET 
WRC20:	CPI 1FH 	; 1FH
	JNZ WRC30
	CALL WR1F 	; ОБРАБАТЫВАЮТСЯ П/П ДРАЙВЕРА
	JMP WRCRET
WRC30:	CALL PRINTC 	; ОСТАЛЬНЫЕ СИМВОЛЫ В МОНИТОР 
WRCRET:	POP PSW
	RET
; WR0D - ОБРАБОТКА СИМВОЛА 0DН +
WR0D:	PUSH B
	MVI C, 0DH 	; КУРСОР В НАЧАЛО СТРОКИ 
	CALL PRINTC
	LDA WHOME 	; МЛАДШИЙ БАЙТ В WHOME 
	MOV B, A 	; КООРДИНАТА ПО СТОЛБЦАМ 
	MVI C, 18H 	; ПЕРЕДВИГАЕМ КУРСОР НА
WRDL0:	CALL PRINTC 	; ПЕРВУЮ ПОЗИЦИЮ ВНУТРИ ОКНА
	DCR B
	JNZ WRDL0 
	POP B 
	RET
; WR0C - ОБРАБОТКА СИМВОЛА 0СН +
WR0C:	PUSH H
	LHLD WHOME 	; УСТАНАВЛИВАЕМ КУРСОР В 
	CALL CUROUT 	; В ВЕРХНИЙ ЛЕВЫЙ УГОЛ
	POP H 		; ОКНА ВНУТРИ РАМКИ
	RET
; WR1F - ОБРАБОТКА СИМВОЛА 1FH +
WR1F:	PUSH H 		; СОХРАНЯЕМ ИСПОЛЬЗУЕМЫЕ
	PUSH D 		; РЕГИСТРЫ
	PUSH B
	LHLD WPARM 	; ЗАГРУЖАЕМ РАЗМЕРЫ ОКНА
	XCHG
	LHLD WHOME 	; ЗАГРУЖАЕМ КООРДИНАТЫ ОКНА 
WRF10:	CALL CUROUT 	; КУРСОР В НАЧАЛО СТРОКИ ОКНА
	MOV B, E 	; РАЗМЕР ОКНА ПО СТОЛБЦАМ
	DCR B 		; УЧИТЫВАЕМ РАМКУ
	DCR B 		; СЧЕТЧИК ПО СТОЛБЦАМ 
WRF20:	MVI C,' ' 	; ОБНУЛЯЕМ СТРОКУ
	CALL PRINTC
	DCR B 		; ЦИКЛ ПО СИМВОЛАМ СТРОКИ
	JNZ WRF20
	INR H 		; ГОТОВИМ КООРД. СЛЕД. СТРОКИ
	DCR D 		; УМЕНЬШАЕМ СЧЕТЧИК СТРОК
	JNZ WRF10 	; ЦИКЛ ПО СТРОКАМ ОКНА
	CALL WR0C 	; КУРСОР В ВЕРХНИЙ ЛЕВЫЙ УГОЛ
	POP B
	POP D 		; ВОССТАНАВЛИВАЕМ РЕГИСТРЫ
	POP H
	RET
;+++++++++++++++++++++++++++++++++++++
;+CURIN - ЗАГРУЗКА КООРДИНАТ КУРСОРА +
;+ВЫХОД: <Н> - НОМЕР СТРОКИ          +
;+ (L) - НОМЕР СТОЛБЦА               +
CURIN:	CALL LDCUR 	; ЗАГРУЖАЕМ КООРД. КУРСОРА 
	PUSH D 		; В ФОРМАТЕ МОНИТОРА 
	LXI D,0FCF8H 	; ПРИВОДИМ К НОРМАЛЬНОМУ ВИДУ 
	DAD D 		; ОТ <0,0> ДО <24,63) 
	POP D 
	RET

;+CUROUT - УСТАНОВКА КУРСОРА В ЗАДАННУП ПОЗИЦИЮ +
;+ВХОД: <Н) - НОМЕР СТРОКИ                      +
;+ (L) - НОМЕР СТОЛБЦА                          +
;++++++++++++++++++++++++++++++++++++++++++++++++
CUROUT:	PUSH H 		; СОХРАНЯЕМ РЕГИСТРЫ 
	PUSH D 
	PUSH B
	LXI D,2020H 	; ГОТОВИМ: 20H+<l ) И 20Н+(Н) 
	DAD D
	XCHG 		; ПЕРЕСЫЛАЕМ В <l),L> 
	LXI H, TXTCUR+3

	MOV M,E 	; ESCAPE ПОСЛЕДОВАТЕЛЬНОСТЬ 
	DCX H 		; АР2,'Y',20Н+(Н>>20H+<L>,0 
	MOV M,D
	LXI H, TXTCUR
	CALL WRITE 	; УСТАНАВЛИВАЕМ КУРСОР ЧЕРЕЗ 
	POP B 		; МОНИТОР 
	POP D 
	POP H 
	RET

;---------------------------------------------------
; Определение наличия терминала VT-52
; ВХОД
;	нет
; ВЫХОД
;	A=0 - есть терминала
;	A<>0 - нет терминала
;	не установлен Z - нет терминала
;---------------------------------------------------
	Z80SYNTAX EXCLUSIVE
VT52DETECT:
	CALL	PRINTI
	DB	1BH, 'Z', 0
	CALL	STATUS
	INC	A
	RET	NZ
	CALL	INPUT
	CP	1BH
	RET	NZ
	CALL	STATUS
	INC	A
	RET	NZ
	CALL	INPUT
	CP	'/'
	RET	NZ
	CALL	STATUS
	INC	A
	RET	NZ
	CALL	INPUT
	CP	'K'		; VT-52
	JP	Z, VDFOUND
	CP	'L'		; VT-52 + Copier
	JP	Z, VDFOUND
	CP	'M'		; VT-52 + Printer
	JP	Z, VDFOUND
	CP	'Z'		; VT-100 or similar in VT-52 Emulation mode
	RET	NZ
VDFOUND:XOR	A		
	RET

;---------------------------------------------------
; Печать строки сразу за вызовом
;---------------------------------------------------
PRINTI:	EX	(SP),HL			; 6 bytes
	CALL	PrintString
	EX	(SP),HL
	RET

	Z80SYNTAX OFF

;***************** ТЕСТОВАЯ ПРОГРАММА ************************
	Z80SYNTAX EXCLUSIVE
TEST:
	CALL	RESETW 		; ИНИЦИАЛИЗИРУЕМ ДРАЙВЕР
TESTLOOP:
	CALL	PRINTI
	DB	1fh, 'standartnye simwoly:', 0dh, 0ah,0

	LD	C, ' '
LLP:	CALL	PRINTC
	INC	C
	LD	A, 80h
	CP	C
	JP	NZ, LLP

	CALL	PRINTI
	DB	0dh,0ah,'grafi~eskie simwoly:', 0dh, 0ah,0

	LD	HL, GRON
	CALL	WRITE	; включаем графрежим

	LD	C, ' '
LLP2:	CALL	PRINTC
	INC	C
	LD	A, 80h
	CP	C
	JP	NZ, LLP2

	LD	HL, GROFF
	CALL	WRITE	; выключаем графрежим

STEP1:
	CALL	PRINTI		; выключаем курсор
	DB	1bh, 'f',0	; Выкл. курсор
STEP2:	LD	HL,506H 	; КООРД.РАМКИ 1 ОКНА
	LD	DE,512H 	; РАЗМЕРЫ РАМКИ 1 ОКНА
	CALL	SAVEW 		; COXP.СОДЕРЖ.ЭКРАНА
	CALL	FRAME 		; РИСУЕМ РАМКУ 
STEP3:	LD	HL, TSTXT1 	; ВЫВОДИМ ТЕКСТ
	CALL	PrintString	; ЧЕРЕЗ ДРАЙВЕР
	CALL	INPUT 		; ПАУЗА 
STEP4:	LD	HL,80EH 	; КООРДИНАТЫ 2 ОКНА
	LD	DE,512H 	; РАЗМЕРЫ 2 ОКНА
	CALL	SAVEW		; OTKPЫBAEM 2 ОКНО
	CALL	FRAME
	LD	HL, TSTXT2 	; ВЫВОДИМ ТЕКСТ
	CALL	PrintString 	; BO 2 ОКНО 
STEP5:	CALL	INPUT		; ПАУЗА
	CALL	RESTW		; СТИРАЕМ 2 OKHО
STEP6:	CALL	INPUT		; ПАУЗА
	CALL	RESTW		; СТИРАЕМ 1 ОКНО
	CALL	INPUT		; ПАУЗА
	JP	TESTLOOP	; НА ПОВТОР ТЕСТ-ПРОГРАММЫ 

CURON:	DB	1bh, 'e',0	; Вкл. курсор
CUROFF:	DB	1bh, 'f',0	; Выкл. курсор
TSTXT1:	DB 1FH,'1 okno'
	DB 0DH, 0AH, '2 stroka 1 okna',0 
TSTXT2:	DB 1FH,'2 okno '
	DB 0DH,0AH,'2 stroka 2 okna'
	DB 0DH,0AH,'3 stroka 2 okna',0CH,0
