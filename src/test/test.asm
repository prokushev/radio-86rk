	CPU	8080
	Z80SYNTAX	EXCLUSIVE

	ORG	00100H
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

	CALL	DumpRegs

	CALL	0F806H		; Ожидание ввода с магнитофона

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки

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

	CALL	DumpRegs

	CALL	0F81EH		; Запрос положения курсора

	CALL	DumpRegs

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

	CALL	DumpRegs

	CALL	0F821H		; Запрос текущего символа

	CALL	DumpRegs

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

	LD	HL, testdata
	LD	DE, testdataend

	CALL	DumpRegs

	CALL	0F82AH		; Расчет контрольной суммы

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

testdata:
	DB	0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,11,22,33,44,22,55,44,88,0EEH
testdataend: EQU	$-1

MTESTF82D:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF82DMsg
	CALL	0F818H		; Вывод строки

	CALL	DumpRegs

	CALL	0F82DH		; Инициализация видеоподсистемы

	CALL	DumpRegs

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

	CALL	DumpRegs

	CALL	0F830H		; Получить последний адрес памяти

	CALL	DumpRegs

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

	CALL	0F830H		; Получить границу памяти
	PUSH	HL

	LD	HL, 02000H

	CALL	DumpRegs

	CALL	0F833H		; установить границу памяти

	CALL	DumpRegs
	
	POP	HL		; Восстановить границу озу
	CALL	0F833H		; установить границу памяти

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

	LD	HL, 02000H
	LD	A, 1

	CALL	DumpRegs

	CALL	0F836H		; считать из допстраницы

	CALL	DumpRegs


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

	LD	HL, 02000H
	LD	A, 1
	LD	C, 077H

	CALL	DumpRegs

	CALL	0F839H		; записать в допстраницу

	CALL	DumpRegs


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

	LD	HL, 1010H
	CALL	DumpRegs

	CALL	0F83CH

	CALL	DumpRegs

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

	CALL	DumpRegs

	CALL	0F83FH		; Beep

	CALL	DumpRegs

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MONITORNonStdTest:
	PUSH	AF
	PUSH	HL

MONITORNonStdTestLoop:
	LD	HL, MONITORNonStdMsg
	CALL	0F818H		; Вывод строки

	CALL	0F803H		; Ожидание ввода

	CP	"A"
	CALL	Z, MTESTF86C
	CP	"B"
	CALL	Z, MTESTF8EE
	CP	"C"
	CALL	Z, MTESTF92C
	CP	"D"
	CALL	Z, MTESTF990
	CP	"E"
	CALL	Z, MTESTF9B0
	CP	"F"
	CALL	Z, MTESTFA68
	CP	"G"
	CALL	Z, MTESTFACE
	CP	"H"
	CALL	Z, MTESTFB78
	CP	"I"
	CALL	Z, MTESTFD27
	CP	"0"
	JP	NZ, MONITORNonStdTestLoop
	
	POP	HL
	POP	AF

	RET

MTESTF86C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF86CMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF8EE:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF92C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0F92CH		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF990:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0F990H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTF9B0:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0F9B0H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTFA68:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0FA68H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTFACE:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF8EEMsg
	CALL	0FACEH		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTFB78:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTFB78Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
	RET

MTESTFD27:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTFD27Msg
	CALL	0F818H		; Вывод строки

	LD	HL, AnyKey
	CALL	0F818H		; Вывод строки
	CALL	0F803H		; Ожидание ввода

	POP	HL
	POP	AF
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
	DB	0dh, 0ah, "prowerka F806H", 0dh, 0ah
	DB	"wwod bajta s magnitofona. zapustite wosproizwedenie i", 0
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
MONITORNonStdMsg:
	DB	0dh, 0ah, "* testirowanie monitora * wyberite podprogrammu: ", 0dh, 0ah
	DB	"A F86C", 0dh, 0ah
	DB	"B F8EE", 0dh, 0ah
	DB	"C F92C", 0dh, 0ah
	DB	"D F990", 0dh, 0ah
	DB	"E F9B0", 0dh, 0ah
	DB	"F FA68", 0dh, 0ah
	DB	"G FACE", 0dh, 0ah
	DB	"H FB78", 0dh, 0ah
	DB	"I FD27", 0dh, 0ah
	DB	"0 nazad"
	DB	0dh, 0ah,">", 0
MTESTF86CMsg:
	DB	0dh, 0ah, "prowerka F86CH", 0dh, 0ah, '>', 0
MTESTF8EEMsg:
	DB	0dh, 0ah, "prowerka F8EEH", 0dh, 0ah, '>', 0
MTESTF92CMsg:
	DB	0dh, 0ah, "prowerka F92CH", 0dh, 0ah, '>', 0
MTESTF990Msg:
	DB	0dh, 0ah, "prowerka F990H", 0dh, 0ah, '>', 0
MTESTF9B0Msg:
	DB	0dh, 0ah, "prowerka F9B0H", 0dh, 0ah, '>', 0
MTESTFA68Msg:
	DB	0dh, 0ah, "prowerka FA68H", 0dh, 0ah, '>', 0
MTESTFACEMsg:
	DB	0dh, 0ah, "prowerka FACEH", 0dh, 0ah, '>', 0
MTESTFB78Msg:
	DB	0dh, 0ah, "prowerka FB78H", 0dh, 0ah, '>', 0
MTESTFD27Msg:
	DB	0dh, 0ah, "prowerka FD27H", 0dh, 0ah, '>', 0

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

CPMTestLoop:
	LD	DE, CPMMsg
	LD	C, 9		; Вывод строки
	CALL	5		; Вызов BDOS

	LD	C, 1				; C_READ
	CALL	5				; BDOS

	CP	"A"
;	CALL	Z, MONITORTest
	CP	"B"
;	CALL	Z, CPMTest
	CP	"0"
	JP	NZ, CPMTestLoop

	POP	DE
	POP	BC
	POP	HL
	POP	AF
	RET

FCB	DB	0
	DB	"BASIC   "
	DB	"COM"
	DB	0
	DB	0
	DB	0
	DB	0
	DB	16 DUP (0)
	DB	0
	DB	0

CPMMsg:
	DB	0dh, 0ah, "* testirowanie CP/M * wyberite komponent: ", 0dh, 0ah
	DB	"A BIOS", 0dh, 0ah
	DB	"B BDOS", 0dh, 0ah
	DB	"0 nazad"
	DB	0dh, 0ah,">$"

CPMBIOSMsg:
	DB	0dh,0ah,"CP/M BIOS", 0dh, 0ah, "CONOUT: ", 0dh, 0ah, "$"

CPMBDOSMsg:
	DB	0dh,0ah,"CP/M BDOS", 0dh, 0ah, "C_WRITE: ", 0dh, 0ah, "$"

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

