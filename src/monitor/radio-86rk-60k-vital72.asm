;  #############################################################################
;  ##  УПРАВЛЯЮЩАЯ ПРОГРАММА "МОНИТОР" ДЛЯ КОМПЬЮТЕРА РАДИО-86РК/60 килобайт  ##
;  #############################################################################
;
;  Author:  Vitaliy Poedinok aka Vital72
;  License: MIT
;  www:     http://www.86rk.ru/
;  e-mail:  vital72@86rk.ru
;  Version: 1.0
;  Date:    17.02.24
;  =============================================================================

VERSION			EQU	"1.0"

CPU_CLOCK		EQU	3000	;  тактовая частота CPU в килогерцах

MONITOR_BASE		EQU	0F800h	;  стартовый адрес МОНИТОРА
MONITOR_EXTENSION	EQU	0F000h	;  стартовый адрес расширения МОНИТОРА
MONITOR_DATA		EQU	0E600h	;  начало области рабочих ячеек МОНИТОРА
MONITOR_DATA_SIZE	EQU	000D0h	;  размер области рабочих ячеек МОНИТОРА
MONITOR_WARM_START	EQU	0F86Ch	;  горячий старт/консоль

;  базовые адреса микросхем периферии
ADDR_TIMER		EQU	0F100h
ADDR_RTC		EQU	0F200h
ADDR_KBD		EQU	0F400h
ADDR_PORT		EQU	0F500h
ADDR_CRT		EQU	0F600h
ADDR_DMA		EQU	0F700h
ADDR_FONT_RAM		EQU	0F800h

ADDR_KBD_PA		EQU	ADDR_KBD + 0
ADDR_KBD_PB		EQU	ADDR_KBD + 1
ADDR_KBD_PC		EQU	ADDR_KBD + 2
ADDR_KBD_CTRL		EQU	ADDR_KBD + 3

ADDR_PORT_PA		EQU	ADDR_PORT + 0
ADDR_PORT_PB		EQU	ADDR_PORT + 1
ADDR_PORT_PC		EQU	ADDR_PORT + 2
ADDR_PORT_CTRL		EQU	ADDR_PORT + 3

ADDR_CRT_PARAM		EQU	ADDR_CRT
ADDR_CRT_CTRL		EQU	ADDR_CRT + 1

ADDR_TIMER_CTRL		EQU	ADDR_TIMER + 3

;  флаги управляющих клавиш клавиатуры
KBD_RUS_FLAG		EQU	80h
KBD_CTRL_FLAG		EQU	40h
KBD_SHIFT_FLAG		EQU	20h

;  константы задержек при обработке нажатий клавиш
KBD_ANTIBOUNCE_INKEY	EQU	15	;  антидребезг
KBD_ANTIBOUNCE		EQU	15	;  антидребезг
KBD_DELAY_FIRST		EQU	30	;  задержка автоповтора для второго символа
KBD_DELAY_REGULAR	EQU	5	;  задержка автоповтора для остальных символов

;  размер видимой части экрана в символах
SCR_VIDEO_SIZE_X	EQU	64	;  по X
SCR_VIDEO_SIZE_Y	EQU	25	;  по Y
;  полный размер экрана, включающий бланкирующие зоны, в символах
SCR_SIZE_X		EQU	78	;  по X
SCR_SIZE_Y		EQU	30	;  по Y
SCR_ARRAY		EQU	SCR_SIZE_X * SCR_SIZE_Y
; отступ левого верхнего угла видимой части экрана, в символах
SCR_PAD_X		EQU	8	;  по горизонтали
SCR_PAD_Y		EQU	3	;  по вертикали
;  адреса экранной области и видимой его части
SCREEN			EQU	MONITOR_DATA + MONITOR_DATA_SIZE
SCREEN_VIDEO		EQU	SCREEN + SCR_SIZE_X * SCR_PAD_Y + SCR_PAD_X

;  коды атрибутов 8275 для вывода цветного изображения
ATTR_COLOR_BLACK	EQU	8Dh
ATTR_COLOR_RED		EQU	8Ch
ATTR_COLOR_GREEN	EQU	85h
ATTR_COLOR_YELLOW	EQU	84h
ATTR_COLOR_BLUE		EQU	89h
ATTR_COLOR_MAGENTA	EQU	88h
ATTR_COLOR_CYAN		EQU	81h
ATTR_COLOR_WHITE	EQU	80h

;  коды атрибутов 8275 для подчеркивания, мерцания и негативного изображения
ATTR_UNDERLINE		EQU	0A0h
ATTR_BLINKING		EQU	82h
ATTR_REVERSE		EQU	90h
ATTR_RESET		EQU	80h

;  коды атрибутов 8275 для переключения знакогенератора
ATTR_CHARSET_G1		EQU	0E5h
ATTR_CHARSET_G0		EQU	0E4h

;  управляющие коды дисплея
CHAR_CODE_CR		EQU	0Dh
CHAR_CODE_LF		EQU	0Ah
CHAR_CODE_BEL		EQU	07h
CHAR_CODE_HT		EQU	09h
CHAR_CODE_FF		EQU	0Ch
CHAR_CODE_SO		EQU	0Eh	;  Invoke G1 character set
CHAR_CODE_SI		EQU	0Fh	;  Select G0 character set

CHAR_CODE_LEFT		EQU	08h
CHAR_CODE_RIGHT		EQU	18h
CHAR_CODE_UP		EQU	19h
CHAR_CODE_DOWN		EQU	1Ah
CHAR_CODE_CLS		EQU	1Fh
CHAR_CODE_BACKSPACE	EQU	7Fh
CHAR_CODE_ENTER		EQU	0Dh
CHAR_CODE_ESC		EQU	1Bh
CHAR_CODE_CTRL_C	EQU	03h

;  код клавиши "АЛФ"
CHAR_CODE_ALF		EQU	0FEh

;  параметры настройки контроллера CRT
CRT_PIXEL_CLOCK		EQU	10000	;  kHz
CRT_CHAR_WIDTH		EQU	8	;  ширина символа, пикселы
CRT_HORIZ_TIME		EQU	64	;  длительность строки, мкс
CRT_SPACED_ROW		EQU	0	;  spaced row [0, 1]
CRT_VERT_ROW_COUNT	EQU	1	;  vertical retrace row count [1, 2, 3, 4]
CRT_UNDERLINE		EQU	10	;  underline placement [1..16]
CRT_LINES_PER_ROW	EQU	10	;  number of lines per character row [1..16]
CRT_LINE_OFFSET		EQU	1	;  line counter mode [0, 1]
CRT_NON_TRANSP_ATTR	EQU	1	;  field attribute mode [0, 1]
CRT_HORIZONTAL_COUNT	EQU	8	;  horizontal retrace count [2, 4, 6, .. 32]
CRT_BURST_SPACE_CODE	EQU	1	;  [0..7]
CRT_BURST_COUNT_CODE	EQU	3	;  [0..3]
CRT_ZZZZ		EQU	((CRT_HORIZ_TIME * CRT_PIXEL_CLOCK / 1000 / CRT_CHAR_WIDTH - SCR_SIZE_X + 1) >> 1) - 1
CRT_ZZZZ6		EQU	((CRT_HORIZ_TIME * 8 / 6 - SCR_SIZE_X + 1) >> 1) - 1
CRT_ZZZZ8		EQU	((CRT_HORIZ_TIME * 10 / 8 - SCR_SIZE_X + 1) >> 1) - 1

;
INP_BUFFER_SIZE		EQU	32
CURSOR_VIEW_INITIAL	EQU	10h

;  управляющие регистры RTC MSM6242
;  управляющий регистр D
RTC_CD_30_S_ADJ		EQU	1 << 3		;  30-second adjustment
RTC_CD_IRQ_FLAG		EQU	1 << 2
RTC_CD_BUSY		EQU	1 << 1
RTC_CD_HOLD		EQU	1 << 0

;  управляющий регистр E
RTC_CE_T_MASK		EQU	3 << 2
RTC_CE_T_64HZ		EQU	0 << 2		;  period 1/64 second
RTC_CE_T_1HZ		EQU	1 << 2		;  period 1 second
RTC_CE_T_1MINUTE	EQU	2 << 2		;  period 1 minute
RTC_CE_T_1HOUR		EQU	3 << 2		;  period 1 hour

RTC_CE_ITRPT_STND	EQU	1 << 1
RTC_CE_MASK		EQU	1 << 0		;  STD.P output control

