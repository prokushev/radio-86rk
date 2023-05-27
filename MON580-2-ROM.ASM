; ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ
;  åéçàíéê-2.00 §´Ô ê†§®Æ-86êä §´Ô äê580, ·Æ¢¨•·‚®¨Î© · é‡®Æ≠-128,
;  ØÆ§§•‡¶™Æ© VT-52 ® Ì¨„´Ô‚Æ‡Æ¨ CP/M
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;  ó†·‚Ï, ≠†ÂÆ§ÔÈ†Ô·Ô ¢ Ø•‡¢ÎÂ 2™ ROM-§®·™†
; ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
; äÆ§ ‡†ß°®‚ ≠† °´Æ™® ØÆ 128 °†©‚. Ç·•£Æ 16 °´Æ™Æ¢. ä†¶§Î© °´Æ™ ·‚‡†≠·´®-
; ‡Æ¢†≠ §´Ô ¢ÎØÆ´≠•≠®Ô ØÆ †§‡•·„ ROMBUF. ÇÎßÆ¢ ™Æ§† ¢ °´Æ™• Æ·„È•·‚¢´Ô•‚·Ô
; · ØÆ¨ÆÈÏÓ ¨†™‡Æ·†
;
; FJMP block, label
; 
; ß§•·Ï block - ≠Æ¨•‡ °´Æ™†, ≠†Á®≠†Ô · 0, † label - ¨•‚™† ™Æ§†;
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ä§‡•·† ·®·‚•¨≠ÎÂ ¢ÎßÆ¢Æ¢
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	INCLUDE	"syscalls.inc"
	IF	STUB
	INCLUDE	"stub.inc"
	ELSE
	INCLUDE	"MON580-2.INC"
	ENDIF

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ä§‡•·† ·®·‚•¨≠ÎÂ Ø•‡•¨•≠≠ÎÂ
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	INCLUDE	"sysvars.inc"


; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ñ†´Ï≠ÔÔ JMP block, label
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

FJMP	MACRO	block, adr
		CALL	FARJMP
		DB	block
		DB	(adr & 0FFH)
	ENDM

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ñ†´Ï≠ÔÔ JP Z, block, label
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

FJPZ	MACRO	block, adr
		RST	8
		DB	block
		DB	adr & 0FFH
	ENDM


CHK	MACRO	adr, msg
		IF	$>(adr)
			ERROR	msg
		ENDIF
	ENDM

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 0. à≠®Ê®†´®ß†Ê®Ô
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0
	PHASE	ROMBUF

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ ß†È®‚Î ß†£‡„ß™® ≠† é‡®Æ≠-128. ÇÎ¢Æ§®‚
; ·ÆÆ°È•≠®•, Á‚Æ §†≠≠Î© §®·™ Ø‡•§≠†ß≠†Á•≠ §´Ô ê†§®Æ-86êä.
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
ORDOSStart:
	LD	HL, MsgRKOnly
	CALL	PrintString
	JP	WarmBoot
MsgRKOnly:
	DB	"|tot ROM-disk prednazna~en dlq radio-86r",'k' + 80H

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; à≠®Ê®†´®ß†Ê®Ô ·®¨„´Ô‚Æ‡† CP/M
; ê†ß¨•È†•‚ ‚ÆÁ™® ¢ÂÆ§† ¢ BIOS ® BDOS
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	INITBDOS
INITBDOS:
	LD	A, 0C3H				; JMP opcode
	
	; CALL 0
	LD	(0), A
	LD	HL, BIOSENTRY+3	; WBOOT
	LD	(0001H), HL

	; CALL 5
	LD	(5), A
	LD	HL, BDOSST
	LD	(0006H), HL

	; BDOS Entry point
	LD	(BDOSST), A
	LD	HL, BDOS
	LD	(BDOSST+1), HL

	; RST 8 (Far Jump if zero)
	LD	(8), A
	LD	HL, FARJZ
	LD	(9), HL

	LD	HL, CPMMSG
	CALL	PrintString
	JP	WarmBoot
