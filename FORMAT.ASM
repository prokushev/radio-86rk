; ������ ��� RK-DOS
; 05.10.1995

; �����ᥬ���஢��� � ��।����� ��� Z80.

	.Z80
	aseg
	ORG     100H

NTRKS	EQU	160
PORT    EQU     0F000H  ; �.� F000...F003,F004
CONIN   EQU     0F803H
MSSG    EQU     0F818H

WPRMSK  EQU     08H     ; ��⮢� ��᪨ ���� PB � �����
IDXMSK  EQU     40H
TR0MSK  EQU     20H

; �㭪樨 ��-���:

BDOS    EQU     0E001H

fvhod2  EQU     2		; ������ � ��� (������ ���.��ப�)
fselbf  EQU     1AH		; ����� ������ ����� � ���
fpusk   EQU     26H
fstop   EQU     27H
ferman  EQU     29H		; �뢮� ᮮ�饭�� �訡�� �� ॣ.B
fopfre  EQU     07H		; �᢮�������� �����
fdir    EQU     03H		; �뢮� ��⠫��� � ����� �뢮��
fwrskt  EQU     08H		; ������ ᥪ��
fkomm   EQU     18H		; ���� 䠩��

; ����稥 �祩�� ��-���

OPDRV   EQU     07541H	; ����⨢�� N ��᪮����
TTRK    EQU     07542H
TSKT    EQU     07543H
BEGS    EQU     07544H
LENGTS  EQU     07546H
ERRORS  EQU     0754BH
NWR     EQU     0754CH
FLAG    EQU     07550H
BREAK   EQU     07551H
ENDNAM  EQU     07557H
BOOTA   EQU     0755EH	; ���� ���� �⥭�� ��⠫��� � TS/LIST
BOOTV   EQU     07560H	; ���� ��砫� VTOC
RIPERR  EQU     07562H	; �᫨ =0, � ������ �뢮� ᮮ�� �� �訡���

;��������������������������������������������

RKDOS	MACRO	PARM
	LD	A,PARM
	CALL	BDOS
	ENDM

;��������������������������������������������

MSG	MACRO	PARM
	LD	HL,PARM
	CALL	MSSG
	ENDM
	
;��������������������������������������������

	.phase	0

	MSG	TITR
	
	LD      HL,(ENDNAM)
	LD      (UK_STR),HL
	
	LD      A,(HL)
	CP      20H
	JP      NZ,EXIHLP
	
	CALL    INCSKP
	SUB     'A'
	JR      Z,A0022
	CP      1
	JP      NZ,EXIHLP
A0022:  LD      (FDRIVE),A
	LD      (OPDRV),A
	
	LD	A,4
	LD	(CATSIZ),A
	LD	(CHK_FL),A
	
	INC     HL
	LD      A,(HL)
	CP      ':'
	JP      NZ,EXIHLP
	
	CALL	CHKEYS
	JP      C,EXIHLP

REPEAT:  MSG	TXPRES

WAI_SP:	CALL    CONIN
	CP	27
	RET	Z
	CP      20H
	JR      NZ,WAI_SP
	
	LD	A,(CHK_FL)
	OR	A
	JR      Z,NO_CHK
	
	MSG	TVERIF
	
	LD      HL,(BREAK)
	LD      (TMPBRK),HL
	
	LD      HL,XBREAK
	LD      (BREAK),HL
	
	LD      (TMPSTK),SP

	XOR	A
	LD      (RIPERR),A	; ����� ᮮ�饭�� �� �騡���

	LD      HL,TJOKER
	LD      A,fkomm		; �饬 �� 䠩�
	LD      (FLAG),A
	CALL    BDOS
A007D:  PUSH	AF
	LD      A,fstop
	LD      (RIPERR),A	; ࠧ���� ᮮ�饭�� �� �騡���
	CALL    BDOS
	
	RKDOS	fopfre
	POP	AF
	CP      4		; �᫨ A=4, � 䠩� �� ������
	JR      Z,GO		; �᫨ �� ��᪥ ��� 䠩���
	OR	A
	JR      Z,FILES

