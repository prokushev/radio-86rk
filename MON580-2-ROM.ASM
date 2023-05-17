; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;  ŒŽˆ’Ž-2.00 ¤«ï  ¤¨®-86Š ¤«ï Š580, á®¢¬¥áâ¨¬ë© á Žà¨®­-128,
;  ¯®¤¤¥à¦ª®© VT-52 ¨ í¬ã«ïâ®à®¬ CP/M
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  — áâì, ­ å®¤ïé ïáï ¢ ¯¥à¢ëå 2ª ROM-¤¨áª 
; ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

	CPU		8080
	Z80SYNTAX	EXCLUSIVE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Š®¤ à §¡¨â ­  ¡«®ª¨ ¯® 128 ¡ ©â. ‚á¥£® 16 ¡«®ª®¢. Š ¦¤ë© ¡«®ª áâà ­á«¨-
; à®¢ ­ ¤«ï ¢ë¯®«­¥­¨ï ¯®  ¤à¥áã ROMBUF. ‚ë§®¢ ª®¤  ¢ ¡«®ª¥ ®áãé¥áâ¢«ï¥âáï
; á ¯®¬®éìî ¬ ªà®á 
;
; FCALL block, label
; 
; §¤¥áì block - ­®¬¥à ¡«®ª , ­ ç¨­ ï á 0,   label - ¬¥âª  ª®¤ ;
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; €¤à¥á  á¨áâ¥¬­ëå ¢ë§®¢®¢
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	INCLUDE	"syscalls.inc"
	IF	STUB
	INCLUDE	"stub.inc"
	ELSE
	INCLUDE	"MON580-2.INC"
	ENDIF

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; €¤à¥á  á¨áâ¥¬­ëå ¯¥à¥¬¥­­ëå
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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
		IF	$>(adr)
			ERROR	msg
		ENDIF
	ENDM

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 0. ˆ­¨æ¨ «¨§ æ¨ï
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0
	PHASE	ROMBUF

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª § é¨âë § £àã§ª¨ ­  Žà¨®­-128. ‚ë¢®¤¨â
; á®®¡é¥­¨¥, çâ® ¤ ­­ë© ¤¨áª ¯à¥¤­ §­ ç¥­ ¤«ï  ¤¨®-86Š.
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ORDOSStart:
	LD	HL, MsgRKOnly
	CALL	PrintString
	JP	WarmBoot
MsgRKOnly:
	DB	"|tot ROM-disk prednazna~en dlq radio-86r",'k' + 80H

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ˆ­¨æ¨ «¨§ æ¨ï á¨¬ã«ïâ®à  CP/M
;  §¬¥é ¥â â®çª¨ ¢å®¤  ¢ BIOS ¨ BDOS
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 1 ‚å®¤ ¢ BDOS
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	080H
	PHASE	ROMBUF

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª í¬ã«ïæ¨¨ â®ç¥ª ¢å®¤  BDOS
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; To make a BDOS call in an 8-bit CP/M, use:
;
;    LD  DE,parameter
;    LD  C,function
;    CALL    5
;
; In CP/M 1.x, 8-bit values are returned in A and 
; 16-bit values in BA. In later 8-bit versions,
; they are also returned in L and HL respectively. 
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	SHARED	BDOSENTRY
BDOSENTRY:
	LD	HL, 0000H		; ‘®åà ­ï¥¬ áâ¥ª
	ADD	HL, SP
	LD	(TMPSTK), HL
	LD	SP, STACK
	DEC	C
	JP	M, WarmBoot		; ”ã­ªæ¨ï 0 P_TERMCPM
	LD	HL, BDOSRET
	PUSH	HL
	LD	A, C
	LD	C, E
	FJPZ	2, C_READ		; ”ã­ªæ¨ï 1 C_READ
	DEC	A
	JP	Z, PrintCharFromC	; ”ã­ªæ¨ï 2 C_WRITE
	SUB	4
	FJPZ	2, C_RAWIO		; ”ã­ªæ¨ï 6 C_RAWIO
	SUB	3
	FJPZ	2, C_WRITESTR		; ”ã­ªæ¨ï 9 C_WRITESTR
	DEC	A
	FJPZ	2, C_READSTR		; ”ã­ªæ¨ï 10 C_READSTR
	DEC	A
	JP	Z, GetKeyboardStatus	; ”ã­ªæ¨ï 11 C_STAT
	DEC	A
	JP	NZ, WarmBoot	; ”ã­ªæ¨¨ 13 ¨ ¢ëè¥ ­¥ ¯®¤¤¥à¦¨¢ ¥âáï
	LD	A, 20H		; ”ã­ªæ¨ï 12 S_BDOSVER
	LD	B, 00H
	RET

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 2 ”ã­ªæ¨¨ BDOS
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0100H
	PHASE	ROMBUF

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ¥ç âì áâà®ª¨ ¯®  ¤à¥áã DE
; ‚•Ž„:
;	DE	-  ¤à¥á áâà®ª¨. $ - ¯à¨§­ ª ª®­æ 
;		  ¨«¨ á¨¬¢®« ¡®«ìè¥ 7Fh
; ‚›•Ž„:
;	HL	-  ¤à¥á ¯®á«¥¤­¥£® ­ ¯¥ç â ­­®£® á¨¬¢®« 
; ˆ‡Œ…Ÿ…’:
;	AF, B, HL, DE
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