;  управляющий регистр F
RTC_CF_TEST		EQU	1 << 3
RTC_CF_12H		EQU	0 << 2
RTC_CF_24H		EQU	1 << 2
RTC_CF_STOP		EQU	1 << 1
RTC_CF_RESET		EQU	1 << 0

;  битовые маски байта конфигурации config_rk
CFG_RK_FONT_RAM		EQU	00000001b
CFG_RK_FONT_8BIT	EQU	00000100b

;  =============================================================================

.macro dbdw
	db	%%1
	dw	%%2
.endm

;  использование:
;  syn_note ДЛИТЕЛЬНОСТЬ, ОКТАВА, НОТА
;      ДЛИТЕЛЬНОСТЬ, ms
;      ОКТАВА = -2..5
;      НОТА   = 1..12
.macro syn_note
	dbdw	%%1, 1000 * CRT_PIXEL_CLOCK / (CRT_CHAR_WIDTH * 440 * 2 ** (((%%2 - 1) * 12 - 10 + %%3) / 12)) + .5
.endm

.macro inp
	in	((%%1) >> 8) | ((%%1) & 0FFh)
.endm

.macro outp
	out	((%%1) >> 8) | ((%%1) & 0FFh)
.endm

;  =============================================================================
;  ================================================================  МОНИТОР  ==

	org	MONITOR_BASE

	jmp	cold_start		;  00  //  холодный старт
	jmp	in_char_vector		;  03  //  ввод символа с клавиатуры (блок)
	jmp	rd_byte_tape_vector	;  06  //  чтение байта с ленты
	jmp	out_char_c		;  09  //  вывод символа на экран (рег. C)
	jmp	wr_byte_tape_vector	;  0c  //  запись байта на ленту
	jmp	out_char_vector		;  0f  //  вывод символа на экран (рег. A)
	jmp	kbd_state_vector	;  12  //  состояние клавиатуры
	jmp	out_hex			;  15  //  вывод на экран байта в hex-коде
	jmp	out_str			;  18  //  вывод строки на экран
	jmp	in_key_vector		;  1b  //  код нажатой клавиши (не блок)
	jmp	get_cursor		;  1e  //  получение координат курсора
	jmp	get_scr			;  21  //  чтение байта с экрана в текущей позиции
	jmp	rd_block_tape_vector	;  24  //  чтение блока с ленты
	jmp	wr_block_tape_vector	;  27  //  запись блока на ленту
	jmp	check_sum		;  2a  //  подсчёт контрольной суммы блока
	jmp	init_video		;  2d  //  инициализация видео
	jmp	get_mem_top		;  30  //  получение верхней границы памяти
	jmp	set_mem_top		;  33  //  установка верхней границы памяти
	ret				;  36
	nop
	nop
	ret				;  39
	nop
	nop
	jmp	set_cursor		;  3c  //  установка курсора по координатам
	jmp	synthesizer		;  3f  //  трёхголосый синтезатор
	jmp	set_charset		;  42  //  выбор знакогенератора
	lda	config_rk		;  45  //  чтение конфигурации
	ret

;  =============================================================================

;  ПЕРЕДАЧА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  ___________________________
;  Выход: HL - адрес границы
get_mem_top:
	lhld	mem_top
	ret

;  УСТАНОВКА АДРЕСА ВЕРХНЕЙ ГРАНИЦЫ СВОБОДНОЙ ПАМЯТИ  __________________________
;  Вход:  HL - адрес границы
set_mem_top:
	shld	mem_top
	ret

;  =============================================================================

cold_start:
	lxi	sp, stack
	;  все три канала таймера в режим 3
	lxi	h, ADDR_TIMER_CTRL
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	;  очистка рабочих ячеек МОНИТОРА
	lxi	h, MONITOR_DATA
	lxi	d, MONITOR_DATA + MONITOR_DATA_SIZE - 17
	mvi	c, 0
	call	directive_f
	call	init_monitor
	;  pad
	ds	MONITOR_WARM_START - $, 0

warm_start:
	;  т.н. теплый старт МОНИТОРА.
	;  для совместимости с программами, которые напрямую переходят
	;  на теплый старт, этот адрес должен быть равен F86C
	.if $ - MONITOR_WARM_START
	.error MONITOR_WARM_START
	.endif

	lxi	sp, stack
	lxi	h, warm_start
	push	h
	mvi	a, 2
	call	set_charset		;  переключение на расширенный знакогенератор
	call	print			;  промт
	db	"\r\n>>\x1bK", 0
	call	get_str			;  ввод директивы
	inx	d
	call	get_param		;  получить первый параметр
	push	h
	cnc	get_param		;  получить второй параметр
	push	h
	lxi	h, 0
	cnc	get_param		;  получить третий параметр
	mov	c, l
	mov	b, h
	pop	d
	pop	h
	jnc	out_error_txt
	lda	inp_buffer
	ana	a
	rz
	call	branch
	dbdw	'B', directive_b
	dbdw	'W', directive_w
	dbdw	'C', directive_c
	dbdw	'D', directive_d
	dbdw	'L', directive_l
	dbdw	'M', directive_m
	dbdw	'F', directive_f
	dbdw	'R', directive_r
	dbdw	'S', directive_s
	dbdw	'T', directive_t
	dbdw	'G', directive_g
	dbdw	'-', directive_sd_card
	db	0
	;  сюда произойдёт переход, если не нашлось ни одного соответствия
	jmp	extended_directive_handler

;  ВВОД СТРОКИ СИМВОЛОВ ВО ВНУТРЕННИЙ БУФЕР  ___________________________________
;  Вводим максимум 31 символа с клавиатуры в специальный буфер
;  Особо обрабатываемые клавиши:
;      [<-] и [ЗБ] - удаление последнего символа
;              [.] - Выход на промт
;             [ВК] - успешный возврат из п/п
get_str:
	lxi	h, inp_buffer
get_str_loop:
	call	in_char_vector
	cpi	CHAR_CODE_LEFT
	jz	get_str_back
	cpi	CHAR_CODE_BACKSPACE
	jz	get_str_back
	cpi	CHAR_CODE_CR
	cz	out_char_vector
	jz	get_str_cr
	cpi	'.'
	cz	out_char_vector
	jz	warm_start
	cpi	' '
	jc	get_str_loop
	mov	c, a
	mvi	a, low (inp_buffer_end - 1)
	cmp	l
	jz	pop_and_out_error_txt
	mov	m, c
	inx	h
	call	out_char_c
	jmp	get_str_loop
get_str_back:
	mvi	a, low (inp_buffer)
	cmp	l
	jz	get_str_loop
	call	print
	db	CHAR_CODE_LEFT, " ", CHAR_CODE_LEFT, 0
	dcx	h
	jmp	get_str_loop
get_str_cr:
	mvi	m, 0
	lxi	d, inp_buffer
	mov	a, e
	cmp	l
	ret

;  ПОЛУЧЕНИЕ ПАРАМЕТРА ИЗ ВВЕДЕННОЙ СТРОКИ  ____________________________________
;  Вход:  DE - адрес буфера, код 0 в строке - конец строки
;  Выход: HL - число
;         флаг CF = 1 - достигнут конец строки
;         в случае ошибки синтаксиса происходит завершение подпрограммы
get_param:
	call	inp_buffer_skip_space
	call	str2hex
	call	inp_buffer_skip_space
	ana	a			;  конец строки?
	stc
	rz				;  да CF = 1
	inx	d
	cpi	','
	rz				;  CF = 0
pop_and_out_error_txt:
	pop	psw
out_error_txt:
	call	print
	db	"?\r\n\a\a", ATTR_COLOR_RED, "\x0eo[IBKA!\x0f", ATTR_COLOR_WHITE, 0
dummy_func:
	ret

inp_buffer_skip_space:
	ldax	d
	cpi	' '
	rnz
	inx	d
	jmp	inp_buffer_skip_space
	
;  ПРОВЕРКА НА НАЖАТИЕ CTRL+C И ДОСТИЖЕНИЕ КОНЦА БЛОКА  ________________________
;  Вход:  HL - текущий адрес блока
;         DE - конечный адрес блока
;  действие: 1. нажата CTRL+C   - переход на тёплый старт
;            2. нажата АЛФ      - приостановка вывода
;            3. достигнут конец - Выход из родительской подпрограммы
cmp_and_check_ctrl_c:
	call	in_key_vector
	cpi	CHAR_CODE_CTRL_C	;  CTRL+C/F4?
	jz	warm_start
	cpi	CHAR_CODE_ALF		;  АЛФ?
	jz	cmp_and_check_ctrl_c