XBREAK: LD      SP,(TMPSTK)

	LD      A,(FDRIVE)
	LD      (OPDRV),A
	
	LD      HL,(TMPBRK)
	LD      (BREAK),HL
	
	LD      A,(ERRORS)
	CP      1
	LD      A,4
	JR      Z,A007D
	LD      (RIPERR),A
	JR      REPEAT

FILES:  MSG	T_SURE

WAIT_Y:	CALL    CONIN
	CP	27
	RET	Z
	CP      'N'
	RET	Z
	CP      'Y'
	JR      NZ,WAIT_Y

GO:	LD      HL,(TMPBRK)
	LD      (BREAK),HL
	
NO_CHK:	MSG	TXFORM

	LD      A,fselbf
	LD      (RIPERR),A
	LD	B,2			; ����ᨬ 2*100H ���⮢
	RKDOS	fselbf
	LD      (BOOTA),HL
	
	LD      B,1			; ����� 100H ����
	RKDOS	fselbf
	LD      (BOOTV),HL
	
	LD      DE,300H
FILL00: LD      (HL),0
	INC     HL
	DEC	DE
	LD	A,D
	OR	E
	JR      NZ,FILL00

	LD      A,(FDRIVE)
	LD      (OPDRV),A

	RKDOS	fpusk

	CALL    TRACK0

FRLOOP: LD      A,3
	LD      (NWR),A
	
REFORM: CALL    FORMAT
	CP      2		; N �訡�� DISK PROTECT
	LD	B,A
	LD      A,ferman
	JP      Z,BDOS		; ������� � ���
	
	LD      A,(BOOTV+1)	; ���訩 ���� ���� VTOC � ���
	LD	H,A
	
	LD      A,(TTRK)
	LD	L,A
	
	LD	(HL),1FH	; ᭠砫� �������� �� ᥪ�� �४� 
	CALL    TEST            ; � ��� �᢮������� ��訥 ᥪ��
	JR      Z,TRK_OK
	
	LD      HL,NWR
	DEC	(HL)
	JR      NZ,REFORM
	
TRK_OK: CALL    NXTTRK

	LD      A,180           ; �����
PAUS01: DEC     A
	JR      NZ,PAUS01

	LD      A,(TTRK)
	CP      NTRKS
	JR      C,FRLOOP
	
	CALL    TRACK0
				; ⥯��� ��襬 VTOC
				
	LD      HL,(BOOTV)	; ���� ��� VTOC                
	LD      L,20H           ; HL 㪠�뢠�� �� �४ 32 � VTOC
	
	LD	A,(HL)
	OR	001H		; �� 㪠���, �� ᥪ�� VTOC �����
	AND	0FDH		 ; 1111.1101
	LD	(HL),A		; ���� ᥪ�� ��⠫��� �᢮�����

	LD      HL,BUFFER
	LD      (UK_CUR),HL
	
	LD	A,(CATSIZ)
A0158:
	PUSH    AF
	CALL    GETCAT		; �饬 � �������� 1 ᥪ�� ��� ��⠫���
	JP	NC,NOSPACE
	
	LD      HL,(UK_CUR)
	LD	(HL),C		; �४
	INC     HL
	LD	(HL),B		; ᥪ��
	INC     HL
	LD      (UK_CUR),HL
	POP	AF
	
	DEC	A
	JR      NZ,A0158

	LD      (HL),A
	INC     HL
	LD      (HL),A
	LD	(UK_NXT),HL
A0171:	LD	HL,(UK_NXT)

	EX	DE,HL
	LD      HL,(BOOTA)
	INC     HL
	LD	A,(DE)
	LD	(HL),A
	DEC	HL
	DEC	DE
	LD	A,(DE)
	LD	(HL),A
	LD      (BEGS),HL
	EX	DE,HL
	
	DEC	HL
	LD	(UK_NXT),HL
A0187:
	LD	A,(CATSIZ)
	OR	A
	JR      Z,WRVTOC
	DEC	A
	LD	(CATSIZ),A

	LD      HL,(UK_CUR)
	DEC	HL
	LD	A,(HL)
	LD      (TSKT),A
	DEC	HL
	LD	A,(HL)
	LD      (TTRK),A
	LD      (UK_CUR),HL
	
	LD      HL,200H
	LD      (LENGTS),HL

	RKDOS	fwrskt
	OR	A
	JR      NZ,A0187
	JR      A0171