C_WRITESTR:
	LD	HL, PrintString+1
	INC	HL
	INC	HL
	PUSH	HL
	EX	DE, HL
	LD	B, '$'
	RET			; JP PrintString+2, â.¥. ¯à®¯ãáâ¨«¨ LD B, 0

C_READ:	EX	(SP),HL		; ¢®ááâ ­ ¢«¨¢ ¥¬ HL ¨§ áâ¥ª¥
	CALL	InputSymbol	; 6 bytes
	JP	PrintCharFromA

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

C_RAWIO:
	INC	E		; Test for 0FFH
	JP	NZ,PrintCharFromC
	CALL	GetKeyboardStatus
	RET	Z
	JP	InputSymbol

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ‚¢®¤ áâà®ª¨ ¢ ¡ãä¥à DE (CP/M á®¢¬¥áâ¨¬®)
; ‚•Ž„:
;	DE	-  ¤à¥á ¡ãä¥à 
; ‚›•Ž„:
;	COMBUF	- ¢¢¥¤¥­­ ï áâà®ª 
; ˆ‡Œ…Ÿ…’:
;	AF, DE, HL, BC
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

C_READSTR:
	PUSH	DE
	POP	HL
	LD	C, (HL)
	INC	HL
GotoCmdLineBegin:
	XOR	A
	LD	B, A
InputNextSymbol:
	CALL	InputSymbol		; ¨á¯®«ì§ã¥âáï ¢ DirectiveModify
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
	OR	A			; ­ ç «® ¡ãä¥à  ¢¢®¤  ?
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

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 3 ‚­¥è­¨¥ ¤¨à¥ªâ¨¢ë ŒŽˆ’Ž 
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0180H
	PHASE	ROMBUF

	SHARED	DirectiveModifyROM
DirectiveModifyROM:
	CALL	PrintCRAndHexWordAndSpaceAndHexByteMemAndSpace			; 22 bytes
	PUSH	HL
	CALL	InputDirective
	POP	HL
	JP	NC,AFA3B
	PUSH	HL
	CALL	GET_HL
	LD	A,L
	POP	HL
	LD	(HL),A
AFA3B:	INC	HL
	JP	DirectiveModifyROM

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; „ ¬¯ ®¡« áâ¨ ¯ ¬ïâ¨ á HL ¯® DE
; ‚•Ž„:
;	HL	- ­ ç «ì­ë©  ¤à¥á
;	DE	- ª®­¥ç­ë©  ¤à¥á
; ‚›•Ž„:
;	HL	- ª®­¥ç­ë©  ¤à¥á ¨áâ®ç­¨ª 
; ˆ‡Œ…Ÿ…’:
;	AF, HL		!!TODO!! ¯à®¢¥à¨âì ¯®¤¯à®£à ¬¬ë ­  ¨§¬¥­¥­¨¥
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	SHARED	DirectiveDumpROM
DirectiveDumpROM:
	CALL	PrintCRAndHexWordAndSpace			; 18 bytes
