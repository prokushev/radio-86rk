; ННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННН
;  ЊЋЌ€’Ћђ-2.00 ¤«п ђ ¤Ё®-86ђЉ ¤«п Љђ580, б®ў¬ҐбвЁ¬л© б ЋаЁ®­-128,
;  Ї®¤¤Ґа¦Є®© VT-52 Ё н¬г«пв®а®¬ CP/M
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
;  — бвм, ­ е®¤пй пбп ў ЇҐаўле 2Є ROM-¤ЁбЄ 
; ННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННННН

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
;
; Љ®¤ а §ЎЁв ­  Ў«®ЄЁ Ї® 128 Ў ©в. ‚бҐЈ® 16 Ў«®Є®ў. Љ ¦¤л© Ў«®Є бва ­б«Ё-
; а®ў ­ ¤«п ўлЇ®«­Ґ­Ёп Ї®  ¤аҐбг ROMBUF. ‚л§®ў Є®¤  ў Ў«®ЄҐ ®бгйҐбвў«пҐвбп
; б Ї®¬®ймо ¬ Єа®б 
;
; FCALL block, label
; 
; §¤Ґбм block - ­®¬Ґа Ў«®Є , ­ зЁ­ п б 0,   label - ¬ҐвЄ  Є®¤ ;
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ђ¤аҐб  бЁбвҐ¬­ле ўл§®ў®ў
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	INCLUDE	"syscalls.inc"

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ђ¤аҐб  бЁбвҐ¬­ле ЇҐаҐ¬Ґ­­ле
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	INCLUDE	"sysvars.inc"


FCALL	MACRO	block, adr
		CALL	CALLROM
		DB	block
		DB	LOW adr
	ENDM

FJPZ	MACRO	block, adr
		RST	8
		DB	block
		DB	adr & 0FFH
	ENDM


CHK	MACRO	adr, msg
		IF	$>=(adr)
			ERROR	msg
		ENDIF
	ENDM

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 0
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0
	PHASE	ROMBUF

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; TODO Ѓ«®Є § йЁвл § Јаг§ЄЁ ­  ЋаЁ®­-128. ‚лў®¤Ёв
; б®®ЎйҐ­ЁҐ, зв® ¤ ­­л© ¤ЁбЄ ЇаҐ¤­ §­ зҐ­ ¤«п ђ ¤Ё®-86ђЉ.
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	RET

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; ЏҐз вм бва®ЄЁ Ї®  ¤аҐбг DE
; ‚•Ћ„:
;	DE	-  ¤аҐб бва®ЄЁ. $ - ЇаЁ§­ Є Є®­ж 
;		  Ё«Ё бЁ¬ў®« Ў®«миҐ 7Fh
; ‚›•Ћ„:
;	HL	-  ¤аҐб Ї®б«Ґ¤­ҐЈ® ­ ЇҐз в ­­®Ј® бЁ¬ў®« 
; €‡Њ…Ќџ…’:
;	AF, B, HL, DE
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

C_WRITESTR:
	LD	HL, PrintString+1
	INC	HL
	INC	HL
	PUSH	HL
	EX	DE, HL
	LD	B, '$'
	RET			; JP PrintString+2, в.Ґ. Їа®ЇгбвЁ«Ё LD B, 0

C_READ:	EX	(SP),HL		; ў®ббв ­ ў«Ёў Ґ¬ HL Ё§ бвҐЄҐ
	CALL	InputSymbol	; 6 bytes
	LD	C, A
	JP	PrintCharFromC

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
;BDOS function 6 (C_RAWIO) - Direct console I/O
;Supported by: CP/M 1.4 and later, with variations
;Entered with C=6, E=code. Returned values (in A) vary.
;
;E=0FFh
;Return a character without echoing if one is waiting;
; zero if none is available. In MP/M 1, this works like
; E=0FDh below and waits for a character.
;Values of E not supported on a particular system will
; output the character. Under CP/M 2 and lower, direct 
;console functions may interact undesirably with non-direct
; ones, since certain buffers may be bypassed. Do not mix them.
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

C_RAWIO:
	INC	E		; Test for 0FFH
	JP	NZ,PrintCharFromC
	CALL	GetKeyboardStatus
	RET	Z
	JP	InputSymbol

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; ‚ў®¤ бва®ЄЁ ў ЎгдҐа DE (CP/M б®ў¬ҐбвЁ¬®)
; ‚•Ћ„:
;	DE	-  ¤аҐб ЎгдҐа 
; ‚›•Ћ„:
;	COMBUF	- ўўҐ¤Ґ­­ п бва®Є 
; €‡Њ…Ќџ…’:
;	AF, DE, HL, BC
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