;��������������������������������������������

WRVTOC:	LD      HL,NTRKS	; ����� ᥪ�� VTOC = NTRKS
	LD      (LENGTS),HL
	
	LD      HL,(BOOTV)
	LD      (BEGS),HL

	LD      HL,00020H               ; TRK=32 SKT=0 - VTOC
	LD      (TTRK),HL

	RKDOS	fwrskt		; ��襬 VTOC

	LD	B,A
	LD      A,ferman
	JP      NZ,BDOS

	RKDOS	fopfre		; ���������� ���

	LD      HL,BYTE13
	RKDOS	fdir
	
	RKDOS	fstop

	MSG	TANOTH

	CALL    CONIN
	CP      'Y'
	JP      Z,REPEAT

	LD      HL,T_CR
	JP      MSSG		; ��� RET � ���

;��������������������������������������������

FORMAT: LD      A,(PORT+1)
	AND     WPRMSK
	LD      A,2		; �ਧ���, �� ���� ���� �� �����
	RET     Z
	                          ; ����� ���� ���������� ��75
	XOR	A
	LD      (TSKT),A	; N ��ࢮ�� ᥪ��

INDEX1: LD      A,(PORT+1)	; ��� �������� ����
	AND     IDXMSK
	JR      NZ,INDEX1

WRSECT: LD      DE,PORT
	LD      HL,PORT+1
	
	LD      A,00CH          ; D6 =0 ��������
	LD      (PORT+3),A	; ������������� ������������
	
	XOR	A
	LD      (PORT+3),A      ; D0=0 ���.����� ������
	
	LD      A,006H
	CALL    ZAP5BT          ; �������� 5 ������������ 06
	
	LD      A,13          ; D6 =1 ���������
	LD      (PORT+3),A	; ������������� ������������
	
WAI_01:
	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_01
	
	XOR	A
	LD      (DE),A
	CALL    ZAP5BT          ; �������� 5 ������ 00

WAI_02: CP      (HL)
	JP      M,WAI_02

	LD      A,0EAH          ; ������ ���.�����:
	LD	(DE),A		; EA,D3 N.SEC, N.TRK, KS.

WAI_03: LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_03

	LD      A,0D3H
	LD      (DE),A          ; ������� ���.���� D3

WAI_04:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_04

	LD      A,(TTRK)
	LD      (DE),A          ; ���.����� �����

	LD	C,A		; ��࠭�� N �४� � ॣ.C

WAI_05:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_05

	LD      A,(TSKT)
	LD      (DE),A          ; ���.������ ����.

WAI_06:	LD      B,(HL)          ; *
	INC     B
	JP      P,WAI_06

	ADD     A,C
	LD      (DE),A          ; N.�� + N.���
	
	XOR     A
	CALL    ZAP5BT          ; ������� 5 ������� ������ (R0)
	
                                ; ����� ���������� "���� ������"
                                
	LD      A,00CH		; D6 = 0 ��������
	LD      (PORT+3),A      ; ������������� �.������
	
	LD      A,006H
	CALL    ZAP5BT          ; ������� 5 ������������ 06
	
	LD      A,13		; D6 =1 ��������� 
	LD      (PORT+3),A      ; ������������� �.������

WAI_07:	LD      B,(HL)          ; *
	INC     B
	JP      P,WAI_07
	
	LD      (DE),A          ; �������� ���� 0D ��� ����প�
	XOR     A
	CALL    ZAP5BT          ; �������� 5 ������� ������

WAI_08: CP      (HL)
	JP      M,WAI_08

	LD	A,0DDH
	LD      (DE),A          ; �������� ����� ������ DD,F3

WAI_09:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_09

	LD	A,0F3H
	LD      (DE),A          ; ������ F3

WAI_10:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_10
	
	XOR	A
	LD      (DE),A          ; �������� 0  (LOW S_SIZE)

WAI_11: CP      (HL)
	JP      M,WAI_11

	LD      A,2
	LD      (DE),A          ; �������� 2   (HIGH S_SIZE)

	XOR     A
