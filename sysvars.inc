; �����������������������������������������������������������������������
;  �������� ��� �����-86�� ��� ��580, ᮢ���⨬� � �ਮ�-128,
;  �����প�� VT-52 � �����஬ CP/M
; �����������������������������������������������������������������������
;  ���⥬�� ��६���� �������� �� ���ᠬ 7600H-76�FH
; �����������������������������������������������������������������������

; ����������������������������������������������
RABADR	EQU	0F800H		; ���� ��砫� ���
DOPPPA	EQU	0A000H		; ���� �������⥫쭮�� ���
PPA	EQU	08000H		; ���� �᭮����� ���
K_ORIG	EQU	1		; �᫨ 0, � ��������� �����
BASE    EQU	7600H		; ࠧ��� ���
BDOSST	EQU	BASE		; ��砫� BDOS

; ����������������������������������������������
;
; ������� ��⥬��� ��६����� � ����� 7600H-76D0H
;
; ����������������������������������������������

; ����� �� ���� �������� �窠 �맮�� BDOS
ESC_FL	EQU	BASE+04H		; 1 ���� ⥪�饣� ����� ��ࠡ�⪨ Esc-��᫥����⥫쭮��
KBDFLG	EQU	BASE+05H		; 1 �᫨ =0, � ���� ᨬ��� � SYMBUF
RUSLAT	EQU	BASE+06H		; 1 �����⨬� ⮫쪮 0 ��� FF  !! ���� ������ ���� xx06h ���� �ࠢ��� SET_RL !!
LAST_K	EQU	BASE+07H		; 1 �� 2 ���� ������ ᫥������ �����
COUNT	EQU	BASE+08H		; 1 ����稪 ���ᮢ (���砫� 15)
APVFLG	EQU	BASE+09H		; 1 䫠� ��⮯����
TMPSTK	EQU	BASE+0AH		; 2 �६���� �࠭�� �⥪ �� �� �/�-����
XYSTOR	EQU	BASE+0CH		; 2 ���࠭���� ���न���� �����
SASTOR	EQU	BASE+0EH		; 2 ���࠭���� ���� �����
CURST	EQU	BASE+10H		; 1 �⮡ࠦ���/������ �����
WRPFLG	EQU	BASE+11H		; 1 ��⮯�७�� ��ப
RAMTOP	EQU	BASE+12H		; 2 ������ �࠭�� ���
EK_ADR  EQU	BASE+14H		; 2 ⥪�騩 ���� �� ��࠭�
POSX	EQU	BASE+16H		; 1 ���न���� �����. ���冷� �����.
POSY	EQU	BASE+17H		; 1
KNS_WR	EQU	BASE+18H		; 1 ����⠭� �����
PAR_HL  EQU	BASE+19H		; 2
PAR_DE  EQU	BASE+1BH		; 2
PAR_BC  EQU	BASE+1DH		; 2
FLG_P2	EQU	BASE+1FH		; 1 䫠�, �� ���� ��ࠬ���� 2 ��� 2,3
INV_MG	EQU	BASE+20H		; 1 䫠� �����ᨨ ������䮭�
KNS_RD	EQU	BASE+21H		; 1 ����⠭� �⥭��
BUFSIZ	EQU	BASE+22H		; 1 ������ ���� �����
BUFCNT	EQU	BASE+23H		; 1 ��᫮ ��������� ᨬ����� � ���� �����
COMBUF	EQU	BASE+24H		; COMBUFMAX ���� ����� ��४⨢�
COMBUFMAX	EQU	28		; ���ᨬ���� ࠧ��� ���� ����� ������
STACK	EQU	BASE+0D0H		; �⥪ ������

ROMBUF	EQU	BASE+40H		; ROMBUFMAX ���� �����窨 ���� �� ROM-��᪠ (⮫쪮 ��� �������� 2.0)
ROMBUFMAX	EQU	128		; ࠧ��� ���� �����窨 �� ROM-���

SA	EQU	BASE+0D0H		; 76D0 ��砫� ��࠭��� ������
SCBASE  EQU	BASE+01C2H		; 77C2 ���.�����.���� ���.

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