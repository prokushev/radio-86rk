; ═══════════════════════════════════════════════════════════════════════
;  МОНИТОР-1.20 для Радио-86РК для КР580, совместимый с Орион-128,
;  поддержкой VT-52 и эмулятором CP/M
; ═══════════════════════════════════════════════════════════════════════

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ───────────────────────────────────────────────────────────────────────
; Адреса системных вызовов
; ───────────────────────────────────────────────────────────────────────

	INCLUDE	"syscalls.inc"

CHK	MACRO	adr, msg
		IF	$>(adr)
			ERROR	msg
		ENDIF
	ENDM

; ───────────────────────────────────────────────────────────────────────
; Блок 0. Инициализация BDOS
; ───────────────────────────────────────────────────────────────────────

	ORG	0

; ──────────────────────────────────────────────
; Блок защиты загрузки на Орион-128. Выводит
; сообщение, что данный диск предназначен для Радио-86РК.
; ──────────────────────────────────────────────

	PHASE	0B800H			; Адрес загрузки для ORDOS
ORDOSStart:
	LD	HL, MsgRKOnly
	CALL	PrintString
	JP	WarmBoot
MsgRKOnly:
	DB	"|tot ROM-disk prednazna~en dlq radio-86r",'k' + 80H

	DEPHASE

	CHK	0800H, "* Block overflow ! *"

; ───────────────────────────────────────────────────────────────────────
; Файловая система в формате ORDOS
; ───────────────────────────────────────────────────────────────────────
	ORG 0800H
	if 0
FILE	MACRO name, start, size
	DB	(0fff0h-$) & 0fh dup (0)	; выравнивание по границе 16
s	SET	$
	DB	name
	DB	8-($-s) DUP (20H)
	DW	start
	DW	size
	DB	080H
	DB	0,0,0
	ENDM

ENDOFFILES	MACRO
	DB	(0fff0h-$) & 0fh dup (0)	; выравнивание по границе 16
	DB	0FFH
	ENDM

	FILE "DUMP$", 100H, ENDDUMPCOM-DUMPCOM
DUMPCOM:
	BINCLUDE "dump.com"
ENDDUMPCOM:

	FILE "BASIC$", 0, 02000H
BASICROM:
	BINCLUDE "basic.rom"

	FILE "ASM$", 0, 01000H
EDASMROM:
	BINCLUDE "edasm.rom"

	FILE "DDT$", 6400H, 01000H
DPDDTROM:
	BINCLUDE "dpddt.rom"
	
	FILE "SORT$", 0, 0E96H
SORTUTROM:
	BINCLUDE "sortut.rom"

	FILE "LOAD$", 07400H, ENDLOADROM-LOADROM
LOADROM:
	BINCLUDE "load.rom"
ENDLOADROM:

	FILE "SAVE$", 07400H, ENDSAVEROM-SAVEROM
SAVEROM:
	BINCLUDE	"SAVE.ROM"
ENDSAVEROM:

	FILE "TEST$", 00100H, ENDTESTROM-TESTROM
TESTROM:
	BINCLUDE	"TEST.COM"
ENDTESTROM:

	ENDOFFILES
	endif
; ───────────────────────────────────────────────────────────────────────
; ПРОГРАММА УПРАВЛЕНИЯ ROM-DISK/32K
; ───────────────────────────────────────────────────────────────────────

	ORG	07E00H

	BINCLUDE "romctrl.rom"

	CHK	08000H, "* Block overflow ! *"
	END 				;