;  ВЫХОД ИЗ РОДИТЕЛЬСКОЙ ПОДПРОГРАММЫ, ЕСЛИ ДОСТИГНУТ КОНЕЦ БЛОКА  _____________
;  Вход:  HL - текущий адрес блока
;         DE - конечный адрес блока
cmp_and_exit:
	call	cmp_de_hl
	jnz	$+5
	pop	psw			;  удаляем предыдущий адрес возврата
	ret				;  возврат из родительской подпрограммы
	inx	h			;  следующий адрес в блоке
	ret

;  ВЫВОД СЛОВА НА ЭКРАН  _______________________________________________________
;  Вход:  HL - 16-разрядное слово
;  действие: вывод начинается с новой строки с отступом от края в 4 символа
out_word:
	call	print
	db	"\r\n\x1bK    ", 0
	mov	a, h
	call	out_hex
	mov	a, l
	jmp	out_hex

;  ВЫВОД АДРЕСА НА ЭКРАН  ______________________________________________________
;  Вход:  HL - адрес
;  действие: вывод начинается с новой строки, адрес выводится в формате:
;            "    xxxx: "
out_addr:
	call	out_word
	mvi	a, ':'
	call	out_char_vector
	jmp	out_space

;  ВЫВОД БАЙТА ИЗ ПЯМЯТИ НА ЭКРАН В HEX  _______________________________________
;  Вход:  HL - адрес ячейки памяти
out_mem_hex:
	mov	a, m
	call	out_hex
out_space:
	mvi	a, ' '
	jmp	out_char_vector

;  =============================================================================
;  =====================================================  ДИРЕКТИВЫ МОНИТОРА  ==

;  ДИРЕКТИВА B  ________________________________________________________________
;  поиска байта в заданной области памяти
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
;         C  - искомый байт
directive_b:
	mov	a, c
	cmp	m
	cz	out_addr
	call	cmp_and_check_ctrl_c
	jmp	directive_b

;  ДИРЕКТИВА W  ________________________________________________________________
;  поиска слова в заданной области памяти
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
;         BC - искомое слово
directive_w:
	mov	a, m
	cmp	c
	jnz	directive_w_lbl1
	inx	h
	mov	a, m
	dcx	h
	cmp	b
	cz	out_addr
directive_w_lbl1:
	call	cmp_and_check_ctrl_c
	jmp	directive_w

;  ДИРЕКТИВА C  ________________________________________________________________
;  сравнение двух областей памяти
;  Вход:  HL - начальный адрес первой области памяти
;         DE - конечный адрес первой области памяти
;         BC - начальный адрес второй области памяти
directive_c:
	ldax	b
	cmp	m
	jz	directive_c_lbl1
	call	out_addr
	call	out_mem_hex
	ldax	b
	call	out_hex
directive_c_lbl1:
	inx	b
	call	cmp_and_check_ctrl_c
	jmp	directive_c

;  ДИРЕКТИВА D  ________________________________________________________________
;  вывод на экран содержимого области памяти в виде шестнадцатеричного дампа
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
directive_d:
	mov	a, l
	ani	0Fh
	jnz	directive_d_space
directive_d_loop1:
	call	out_addr
directive_d_loop2:
	call	out_mem_hex
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	07h
	jnz	directive_d_loop2
	call	out_space
	mov	a, l
	ani	0Fh
	jnz	directive_d_loop2
	cmp	l			;  A = 0
	jnz	directive_d_loop1
	mvi	a, 0Ah
	call	out_char_vector
	jmp	directive_d_loop1

directive_d_space:
	push	h
	mov	c, a
	mov	a, l
	ani	0F0h
	mov	l, a
	call	out_addr
	mov	a, c
	cpi	8
	cmc
	adc	c
	add	c
	mov	c, a
	call	out_space
	dcr	c
	jnz	$-4
	pop	h
	jmp	directive_d_loop2

;  ДИРЕКТИВА L  ________________________________________________________________
;  вывод на экран содержимого области памяти в виде алфавитно-цифровых символов
;  Вход:  HL - начальный адрес
;         DE - конечный адрес
directive_l:
	mov	a, l
	ani	0Fh
	jnz	directive_l_space
directive_l_loop1:
	call	out_addr
directive_l_loop2:
	mov	a, m
	ora	a
	jm	$+8
	cpi	' '
	jnc	$+5
	mvi	a, '.'
	call	out_char_vector
	call	cmp_and_check_ctrl_c
	mov	a, l
	ani	0Fh
	jnz	directive_l_loop2
	ora	l
	jnz	directive_l_loop1
	mvi	a, 0Ah
	call	out_char_vector
	jmp	directive_l_loop1
directive_l_space:
	push	h
	mov	c, a
	mov	a, l
	ani	0F0h
	mov	l, a
	call	out_addr
	call	out_space
	dcr	c
	jnz	$-4
	pop	h
	jmp	directive_l_loop2

;  ДИРЕКТИВА M  ________________________________________________________________
;  просмотр и изменение содержимого одной или нескольких ячеек памяти
;  Вход:  HL - адрес
directive_m:
	call	out_addr
	call	out_mem_hex
	push	h
	call	get_str
	pop	h
	jnc	directive_m_next
	push	h
	call	str2hex
	mov	a, l
	pop	h
	mov	m, a
directive_m_next:
	inx	h
	jmp	directive_m

;  ДИРЕКТИВА F  ________________________________________________________________
;  заполнение области памяти кодом
;  Вход:  HL - адрес начала области
;         DE - адрес конца области
;         C  - код
directive_f:
	mov	m, c
	call	cmp_and_exit
	jmp	directive_f

;  ДИРЕКТИВА -  ________________________________________________________________
;  запуск шелла с SD карты
directive_sd_card:
	lxi	d, 007Fh
	mov	h, d
	mov	l, d
	mov	b, d
	mov	c, d
	push	b

;  ДИРЕКТИВА R  ________________________________________________________________
;  чтение блока из внешнего ROM-диска
;  Вход:  HL - начальный адрес ПЗУ
;         DE - конечный адрес ПЗУ
;         BC - адрес назначения
directive_r:
	; режим 0, канал PA на ввод, каналы PB и PC на вывод
	mvi	a, 10010000b
	outp	ADDR_PORT_CTRL
directive_r_loop:
	shld	ADDR_PORT_PB
	inp	ADDR_PORT_PA
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_r_loop

;  ДИРЕКТИВА S  ________________________________________________________________
;  подсчёт контрольной суммы блока
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
directive_s:
	call	out_word
	xchg
	call	out_word
	xchg
	call	check_sum
	mov	l, c
	mov	h, b
	jmp	out_word

;  ДИРЕКТИВА T  ________________________________________________________________
;  пересылка блока памяти
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
;         BC - адрес назначения
directive_t:
	call	cmp_de_hl
	jc	out_error_txt		;  DE < HL
directive_t_loop:
	mov	a, m
	stax	b
	inx	b
	call	cmp_and_exit
	jmp	directive_t_loop

;  ДИРЕКТИВА G  ________________________________________________________________
;  запуск программы
;  Вход:  HL - адрес запуска
directive_g:
	pchl

;  =============================================================================
;  ====================================================  ПОДПРОГРАММЫ ЭКРАНА  ==

;  ВЫВОД СИМВОЛА  ______________________________________________________________
;  Вход:  A - код символа
out_char:
	push	b
	push	d
	push	h
	push	psw
	lxi	h, out_char_exit
	push	h
	lhld	cursor_pos
	xchg
	lhld	cursor_addr
	;  проверку на вывод видимого символа делаем вначале, чтобы сэкономить
	;  такты на куче проверок, т.к. вывод обычных символов производится
	;  гораздо чаще, чем вывод управляющих символов
	cpi	' '
	jnc	out_char_regular
	cpi	CHAR_CODE_CR		; (7)
	jz	out_char_code_cr	; (10)
	cpi	CHAR_CODE_LF
	jz	out_char_code_lf
	cpi	CHAR_CODE_ESC
	jz	out_char_code_esc
	cpi	CHAR_CODE_CLS
	jz	out_char_code_cls
	cpi	CHAR_CODE_HT
	jz	out_char_code_ht
	cpi	CHAR_CODE_SO
	jz	out_char_code_so
	cpi	CHAR_CODE_SI
	jz	out_char_code_si
	cpi	CHAR_CODE_LEFT
	jz	out_char_code_left
	cpi	CHAR_CODE_RIGHT
	jz	out_char_code_right
	cpi	CHAR_CODE_UP
	jz	out_char_code_up
	cpi	CHAR_CODE_DOWN
	jz	out_char_code_down
	cpi	CHAR_CODE_FF
	jz	out_char_code_ff
	cpi	CHAR_CODE_BEL
	jz	out_char_code_bel