WAI_12: CP      (HL)
	JP      M,WAI_12
	
	LD      (DE),A          ; ������� ���� 00 ��᫥ �����
	
	LD	C,A		; C=0
	CALL    ZAPCBT          ; �������� 256 ������ 00
	CALL    ZAPCBT          ; �������� 256 ������ 00
	
	LD      C,35
	CALL    ZAPCBT          ; �������� 35 ������ 00
	
	LD      A,001H          ; ��� 0 = 1 ��������� ���.������
	LD      (PORT+3),A
	
	LD      A,(TSKT)
	OR	A
	LD      C,3
	JR      Z,CSECT         ; ����� 0-�� ������� ������ 3
	CP      1
	LD      C,4
	JR      Z,CSECT         ; ����� 1-�� - 4-���
	CP      2
	JR      Z,RET_OK        ; 2-��� ������ - ���������
	CP      3
	LD      C,1             ; ����� 3-�� - 1-���
	JR      Z,CSECT
	CP      4
	LD      C,2             ; ����� 4-�� - 2-���
	JR      Z,CSECT
CSECT:  LD      A,C
	LD      (TSKT),A
	JP      WRSECT

;��������������������������������������������

RET_OK: XOR     A
	RET

;��������������������������������������������

TEST:	XOR     A
	LD      (TSKT),A
	LD      (BADFLG),A
	
	LD	HL,BADLY	; ���� ��� RET (⠬ ��⠭����
	PUSH	HL		; 䫠�� BADFLG)

TSTLOO:	CALL    POSIT
	CALL    FND_MD

WAI_13:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_13

	LD	A,(BC)		; low S_SIZE
	OR	A
	RET	NZ		; ������ ࠧ��� ᥪ��

WAI_14: CP      (HL)
	JP      M,WAI_14
	
	LD	A,(BC)		; high S_SIZE
	CP      2
	RET     NZ              ; ���� ����� �� 200H
	LD	D,A
	INC     A
	LD      E,A             ; DE = 0203H (0, 200H, KS)

WAI_15:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_15
	
	LD	A,(BC)		; �஢�ਬ 203H �㫥��� ���⮢
	OR      A
	RET     NZ

	DEC	DE
	LD	A,D
	OR	E
	JR      NZ,WAI_15

	LD      A,(BOOTV+1)	; ��.���� ���� VTOC
	LD	H,A
	
	LD      A,(TTRK)
	LD	L,A	     ; HL 㪠�뢠�� �� ���� VTOC ᮮ�.ᥪ���
	
	LD      A,(TSKT)
	LD	B,A
	LD	A,0FEH		; 1111.1110
A030C:	DEC	B
	JP      M,A0314
	ADD	A,A		; ����騩 0 ᤢ����� �����
	JR      A030C

;��������������������������������������������

A0314:	AND	(HL)		; ���������� ������
	LD	(HL),A
	POP	HL		; HL= BADLY

A0317:  PUSH    HL              ; ������� �������� 0,3,1,4,2
	LD      A,(TSKT)
	
	OR	A		; ����� 0-�� 3-���
	LD      C,3
	JR      Z,USTSKT
	
	CP      1		; ����� 1-�� 4-���
	LD      C,4
	JR      Z,USTSKT
	
	CP      2		; 2-��� - ���������
	JR      Z,LAST_S
	
	CP      3		; ����� 3-�� 1-���
	LD      C,1
	JR      Z,USTSKT
	
;	CP      4		; ����� 4-�� 2-���
	LD      C,2
USTSKT: LD      A,C
	LD      (TSKT),A
	JR      TSTLOO

LAST_S:	POP	BC		; ���� �� �⥪� BADLY
	LD      A,(BADFLG)
	OR	A
	RET

;��������������������������������������������

BADLY:	LD      A,1
	LD      (BADFLG),A
	LD	HL,BADLY
	JR      A0317

BADFLG:	DS	1

;��������������������������������������������

TRACK0: LD      A,(PORT+1)
	AND     TR0MSK
	JR      Z,DIRC0
	LD	A,3
	CALL    STEP
	JR      TRACK0