CPMMSG:
	DB	' s |mulqtorom CP/','M'+80H

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 1 ÇÂÆ§ ¢ BDOS
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	080H
	PHASE	ROMBUF

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ Ì¨„´ÔÊ®® ‚ÆÁ•™ ¢ÂÆ§† BDOS
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; To make a BDOS call in an 8-bit CP/M, use:
;
;    LD  DE,parameter
;    LD  C,function
;    CALL    5
;
; In CP/M 1.x, 8-bit values are returned in A and 
; 16-bit values in BA. In later 8-bit versions,
; they are also returned in L and HL respectively. 
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	BDOSENTRY
BDOSENTRY:
	LD	HL, 0000H		; ëÆÂ‡†≠Ô•¨ ·‚•™
	ADD	HL, SP
	LD	(TMPSTK), HL
	LD	SP, 080H
	DEC	C
	JP	M, WarmBoot		; î„≠™Ê®Ô 0 P_TERMCPM
	LD	HL, BDOSRET
	PUSH	HL			; Ç ·‚•™ ™´†§•¨ †§‡•· ¢Æß¢‡†‚† ®ß BDOS
	LD	A, C
	LD	C, E
	FJPZ	2, C_READ		; î„≠™Ê®Ô 1 C_READ
	DEC	A
	JP	Z, PrintCharFromC	; î„≠™Ê®Ô 2 C_WRITE
	SUB	4
	FJPZ	2, C_RAWIO		; î„≠™Ê®Ô 6 C_RAWIO
	SUB	3
	FJPZ	2, C_WRITESTR		; î„≠™Ê®Ô 9 C_WRITESTR
	DEC	A
	FJPZ	2, C_READSTR		; î„≠™Ê®Ô 10 C_READSTR
	DEC	A
	JP	Z, GetKeyboardStatus	; î„≠™Ê®Ô 11 C_STAT
	DEC	A
	JP	NZ, WarmBoot	; î„≠™Ê®® 13 ® ¢ÎË• ≠• ØÆ§§•‡¶®¢†•‚·Ô
	LD	A, 20H		; î„≠™Ê®Ô 12 S_BDOSVER
	LD	B, 00H
	RET

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 2 î„≠™Ê®® BDOS
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0100H
	PHASE	ROMBUF

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; è•Á†‚Ï ·‚‡Æ™® ØÆ †§‡•·„ DE
; ÇïéÑ:
;	DE	- †§‡•· ·‚‡Æ™®. $ - Ø‡®ß≠†™ ™Æ≠Ê†
; ÇõïéÑ:
;	HL	- †§‡•· ØÆ·´•§≠•£Æ ≠†Ø•Á†‚†≠≠Æ£Æ ·®¨¢Æ´†
; àáåÖçüÖí:
;	AF, HL, DE
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

C_WRITESTR:
	EX	DE, HL
C_WRITESTR_LOOP:
	LD	A,(HL)
	CP	'$'
	RET	Z
	LD	C, A
	CALL	PrintCharFromC
	INC	HL
	JP	C_WRITESTR_LOOP

C_READ:	EX	(SP),HL		; ¢Æ··‚†≠†¢´®¢†•¨ HL ®ß ·‚•™•
	CALL	InputSymbol	; 6 bytes
	JP	PrintCharFromA

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
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
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

C_RAWIO:
	INC	E		; Test for 0FFH
	JP	NZ,PrintCharFromC
	CALL	GetKeyboardStatus
	RET	Z
	JP	InputSymbol

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ç¢Æ§ ·‚‡Æ™® ¢ °„‰•‡ DE (CP/M ·Æ¢¨•·‚®¨Æ)
; ÇïéÑ:
;	DE	- †§‡•· °„‰•‡†
; ÇõïéÑ:
;	COMBUF	- ¢¢•§•≠≠†Ô ·‚‡Æ™†
; àáåÖçüÖí:
;	AF, DE, HL, BC
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