out_char_regular:
	mov	m, a
	dcr	e
	inr	e
	jnz	$+9
	;  атрибут для установки нужного знакогенератора при выводе с новой строки
	;  \\
	lda	attr_charset
	dcx	h
	mov	m, a
	inx	h
	;  //
	call	out_char_code_right	;  курсор вправо
	rnz				;  за экран не вышли, скроллинг не нужен
	;  здесь D = E = 0
	;  устанавливаем курсор на первой позиции последней строки
	mvi	d, SCR_VIDEO_SIZE_Y - 1
	lxi	h, SCREEN_VIDEO + SCR_SIZE_X * (SCR_VIDEO_SIZE_Y - 1)

;  скроллинг экрана
out_char_scroll:
	;  в цикле пересылки данных используется стек, таким образом
	;  записывается два байта за раз, что увеличивает скорость
	push	h
	lxi	h, 0
	dad	sp			;  копируем SP в HL
	shld	tmp_storage		;  и сохраняем SP
	;  адрес источника
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + 1)
	;  адрес приёмника
	lxi	h, SCREEN + SCR_SIZE_X * SCR_PAD_Y
	;  счётчик итераций цикла
	mvi	a, SCR_SIZE_X * SCR_VIDEO_SIZE_Y / 5 / 2
out_char_scroll_loop:
	.rept 5
	pop	b			; (10)
	mov	m, c			; (7)
	inx	h			; (5)
	mov	m, b			; (7)
	inx	h			; (5) / 34
	.endm
	dcr	a			; (5)
	jnz	out_char_scroll_loop	; (10)
	;  цикл: (34 * 5 + 15) * 78 * 25 / 5 / 2 = 36075 тактов
	lhld	tmp_storage		;  восстанавливаем указатель стека
	sphl
	pop	h
	ret

;  управляющий код: возврат каретки
out_char_code_cr:
	mov	a, l
	sub	e
	mov	l, a
	mvi	e, 0
	rnc
	dcr	h
	ret

;  управляющий код: перевод строки
out_char_code_lf:
	mov	a, d
	cpi	SCR_VIDEO_SIZE_Y - 1
	jnc	out_char_scroll		;  если курсор на последней строке, то скролл
	inr	d			;  курсор сдвигаем вниз
	lxi	b, SCR_SIZE_X
	dad	b
	ret

;  управляющий код: переключение на альтернативный знакогенератор
out_char_code_so:
	mvi	a, ATTR_CHARSET_G1
	sta	attr_charset
	jmp	out_char_regular

;  управляющий код: возврат на основной знакогенератор
out_char_code_si:
	mvi	a, ATTR_CHARSET_G0
	sta	attr_charset
	jmp	out_char_regular

;  управляющий код: горизонтальная табуляция
out_char_code_ht:
	mov	a, e
	cma
	ani	07h
	mov	c, a
	mvi	b, 0
	dad	b
	add	e
	mov	e, a

;  управляющий код: курсор вправо
out_char_code_right:
	inx	h
	inr	e
	mov	a, e
	sui	SCR_VIDEO_SIZE_X
	rnz				;  ret if E < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -SCR_VIDEO_SIZE_X
	dad	b			;  правим текущий адрес вывода на экран
	mov	e, a			;  курсор переместился в начало строки

;  управляющий код: курсор вниз
out_char_code_down:
	lxi	b, SCR_SIZE_X
	dad	b
	inr	d
	mov	a, d
	sui	SCR_VIDEO_SIZE_Y
	rnz				;  ret if D < SCR_VIDEO_SIZE_X, ZF = 0
	lxi	b, -((SCR_SIZE_X + 1) * (SCR_VIDEO_SIZE_Y - 1))
	dad	b
	mov	d, a			;  курсор переместился на первую строку
	;  здесь флаги ZF = 1, CF = 0
	ret

;  управляющий код: курсор влево
out_char_code_left:
	dcx	h
	dcr	e
	rp				;  ret if E >= 0
	mvi	e, SCR_VIDEO_SIZE_X - 1
	lxi	b, SCR_VIDEO_SIZE_X	;  курсор переместился в конец строки
	dad	b

;  управляющий код: курсор вверх
out_char_code_up:
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	rp				;  ret if D >= 0
	mvi	d, SCR_VIDEO_SIZE_Y - 1	;  курсор переместился на последнюю строку
	lxi	b, (SCR_SIZE_X + 1) * (SCR_VIDEO_SIZE_Y - 1)
	dad	b
	ret
	
;  управляющий код: очистка экрана
out_char_esc_e:
out_char_code_cls:
	xra	a
	sta	attr_charset
	mov	l, a
	mov	h, a
	mov	e, a
	mov	d, a
	dad	sp			;  копируем SP в HL
	lxi	sp, SCREEN + SCR_ARRAY	;  адрес последнего байта экрана + 1
	mvi	a, SCR_ARRAY / 13 / 2	;  через стек заносим 26 байт за итерацию
					;  8-битного регистра хватает для счётчика
out_char_code_cls_loop:
	.rept 13
	push	d			; (11)
	.endm
	dcr	a			; (5)
	jnz	out_char_code_cls_loop	; (10)
	;  цикл: (11 * 13 + 15) * 78 * 30 / 13 / 2 = 14220 тактов
	sphl

;  управляющий код: курсор в начало экрана
out_char_esc_h:
out_char_code_ff:
	lxi	d, 0
	lxi	h, SCREEN_VIDEO
	ret

;  управляющий код: звуковой сигнал
out_char_code_bel:
	lxi	h, out_char_beep
	call	synthesizer3
	pop	h			;  удаляем адрес возврата из стека
	jmp	pop_all_and_ret

;  управляющий код: начало ESC-последовательности, меняется режим вывода
out_char_code_esc:
	lxi	h, out_char_escape
	shld	out_char_vector + 1	;  следующий шаг - обработчик
	pop	h			;  удаляем адрес возврата из стека
	jmp	pop_all_and_ret

;  обработка ESC-последовательности: код
out_char_escape:
	;  для комбинации ESC+Y проверку делаем в первую очередь,
	;  как потенциально самую часто используемую для меньших задержек
	cpi	'Y'
	jz	out_char_esc_y		;  ESC+Y
	;  для остальных кодов используем таблицу переходов
	;  допустимыми являются коды: A - K
	push	b
	push	d
	push	h
	push	psw
	lxi	h, out_char
	shld	out_char_vector + 1	;  в исходное
	;  проверка диапазона от 'A' до 'K'
	sui	'A'
	jc	pop_all_and_ret		;  ошибочный код
	cpi	'K' - 'A' + 1
	jnc	pop_all_and_ret		;  ошибочный код
	;  выбор адреса перехода на обработчик ESC-последовательности
	;  индекс в регистре A
	add	a			;  размер адреса = слово
	mov	l, a
	xra	a
	mov	h, a
	lxi	b, out_char_esc_table	;  база
	dad	b			;  получили адрес ячейки
	mov	c, m
	inx	h
	mov	b, m			;  BC = адрес обработчика
	;  загружаем все необходимые данные
	lxi	h, out_char_exit
	push	h
	lhld	cursor_pos
	xchg				;  D = posY, E = posX
	lhld	cursor_addr		;  HL = scr addr
	;  переход по адресу через стек
	push	b
	ret

out_char_esc_table:
	;  управляющие коды терминала VT52
	dw	out_char_esc_a		;  ESC+A
	dw	out_char_esc_b		;  ESC+B
	dw	out_char_esc_c		;  ESC+C
	dw	out_char_esc_d		;  ESC+D
	dw	out_char_esc_e		;  ESC+E
	dw	out_char_esc_f		;  ESC+F
	dw	out_char_esc_g		;  ESC+G
	dw	out_char_esc_h		;  ESC+H
	dw	out_char_esc_i		;  ESC+I
	dw	out_char_esc_j		;  ESC+J
	dw	out_char_esc_k		;  ESC+K

out_char_esc_f:
out_char_esc_g:
	pop	b
	jmp	pop_all_and_ret

;  ESC+A: курсор вверх, останавливается в верхней позиции
out_char_esc_a:
	cmp	d			;  A = 0
	jnz	out_char_code_up
	ret

;  ESC+B: курсор вниз, останавливается в нижней позиции
out_char_esc_b:
	mvi	a, SCR_VIDEO_SIZE_Y - 1
	cmp	d
	jnz	out_char_code_down
	ret