C_READSTR:
	PUSH	DE
	POP	HL
	LD	C, (HL)
	INC	HL
GotoCmdLineBegin:
	XOR	A
	LD	B, A
InputNextSymbol:
	CALL	InputSymbol		; ЁбЇ®«м§гҐвбп ў DirectiveModify
	CP	7FH
	JP	Z,ProcessBackspace
	INC	HL
	LD	(HL), A
	PUSH	BC
	LD	C, A
	CALL	PrintCharFromC
	POP	BC
	CP	13
	JP	Z,L00B2H
	CP	03
	JP	Z,WarmBoot
	INC	B
	LD	A, C
	CP	B
	JP	NZ, InputNextSymbol;	SyntaxError
	LD	B, C
L00B2H:	INC	DE
	EX	DE, HL
	LD	(HL), B
	RET

ProcessBackspace:
	LD	A,B			; 15 bytes
	OR	A			; ­ з «® ЎгдҐа  ўў®¤  ?
	JP	Z,GotoCmdLineBegin	; GotoCmdLineBegin
	DEC	B
	DEC	HL
	PUSH	HL
	LD	HL, BkSp
	CALL	PrintString
	pop	HL
	JP	InputNextSymbol

BkSp:	DB	8,' ',8+80H

	if 0
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; €­ЁжЁ «Ё§ жЁп бЁ¬г«пв®а  CP/M
; ђ §¬Ґй Ґв в®зЄЁ ўе®¤  ў BIOS Ё BDOS
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	LD	A, 0C3H				; JMP opcode
	LD	(0), A
	LD	(5), A
	LD	(8), A
	LD	(BDOSST), A
	LD	HL, BDOS
	LD	(BDOSST+1), HL
	LD	HL, BIOSENTRY+3	; WBOOT
	LD	(0001H), HL
	LD	HL, BDOSST
	LD	(0006H), HL
	LD	HL, BDOS
	JP	WarmBoot

	endif

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 1
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	080H
	PHASE	ROMBUF

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є н¬г«пжЁЁ в®зҐЄ ўе®¤  BDOS
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; To make a BDOS call in an 8-bit CP/M, use:
;
;    LD  DE,parameter
;    LD  C,function
;    CALL    5
;
; In CP/M 1.x, 8-bit values are returned in A and 
; 16-bit values in BA. In later 8-bit versions,
; they are also returned in L and HL respectively. 
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	SHARED	BDOSENTRY
BDOSENTRY:
	LD	HL, 0000H		; ‘®еа ­пҐ¬ бвҐЄ
	ADD	HL, SP
	LD	(TMPSTK), HL
	LD	SP, STACK
	DEC	C
	JP	M, WarmBoot		; ”г­ЄжЁп 0 P_TERMCPM
	LD	HL, BDOSRET
	PUSH	HL
	LD	A, C
	LD	C, E
	FJPZ	0, C_READ		; ”г­ЄжЁп 1 C_READ
	DEC	A
	JP	Z, PrintCharFromC	; ”г­ЄжЁп 2 C_WRITE
	SUB	4
	FJPZ	0, C_RAWIO		; ”г­ЄжЁп 6 C_RAWIO
	SUB	3
	FJPZ	0, C_WRITESTR		; ”г­ЄжЁп 9 C_WRITESTR
	DEC	A
	FJPZ	0, C_READSTR		; ”г­ЄжЁп 10 C_READSTR
	DEC	A
	JP	Z, GetKeyboardStatus	; ”г­ЄжЁп 11 C_STAT
	DEC	A
	JP	NZ, WarmBoot	; ”г­ЄжЁЁ 13 Ё ўлиҐ ­Ґ Ї®¤¤Ґа¦Ёў Ґвбп
	LD	A, 20H		; ”г­ЄжЁп 12 S_BDOSVER
	LD	B, 00H
	RET

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 2
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0100H
	PHASE	ROMBUF


	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 3
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0180H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 4
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0200H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 5
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0280H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 6
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0300H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 7
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0380H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 8
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0400H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 9
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0480H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 10
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0500H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 11
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0580H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 12
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0600H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 13
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0680H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 14
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0700H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Ѓ«®Є 15
; ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

	ORG	0780H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	DEPHASE

	END