C_READSTR:
	PUSH	DE
	POP	HL
	LD	C, (HL)
	INC	HL
GotoCmdLineBegin:
	XOR	A
	LD	B, A
InputNextSymbol:
	CALL	InputSymbol		; ®·ØÆ´Ïß„•‚·Ô ¢ DirectiveModify
	CP	7FH
	JP	Z,ProcessBackspace
	INC	HL
	LD	(HL), A
	CALL	PrintCharFromA
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
	OR	A			; ≠†Á†´Æ °„‰•‡† ¢¢Æ§† ?
	JP	Z,GotoCmdLineBegin	; GotoCmdLineBegin
	DEC	B
	DEC	HL
	PUSH	HL
	LD	HL, BkSp
	CALL	PrintString
	pop	HL
	JP	InputNextSymbol

BkSp:	DB	8,' ',8+80H

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 3 Ç≠•Ë≠®• §®‡•™‚®¢Î åéçàíéê†
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0180H
	PHASE	ROMBUF

	SHARED	DirectiveModifyROM
DirectiveModifyROM:
	CALL	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace			; 22 bytes
	PUSH	HL
	CALL	InputDirective
	POP	HL
	JP	NC,EmptyString
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
EmptyString:
	INC	HL
	JP	DirectiveModifyROM

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Ñ†¨Ø Æ°´†·‚® Ø†¨Ô‚® · HL ØÆ DE
; ÇïéÑ:
;	HL	- ≠†Á†´Ï≠Î© †§‡•·
;	DE	- ™Æ≠•Á≠Î© †§‡•·
; ÇõïéÑ:
;	HL	- ™Æ≠•Á≠Î© †§‡•· ®·‚ÆÁ≠®™†
; àáåÖçüÖí:
;	AF, HL		!!TODO!! Ø‡Æ¢•‡®‚Ï ØÆ§Ø‡Æ£‡†¨¨Î ≠† ®ß¨•≠•≠®•
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	DirectiveDumpROM
DirectiveDumpROM:
	CALL	PrintCRAndHexWordAndSpace			; 18 bytes
AF9C8:	CALL	PrintHexByteFromMemAndSpace
	CALL	IncHLAndRetIfEqDEWithBrk
	LD	A,L
	AND	0FH
	JP	Z,DirectiveDumpROM
	JP	AF9C8

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; ÇÎ¢Æ§ ‚•™·‚† Æ°´†·‚® Ø†¨Ô‚® · HL ØÆ DE
; ÇïéÑ:
;	HL	- ≠†Á†´Ï≠Î© †§‡•·
;	DE	- ™Æ≠•Á≠Î© †§‡•·
; ÇõïéÑ:
;	HL	- ™Æ≠•Á≠Î© †§‡•· ®·‚ÆÁ≠®™†
; àáåÖçüÖí:
;	AF, HL		!!TODO!! Ø‡Æ¢•‡®‚Ï ØÆ§Ø‡Æ£‡†¨¨Î ≠† ®ß¨•≠•≠®•
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	DirectiveListROM
DirectiveListROM:
	CALL	PrintCRAndHexWordAndSpace			; 30 bytes
AFA0B:	LD	A,(HL)
	OR	A
	JP	M,AFA15
	CP	20H
	JP	NC,AFA17