;  ESC+C: курсор вправо, останавливается в правой позиции
out_char_esc_c:
	mvi	a, SCR_VIDEO_SIZE_X - 1
	cmp	e
	rz
	inx	h
	inr	e
	ret

;  ESC+D: курсор влево, останавливается в левой позиции
out_char_esc_d:
	cmp	e			;  A = 0
	rz
	dcx	h
	dcr	e
	ret

;  ESC+I: курсор вверх, если курсор уже был на самой верхней позиции,
;  производится прокрутка экрана вниз
out_char_esc_i:
	cmp	d			;  A = 0
	jz	out_char_esc_i_scroll
	lxi	b, -SCR_SIZE_X
	dad	b
	dcr	d
	ret

out_char_esc_i_scroll:
	push	h
	lxi	h, 0
	dad	sp			;  копируем SP в HL
	shld	tmp_storage		;  и сохраняем SP
	;  адрес приёмника
	lxi	sp, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y)
	;  адрес источника
	lxi	h, SCREEN + SCR_SIZE_X * (SCR_PAD_Y + SCR_VIDEO_SIZE_Y - 1)
	;  счётчик итераций цикла
	mvi	a, SCR_SIZE_X * SCR_VIDEO_SIZE_Y / 10
out_char_esc_i_scroll_loop:
	.rept 5
	dcx	h
	mov	c, m
	dcx	h
	mov	b, m
	push	b
	.endm
	dcr	a
	jnz	out_char_esc_i_scroll_loop
	lhld	tmp_storage		;  восстанавливаем указатель стека
	sphl
	pop	h
	ret

;  ESC+J: очистка экрана от текущей позиции, положение курсора не меняется
out_char_esc_j:
	pop	b			;  удаляем адрес возврата из стека
	mov	d, a			;  A = 0
	mov	e, a			;  A = 0
	mov	m, a			;  первым делом очищаем тут, в случае нечётного адреса
					;  дальнейший код его пропустит, для чётного не имеет смысла
	lxi	b, -SCREEN		;  вычитание заменяется на сложение с отриц. числом
	dad	b			;  HL = адрес текущей позиции курсора от нуля
	mov	c, l			;  младшие 4 бита будут ещё нужны
	dad	h
	dad	h
	dad	h
	dad	h			;  сдвиг HL влево на 4 разряда, H = адрес / 16
	mvi	a, SCR_ARRAY / 16	;  сколько итераций для всего экрана
	sub	h			;  сколько итераций для части экрана
	lxi	h, 0
	dad	sp			;  копируем SP в HL
	lxi	sp, SCREEN + SCR_ARRAY	;  адрес последнего байта экрана + 1
out_char_esc_j_loop:
	.rept 8
	push	d
	.endm
	dcr	a
	jnz	out_char_esc_j_loop
	mov	a, c			;  какие-то остатки
	rrc				;  уполовиниваем
	ani	7			;  остаток от деления на 8
	jz	$+8			;  а не осталось нихера
	push	d
	dcr	a
	jnz	$-2
	sphl
	jmp	pop_all_and_ret

;  ESC+K: очистка строки от текущей позиции, положение курсора не меняется
out_char_esc_k:
	pop	b			;  удаляем адрес возврата из стека
	mov	c, a			;  A = 0
	mvi	a, SCR_VIDEO_SIZE_X
	sub	e			;  сколько
	mov	m, c
	inx	h
	dcr	a
	jnz	$-3
	jmp	pop_all_and_ret

;  ESC+Y
out_char_esc_y:
	;  пока не получим все параметры на экране ничего меняться не будет
	push	h
	lxi	h, out_char_esc_y_p1
	shld	out_char_vector + 1	;  следующий шаг - получение параметров
	pop	h
	ret

;  ESC+Y: первый параметр - номер строки
out_char_esc_y_p1:
	;  сохраняем параметр, обработка будет происходить, на последнем шаге
	sta	out_char_param
	push	h
	lxi	h, out_char_esc_y_p2
	shld	out_char_vector + 1	;  следующий шаг
	pop	h
	ret

;  ESC+Y: второй параметр - номер позиции
out_char_esc_y_p2:
	push	b
	push	d
	push	h
	push	psw
	lxi	h, out_char
	shld	out_char_vector + 1	;  в исходное
	sui	' '			;  приводим параметр к нужному виду
	mov	l, a
	lda	out_char_param		;  теперь первый параметр
	sui	' '			;  приводим параметр к нужному виду
	mov	h, a
out_char_set_cursor:
	mov	a, l
	cpi	SCR_VIDEO_SIZE_X
	jc	$+4			;  ok
	xra	a
	mov	e, a			;  E = POS_X
	mov	a, h
	cpi	SCR_VIDEO_SIZE_Y
	jc	$+4			;  ok
	xra	a
	mov	d, a			;  D = POS_Y
	;  вычисляется адрес экрана по координатам
	;  HL = POS_Y * SCR_SIZE_X + POS_X + SCREEN_VIDEO
	;  здесь: A = D = POS_Y, E = POS_X
	mvi	h, 00h
	mov	l, d
	mov	b, h
	mov	c, d
	dad	h			;  y * 2
	dad	h			;  y * 4
	dad	h			;  y * 8
	dad	b			;  y * 9
	dad	h			;  y * 18
	dad	b			;  y * 19
	dad	h			;  y * 38
	dad	b			;  y * 39
	dad	h			;  y * 78
	mov	c, e			;  BC = POS_X
	dad	b
	lxi	b, SCREEN_VIDEO
	dad	b

out_char_exit:
	shld	cursor_addr
	xchg
	shld	cursor_pos
	lxi	d, (SCR_PAD_Y << 8) | SCR_PAD_X
	dad	d
	xchg
	;  установка курсора в новую позицию
	lxi	h, ADDR_CRT_CTRL	;  HL = адрес регистра команд CRT
	mvi	m, 80h			;  команда "загрузка курсора"
	dcx	h			;  HL = адрес регистра параметров CRT
	mov	m, e			;  номер знака (X)
	mov	m, d			;  номер знакоряда (Y)
	;
pop_all_and_ret:
	pop	psw
pop_hdb_and_ret:
	pop	h
pop_db_and_ret:
	pop	d
	pop	b
	ret

;  ВЫВОД СИМВОЛА  ______________________________________________________________
;  Вход:  C - код символа
out_char_c:
	push	psw
	mov	a, c
	call	out_char_vector
	pop	psw
	ret

;  ВЫВОД СТРОКИ СИМВОЛОВ  ______________________________________________________
;  Вход:  HL - адрес строки, строка оканчивается нулевым символом
out_str:
	mov	a, m
	inx	h
	ana	a
	rz
	call	out_char_vector
	jmp	out_str

;  ВЫВОД СТРОКИ СИМВОЛОВ  ______________________________________________________
;  Вход: строка символов должна следовать сразу за вызовом этой функции,
;        строка оканчивается нулевым символом
;  примечание: все регистры сохраняются, кроме A.
print:
	xthl
	call	out_str
	xthl
	ret

;  ВЫВОД БАЙТА В HEX-КОДЕ  _____________________________________________________
;  Вход:  A - байт
out_hex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	$+4
	pop	psw
	ani	0Fh
	cpi	10
	sbi	'0' - 1
	daa
	jmp	out_char_vector

;  ЗАПРОС ПОЛОЖЕНИЯ КУРСОРА  ___________________________________________________
;  Выход: H - номер строки
;         L - номер позиции
;  замечание: функция возвращает положение курсора от начала видимой области
;    экрана, это поведение отличается от принятой в РК. т.к. импульсы гашения
;    в РК формируются программным образом, на мой взгляд, это было глупое
;    решение разработчиков РК сместить точку отсчёта в область формирования
;    импульсов гашения, и нулевой отсчёт у них стал начинаться не с нуля.
;    поскольку в эту область всё равно ничего писать нельзя, я буду отсчитывать
;    экранные координаты от видимой области, как это сделано во всех нормальных
;    компьютерах. это, конечно, приведет к несовместимости с некоторыми
;    программами, но лучше исправить программу, чем иметь кривое решение.
;    пс: ESC+Y+posY+posX в родной п/п РК out_char принимает координаты
;    как положено -- от нуля, вот такой вот парадокс.
get_cursor:
	lhld	cursor_pos
	ret

;  УСТАНОВКА ПОЛОЖЕНИЯ КУРСОРА  ________________________________________________
;  Вход:  H - номер строки (Y)
;         L - номер позиции (X)
;  примечание: отсчёт от нуля
set_cursor:
	push	b
	push	d
	push	h
	push	psw
	jmp	out_char_set_cursor