AF9C8:	CALL	PrintHexByteFromMemAndSpace
	CALL	IncHLAndRetIfEqDEWithBrk
	LD	A,L
	AND	0FH
	JP	Z,DirectiveDumpROM
	JP	AF9C8

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ‚ë¢®¤ â¥ªáâ  ®¡« áâ¨ ¯ ¬ïâ¨ á HL ¯® DE
; ‚•Ž„:
;	HL	- ­ ç «ì­ë©  ¤à¥á
;	DE	- ª®­¥ç­ë©  ¤à¥á
; ‚›•Ž„:
;	HL	- ª®­¥ç­ë©  ¤à¥á ¨áâ®ç­¨ª 
; ˆ‡Œ…Ÿ…’:
;	AF, HL		!!TODO!! ¯à®¢¥à¨âì ¯®¤¯à®£à ¬¬ë ­  ¨§¬¥­¥­¨¥
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ¥à¥¬¥é ¥â ®¡« áâì ¯ ¬ïâ¨ á HL ¯® DE ¢  ¤à¥á  BC
; ‚•Ž„:
;	HL	- ­ ç «ì­ë©  ¤à¥á
;	DE	- ª®­¥ç­ë©  ¤à¥á
;	BC	- æ¥«¥¢®©  ¤à¥á
; ‚›•Ž„:
;	HL	- ª®­¥ç­ë©  ¤à¥á ¨áâ®ç­¨ª 
;	BC	- æ¥«¥¢®© ª®­¥ç­ë©  ¤à¥á
; ˆ‡Œ…Ÿ…’:
;	AF, HL, BC
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	SHARED	DirectiveTransferROM
DirectiveTransferROM:
	LD	A,(HL)			; 9 bytes
	LD	(BC),A
	INC	BC
	CALL	IncHLAndRetIfEqDE
	JP	DirectiveTransferROM

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ˆé¥â ¡ ©â C ¢ ®¡« áâ¨ ¯ ¬ïâ¨ á HL ¯® DE
; ‚•Ž„:
;	HL	- ­ ç «ì­ë©  ¤à¥á
;	DE	- ª®­¥ç­ë©  ¤à¥á
;	C	- ¨áª®¬ë© ¡ ©â
; ‚›•Ž„:
;	HL	- ª®­¥ç­ë©  ¤à¥á ¨áâ®ç­¨ª 
; ˆ‡Œ…Ÿ…’:
;	AF, HL
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 4
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0200H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 5
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0280H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 6
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0300H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 7
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0380H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 8
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0400H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 9
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0480H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 10
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0500H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 11
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0580H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 12
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0600H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 13
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0680H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 14
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0700H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; «®ª 15
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	0780H
	PHASE	ROMBUF

	DB	80H dup 0ffH

	CHK	ROMBUF+ROMBUFMAX, "* Block overflow ! *"
	DEPHASE

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ¥©á¨ª
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG 0800H
BASICROM:
	BINCLUDE "basic.rom"
EDASMROM:
	BINCLUDE "edasm.rom"
DPDDTROM:
	BINCLUDE "dpddt.rom"
SORTUTROM:
	BINCLUDE "sortut.rom"

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Žƒ€ŒŒ€ “€‚‹…ˆŸ ROM-DISK/32K „‹Ÿ ŠŽŒœž’…€ 
;"€„ˆŽ-86Š" ‘ OšEMOM Ž‡“ Ž‹œ‡Ž‚€’…‹Ÿ 32Š.
;Žƒ€ŒŒ€ “€‚‹…ˆŸ ‡€”ˆŠ‘ˆŽ‚€€ ‚ ‡“ 
;Ž €„…‘€Œ 7E00H-7FFFH. “Š€‡€“ž Ž‹€‘’œ ‡“ 
;‡€…™…Ž ˆ‘Ž‹œ‡Ž‚€’œ Ž„ ROM-DISK. 
;Žƒ€ŒŒ€ ˆ‡ ‡“ ‚ Ž‡“ ……Ž‘ˆ’‘Ÿ ‡€ƒ“‡—ˆŠŽŒ, 
;(‚ MONITORE) Ž „ˆ…Š’ˆ‚… "U" ˆ ‡€ˆŒ€…’ 
; ‚…•ˆ… €„…‘€ Ž‡“, €—ˆ€Ÿ ‘ 7400.
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ORG	07E00H
	
	PHASE	07400H

CONST:	EQU	6     	;—ˆ‘‹Ž Žƒ€ŒŒ 
M0:	LD	HL,SO1 	; ‚›‚…‘’ˆ Š€’€‹Žƒ 
M1:	CALL	PrintString 	;ROM-DISK/32K 
	CALL    InputSymbol    	; ‚›Ž Œ…ž. 
	CP	'Z'   	;“‘’€Ž‚Š€ €ŒŸ’ˆ ‚ 0?
 	JP	Z, ZERO	;…’,
	CP     'S'   	; ‡€ˆ‘œ ‚Ž ‚…Œ…›‰ 
	JP	Z, SAVE  	; “”…?- …’,
 	CP     'L'   	;‘—ˆ’›‚€ˆ… ‚ ’…Š‘’Ž‚›‰ 
	JP	Z, LOAD	; “”…?-…’, 
 	CP     'M'   	;
	JP	Z, WarmBoot	;
	SUB     30H   	; ‚•Ž„ˆ’ ‹ˆ €†€’€Ÿ 
	JP	M, M0  	; –ˆ”€ ‚ „ˆ€€‡Ž 
	CP     CONST 	; “ Š€‡€›• ‡€—…ˆ‰? 
	JP	NC, M0 	;…’, Ž‚’Žˆ’œ ‚‚Ž„. 
	LD	B,A   	;„€, ŠŽ„ ‘Ž•€ˆ’œ. 
	OR	A     	;’Ž 0?   
	JP	NZ, M2 	;…’, € ‚›—ˆ‘‹…ˆ… €„…‘Ž‚. 
	XOR     A     	;„€, Ž—ˆ‘’ˆ’œ ‘‹“†…“ž 
	LD	(2117H),A 	;Ÿ—…‰Š“ €ŒŸ’ˆ BASIC. 