AFA15:	LD	A,'.'
AFA17:	CALL	PrintCharFromA
	CALL	IncHLAndRetIfEqDEWithBrk
	LD	A,L
	AND	0FH
	JP	Z,DirectiveListROM
	JP	AFA0B

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; è•‡•¨•È†•‚ Æ°´†·‚Ï Ø†¨Ô‚® · HL ØÆ DE ¢ †§‡•·† BC
; ÇïéÑ:
;	HL	- ≠†Á†´Ï≠Î© †§‡•·
;	DE	- ™Æ≠•Á≠Î© †§‡•·
;	BC	- Ê•´•¢Æ© †§‡•·
; ÇõïéÑ:
;	HL	- ™Æ≠•Á≠Î© †§‡•· ®·‚ÆÁ≠®™†
;	BC	- Ê•´•¢Æ© ™Æ≠•Á≠Î© †§‡•·
; àáåÖçüÖí:
;	AF, HL, BC
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	DirectiveTransferROM
DirectiveTransferROM:
	LD	A,(HL)			; 9 bytes
	LD	(BC),A
	INC	BC
	CALL	IncHLAndRetIfEqDE
	JP	DirectiveTransferROM

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; àÈ•‚ °†©‚ C ¢ Æ°´†·‚® Ø†¨Ô‚® · HL ØÆ DE
; ÇïéÑ:
;	HL	- ≠†Á†´Ï≠Î© †§‡•·
;	DE	- ™Æ≠•Á≠Î© †§‡•·
;	C	- ®·™Æ¨Î© °†©‚
; ÇõïéÑ:
;	HL	- ™Æ≠•Á≠Î© †§‡•· ®·‚ÆÁ≠®™†
; àáåÖçüÖí:
;	AF, HL
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	SHARED	DirectiveSearchROM
DirectiveSearchROM:
	LD	A,C			; 11 bytes
	CP	(HL)
	CALL	Z,PrintCRAndHexWordAndSpace
	CALL	IncHLAndRetIfEqDEWithBrk
	JP	DirectiveSearchROM

	SHARED	DirectiveCompareROM
DirectiveCompareROM:
	LD	A,(BC)			; 19 bytes
	CP	(HL)
	JP	Z,AF9E6
	CALL	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace
	LD	A,(BC)
	CALL	PrintHexByteAndSpace
AF9E6:	INC	BC
	CALL	IncHLAndRetIfEqDEWithBrk
	JP	DirectiveCompareROM

	SHARED	DirectiveOutputTapeROM
DirectiveOutputTapeROM:
	LD	A,C
	OR	A
	JP	Z,DefaultConstant
	LD	(KNS_WR),A
DefaultConstant:
	PUSH	HL
	CALL	CalcChecksum
	POP	HL

	FJMP	4, DirectiveOutputTapeROM2

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 4 Ç≠•Ë≠®• §®‡•™‚®¢Î åéçàíéê†
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0200H
	PHASE	ROMBUF

DirectiveOutputTapeROM2:
	CALL	PrintCRAndHexWordAndSpaceAndCRAndHexWordAndSpace
	EX	DE,HL
	

	PUSH	HL
	CALL	PrintCRAndHexWordBCAndSpace
	POP	HL

	SHARED	TapeWriteBlockROM
TapeWriteBlockROM:
	PUSH	BC		; äë

	LD	BC,0		; ¢Î¢Æ§®¨ 256 °†©‚Æ¢ 00 (Ø®´Æ‚Æ≠)
AFB4D:	CALL	TapeWriteByte
	EX	(SP),HL 	; Ì‚Æ ß†§•‡¶™† 38 ‚†™‚Æ¢
	EX	(SP),HL
	DEC	B
	JP	NZ,AFB4D

	CALL	TapeWriteSync

	CALL	TapeWriteWord		; ¢Î¢Æ§®¨ çÄ
	EX	DE,HL
	CALL	TapeWriteWord		; ¢Î¢Æ§®¨ äÄ

	EX	DE,HL
	CALL	TapeWriteFromHLtoDE		; ¢Î¢Æ§®¨ °´Æ™

	LD	HL,0
	CALL	TapeWriteWord		; ¢Î¢Æ§®¨ 2 °†©‚† 00

	CALL	TapeWriteSync

	POP	HL
	CALL	TapeWriteWord		; ¢Î¢Æ§®¨ äë

	JP	InitVideo

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; á†Ø®·Ï ·´Æ¢†
; ÇïéÑ:
;	HL	- ·´Æ¢Æ §´Ô ß†Ø®·®
; ÇõïéÑ:
;	ç•‚
; àáåÖçüÖí:
;	BC
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