;  ЗАПРОС БАЙТА ИЗ ЭКРАННОГО БУФЕРА  ___________________________________________
;  Выход: A - код из буфера
get_scr:
	push	h
	lhld	cursor_addr
	mov	a, m
	pop	h
	ret

;  =============================================================================
;  ================================================  ПОДПРОГРАММЫ КЛАВИАТУРЫ  ==

;  ОПРОС СОСТОЯНИЯ КЛАВИАТУРЫ  _________________________________________________
;  Выход: A = 00 - не нажата
;         A = FF - нажата
;  примечание: кроме проверки регистра A можно использовать проверку флага ZF
;         флаг ZF = 0 - не нажата
;         флаг ZF = 1 - нажата
kbd_state:
	lda	kbd_buffer_full
	ana	a
	rnz				;  в буфере есть непрочитанный код
	push	h
	call	in_key_vector
	lhld	kbd_key_status
	cmp	l
	jz	kbd_state_handling
	mov	l, a
kbd_state_released:
	mvi	h, 1			;  задержка выдачи первого символа
	lda	kbd_delay_first_const	;  задержка автоповтора для второго символа
	sta	kbd_delay
kbd_state_rst_and_exit:
	xra	a			;  код выхода: не нажата
kbd_state_exit:
	shld	kbd_key_status
	pop	h
	ret

kbd_state_rus:
	call	in_key_vector
	cpi	CHAR_CODE_ALF
	jz	kbd_state_rus		;  ждём отпускания клавиши [РУС/ЛАТ]
	lda	kbd_rus
	cma
	sta	kbd_rus
	mvi	l, 0FFh
	jmp	kbd_state_released

kbd_state_handling:
	lda	antibounce
	dcr	a
	sta	antibounce
	jnz	kbd_state_rst_and_exit
	lda	antibounce_const
	sta	antibounce
	dcr	h			;  переменная задержки
	jnz	kbd_state_rst_and_exit	;  ещё не время
	;  задержка прошла
	mov	a, l
	inr	a			;  in_key == FF ?
	jz	kbd_state_exit		;  ничего не нажато
	inr	a			;  in_key == FE ?
	jz	kbd_state_rus		;  нажата [РУС/ЛАТ]
	lda	kbd_delay
	mov	h, a			;  рабочая переменная
	lda	kbd_delay_regular_const	;  задержка автоповтора для остальных символов
	sta	kbd_delay
	mvi	a, 0FFh			;  код выхода: нажата
	sta	kbd_buffer_full
	jmp	kbd_state_exit

;  ВВОД СИМВОЛА С КЛАВИАТУРЫ  __________________________________________________
;  Выход: A - введенный код
in_char:
	call	kbd_state_vector
	jz	in_char
	push	h
	lxi	h, in_char_lat_beep	;  параметры сигнала для латинской раскладки
	lda	kbd_rus
	ana	a
	jz	$+6
	lxi	h, in_char_rus_beep	;  параметры сигнала для русской раскладки
	xra	a
	sta	kbd_buffer_full		;  сброс флага "буфер полон"
	cmp	m
	cnz	synthesizer3
	pop	h
	lda	kbd_key_status
	ret

;  ВВОД КОДА НАЖАТОЙ КЛАВИШИ  __________________________________________________
;  Выход: A = FF - не нажата
;         A = FE - РУС/ЛАТ
;         A - код клавиши
in_key:
	inp	ADDR_KBD_PC
	ani	KBD_RUS_FLAG
	mvi	a, CHAR_CODE_ALF
	rz				;  результат: FEh, нажата [РУС/ЛАТ]
	lda	kbd_rus
	ani	1
	ori	3 << 1			;  3-й бит порта C
	outp	ADDR_KBD_CTRL		;  светодиод
	xra	a
	outp	ADDR_KBD_PA
	inp	ADDR_KBD_PB
	cpi	0FFh
	rz				;  результат: ничего не нажато
	push	b
	push	d
	lxi	b, pop_db_and_ret
	push	b
	lxi	b, 1F7Fh
	mvi	d, 20h
	;  B = скан код
	;  C = бегающий ноль
in_key_loop:
	mov	a, c
	rlc
	mov	c, a
	outp	ADDR_KBD_PA
	lda	antibounce_inkey
	mov	e, a
in_key_antibounce_loop:
	inp	ADDR_KBD_PB
	cpi	0FFh
	jz	in_key_end
	dcr	e
	jnz	in_key_antibounce_loop
	;  находим линию и подсчитываем сканкод
	inr	b
	rar
	jc	$-2
	mov	a, b
	cpi	5Fh
	mov	a, d			;  A = 20h, сканкод 5Fh -- это пробел
	rz				;  результат: пробел
	mov	a, b
	cpi	30h
	rz				;  результат: '0', '0' не модифицируется шифтом
	jnc	in_key_31_7F		;  линии опроса A2-A7
	;  линии опроса A0-A1
	;  сканкоды 20h-2Fh
	;  конвертанция сканкода через таблицу
	lxi	b, kbd_table - 20h
	add	c
	mov	c, a
	adc	b
	sub	c
	mov	b, a
	ldax	b
	cpi	7Fh
	rnz				;  результат: коды управляющих клавиш, кроме Забоя
	mov	b, a			;  B = 7Fh
in_key_31_7F:
	cpi	40h
	inp	ADDR_KBD_PC
	jc	in_key_31_3F

	;  коды 40-7Fh
	mov	c, a
	ani	KBD_CTRL_FLAG
	jnz	in_key_40_7F		;  no ctrl
	;  ctrl
	mov	a, b
	ani	1Fh
	ret				;  результат: коды 00h-1Fh

in_key_40_7F:
	;  буквенные клавиши
	;  результат зависит от текущего знакогенератора:
	;  для стандартного з/г (0, только заглавные латинские и русские буквы)
	;    --  стандартное поведение: режим RUS и SHIFT меняет коды
	;  для расширенного з/г (2, заглавые и строчные буквы обоих алфавитов)
	;    --  коды меняет только клавиша SHIFT
	inp	ADDR_KBD_PC
	rar				;  проверить 0-й разряд
	jc	in_key_mode2		;  для расширенного з/г
	lda	kbd_rus
	ana	a
	jz	in_key_mode2		;  lat
	;  rus
	mov	a, b
	ora	d			;  4xh => 6xh
	mov	b, a
in_key_mode2:
	mov	a, c			;  ADDR_KBD_PC
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mov	a, b
	rnz				;  результат: буквенные клавиши без шифта
	xra	d			;  4xh => 6xh, 6xh => 4xh
	ret				;  результат: буквенные клавиши с шифтом

in_key_31_3F:
	;  коды 31h-3Fh
	ana	d			;  KBD_PC & KBD_SHIFT_FLAG
	mov	a, b
	jnz	$+6			;  no shift
	;  shift
	ani	2Fh
	mov	b, a
	ani	0Fh
	cpi	0Ch
	mov	a, b
	rc
	xri	10h			;  для кодов xC-xF инвертировать 4-й бит:
					;  2xh => 3xh, 3xh => 2xh
	ret				;  результат: коды 20h-3Fh

in_key_end:
	mov	a, b
	adi	8
	mov	b, a
	cpi	58h
	jc	in_key_loop
	mvi	a, 0FFh			;  результат: не нажато
	ret

kbd_table:
	db	0Ch, 1Fh, 1Bh, 00h, 01h, 02h, 03h, 04h
	db	09h, 0Ah, 0Dh, 7Fh, 08h, 19h, 18h, 1Ah

;  =============================================================================
;  ====================================================  ПРОЧИЕ ПОДПРОГРАММЫ  ==

;  ПРЕОБРАЗОВАНИЕ HEX-СТРОКИ В ЧИСЛО  __________________________________________
;  Вход:  DE - адрес строки
;  Выход: HL - результат
;         DE - адрес, где остановилась обработка
;         флаг ZF = 1 и CF = 0 - достигнут конец строки
;         флаг CF = 1 - встретился символ, не соответствующий hex-цифре
;  примечание: проверка на переполнение не производится, разряды будут сдвигаться
;         влево, пока в строке встречаются HEX-цифры, например, строка
;         "123ACF" даст результат 3ACF
str2hex:
	xra	a
	mov	h, a		;  HL = результат
str2hex_loop:
	mov	l, a
	ldax	d
	ana	a
	rz
	sui	'0'
	rc
	cpi	10
	jc	str2hex_add
	sui	7
	cpi	10
	rc
	cpi	16
	cmc
	rc
str2hex_add:
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	inx	d
	jmp	str2hex_loop