DIRC0:  LD      A,4             ; ��� 2 = 0  DIRC=0
	LD      (PORT+3),A      ; ��� �� ����� 00
	XOR	A
	LD      (TTRK),A
	RET

;��������������������������������������������

NXTTRK: LD      A,(TTRK)
	INC     A
	LD      (TTRK),A
	RRCA
	LD      A,0
	RLA
	ADD     A,4
	LD      (PORT+3),A	; DISK SIDE
	RRCA
	RET	C
	LD      A,2
STEP:	LD      HL,PORT+3
	LD      (HL),001H	; D0=1, ����. ����� ������
	LD      (HL),A		; DIRC
   ADD	A,A
	LD      (HL),008H	; STEP=0

A0389:	DEC	A		; A=4 �������� ��� STEP=0
	JR      NZ,A0389
	LD      (HL),009H	; STEP=1

AED98:  DEC     A               ; A=0 ����� ����� ����
	EX	(SP),HL
	EX	(SP),HL
	JR      NZ,AED98
	RET

;��������������������������������������������

POSIT:  LD      HL,PORT+1
	LD      BC,PORT+4

A039F:  LD      DE,03E8H        ; 03E8H =1000 ���.
A03A2:	DEC	DE
	LD	A,D
	OR	E
	JR      Z,BADPOP	; ����� ������ �� ���.����� �������

WAI_16:	LD      A,(HL)          ; *
	INC     A
	JP      P,WAI_16
	
	LD      A,(BC)
	SUB     0EAH            ; ������ ���.����� EA,D3
	JR      NZ,A03A2

WAI_17: CP      (HL)
	JP      M,WAI_17
	
	LD	A,(BC)
	SUB     0D3H            ; ������ D3
	JR      NZ,A03A2

WAI_18: CP      (HL)
	JP      M,WAI_18
	
	LD	A,(BC)		; ����
	LD      E,A
	LD      A,(TTRK)
	SUB     E               ; ���� �� ��� ���� ������ ������
	JR      NZ,BADPOP

WAI_19:	CP      (HL)
	JP      M,WAI_19
	
	LD	A,(BC)		; ������		
	LD	D,A
	LD      A,(TSKT)
	CP	D
	JR      NZ,A039F        ; ���� �� ��� ������

WAI_20:	LD      B,(HL)
	INC     B
	JP      P,WAI_20
	
	ADD     A,E		; TRK+SKT
	LD	E,A
	LD	A,(BC)		; TRK+SKT
	SUB	E
	RET	Z
	JR      BADPOP		; ������ ������

;��������������������������������������������

FND_MD:	LD      D,0
A03E4:	DEC	D
	JR      Z,BADPOP
	
A03E8:	INC	(HL)
	JP      P,A03E8
	
	LD	A,(BC)
	SUB     0DDH            ; ����� ������ DD,F3
	JR      NZ,A03E4
	
A03F2:	CP	(HL)		; A=0
	JP      M,A03F2
	
	LD	A,(BC)
	SUB     0F3H            ; ������ �������� F3
	RET	Z
	JR      A03E4

;��������������������������������������������

BADPOP: POP     AF
	LD	A,001H
	OR	A
	RET

;��������������������������������������������

ZAP5BT: LD      C,5

ZAPCBT:	LD      B,(HL)
	INC     B
	JP      P,ZAPCBT
	
	LD	(DE),A
	DEC	C
	RET	Z
	JR      ZAPCBT

;��������������������������������������������

INCSKP: INC     HL
	LD	A,(HL)
	CP	20H
	JR      Z,INCSKP
	RET

;��������������������������������������������

EXIHLP: LD      HL,T_HELP
	JP	MSSG

;��������������������������������������������

GETDEC: LD      B,0	; ������� ���.�᫮ �� ���.��ப�
DECDG1: LD      A,(HL)
	SUB	30H
	RET	C
	CP      10
	RET	NC
	PUSH	AF
	LD	A,B       ; B �����.�� 10
	ADD     A,A       ;*2
	ADD     A,A       ;*4
	ADD     A,A       ;*8
	ADD     A,B       ;*(8+1)
	ADD	A,B	  ;*(8+2)
	LD	B,A
	POP	AF
	ADD	A,B	  ; A+B*10
	LD	B,A
	INC	HL
	JR      DECDG1