TapeWriteWord:
	LD	C,H
	CALL	TapeWriteByte
	LD	C,L
	DB	06H		; LD B,..

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; á†Ø®·Ï ·®≠Â‡Æ°†©‚†
; ÇïéÑ:
;	ç•‚
; ÇõïéÑ:
;	ç•‚
; àáåÖçüÖí:
;	C
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

TapeWriteSync:
	LD	C, 0E6H
	JP	TapeWriteByte

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; á†Ø®·Ï °´Æ™† · HL ØÆ DE ≠† ¨†£≠®‚Æ‰Æ≠
; ÇïéÑ:
;	HL	- ≠†Á†´Æ °´Æ™†
;	DE	- ™Æ≠•Ê °´Æ™†
; ÇõïéÑ:
;	HL	- ™Æ≠•Ê °´Æ™†
; àáåÖçüÖí:
;	AF, C, HL
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

TapeWriteFromHLtoDE:
	LD	C,(HL)			; 10 bytes
	CALL	TapeWriteByte
	CALL	IncHLAndRetIfEqDE
	JP	TapeWriteFromHLtoDE

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 5
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0280H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 6
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0300H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 7
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0380H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 8
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0400H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 9
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0480H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 10
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0500H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 11
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0580H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 12
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0600H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 13
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0680H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 14
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0700H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Å´Æ™ 15
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	0780H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; î†©´Æ¢†Ô ·®·‚•¨† ¢ ‰Æ‡¨†‚• ORDOS
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
	ORG 0800H

FILE	MACRO name, start, size
	DB	(0fff0h-$) & 0fh dup (0)	; ¢Î‡†¢≠®¢†≠®• ØÆ £‡†≠®Ê• 16
s	SET	$
	DB	name
	DB	8-($-s) DUP (20H)
	DW	start
	DW	size
	DB	080H
	DB	0,0,0
	ENDM

ENDOFFILES	MACRO
	DB	(0fff0h-$) & 0fh dup (0)	; ¢Î‡†¢≠®¢†≠®• ØÆ £‡†≠®Ê• 16
	DB	0FFH
	ENDM

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
; èêéÉêÄååÄ ëóàíõÇÄçàü îÄâãÄ àá ÇêÖåÖççéÉé ÅìîÖêÄ 
; Ç íÖäëíéÇõâ ÅìîÖê êÖÑÄäíéêÄ "åàäêéç". 
LOADROM:
	PHASE	07400H
	LD     HL,4A00H	;çÄóÄãúçõâ ÄÑêÖë 
	LD     DE,2100H	;BPEMEHHOÉO ÅìîÖêÄ. 
	LD     BC,28FFH	;OÅöEM îÄâãÄ. 
RD1:	LD     A,(HL)   	;èÖêÖëãÄíú
	LD	(DE),A     	;îÄâã 
	INC     HL     	;à3
	INC     DE     	;ÇêÖåÖççéÉé ÅìîÖêÄ 
	DEC     BC     	;B íÖäëíéÇõâ ÅìîÖê 
	LD     A,B   	;ë ÄÑêÖëÄ 2100ç. 
	OR     C     	; 
	JP	NZ,     RD1   	; 
	JP	WarmBoot
	DEPHASE
ENDLOADROM:

	FILE "SAVE$", 07400H, ENDSAVEROM-SAVEROM
; èêéÉêÄååÄ ëéïêÄçÖçàü îÄâãÄ Çé ÇêÖåÖççéå 
; ÅìîÖêÖ. Öëãà éÅöÖå îÄâãÄ èêÖÇõòÄÖí 28FFH, íé 
; éèÖêÄñàü èé ïêÄçÖçàû çÖ ÇõèéãçüÖíëü. 

SAVEROM:
	PHASE	07400H
	LD     HL, 2100H