;  ПЕРЕХОД ПО АДРЕСУ ИЗ ТАБЛИЦЫ ПЕРЕХОДОВ  _____________________________________
;  Вход:  A - входное значения для поиска, должно быть отличное от нуля
;         таблица переходов должна следовать сразу за вызовом этой функции
;  формат таблицы:
;         DB  XX, где XX - байт соответствия
;         DW  ADDR, где ADDR - адрес перехода при совпадении
;         нулевой байт XX - завершение таблицы 
;  описание: при совпадении входного байта с одним из байтов соответствия
;         произойдет переход по адресу ADDR, если соответствия байта в таблице
;         не обнаружилось, произойдет переход по адресу, следующему за таблицей.
;  примечание: все регистры сохраняются.
branch:
	xthl				;  (18)
	push	b			;  (11)
	mov	c, a			;  (5)
	dcx	h			;  (5)
	dcx	h			;  (5)
branch_loop:
	inx	h			;  (5)
	inx	h			;  (5)
	mov	a, m			;  (7)
	inx	h			;  (5)
	ana	a			;  (4)
	jz	branch_exit		;  (10)
	cmp	c			;  (4)
	jnz	branch_loop		;  (10) / 50 тактов за итерацию
	;  найдено совпадение
	mov	a, m			;  (7)
	inx	h			;  (5)
	mov	h, m			;  (7)
	mov	l, a			;  (5)
branch_exit:
	mov	a, c			;  (5)
	pop	b			;  (10)
	xthl				;  (18)
	ret				;  (10)
	;  161 такт весь код

;  СРАВНЕНИЕ ДВУХ 16-РАЗРЯДНЫХ ЧИСЕЛ  __________________________________________
;  Вход:  DE - первое слово
;         HL - второе слово
;  Выход: флаг ZF = 1: DE == HL
;         флаг ZF = 0 и CF = 1: DE < HL
;         флаг ZF = 0 и CF = 0: DE > HL
cmp_de_hl:
	mov	a, d
	cmp	h
	rnz
	mov	a, e
	cmp	l
	ret

;  ПОДСЧЁТ КОНТРОЛЬНОЙ СУММЫ БЛОКА  ____________________________________________
;  Вход:  HL - адрес начала блока
;         DE - адрес конца блока
;  Выход: BC - контрольная сумма
check_sum:
	lxi	b, 0
	jmp	check_sum_start
check_sum_loop:
	mov	a, c
	add	m
	mov	c, a
	mov	a, b
	adc	m
	mov	b, a
	inx	h
check_sum_start:
	call	cmp_de_hl
	jnz	check_sum_loop
	mov	a, c
	add	m
	mov	c, a
	ret

;  SYNTHESIZER  ________________________________________________________________
;  Запуск генератора в одном канале
;  Вход:  A  - номер канала [0, 1, 2]
;         H  - задержка в мс, если 0 - без задержки
;         DE - коэффициент деления
synthesizer:
	cpi	3
	rnc
	mov	l, a
	push	h
	lxi	h, ADDR_TIMER
	add	l
	mov	l, a
	mov	m, e			;  младший байт
	mov	m, d			;  старший байт
	pop	h
	inr	h
	dcr	h
	rz				;  без задержек
	;  1 такт(мкс) = 1000 / CPU_CLOCK(кГц)
	;  количество тактов для 1мкс = CPU_CLOCK(кГц) / 1000
	;  для задержки в 1мс количество итераций = 1000 * (к.т.1мкс) / 20
synthesizer_delay:
	mvi	a, (1000 * CPU_CLOCK / 1000) / 20
	mov	a, a			;  (5)
	dcr	a			;  (5)
	jnz	$-2			;  (10)
	dcr	h
	jnz	synthesizer_delay
	mov	a, l			;  сдвиг 1 и 0 разряда в 7 и 6 разряды
	rar
	rar
	rar
	ori	00110110b		;  D7:D6 - канал таймера
	outp	ADDR_TIMER_CTRL		;  выключить канал
	ret

;  SYNTHESIZER3  _______________________________________________________________
;  Запуск генератора сразу в трёх каналах
;  Вход:  HL - адрес структуры с данными
;              формат структуры:
;                  DB	задержка в мс (обязательно)
;                  DW	коэффициент деления
synthesizer3:
	push	b
	mov	a, m
	inx	h
	mov	c, m
	inx	h
	mov	b, m
	lxi	h, ADDR_TIMER
	mov	m, c
	mov	m, b
	inx	h
	mov	m, c
	mov	m, b
	inx	h
	mov	m, c
	mov	m, b
	inx	h
	mov	c, a
synthesizer_int_delay:
	mvi	a, (1000 * CPU_CLOCK / 1000) / 20
	mov	a, a			;  (5)
	dcr	a			;  (5)
	jnz	$-2			;  (10)
	dcr	c
	jnz	synthesizer_int_delay
	mvi	m, 00110110b
	mvi	m, 01110110b
	mvi	m, 10110110b
	pop	b
	ret

;  ВЫБОР ЗНАКОГЕНЕРАТОРА  ______________________________________________________
;  Вход:  A - номер знакогенератора
;         A = 0 - стандартный з/г: только заглавные латинские и русские буквы
;         A = 1 - графический з/г Апогея
;         A = 2 - расширенный з/г: заглавые и строчные буквы обоих алфавитов
set_charset:
	;  PC0 = ROM_A11
	;  PC1 = 0 => ROM_A10 = 1
	;  PC1 = 1 => ROM_A10 = screen attr
	;  A = 0: PC = 10b
	;  A = 1: PC = 00b
	;  A = 2: PC = 11b
	cpi	3
	rnc
	xri	1		;  A = 1, 0, 3
	push	psw
	ani	1
	ori	1 << 1
	outp	ADDR_KBD_CTRL	;  PC1
	pop	psw
	rar
	outp	ADDR_KBD_CTRL	;  PC0
	ret

;  ИНИЦИАЛИЗАЦИЯ МОНИТОРА ПРИ ХОЛОДНОМ СТАРТЕ  _________________________________
init_monitor:
	call	init_video	;  возможно не требуется,
				;  надо подсчитать количество времени, которое
				;  потребуется для вывода заголовка
	;  первым делом необходимо считать значения с порта PC клавиатуры.
	;  порт PC на ввод, для чтения конфигурации
	;  порт PC содержит конфигурацию компьютера:
	;  PC0 = 0 - знакогенератор хранится в ROM
	;  PC0 = 1 - знакогенератор хранится в RAM
	;  PC2 = 0 - шрифт имеет ширину 6 пикселов
	;  PC2 = 1 - шрифт имеет ширину 8 пикселов
	lxi	h, ADDR_KBD_CTRL
	mvi	m, 10001011b
	inp	ADDR_KBD_PC
	sta	config_rk
	;  порт клавиатуры в режиме 0
	;  канал A на вывод, канал B на ввод,
	;  линии PC0-PC3 на вывод, PC4-PC7 на ввод
	mvi	m, 10001010b
	;  установка бита порта PC выбора ширины символа согласно конфигурации
	ani	CFG_RK_FONT_8BIT
	outp	ADDR_KBD_PC
	;  копирование части кода из ROM в RAM
	lxi	h, rom_data			;  откуда
	lxi	d, rom_data_end - 1		;  докуда
	lxi	b, ram_data			;  куда
	call	directive_t_loop
	;  заголовок
	call	print
	db	CHAR_CODE_CLS, ATTR_COLOR_YELLOW, "\x0eradio-86rk/60K\x0f", ATTR_COLOR_WHITE, 0