M2:	LD      DE,6   	;˜€ƒ Žˆ‘Š€ Ž ’€‹ˆ–…. 
	LD      HL,TABL	; €‡Ž‚›‰ €„…‘ ’€‹ˆ–›. 
	XOR     A     	; ‘Ž„…†ˆŒŽ… €ŠŠ“Œ“‹Ÿ’Ž€ 
M3:	CP     B     	; €‚Ž •€ˆŒŽŒ“ ŠŽ„“? 
	JP	Z, M4    	;„€, ‚‡Ÿ’œ €„…‘€ Žƒ€ŒŒ›. 
	ADD     HL, DE     	;…’, ……‰’ˆ € ‘‹…„“ž™“ž 
	INC     A     	; ‘’ŽŠ“ ’€‹ˆ–›, “‚…‹ˆ—ˆ’œ „€›…
	JP     M3    	;€ŠŠ“Œ“‹Ÿ’Ž€ ˆ ‚Ž‚œ ‘€‚ˆ’œ 
M4:	LD	SP, HL  ;ˆ‘Ž‹œ‡“Ÿ ‘’…Š,
	POP     HL     	; ‚‡Ÿ’œ 
	POP     DE     	; €„…‘€ 
	POP     BC     	; Žƒ€ŒŒ›. 
	DEC     SP    	; Ž‘‹…„ˆ‰ €„…‘ 
	DEC     SP    	; -‘’€’Ž‚›‰ .

; Ž„Žƒ€ŒŒ€ MONITORA, Ž…‘…—ˆ‚€ž™€Ÿ ŠŽˆŽ‚€ˆ… 
; „€›• ˆ‡ €„…‘“…ŒŽ‰ Ž‹€‘’ˆ ‡“ ‚ €„…‘“…Œ“ž 
; Ž‹€‘’œ Ž‡“ Ž‹œ‡Ž‚€’…‹Ÿ. 
	CALL    ReadROM	;0FA68H	; ……‘›‹Š€ Žƒ€ŒŒ›. 
	POP     HL     	; ‚‡Ÿ’œ €„…‘ 
	JP	(HL)          	;ˆ ‡€“‘’ˆ’œ Žƒ€ŒŒ“.

; Ž„Žƒ€ŒŒ€ ‘—ˆ’›‚€ˆŸ ”€‰‹€ ˆ‡ ‚…Œ…ŽƒŽ “”…€ 
;‚ ’…Š‘’Ž‚›‰ “”… …„€Š’Ž€ "ŒˆŠŽ". 
LOAD:	LD     HL, SO4 	; Ž„’‚…„ˆ’œ 
	CALL    PrintString 	;‚›Ž ‘—ˆ’›‚€ˆŸ. 
	LD     HL,4A00H	;€—€‹œ›‰ €„…‘ 
	LD     DE,2100H	;BPEMEHHOƒO “”…€. 
RD0:	LD     BC,28FFH	;OšEM ”€‰‹€. 
RD1:	LD     A,(HL)   	;……‘‹€’œ
	LD	(DE),A     	;”€‰‹ 
	INC     HL     	;ˆ3
	INC     DE     	;‚…Œ…ŽƒŽ “”…€ 
	DEC     BC     	;B ’…Š‘’Ž‚›‰ “”… 
	LD     A,B   	;‘ €„…‘€ 2100. 
	OR     C     	; 
	JP	NZ,     RD1   	; 
	JP     M0    	;‚›‰’ˆ ‚ Œ…ž.