S1:	LD     A,(HL)   	;èêéÇÖêàíú êÄáåÖê
	CP     0FFH  	; îÄâãÄ. 
	JP	Z, S2    	;Öëãà îÄâã HE ìåÖôÄÖíëü 
	INC     HL     	;Çé ÇêÖåÖççéå 
	LD     A, H   	; ÅìîÖêÖ, íé 
	CP     4AH   	; 
	JP	NZ,     S1    	;
	LD     HL,SO6 	;ëééÅôàíú, Ä èÖêÖëõãäì 
	CALL	PrintString
	JP     WarmBoot    	;HE èêéàáÇéÑàíú.
S2:	LD 	HL,2100H	;Çé ÇêÖåÖççõâ ÅìîÖê.
	LD 	DE,4A00H ;
	LD     BC,28FFH	;OÅöEM îÄâãÄ. 
S3:	LD     A,(HL)   	;èÖêÖëãÄíú
	LD	(DE),A     	;îÄâã 
	INC     HL     	;à3
	INC     DE     	;ÇêÖåÖççéÉé ÅìîÖêÄ 
	DEC     BC     	;B íÖäëíéÇõâ ÅìîÖê 
	LD     A,B   	;ë ÄÑêÖëÄ 2100ç. 
	OR     C     	; 
	JP	NZ, S3
	JP	WarmBoot
SO6:	DB 	0DH,"OUT OF BUFFER",0
	DEPHASE
ENDSAVEROM:

	FILE "ZERO$", 07400H, ENDZEROROM-ZEROROM
; èêéÉêÄååÄ éóàëíäà èÄåüíà (áÄèàëú "0")
; BO ÇëÖ ÑéëíìèçõÖ èéãúáéÇÄíÖãû üóÖâäà éáì,
; äêéåÖ üóÖÖä, çÄóàçÄü ë 7400ç).
ZEROROM:
	PHASE	07400H
	LD 	HL,0 	;
Z1:	LD 	(HL),0 	;éóàëíàíú
	INC 	HL 	; èÄåüíú.
	LD 	A,H 	;
	CP 	74H 	;Öëãà ÄÑêÖë ÅéãúòÖ
	JP	NZ, 	Z1 	; 7400ç, íé Çõâíà
	JP 	WarmBoot 	;Ç åÖçû.
	DEPHASE
ENDZEROROM:

	FILE "TEST$", 00100H, ENDTESTROM-TESTROM

TESTROM:
	PHASE	00100H
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

	RST	0				; ÇÆß¢‡†‚ ¢ CP/M
WelcomeMsg:
	DB	0dh,0ah,"* analiz sowmestimosti *",0dh,0ah
	DB	"wyberite komponent:", 0dh, 0ah
	DB	"A monitor", 0dh,0ah
	DB	"B CP/M", 0dh,0ah
	DB	"0 wyhod iz programmy", 0dh,0ah
	DB	">"
	DB	"$"

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; èÆ§Ø‡Æ£‡†¨¨† ‚•·‚®‡Æ¢†≠® åéçàíéê† ≠† ·Æ¢¨•·‚®¨Æ·‚Ï
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
MONITORTest:
	PUSH	AF
	PUSH	HL

MONITORTestLoop:
	LD	HL, MONITORMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

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
	JP	NZ, MONITORTestLoop
	
	POP	HL
	POP	AF

	RET


MTESTF800:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF800Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	CALL	0F800H		; "ïÆ´Æ§≠Î©" ·‚†‡‚ ·®·‚•¨Î

	POP	HL
	POP	AF
	RET

MTESTF803:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF803Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF806:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF806Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF809:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF809Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF80C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF80CMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF80F:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF80FMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF812:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF812Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF815:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF815Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF818:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF818Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF81B:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF81BMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF81E:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF81EMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF821:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF821Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF824:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF824Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF827:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF827Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF82A:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF82AMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF82D:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF82DMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF830:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF830Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF833:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF833Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF836:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF836Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF839:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF839Msg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF83C:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF83CMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MTESTF83F:
	PUSH	AF
	PUSH	HL
	LD	HL, MTESTF83FMsg
	CALL	0F818H		; ÇÎ¢Æ§ ·‚‡Æ™®

	CALL	0F803H		; é¶®§†≠®• ¢¢Æ§†

	POP	HL
	POP	AF
	RET

