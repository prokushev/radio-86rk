; Драйвер "оконного" интерфейса, опубликованный
; в Радио 1990 года №3

	CPU 8080
	ORG 0
	JMP TEST 	; ПЕРЕХОД НА ТЕСТИРОВАНИЕ ДР.
PRINTC:	JMP 0F809H 	;ВЫВОД СИМВОЛА ЧЕРЕЗ МОНИТОР
PRINT:	JMP 0F818H 	;ВЫВОД ТЕКСТА ЧЕРЕЗ МОНИТОР
INPUT:	JMP 0F803H 	;ввод символа с клавиатуры 
LOADM:	JMP 0F821H 	;запрос символа над курсором
LDCUR:	JMP 0F81EH 	;ЗАПРОС ПОЛОЖЕНИЯ КУРСОРА
INITSP:	DW TXTCUR+5 	;АДРЕС ОБЛАСТИ СОХРАНЕНИЯ ЭК.
		; ОПИСАНИЕ РАБОЧИХ ПОЛЕЙ ДРАЙВЕРА
BASEAD:	EQU 6000H 	;АДРЕС НАЧАЛА РАБ. ОБЛАСТИ
WPARM:	EQU BASEAD 	;РАЗМЕР ОКНА (ВЕРТ./ГОРИЭ.>
WHOME:	EQU WPARM+2 	;ПОЛОЖЕНИЕ ВЕРХ. ЛЕВОГО УГЛА
WCURSR:	EQU WHOME+2 	;ПОЛОЖЕНИЕ КУРСОРА
NUMWND:	EQU WCURSR+2	;НОМЕР АКТИВНОГО ОКНА
ADRSP:	EQU NUMWND+1	; АДРЕС СВОБОДНОЙ ОБЛАСТИ
TXTCUR:	EQU ADRSP+2 	; РАБОЧИЕ ЯЧ. ДЛЯ УСТ.КУСОРА
;+resetw - инициирование драйвера оконного +
;* интерфейса +
;++++++++++++++++++++++++++++++++++++++++++++++++
RESETW:	PUSH H
	XRA A 		;ОБНУЛЕНИЕ НОМЕРА 
	STA NUMWND	;АКТИВНОГО ОКНА 
	LHLD INITSP 	;ИНИЦИИРУЕМ АДРЕС НАЧАЛА ОЗУ 
	SHLD ADRSP 	;ДЛЯ СОХРАНЕНИЯ ЭКРАНОВ 
	POP H 
	RET
;+++++++++++++++++++++++++++++++++++++++++++++++
;+SAVEW - СОХРАНЕНИЕ ОБЛАСТИ ЭКРАНА ЗАНИМАЕМОЙ +
;+ ПОД ОТКРЫВАЕМОЕ ОКНО                        +
;+ВХОД: H,L- КООРДИНАТЫ ЛЕВОЙ ВЕРШИНЫ ОКНА     +
;+ D,Е- РАЗМЕРЫ ОКНА С РАМКОЙ (СТРК/СТЛБ1      +
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
RES20:	MOV C,M 	; ВОССТАНАВЛИВАЕМ СОДЕР".
	CALL PRINTC 	; ЭКРАНА
	INX H 		; УВЕЛИЧИВАЕМ АДРЕС
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
FRAME:	PUSH H 		; СОХРАНЯЕМ РЕГИСТРЫ 
	PUSH D
	CALL CUROUT 	; КУРСОР В УГОЛ РАМКИ 
	DCR D 		; УМЕНЬШАЕМ ВЫСОТУ РАМКИ 
	DCR D
	MOV B, E 	; ШИРИНУ РАМКИ В СЧЕТЧИК 
	LXI H, FRTEXT 	; АДРЕС ВЕРХНЕЙ ЛИНИИ 
	CALL DRWFR 	; РИСУЕМ ЛИНИЮ И УГОЛ 
	MOV B, D 	; ВЫСОТУ РАМКИ В СЧЕТЧИК
	CALL DRWFR 	; РИСУЕМ ПРАВУЮ ЛИНИИ
	MOV B,E 	; ширину рамки в счетчик
	CALL DRWFR 	; РИСУЕМ НИЖНЮЮ ЛИНИЮ
	MOV B, D 	; ВЫСОТУ РАМКИ В СЧЕТЧИК
	CALL DRWFR 	; РИСУЕМ ЛЕВУЮ ЛИНИЮ И
	CALL CURIN 	; ЗАГРУЖАЕМ КООРДИНАТЫ
	SHLD WHOME 	; ПОЛОЖЕНИЯ НОМЕ ОКНА
	XCHG
	SHLD WPARM 	; ЗАПИСЫВАЕМ РАЗМЕРЫ АКТ.
	POP D 		; ОКНА
	POP H 		; ВОССТАНАВЛИВАЕМ РЕГИСТРЫ
	RET
;-DRWFR - РИСОВАНИЕ СТОРОНЫ И УГЛА РАМКИ 
;-ВХОД: В - ДЛИНА СТОРОНЫ
DRWFR:	DCR B 		; ЕСЛИ ДЛИНА 1
	JZ DRR20 	; ОБХОДИМ ЦИКЛ ПО ДЛИНЕ СТОР. 
DRW10:	PUSH H 		; РИСУЕМ В-1 СИМВОЛОВ СТОРОНЫ
	CALL PRINT
	POP H
	DCR B
	JNZ DRW10 
DRR20:	CALL PRINT 	; РИСУЕМ ПОСЛЕДНИЙ СИМВОЛ
	INX H
	CALL PRINT 	; ПРОРИСОВЫВАЕМ УГОЛ
	INX H 		; готовим адрес очереди. стор.
	RET
; ДАННЫЕ ДЛЯ ПОСТРОЕНИЯ РАМКИ 
FRTEXT:	DB 17H, 0		; ВЕРХНЯЯ СТОРОНА
	DB 1AH, 8, 0 	; УГОЛ
	DB 17H, 1AH, 8, 0 	; ПРАВАЯ СТОРОНА
	DB 0 		; УГОЛ
	DB 17H, 8, 8, 0	; НИЖНЯЯ СТОРОНА
	DB 19H, 18H, 0	; УГОЛ
	DB 17H,19H, 8, 0	;ЛЕВАЯ СТОРОНА
	DB 18H,1AH, 0 	; КУРСОР В ЛЕВЫЙ ВЕРХНИЙ УГОЛ
;WRITE - ВЫВОД ТЕКСТА ЧЕРЕЗ ДРАЙВЕР ОКНА. +
; АНАЛОГ П/П МОНИТОРА 0F818H )            +
;ВХОД: HL - АДРЕС НАЧАЛА ТЕКСТА.          +
WRITE:	MOV A, M 	; ВЫВОДИМ ВСЕ СИМВОЛЫ
	ORA A 		; ДО НУЛЯ
	JZ WRTRET
	MOV C, A 	; ЧЕРЕЗ
	CALL WRITEC 	; ПОДПРОГРАММУ WRITEC
	INX H
	JMP WRITE 
WRTRET:	INX H
	RET
;++++++++++++++++++++++++++++++++++++++++++++
; WRITEC - ВЫВОД СИМВОЛА ЧЕРЕЗ ДРАЙВЕР ОКНА +
; АНАЛОГ П/П МОНИТОРА 0F809Н                +
; ВХОД: С - КОД СИМВОЛА                     +
;++++++++++++++++++++++++++++++++++++++++++++
WRITEC:	LDA NUMWND 	; ПРОВЕРЯЕМ НАЛИЧИЕ
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
WRCRET: 	RET
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
	LXI H,TXTCUR+4 	; РАБОЧЕЕ ПОЛЕ В ОЗУ 
	MVI M,0 	; ПРИЗНАК КОНЦА СТРОКИ 
	DCX H 		; ФОРМИРУЕМ В TXTCUR 
	MOV M,E 	; ESCAPE ПОСЛЕДОВАТЕЛЬНОСТЬ 
	DCX H 		; АР2,'Г',2вН+(Н>>20H+<L>,0 
	MOV M,D 
	DCX H 
	MVI M,'Y' 
	DCX H 
	MVI M,1BH
	CALL PRINT 	; УСТАНАВЛИВАЕМ КУРСОР ЧЕРЕЗ 
	POP B 		; МОНИТОР 
	POP D 
	POP H 
	RET

;***************** ТЕСТОВАЯ ПРОГРАММА ************************
TEST:
STEP1:	CALL RESETW 	; ИНИЦИИРУЕМ ДРАЙВЕР
STEP2:	LXI H,506H 	; КООРД.РАМКИ 1 ОКНА
	LXI D,512H 	; РАЗМЕРЫ РАМКИ 1 ОКНА
	CALL SAVEW 	; COXP.СОДЕРЖ.ЭКРАНА
	CALL FRAME 	; РИСУЕМ РАМКУ 
STEP3:	LXI H, TSTXT1 	; ВЫВОДИМ ТЕКСТ
	CALL WRITE 	; ЧЕРЕЗ ДРАЙВЕР
	CALL INPUT 	; ПАУЗА 
STEP4:	LXI H,80EH 	; КООРДИНАТЫ 2 ОКНА
	LXI D,512H 	; РАЗМЕРЫ 2 ОКНА
	CALL SAVEW 	; OTKPblBAEM 2 ОКНО
	CALL FRAME
	LXI H, TSTXT2 	; ВЫВОДИМ ТЕКСТ
	CALL WRITE 	; BO 2 ОКНО 
STEP5:	CALL INPUT 	; ПАУЗА
	CALL RESTW 	; СТИРАЕМ 2 OKHО
STEP6:	CALL INPUT 	; ПАУЗА
	CALL RESTW 	; СТИРАЕМ 1 ОКНО
	CALL INPUT 	; ПАУЗА
	JMP TEST 	; НА ПОВТОР ТЕСТ-ПРОГРАММЫ 

TSTXT1:	DB 1FH,'1 okno'
	DB 0DH, 0AH, '2 stroka 1 okna',0 
TSTXT2:	DB 1FH,'2 okno '
	DB 0DH,0AH,'2 stroka 2 okna'
	DB 0DH,0AH,'3 stroka 2 okna',0CH,0