;Ž„Žƒ€ŒŒ€ ‘Ž•€…ˆŸ ”€‰‹€ ‚Ž ‚…Œ…ŽŒ 
; “”……. …‘‹ˆ Žš…Œ ”€‰‹€ …‚›˜€…’ 28FFH, ’Ž 
; Ž…€–ˆŸ Ž •€…ˆž … ‚›Ž‹Ÿ…’‘Ÿ. 
SAVE:	LD     HL, 2100H
S1:	LD     A,(HL)   	;Ž‚…ˆ’œ €‡Œ…
	CP     0FFH  	; ”€‰‹€. 
	JP	Z, S2    	;…‘‹ˆ ”€‰‹ HE “Œ…™€…’‘Ÿ 
	INC     HL     	;‚Ž ‚…Œ…ŽŒ 
	LD     A, H   	; “”……, ’Ž 
	CP     4AH   	; 
	JP	NZ,     S1    	;
	LD     HL,SO6 	;‘ŽŽ™ˆ’œ, € ……‘›‹Š“ 
	JP     M1    	;HE Žˆ‡‚Ž„ˆ’œ.
S2:	LD 	HL,SO5 	; ˆ€—…
	CALL 	PrintString 	;Ž„’‚…„ˆ’œ ‡€ˆ‘œ
	LD 	HL,2100H	;‚Ž ‚…Œ…›‰ “”….
	LD 	DE,4A00H ;
	JP 	RD0 	;“©’ˆ € ‡€ˆ‘œ.

;Ž„Žƒ€ŒŒ€ Ž—ˆ‘’Šˆ €ŒŸ’ˆ (‡€ˆ‘œ "0")
;BO ‚‘… „Ž‘’“›… Ž‹œ‡Ž‚€’…‹ž Ÿ—…‰Šˆ Ž‡“,
; ŠŽŒ… Ÿ—……Š, €—ˆ€Ÿ ‘ 7400).
ZERO:	LD 	HL,SO5 	;Ž„’‚…„ˆ’œ ˆ…Œ
	CALL 	PrintString 	; Ž…€–ˆˆ ‘Ž‘€ RAM.
	LD 	HL,0 	;
Z1:	LD 	(HL),0 	;Ž—ˆ‘’ˆ’œ
	INC 	HL 	; €ŒŸ’œ.
	LD 	A,H 	;
	CP 	74H 	;…‘‹ˆ €„…‘ Ž‹œ˜…
	JP	NZ, 	Z1 	; 7400, ’Ž ‚›‰’ˆ
	JP 	M0 	;‚ Œ…ž.

SO1:	DB 	1FH
	DB	0CH,"*ROM-DISK/32K* V2.1-23";
	DB 	0AH,0AH,0DH,"DIR:";
	DB 	0DH,0AH,"<0>-BASIC";
	DB 	0DH,0AH,"<1>-ED/ASSM";
	DB 	0DH,0AH,"<2>-DP/DDT";
	DB 	0DH,0AH,"<3>-SORT UT";
	DB 	0DH,0AH,"<4>-DRIV/260";
	DB 	0DH,0AH,"<5>-PROGR" ;
	DB 	0AH,0DH
	DB 	0AH,0DH," <S>-SAVE TO BUFFER";
	DB 	0AH,0DH," <L>-READ FROM BUFFER" ;
	DB 	0AH,0DH," <Z>-FILL RAM WITH ZERO" ;
	DB 	0AH,0DH," <M>-MONITOR" ;
	DB 	0DH,0AH,0
SO3:	DB 	19H		;
SO4:	DB 	19H		;
SO5:	DB 	19H,19H,7FH,08H,0
SO6:	DB 	0DH,"OUT OF BUFFER",0

;’€‹ˆ–€ €„…‘Ž‚ ”€‰‹Ž‚ ROM-DISK/32K.
;Ž‘‹…„Ž‚€’…‹œŽ Ž Š€’€‹Žƒ“ “Š€‡€›;
;€—€‹œ›‰, ŠŽ…—›‰ €„…‘€ ”€‰‹€ ‚ ‡“.
;€—€‹œ›‰ €„…‘ ’ŽƒŽ †… ”€‰‹€ ‚ Ž‡“.
TABL:	DW	BASICROM, BASICROM+1FFFH,0 	; BASIC
	DW 	EDASMROM, EDASMROM+0FFFH,0	; RED/ASSM
	DW 	DPDDTROM, DPDDTROM+0FFFH,6400H	; DP/DDT
	; TODO ‚ ®¡à §¥ ª ª-â® ­¥ ®ç¥­ì ¯®­ïâ­®. ‘¢¥à¨âìáï á ¯ã¡«¨ª æ¨¥©.
	DW 	SORTUTROM+800H, SORTUTROM+0E95H,000H	; SORT/UT
	DW 	74E4H,7A94H,800H		; DRIV/260
	DW 	7A95H,7DFFH,0			; PROGR

	ORG	07FFFH
	NOP
	DEPHASE
	CHK	08000H, "* Block overflow ! *"
	END 				;