;  ИНИЦИАЛИЗАЦИЯ КОНТРОЛЛЕРОВ  _____________________________________________
init_video:
	push	h
	lxi	h, ADDR_CRT_CTRL
	mvi	m, 0			;  команда "сброс"
	dcx	h

	;  компоновка кадра: загружаются 4 байта в регистр параметров
	;  1. SHHHHHHH
	;     S        - знакоряды:
	;                0 - нормальные знакоряды
	;                1 - чередующиеся знакоряды
	;      HHHHHHH - число знаков в знакоряду минус один (от 1 до 80)
	mvi	m, (SCR_SIZE_X - 1) | (CRT_SPACED_ROW << 7)

	;  2. VVRRRRRR
	;     VV       - длительность обратного хода кадровой развертки
	;                00 - 1 знакоряд
	;                01 - 2 знакоряда
	;                10 - 3 знакоряда
	;                11 - 4 знакоряда
	;       RRRRRR - число знакорядов в кадре минус один (от 1 до 64):
	mvi	m, (SCR_SIZE_Y - 1) | ((CRT_VERT_ROW_COUNT - 1) << 6)

	;  3. UUUULLLL
	;     UUUU     - номер строки подчеркивания в знакоряду, старший бит
	;                определяет гашение верхней и нижней строк растра в
	;                знакоряду, если UUUU = 1xxx, то строки гасятся
	;         LLLL - число строк растра в знакоряду (от 1 до 16)
	mvi	m, ((CRT_UNDERLINE - 1) << 4) | (CRT_LINES_PER_ROW - 1)

	;  4. MFCCZZZZ
	;     M        - режим счетчика строк:
	;                0 - не сдвинуто
	;                1 - смещено на 1 счет
	;                подробно на стр. 125
	;      F       - режим атрибутов поля:
	;                0 - прозрачный
	;                1 - непрозрачный
	;       CC     - тип курсора:
	;                00 - мерцающий негативный видеоблок
	;                01 - мерцающие подчеркивание
	;                10 - немерцающий негативный видеоблок
	;                11 - немерцающее подчеркивание
	;         ZZZZ - число знаков при обратном ходе строчной
	;                развертки (2, 4, 6, ..., 32): (3 + 1) * 2 = 8
	inp	ADDR_KBD_PC
	ani	CFG_RK_FONT_8BIT
	mvi	l, CRT_ZZZZ6 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	jz	$+5
	mvi	l, CRT_ZZZZ8 | (CRT_LINE_OFFSET << 7) | (CRT_NON_TRANSP_ATTR << 6)
	lda	cursor_view
	ora	l
	mvi	l, low (ADDR_CRT_PARAM)
	mov	m, a
	inx	h			;  HL = адрес регистра команд CRT

	;  001SSSBB - команда "начало воспроизведения"
	;     SSS   - интервал между пакетами, число синхроимпульсов
	;             знака между пакетными запросами ПДП:
	;             000 = 0
	;             001 = 7
	;             010 = 15
	;             011 = 23
	;             100 = 31
	;             101 = 39
	;             110 = 47
	;             111 = 55
	;        BB - число запросов ПДП в пакете:
	;             00 = 1
	;             01 = 2
	;             10 = 4
	;             11 = 8
	mvi	m, 00100000b | (CRT_BURST_SPACE_CODE << 2) | CRT_BURST_COUNT_CODE
	mov	a, m			;  сброс регистра флагов
	mov	a, m			;  чтение слова состояния
	ani	20h			;  нужен флаг IR - запрос прерывания
	jz	$-3			;  ждём установленного IR

	lxi	h, ADDR_DMA + 8		;  адрес регистра режимов ПДП
	mvi	m, 10000000b		;  запрет ПДП
	mvi	l, low (ADDR_DMA + 04h)	;  адрес регистра адреса канала 2 ПДП
	mvi	m, low (SCREEN)		;  младший адрес памяти
	mvi	m, high (SCREEN)	;  старший адрес памяти
	inr	l			;  адрес регистра количества циклов ПДП канала 2

	;  16 бит = RWCCCCCC CCCCCCCC
	;  CCCCCC CCCCCCCC - количество циклов
	;  RW = 00 - цикл проверки ПД
	;  RW = 01 - цикл записи ПД
	;  RW = 10 - цикл чтения ПД
	;  RW = 11 - запрещенная комбинация
	;  младший байт счётчика циклов (биты C7-C0)
	mvi	m, low (SCR_ARRAY - 1)
	;  старший байт счётчика циклов (биты C13-C8)
	mvi	m, high (SCR_ARRAY - 1) | (01b << 6)
	mvi	l, low (ADDR_DMA + 08h)	;  адрес регистра режимов ПДП

	;  D7 [AL]  = 1 - автозагрузка
	;  D6 [TCS] = 0 - КС-стоп
	;  D5 [EW]  = 1 - удлиненная запись
	;  D4 [RP]  = 0 - циклический сдвиг
	;  D3 [EN3] = 0 - разрешение канала 3
	;  D2 [EN2] = 1 - разрешение канала 2
	;  D1 [EN1] = 0 - разрешение канала 1
	;  D0 [EN0] = 0 - разрешение канала 0
	mvi	m, 10100100b		;  установка режима

	;  здесь начинаются циклы ПДП
	pop	h
	ret

;  =============================================================================
;  =================================================================  ДАННЫЕ  ==

;  блок кода, который переносится в оперативную память  ________________________
rom_data:
	jmp	out_char		;  out_char_vector
	jmp	in_char			;  in_char_vector
	jmp	in_key			;  in_key_vector
	jmp	kbd_state		;  kbd_state_vector
	jmp	dummy_func		;  rd_byte_tape_vector
	jmp	dummy_func		;  wr_byte_tape_vector
	jmp	dummy_func		;  rd_block_tape_vector
	jmp	dummy_func		;  wr_block_tape_vector
	db	0C3h			;  jmp
	dw	out_error_txt

	dw	MONITOR_DATA - 1	;  mem_top
	syn_note	4, 2, 4		;  in_char_lat_beep: латинская раскладка
					;  "ми" второй октавы, 4 мс
	syn_note	4, 2, 7		;  in_char_rus_beep: русская раскладка
					;  "соль" второй октавы, 4 мс
	syn_note	50, 1, 9	;  out_char_beep: "ля" первой октавы, 50 мс
	db	KBD_ANTIBOUNCE_INKEY	;  antibounce_inkey
	db	KBD_ANTIBOUNCE		;  antibounce
	db	KBD_ANTIBOUNCE		;  antibounce_const
	db	KBD_DELAY_FIRST		;  	
	db	KBD_DELAY_REGULAR	;  kbd_delay_regular_const
	dw	0FFFFh			;  kbd_key_status
	db	CURSOR_VIEW_INITIAL	;  cursor_view: 00h, 10h, 20h, 30h
rom_data_end:

;  =============================================================================
;  рабочие переменные МОНИТОРА в оперативной памяти

	org	MONITOR_DATA

;  область ОЗУ в которую копируются данные из ПЗУ  _____________________________
ram_data:
;  вектора подпрограмм МОНИТОРА
out_char_vector:			;  #0
	ds	3
in_char_vector:				;  #1
	ds	3
in_key_vector:				;  #2
	ds	3
kbd_state_vector:			;  #3
	ds	3
rd_byte_tape_vector:			;  #4
	ds	3
wr_byte_tape_vector:			;  #5
	ds	3
rd_block_tape_vector:			;  #6
	ds	3
wr_block_tape_vector:			;  #7
	ds	3
extended_directive_handler:
	ds	1			;  0C3h = jmp
	ds	2			;  адрес обработчика
mem_top:				;  верхняя граница памяти [get_mem_top] [set_mem_top]
	ds	2
in_char_lat_beep:			;  сигнал клавиши для латинской раскладки [in_char]
	ds	3
in_char_rus_beep:			;  сигнал клавиши для русской раскладки [in_char]
	ds	3
out_char_beep:				;  код 7 [out_char]
	ds	3
antibounce_inkey:			;  счётчик антидребезга [in_key]
	db	0
antibounce:				;  счётчик антидребезга [kbd_state]
	db	0
antibounce_const:			;  [kbd_state]
	db	0
kbd_delay_first_const:			;  [kbd_state]
	db	0
kbd_delay_regular_const:		;  [kbd_state]
	db	0
kbd_key_status:				;  код клавиши и переменная задержки [kbd_state]
	dw	0
cursor_view:				;  вид курсора (видеоблок/подчеркивание) [init_video]
	db	0			;  допустимые значения: 00h, 10h, 20h, 30h
;  end ram_data
;  _____________________________________________________________________________
cursor_addr:				;  текущее значение адреса курсора [out_char]
	dw	0
cursor_pos:				;  текущее положение курсора [out_char]
	dw	0
attr_charset:				;  код для переключения знакогенератора [out_char]
	db	0
out_char_param:				;  рабочае ячейка ESC+Y [out_char]
	db	0
kbd_buffer_full:			;  флаг наличия кода в буфере клавиатуры [kbd_state]
	db	0
kbd_delay:				;  константа задержки выдачи кода [kbd_state]
	db	0
kbd_rus:				;  флаг русской раскладки клавиатуры [kbd_state] [in_key]
	db	0
tmp_storage:				;  переменная для временного хранения
	dw	0
inp_buffer:				;  буфер введенной строки
	ds	INP_BUFFER_SIZE
inp_buffer_end:

config_rk:				;  биты, выставленные джамперами
	db	0

	org	MONITOR_DATA + MONITOR_DATA_SIZE
stack:

;  =============================================================================
;  end of file  ================================================================