MONITORMsg:
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
	DB	"0 nazad", 0dh, 0ah
	DB	">", 0
MTESTF800Msg:
	DB	0dh, 0ah, "prowerka F800H", 0dh, 0ah
	DB	"\"holodnyj\" zapusk monitora. pri wyzowe dannoj podprogrammy", 0dh, 0ah
	DB	"osu}estwlqetsq polnyj perezapusk sistemy.", 0dh, 0ah
	DB	"navmite l`bu` klawi{u dlq wyzowa.", 0dh, 0ah, '>', 0
MTESTF803Msg:
	DB	0dh, 0ah, "prowerka F803H", 0dh, 0ah, '>', 0
MTESTF806Msg:
	DB	0dh, 0ah, "prowerka F806H", 0dh, 0ah, '>', 0
MTESTF809Msg:
	DB	0dh, 0ah, "prowerka F809H", 0dh, 0ah, '>', 0
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

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; èÆ§Ø‡Æ£‡†¨¨† ‚•·‚®‡Æ¢†≠® CP/M ≠† ·Æ¢¨•·‚®¨Æ·‚Ï
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

CPMTest:
	PUSH	AF
	PUSH	HL
	PUSH	BC
	PUSH	DE

	LD	C, 9				; C_WRITESTR
	LD	DE, CPMBDOSMsg
	CALL	5				; BDOS

	LD	C, 9				; C_WRITESTR
	LD	DE, CPMBDOSMsg
	CALL	5				; BDOS

	POP	DE
	POP	BC
	POP	HL
	POP	AF
	RET

CPMBIOSMsg:
	DB	"CP/M BIOS", 0dh, 0ah, "CONOUT: ", 0dh, 0ah, "$"

CPMBDOSMsg:
	DB	"CP/M BDOS", 0dh, 0ah, "C_WRITE: ", 0dh, 0ah, "$"

;CONST	EQU	BIOS+3
;CONIN	EQU	BIOS+6
;CONOUT	EQU	BIOS+9
;LIST	EQU	BIOS+12
;PUNCH	EQU	BIOS+15
;AUXOUT	EQU	BIOS+15
;READER	EQU	BIOS+18
;AUXIN	EQU	BIOS+18

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; èÆ§Ø‡Æ£‡†¨¨† ¢Î¢Æ§† ·Æ§•‡¶®¨Æ£Æ ‡•£®·‚‡Æ¢
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	DEPHASE
ENDTESTROM:

	ENDOFFILES

; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; èêéÉêÄååÄ ìèêÄÇãÖçàü ROM-DISK/32K Ñãü äéåèúûíÖêÄ 
; "êÄÑàé-86êä" ë OÅöEMOM éáì èéãúáéÇÄíÖãü 16ä/32ä.
; èêéÉêÄååÄ ìèêÄÇãÖçàü áÄîàäëàêéÇÄçÄ Ç èáì 
; èé ÄÑêÖëÄå 7E00H-7FFFH. ìäÄáÄççìû éÅãÄëíú èáì 
; áÄèêÖôÖçé àëèéãúáéÇÄíú èéÑ ROM-DISK. 
; èêéÉêÄååÄ àá èáì Ç éáì èÖêÖçéëàíëü áÄÉêìáóàäéå, 
; (Ç MONITORE) èé ÑàêÖäíàÇÖ "U" à áÄçàåÄÖí 
; ÇÖêïçàÖ ÄÑêÖëÄ éáì, çÄóàçÄü ë 7400ç.
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

	ORG	07E00H
	
	PHASE	BASE-0200H

	LD	HL, SO1
	CALL	PrintString
	LD	B, 0FFH
	CALL	SEARCHS

	LD	C, '>'
	CALL	PrintCharFromC
	CALL	InputSymbol
	LD	C, A
	CALL	PrintCharFromC
	CP	03h
	JP	Z,WarmBoot
	SUB	30H
	LD	B, A
	LD	HL, FUNC+1
	LD	(HL), EXECN & 0ffh
	INC	HL
	LD	(HL), EXECN >> 8
	CALL	SEARCHS
	JP	WarmBoot