;��������������������������������������������

GETCAT:		; �饬 � �������� ���� ᥪ�� ��� ��⠫���,
		; ��稭�� � �४� 20H	
		; �����: CY=1 if OK, B= ᥪ��, C= �४ 	


	LD      HL,(BOOTV)	; ���� ��� VTOC                
	LD	L,20H		; HL 㪠�뢠�� �� �४ 32 � VTOC

GETS1:	LD	A,(HL)		; A= ���� ����뢠�騩 �४
	AND	1FH
	CP	1FH
	JR      Z,GETS4		; �᫨ � �४� ��� ᢮�.ᥪ�஢
	LD      BC,0001H	; B= ⥪�騩 ᥪ�� C= 0000.0001
GETS2:	LD	A,(HL)
	AND	C
	JR      Z,GETS3
	INC	B
	LD	A,C
	ADD	A,A		; ᤢ����� ������� 1 �����
	LD	C,A
	JR      GETS2

GETS3:  LD      A,(HL)		; ������ ᥪ��
	OR	C
	LD	(HL),A
	LD	C,L		; C= ����� �४�, B= ����� ᥪ��
	SCF
	RET

;��������������������������������������������

GETS4:	INC	L		; � ᫥� �४� �� VTOC
	LD	A,L		; �室 �� GETS1, �᫨ �� ��᫥���� �४
	CP      NTRKS
	JR      C,GETS1
	RET

;��������������������������������������������

CHKEYS:				; ������ � CY=0, �᫨ OK
	CALL    INCSKP
	CP      '/'
	JR      NZ,A0490
	CALL    INCSKP
	CP      'S'
	JR      NZ,A0487
	CALL    INCSKP
	CALL    GETDEC
	LD	A,B
	OR	A
	SCF
	RET	Z
	LD	(CATSIZ),A
	LD	A,(HL)
	CP      '/'
	JR      NZ,A0490
	CALL    INCSKP
A0487:  CP      'V'
	JR      NZ,A0490
	XOR	A
	LD	(CHK_FL),A
A0490:	CP	20H
	CALL    Z,INCSKP
	CP	13
	JR      Z,A049D
	OR	A
	SCF
	RET	NZ
A049D:	OR	A
	RET

;��������������������������������������������

NOSPACE:
	MSG	TNOSPA
	JP	REPEAT

TNOSPA:	defb	13,10,'NO SPACE...',0

;��������������������������������������������

; ������� ������ � ������ ��������, �.� ���7

T_HELP: defb    13,10,'FORMAT DRIVE /SN /V',10,10,13
	defb    '   DRIVE - A: ili B:',10,10,13
	defb    'opcii:',13,10
	defb    '   /S - sektorow pod katalog (N - 1..90)',13,10
	defb    '   /V - otkl.kontrolx informacii na diske',10,13,0
TITR: 	defb    10,13,'RK-DOS FORMAT VER 3.0  (qnwarx 1993)'
T_CR: defb    13,10,0
TXPRES: defb    13,10,10,'postawx disk dlq formata i navmi <probel>',0
BYTE13:  defb    13
TXFORM: defb    10,13,'idet formatirowanie ...',0
TANOTH: defb    10,10,13,'format zakon~en.  drugoj disk (Y/N) ?',0
TVERIF: defb    10,13,'prowerka diska ...',0
T_SURE: defb    10,13,'disk sodervit informaci`. formatirowatx (Y/N) ?',0
TJOKER: defb    '*.*',13,0

ZZ	EQU	$

if	(ZZ and 0FH) eq 0
	LENGTH	EQU	ZZ
    else	
	LENGTH	EQU	(ZZ and 0FFF0H) +10H
endif

TMPBRK: DS      2
TMPSTK: DS      2
FDRIVE: DS      1
UK_CUR: DS      2
UK_NXT:  DS      2
UK_STR:  DS      2
CHK_FL:  DS      1
CATSIZ:	DS      1

BUFFER:
	.dephase
	
        END