SEARCHS:
	LD	HL, 0800H		; ç†Á†´Æ ROM-§®·™†
	LD	C, L			; LD C, 0
SEARCH:
	PUSH	HL			; (1)
	LD	DE, (8+2+2)-1
	ADD	HL, DE
	EX	HL, DE
	POP	HL			; (1)

	PUSH	HL			; (2)
	
	PUSH	BC			; (3)

	LD	BC, T
	PUSH	BC			; (4)
	CALL	ReadROM
	POP	HL			; (4)

	POP	BC			; (3)

	LD	A, (HL)
	CP	0FFH

	POP	DE			; (2)
	
	RET	Z

FUNC:	CALL	PRINTN

	PUSH	DE			; (5)
;---------------------
	LD	HL, (T+8+2)
	LD	A, L			; ¢Î·Á®‚Î¢†•¨ ≠†Á†´Æ ·´•§„ÓÈ•© ß†Ø®·®
	OR	A			; Æ™†≠Á®¢†•‚·Ô ≠† ≠Æ´Ï
	JP	Z, SKIP
	OR	0fh
	LD	L, A
	INC	HL
SKIP:
	LD	DE, 10h
	ADD	HL, DE
;---------------------
	POP	DE			; (5)
	
	ADD	HL, DE
	INC	C
	JP	SEARCH

PRINTN:
	PUSH	HL
	PUSH	BC
	PUSH	DE

	LD	A, C			; è•Á†‚†•¨ ØÆ‡Ô§™Æ¢Î© ≠Æ¨•‡
	ADD	A, 30H
	LD	C, A
	CALL	PrintCharFromC
	LD	C, ' '
	CALL	PrintCharFromC

	LD	B, 8
	LD	HL, T
PLOOP:	LD	A, (HL)			; è•Á†‚†•¨ ®¨Ô
	LD	C, A
	CALL	PrintCharFromC
	INC	HL
	DEC	B
	JP	NZ, PLOOP

	INC	HL
	LD	C, ' '			; è•Á†‚†•¨ ·‚†‡‚Æ¢Î© †§‡•·
	CALL	PrintCharFromC
	LD	A, (HL)
	CALL	PrintHexByte
	DEC	HL
	LD	A, (HL)
	CALL	PrintHexByte

	INC	HL
	INC	HL
	INC	HL
	LD	C, ' '			; è•Á†‚†•¨ ‡†ß¨•‡
	CALL	PrintCharFromC
	LD	A, (HL)
	CALL	PrintHexByte
	DEC	HL
	LD	A, (HL)
	CALL	PrintHexByte

	LD	HL, SO2			; è•Á†‚†•¨ Ø•‡•¢Æ§ ·‚‡Æ™®
	CALL	PrintString
	POP	DE
	POP	BC
	POP	HL
	RET

EXECN:
	LD	A, C
	SUB	B
	RET	NZ
	
	LD	HL, 010H
	ADD	HL, DE		; DE - Ì‚Æ †§‡•· ≠† ROM-§®·™•
	EX	DE, HL
	
	LD	SP, T+8		; àëèéãúáìü ëíÖä,
	POP	BC		; start
	POP	HL		; size

	ADD	HL, DE
	EX	DE, HL

	PUSH	BC		; ó®‚†•¨ ¢ éáì
	CALL    ReadROM
	POP	HL

	JP	(HL)          	;à áÄèìëíàíú èêéÉêÄååì.

T:	DB	8+2+2 DUP 0			;

SO1:	DB 	0AH,0DH,"*ROM-DISK/32K* V3.0-23"
	DB 	0AH,0AH,0DH,"DIRECTORY:"
SO2:	DB	0AH,0DH,0

	DEPHASE

	DB	08000H-$ DUP (0FFH)
	CHK	08000H, "* Block overflow ! *"
	END 				;

