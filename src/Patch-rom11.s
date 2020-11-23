;
; Patch de la ROM v1.1 pour CH376
;
; CSAVE: OK
; CLOAD: OK
; STORE: OK
; RECALL: OK

;---------------------------------------------------------------------------
;				MACROS
;---------------------------------------------------------------------------
#define new_patch(a,f) *=a-4 : .word a : .word (f-a)
#define new_patchl(a,l) *=a-4 : .word a : .word l

;---------------------------------------------------------------------------
;
;			Modes du CH376
;
;---------------------------------------------------------------------------
#define SDCARD_MODE $03
#define USB_HOST_MODE $06

;---------------------------------------------------------------------------
;
;			Codes d'erreur du CH376
;
;---------------------------------------------------------------------------
#define SUCCESS $12
#define INT_SUCCESS $14
#define INT_DISK_READ $1D
#define INT_DISK_WRITE $1E
#define ERR_OPEN_DIR $41
#define ABORT $5F

;---------------------------------------------------------------------------
;
;			Codes commande du CH376
;
;---------------------------------------------------------------------------
#define CH376_CMD_CHECK_EXIST   $06
#define CH376_CMD_SET_USB_MODE  $15
#define CH376_CMD_GET_STATUS    $22
#define CH376_CMD_RD_USB_DATA0  $27
#define CH376_CMD_WR_REQ_DATA   $2d
#define CH376_CMD_SET_FILE_NAME $2f
#define CH376_CMD_DISK_MOUNT    $31
#define CH376_CMD_FILE_OPEN     $32
#define CH376_CMD_FILE_CREATE   $34
#define CH376_CMD_FILE_CLOSE    $36
#define CH376_CMD_BYTE_READ     $3a
#define CH376_CMD_BYTE_RD_GO    $3b
#define CH376_CMD_BYTE_WRITE    $3c
#define CH376_CMD_BYTE_WR_GO    $3d

;---------------------------------------------------------------------------
;
;			Couleurs
;
;---------------------------------------------------------------------------
#define BLACK   0
#define RED     1
#define GREEN   2
#define YELLOW  3
#define BLUE    4
#define PURPLE  5
#define CYAN    6
#define WHITE   7

;---------------------------------------------------------------------------
;
;			Personnalisation
;
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	;			Couleurs par défaut
	;---------------------------------------------------------------------------
#ifndef DEFAULT_INK
#define DEFAULT_INK WHITE
#endif

#ifndef DEFAULT_PAPER
#define DEFAULT_PAPER BLACK
#endif

	;---------------------------------------------------------------------------
	;			Message de Copyright
	;---------------------------------------------------------------------------
#ifndef COPYRIGHT_MSG
#define COPYRIGHT_MSG1 "ORIC EXTENDED BASIC V1.1",$0D,$0A
#define COPYRIGHT_MSG2 $60," 1983 TANGERINE",$0D,$0A
#define COPYRIGHT_MSG COPYRIGHT_MSG1 , COPYRIGHT_MSG2
#endif

	;---------------------------------------------------------------------------
	;			Mode du CH376
	;---------------------------------------------------------------------------
#ifndef CH376_USB_MODE
#define CH376_USB_MODE SDCARD_MODE
#endif

	;---------------------------------------------------------------------------
	;			Commande QUIT
	; Pris en charge par le Makefile
	;---------------------------------------------------------------------------
; #define BASIC_QUIT
; #define ROM_122
; #define FAST_LOAD
; #define ROOT_DIR "/HOME/BASIC11"

	;---------------------------------------------------------------------------
	;				Défaut
	;---------------------------------------------------------------------------
#define NO_CHARSET
#define ORIX_CLI
#define LOAD_CHARSET
#define ORIX_SIGNATURE

#define FORCE_ROOT_DIR
#ifndef GAMES
#ifndef ROOT_DIR
#define ROOT_DIR "/HOME/BASIC11"
#endif
#endif

#define JOYSTICK_DEFAULT_CONF
#undef AUTO_USB_MODE
#undef MULTIPART_SAVE

#define SET_CHROOT

; Si la carte contient un vrai 6522
;#define VIA2_6522
; Si la carte contient juste le  minimum
#define VIA2_FAKE

	;---------------------------------------------------------------------------
	;			Configuration "Games"
	;---------------------------------------------------------------------------
#ifdef GAMES
#undef HOBBIT
#undef ORIX_SIGNATURE
;#define FORCE_ROOT_DIR
;#define ROOT_DIR "/USR/SHARE/GAMES"
#ifndef ROOT_DIR
#define ROOT_DIR "/USR/SHARE/BASIC11"
#endif
;#define FAST_LOAD
#undef EXPERIMENTAL
#undef ROM_122
#undef MULTIPART_SAVE

	; Cyclotron modifie l'octet en $99, donc on doit forcer le mode du CH376
;#undef AUTO_USB_MODE

#define JOYSTICK_EXTERNAL_CONF

#endif

	;---------------------------------------------------------------------------
	;			Configuration "Hobbit"
	;---------------------------------------------------------------------------
#ifdef HOBBIT
#undef JOYSTICK_DRIVER
#undef JOYSTICK_DEFAULT_CONF
#undef JOYSTICK_EXTERNAL_CONF
#define FORCE_ROOT_DIR
#undef ROOT_DIR
;#define ROOT_DIR "/USR/SHARE/GAMES/"
#undef EXPERIMENTAL
#undef LOAD_CHARSET
#undef ROM_122
#undef MULTIPART_SAVE

#undef SET_CHROOT
#endif

	;---------------------------------------------------------------------------
	;			Gestion Joystick
	; Pris en charge par le Makefile
	;---------------------------------------------------------------------------
#ifdef JOYSTICK_DRIVER
#undef HOBBIT
#endif

	;---------------------------------------------------------------------------
	;			Fonctions expérimentales
	;---------------------------------------------------------------------------
#ifdef EXPERIMENTAL
#define ADD_DEF_CHAR

#ifdef ROM_122
#define ADD_ERROR
#define ADD_ONERROR
#endif

#endif

	;---------------------------------------------------------------------------
	;			Chargement du jeu de caractères
	;---------------------------------------------------------------------------
#ifdef NO_CHARSET
#ifdef LOAD_CHARSET
#ifndef DEFAULT_CHARSET
#ifdef FORCE_ROOT_DIR
#define DEFAULT_CHARSET "/USR/SHARE/FONTS/DEFAULT.CHS"
#else
#define DEFAULT_CHARSET ROOT_DIR,"DEFAULT.CHS"
#endif
#endif
#echo "Default charset:" DEFAULT_CHARSET
#endif
#endif

	;---------------------------------------------------------------------------
	;			Gestion CHROOT
	;---------------------------------------------------------------------------
#ifdef SET_CHROOT
#undef FORCE_ROOT_DIR
#echo "Mode 'CHROOT' activé:" ROOT_DIR
#endif

	;---------------------------------------------------------------------------
	;			Gestion VIA2
	;---------------------------------------------------------------------------
#ifdef VIA2_6522
#undef VIA2_FAKE
#echo "Mode VIA2: 6522"
#else
#define VIA2_FAKE
#echo "Mode VIA2: Fake"
#endif

;---------------------------------------------------------------------------
;
;			Variables en page 0
;
;---------------------------------------------------------------------------
;rwpoin          = $0C			; word

KBD_flag        = $2e
INTTMP          = $33			; $33-$34: Utilisé par GetTapeData

PTR1            = $91			; Pointeur utilisé notamment par les fonctions
					; de manipulations des chaînes
					; Utilisé ici par open_fqn()

#ifdef AUTO_USB_MODE
CH376_MODE	= $99			; Mis à jour par Orix lors de l'appel
					; à la rom
					; /!\ doit être 3 ou 6, pas de vérification
#endif

HIMEM_PTR       = $a6

CURLINE         = $A8                        ; Ligne courante
VARNAME         = $B4                        ; 2 premiers caractères du nom de la variable

TXTPTR          = $e9
JOY_TBL         = $f3

#ifdef ROM_122
CURPOS          = $0030                        ; Position du curseur (écran ou imprimante)
#endif

;---------------------------------------------------------------------------
;
;			Variables en page 2
;
;---------------------------------------------------------------------------
fTextMode	= $021f			; 0:TEXT, 1:HIRES (pour DEF CHAR)

RAMSIZEFLAG     = $0220
RAMFAULT        = $0260

TAPE_SPEED	= $024d			; 0: Fast, 'S': Slow (mis à jour par GetTapeParams)

MERGEFLG	= $025a
VERIFYFLG	= $025b

PAPER_VAL       = $026b
INK_VAL         = $026c

PROGNAME        = $027f

HIMEM_MAX       = $02c1

PROGSTART       = $02a9
PROGEND         = $02ab
PROGTYPE        = $02ae

;#ifdef ROM_122
IF_flag         = $0252                        ; b7: Pas de IF/IF
LPRPOS          = $0258                        ; Position tête d'impressions
SCREENY         = $0268                        ; N° de ligne du curseur
SCREENX         = $0269                        ; N° de colonne du curseur
SOUNDHIRES_ERR  = $02E0                        ; Drapeau erreur pour les instructions SOUND/HIRES
PARAMS		= SOUNDHIRES_ERR
PARAM1          = $02E1                        ; Paramètre 1 pour instructions SOUNDS/HIRES
PARAM2          = $02E3                        ; Paramètre 2 pour instructions SOUNDS/HIRES
PARAM3          = $02E5                        ; Paramètre 3 pour instructions SOUNDS/HIRES
PRINTERFLG      = $02F1                        ; b7: Imprimante HS/ Imprimante OK
;#endif
VDU_hook        = $0238                        ; JMP Char2Scr ; $F77C


;---------------------------------------------------------------------------
;
;			Spécifique Multi-Part
; Non utilisées par le BASIC
;---------------------------------------------------------------------------
OPENFFLAG	= $020f			; Flag pour détecter si un fichier .tap a été ouvert (0: Fichier ouvert, 1: Fichier fermé)
MULTIPFLAG	= $0267			; Flag pour Multipart (0: Fichier ouvert, 1: GetTapeParams a été appelé)


;---------------------------------------------------------------------------
;
;			I/O en page 3
;
;---------------------------------------------------------------------------
VIA             = $0300                        ; VIA IORB
VIA_IORA        = $0301
VIA_DDRB        = $0302
VIA_DDRA        = $0303

;---------------------------------------------------------------------------
;
;			Spécifique Telestrat
;
;---------------------------------------------------------------------------
VIA2_IORB    = $0320
VIA2_DDRA    = $0323

#ifdef VIA2_6522
	VIA2_IORA    = $032f
#else
	VIA2_IORA    = $0321
#endif

BUFEDT       = $0590

;---------------------------------------------------------------------------
;
;			Adresse de l'interface CH376
;
;---------------------------------------------------------------------------
CH376_COMMAND   = $0341
CH376_DATA      = $0340

;---------------------------------------------------------------------------
;			Routines ROM v1.1
;---------------------------------------------------------------------------
CharGet         = $00e2

PrintErrorX	= $c47e

LC496           = $c496
BackToBASIC     = $c4a8
DoNextLine      = $c8c1
SetScreen       = $c82f

REM             = $ca99

NewLine         = $cbf0
PrintString     = $ccb0
LCCD7           = $ccd7

TRON            = $cd16

; Pour DEF CHAR
EvalComma	= $d065
SyntaxError	= $d070
FindVar		= $D1E8
GIVAYF		= $D499
DEF		= $D4BA
DEF_USR		= $D4BE
DEF_FN		= $D4DF
GetByteExpr	= $d8c5
MOVMF		= $DEAD
TapeSync        = $e4ac
GetTapeData     = $e4e0
GetTapeParams   = $e7b2
GetStoreRecallParams = $ea57

ClrTapeStatus   = $e5f5
WriteFileHeader = $e607
LE62A           = WriteFileHeader+35
PutTapeByte     = $e65e
WriteLeader     = $e75a
GetTapeByte     = $e6c9
SyncTape        = $e735
SetupTape       = $e76a
CheckFoundName  = $e790

#ifdef FAST_LOAD
LE810		= $e810
#endif

CLOAD           = $e85b
CSAVE           = $e909
STORE           = $e987
RECALL          = $e9d1
LE93D           = $e93d
CheckKbd        = $eb78

#ifdef JOYSTICK_DEFAULT_CONF
LEC9C           = $ec9c
#else
#ifdef ROM_122
LEC9C           = $ec9c
#endif
#endif

#ifdef ROM_122
FindLine	= $c6b3
RESTORE		= $c952
GetExpr		= $cf03
POS		= $d4a6
WAIT		= $d958
RowCalc		= $da0c
GetWord		= $e853
POINT		= $ec45
LECB9		= $ecb9			; suite de CharGet en ROM
Delay		= $eec9
DrawLine	= $eef8
LEFFA		= $effa
ResetVIA	= $f9aa
SOUND		= $fb40
#endif

StopTimer       = $ee1a

StartBASIC      = $eccc

ReadKbd         = $f495
LF4C6           = ReadKbd+49

ReadKbdCol      = $f561

LF8B8           = $f8b8

RamTest         = $fa14
CharSet         = $fc78
KeyCodeTab      = $ff78

Reset           = $f88f

RESET_VECTOR    = $fffc

;---------------------------------------------------------------------------
;				CSAVE
;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	; Patch routine existante: détournement vers OpenTapeWrite qui repassera
	; ensuite en $E60A
	; Sinon, il faut modifier les routines qui appelle WriteFileHeader pour
	; qu'elles appellent OpenTapeWrite
	;
	; MIEUX: modifier WriteLeader pour appeler OpenTapeWrite
	;---------------------------------------------------------------------------
	new_patchl(WriteFileHeader,3)

		-WriteFileHeader:
			jsr OpenTapeWrite

	;---------------------------------------------------------------------------
	; Supprime une boucle de délai (utile uniquement pour les K7)
	;---------------------------------------------------------------------------
	new_patchl(LE62A,3)
			nop
			nop
			nop

	;---------------------------------------------------------------------------
	; 14 Octets
	;---------------------------------------------------------------------------
	new_patch(PutTapeByte, LE6C9)

		-PutTapeByte:
		.(
			; Doit conserver X et Y
			; A voir si la modification de $2f ne perturbe pas
			; les programmes de jeux
		        sta     $2F                             ; E6F9 A5 2F
		        tya                                     ; E6C9 98
		        pha                                     ; E6CA 48
		        txa                                     ; E6CB 8A
		        pha                                     ; E6CC 48

			; On écrit 1 caractère
			jsr 	WriteUSBData3			; Ecrit un caractère, résultat dans $2f
;			bcs	fin_erreur
;		fin_erreur:
;			message d'erreur?
		fin:
		        pla                                     ; E6F5 68
		        tax                                     ; E6F6 AA
		        pla                                     ; E6F7 68
		        tay                                     ; E6F8 A8
		        rts                                     ; E6FB 60
		.)

		;---------------------------------------------------------------------------
		; 6 Octets
		;---------------------------------------------------------------------------
		; Sauvegarde de l'entête
		OpenTapeWrite:
		.(
			;lda #<PROGNAME			; Forcé dans SetFilename2
			;ldy #>PROGNAME
#ifdef MULTIPART_SAVE
			lda	OPENFFLAG		; Fichier déjà ouvert?
			bne	_open_file		; Non -> il faut en ouvrir un
			lda	PROGNAME		; Nom du fichier commence par '+'?
			cmp	#'+'
			beq	*+5			; Oui -> mode multipart
		_open_file
#endif
			jsr	OpenForWrite
			jmp	WriteLeader
;			jsr	WriteLeader
;			jmp	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
		.)

		;---------------------------------------------------------------------------
		; 29 Octets
		;---------------------------------------------------------------------------
		; Ecrit un octet sur la bande
                WriteUSBData3:
                .(
			; On écrit 1 caractère
			lda	#$01
			ldy	#$00
			jsr	SetByteWrite
			cmp	#INT_DISK_WRITE			; /!\ Test par rapport à INT_SUCCESS mais SetByteWrite renvoie INT_DISK_WRITE si on écrit un seul octet
			bne	fin_erreur

                        lda     #CH376_CMD_WR_REQ_DATA		; WriteRqData
                        sta     CH376_COMMAND
			lda	CH376_DATA			; Nombre de caractère à écrire
                        lda     $2f				; Caractère à écrire
                        sta     CH376_DATA
			jsr     ByteWrGo			; Nécessaire en réel, sinon le CH376 boucle sur son buffer
			clc					; Indique pas d'erreur d'écriture
			.byte $24
		fin_erreur:
			sec
                        rts
		.)

#if 0
; 24 octets
		-PutTapeData:
		.(
			jsr	SetByteReadWrite+2
			bne	_PutTapeData_error

			; Inutile si on vient de PutTapeData+10
			;lda PROGSTART
			;ldy PROGSTART+1
			;sta INTTMP
			;sty INTTMP+1

			; Boucle de sauvegarde du bloc (18 octets)
		loop:
			; On peut supprimer les lda/ldy si on supprime les sta/sty de WriteUSBData
			;lda INTTMP
			;ldy INTTMP+1
			jsr WriteUSBData

			;clc
			;bcs WriteNextChunk
			;cpy #$00		; Nombre d'octets écrits == 0?
			;beq fin

			; Ajuste le pointeur
			clc
			tya
			adc INTTMP
			sta INTTMP
			bcc *+4
			inc INTTMP+1

		WriteNextChunk:
			jsr ByteWrGo
			beq loop

		fin:
		_GetTapeData_error:
			rts
		.)

; 22 octets
		WriteUSBData:
		.(
			; On peut supprimer les sta/sty si on supprime les lda/ldy de PutTapeData
			; et que INTTMP est à jour avant l'appel
		        ;sta INTTMP
		        ;sty INTTMP+1

		WriteUSBData2:
		        ldy #0

		        lda #CH376_CMD_WR_REQ_DATA	; WriteReqData
		        sta CH376_COMMAND
		        ldx CH376_DATA

		        beq ZZZ002

		ZZZ003:
		        lda (INTTMP),Y
		        sta CH376_DATA
		        iny
		        dex
		        bne ZZZ003

		ZZZ002:
		        rts
		.)
#endif


		; 9 octets - Inutile pour le moment
;		WriteRqData:
;			lda	#CH376_CMD_WR_REQ_DATA	; WriteReqData
;			sta	CH376_COMMAND
;			lda	CH376_DATA
;			rts

		;---------------------------------------------------------------------------
		; 26 Octets - Calcul du nombre d'octets à écrire dans le fichier
		;---------------------------------------------------------------------------
		; 11 Octets
		;	lda	PROGEND
		;	ldy	PROGEND+1
		;	bit	PROGTYPE			; Commande STORE?
		;	bvs	Fin			; Oui -> pas de calcul de la taille, c'est déjà fait

			; Optimisé (10+5)
		;	sec				; Calcule la taille du programme
			;lda	PROGEND			; Déjà fait
		;	sbc	PROGSTART
		;	tax

			;lda	PROGEND+1
		;	tya
		;	sbc	PROGSTART+1
		;	tay

		;	inx				; +1
		;	bne	*+3
		;	iny

		;	txa
		;Fin

		;E6B0
		;---------------------------------------------------------------------------
		; WaitResponse:
		; A voir si il faut preserver X et Y
		;
		; Entree:
		;
		; Sortie:
		; Z: 0 -> ACC: Status du CH376
		; Z: 1 -> Timeout
		; X,Y: Modifies
		;---------------------------------------------------------------------------
		; 25 Octets
		;---------------------------------------------------------------------------
		WaitResponse:
		.(
			ldy	#$ff
		ZZZ009:
			ldx	#$ff
		ZZZ010:
			lda	CH376_COMMAND
			bmi	ZZZ011
			lda	#CH376_CMD_GET_STATUS
			sta	CH376_COMMAND
			lda	CH376_DATA
			rts
		ZZZ011:
			dex
			bne	ZZZ010
			dey
			bne	ZZZ009
			rts
		.)
		;---------------------------------------------------------------------------
		; Version sans Timeout: 14 Octets
		;---------------------------------------------------------------------------
		;										; REPEAT;
		;ZZZ010
		;										; .A = CH376_COMMAND;
		;	lda	CH376_COMMAND
		;										; UNTIL -;
		;	bpl	zzz010
		;										; CH376_COMMAND = $22;
		;	lda	#CH376_CMD_GET_STATUS
		;	sta	CH376_COMMAND
		;										; .A = CH376_DATA;
		;	lda	CH376_DATA
		;										; RETURN;
		;	rts

	CloadMultiPart
			jsr	MultiPart
			jmp	GetTapeParams
	RecallMultiPart
			jsr	MultiPart
			jmp	GetStoreRecallParams

;#ifndef FORCE_ROOT_DIR
;	load_charset2:
;		jsr	load_charset
;		jmp	FileClose
;#endif
	; Actuellement: $E6C6 si MULTIPART_SAVE, $E6BC sinon


		;---------------------------------------------------------------------------
		; 11 Octets
		;---------------------------------------------------------------------------
		; Fermeture du fichier après sauvegarde
		;---------------------------------------------------------------------------
#ifndef MULTIPART_SAVE
		WriteClose:
			lda #$01			; Fermeture avec mise à jour
			sta OPENFFLAG			; Indique fichier fermé
			jsr FileClose
			jmp LE93D
#endif


		;---------------------------------------------------------------------------
		; OpenForWrite ( 6 octets)
		;---------------------------------------------------------------------------
		; Ouvre un fichier en écriture
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Code de retour du CH376
		;
		; Modifie:
		;	OPENFFLAG: Flag fichier ouvert
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	CloseOpenedFile
		;	FileCreate
		;---------------------------------------------------------------------------
		; $fdd3: 'K' -> 'L'
		; $ff61: '}' -> '}' (Hobbit)
		OpenForWrite:
		.(
			jsr CloseOpenedFile
			;jsr SetFilename2
			jmp	FileCreate
		.)

	LE6C9:
;#print *
#if * > $e6c9
#print "*** ERROR PutTapeByte too long"
#endif


	;---------------------------------------------------------------------------
	; Patch de la routine pour n'écrire que 4x$16 au lieu de 259
	;---------------------------------------------------------------------------
		; E75A - E769: 16 Octets
		; Sauvegarde de la bande amorce
		; (uniquement les $16)
		; Sortie avec X=Y=0, Z=1
		; Peut être conservé en limitant le nombre de $16 écrits à 4
		; ( E75A LDX #$01 / E75C LDY #$04 )
		;
		; Peut-être réécrit pour gagner 5 octets...
		; *** Réécrire la procédure pour mettre un jmp OpenWriteTape au début ***

	new_patch(WriteLeader,LE76A)
		-WriteLeader:
		.(
			;ldx	#$01
			ldy	#$04
			lda	#$16
			jsr	PutTapeByte
			dey
			bne	*-6
			;dex
			;bne	*-9
			rts

			; Utilisé par SetFilename2
		&ZZD001:
			.byte ".TAP",0
		.)
	LE76A:

#ifndef MULTIPART_SAVE
	;---------------------------------------------------------------------------
	; Patche du CSAVE pour clore le fichier après la sauvegarde
	;---------------------------------------------------------------------------
	new_patchl((CSAVE+47),3)
		jsr WriteClose

	;---------------------------------------------------------------------------
	; Patche du STORE pour clore le fichier après la sauvegarde
	;---------------------------------------------------------------------------
	new_patchl((STORE+69),3)
		jsr WriteClose
#endif

	;---------------------------------------------------------------------------
	; 10 Octets à l'emplacement de "MICROSOFT!"
	;
	; Spécifique MultiPart (Harrier Attack)
	;---------------------------------------------------------------------------
	new_patch($e435,LE43F)
			; Place un flag pour la détection multipart
			; pour certains programmes de Jeu
	MultiPart:
			lda	#$01
			sta	MULTIPFLAG
			rts
			nop
			nop
			nop
			nop
	LE43F:



;---------------------------------------------------------------------------
;				CLOAD
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	; Patch la détection multipart de certains jeux qui ne passe pas par CLOAD
	;---------------------------------------------------------------------------
	new_patchl((CLOAD+1),3)
		jsr CloadMultiPart

	;---------------------------------------------------------------------------
	; Patch la détection multipart de certains jeux qui ne passe pas par RECALL
	;---------------------------------------------------------------------------
	new_patchl((RECALL+4),3)
		jsr RecallMultiPart

	;---------------------------------------------------------------------------
	; Patch l'appel à SyncTape pour détecter l'appel direct
	;---------------------------------------------------------------------------
	new_patchl(TapeSync,3)
		jsr SyncTape+3


#ifdef FAST_LOAD
#echo "Mode Fast Load: activé"
		;---------------------------------------------------------------------------
		; Pas de CLOAD "",V dans ce mode
		;---------------------------------------------------------------------------
	new_patchl(LE810,9)
		.dsb 9, $ea

	new_patch(GetTapeData,LE50A)
		;---------------------------------------------------------------------------
		; GetTapeData (40 octets avec les nop / 43 octets pour la version BASIC 1.1)
		;---------------------------------------------------------------------------
		; Charge un programme en mémoire
		;
		; NOTE: - si ce patch est activé, la commande CLOAD "xxx",V est
		;         désactivée et renverra "SYNTAX ERROR"
		;
		;       - Poopy copie cette routine en $A410 et la modifie
		;
		; Entree:
		;	AY: Adresse de chargement
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;
		; Modifie:
		;	INTTMP: Pointeur adresse de chargement
		;
		; Utilise:
		;	PROGSTART
		;
		; Sous-routines:
		;	ReadUSBData
		;	ByteRdGo
		;---------------------------------------------------------------------------
		-GetTapeData:
		.(
			jsr	SetByteReadWrite
			bne	_GetTapeData_error

			lda PROGSTART
			ldy PROGSTART+1
			sta INTTMP
			sty INTTMP+1

			; Boucle de chargement du fichier (25 octets avec les 3 nop)
		loop:
			jsr ReadUSBData
			bcs fin

			; Ajuste le pointeur
			tya
#ifdef GAMES
			bne *+4				; Saute les 2 octets suivants
			nop					; Poopy place $35 ici
			nop					; Poopy place $A4 ici
#endif
			adc INTTMP
			sta INTTMP
			bcc *+4
			inc INTTMP+1

			jsr ByteRdGo
			beq loop

		fin:
		_GetTapeData_error:
			rts					; Poopy place $60 ici :)
#ifdef GAMES
			nop					; Poopy place $A4 ici
#endif
		.)

	; Actuellement: $E503, $E508 si GAMES
	LE50A:

;#print *
#if * > $e50a
#print "*** ERROR GetTapeData too long"
#endif

#endif

	;---------------------------------------------------------------------------
	; 24 Octets
	;---------------------------------------------------------------------------
	new_patch(GetTapeByte,LE735)
		;LE6C9
		; E6C9 - E6FB: 51 octets
		; Chargement d'un octet
		; Doit conserver X et Y
		; Octet lu dans ACC (utilise $2F comme zone temporaire pour ACC)
		; Sortir avec C=0 et $2B1=0 (pas d'erreur de parité) (2B1 doit être mise à 0 quelque part avant...)

		; Ok: 24/51 octets
		-GetTapeByte:
		; ----------------------------------------------------------------------------
		; GetTapeByte: Modifié (14 octets)
		; ----------------------------------------------------------------------------
		.(
		        tya                                     ; E6C9 98
		        pha                                     ; E6CA 48
		        txa                                     ; E6CB 8A
		        pha                                     ; E6CC 48

			; On lit 1 caractère
;			lda	#$01
;			ldy	#$00
;			jsr	SetByteRead
;			bne	fin_erreur

			jsr 	ReadUSBData3			; Lit un caractère, résultat dans $2f

;		fin_erreur:

		fin:
		        pla                                     ; E6F5 68
		        tax                                     ; E6F6 AA
		        pla                                     ; E6F7 68
		        tay                                     ; E6F8 A8
		        lda     $2F                             ; E6F9 A5 2F
		        rts                                     ; E6FB 60
		.)
		; E6E1

		;---------------------------------------------------------------------------
		; 35 Octets + 5 en ZZD001 (ou 45+5 si FORCE_UPPERCASE)
		;---------------------------------------------------------------------------
			; SetFilename2: 38 octets
		SetFilename2:
		.(
			;sta PTR_READ_DEST
			;sty PTR_READ_DEST+1
#ifdef SET_CHROOT
			jsr	SetChroot
			bne	fin
#endif
			lda	#CH376_CMD_SET_FILE_NAME
			sta	CH376_COMMAND

#ifdef FORCE_ROOT_DIR
			sta	CH376_DATA		; Pour ouverture de '/'
#endif

			ldy	#$ff
			;---
			sty	$2f			; Flag pour détection du '.'
		ZZ0003:
			iny
			;lda (PTR_READ_DEST),y
			lda	PROGNAME,y
			beq	ZZ0004

			cmp	#'.'
			bne	*+4
			sty	$2f

			sta	CH376_DATA
;			bne	ZZ0003
			jmp	ZZ0003

		ZZ0004:
			bit	$2f			; '.' vu?
			sty	$2f			; Sauvegarde la longueur (utilisée par CSAVE)
			bmi	ZZ0005-2			; Non -> ajoute '.TAP'
			lda	#$00			; Ajoute <NULL>
			beq	fin_null

			ldy	#$ff			; Ajoute '.TAP'
		ZZ0005:
			iny
			lda	ZZD001,y
#ifdef FORCE_UPPERCASE
			; Force le nom du fichier .tap en majuscules
		        cmp     #'a'
		        bcc     bk2
		        cmp     #'z'+1
		        bcs     bk2
		        eor     #'a'-'A'
		bk2
#endif
		fin_null
			sta	CH376_DATA
			bne	ZZ0005
		fin
			rts
		.)

#if 0
		;---------------------------------------------------------------------------
		; Alternative sans extension .TAP et ouverture dans le répertoire courant
		;---------------------------------------------------------------------------
		; 17 Octets et ZZD001 peut être supprimé (Gain 18+5 = 23 Octets)
		;---------------------------------------------------------------------------

		SetFilename2
			;sta	PTR_READ_DEST
			;sty	PTR_READ_DEST+1

			lda	#CH376_CMD_SET_FILE_NAME
			sta	CH376_COMMAND
			ldy	#$ff
		ZZ0003
			iny
			;lda	(PTR_READ_DEST),y
			lda	PROGNAME,y
			sta	CH376_DATA
			bne	ZZ0003

			rts
#endif

		;---------------------------------------------------------------------------
		; 28 Octets
		;---------------------------------------------------------------------------
		Mount:
			lda	#CH376_CMD_DISK_MOUNT
			.byte $2c

		FileOpen:
			lda	#CH376_CMD_FILE_OPEN
			.byte $2c

		FileCreate:
			lda	#CH376_CMD_FILE_CREATE

		CH376_Cmd:
			sta	CH376_COMMAND

		CH376_CmdWait:
			jsr	WaitResponse
			cmp	#INT_SUCCESS
			rts
		;---------------------------------------------------------------------------
		FileClose:
			ldx	#CH376_CMD_FILE_CLOSE
			stx	CH376_COMMAND
			sta	CH376_DATA

			clc				; Saut inconditionel
			bcc	CH376_CmdWait

		;---------------------------------------------------------------------------
		; 11 Octets
		;---------------------------------------------------------------------------
		ByteWrGo:
			lda	#CH376_CMD_BYTE_WR_GO
			sta	CH376_COMMAND
			jsr	WaitResponse
			cmp	#INT_DISK_WRITE
			rts

		;---------------------------------------------------------------------------
		; 10 Octets
		;---------------------------------------------------------------------------
;		WriteLeader2:
;			jsr	SetByteAndWrite
;			jsr	WriteLeader		; Ecriture de l'amorce
;			jmp	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
;			; jsr	WriteRqData		; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)

		;---------------------------------------------------------------------------
		; 11 Octets
		;---------------------------------------------------------------------------
		; Fermeture du fichier après sauvegarde
		; Transféré en $e6b6 pour libérer de la place pour pouvoir faire un chroot
		;---------------------------------------------------------------------------
;#ifndef MULTIPART_SAVE
;		WriteClose:
;			lda #$01			; Fermeture avec mise à jour
;			sta OPENFFLAG			; Indique fichier fermé
;			jsr FileClose
;			jmp LE93D
;#endif
	; Actuellement: $E734 si not defined(MULTIPART_SAVE)
	; Actuellement: $E729 si defined(MULTIPART_SAVE)
	LE735:
;#print *
#if * > $e735
#print "*** ERROR GetTapeByte too long"
#endif


	;---------------------------------------------------------------------------
	; 32 Octets
	;---------------------------------------------------------------------------
	new_patch(SyncTape,LE75A)
		;LE735
		; E735 - E759: 37 octets
		; Saute la bande amorce
		; Sortie ACC: octet trouvé
		; On pourrait sortir quand on a trouvé un $24 (inutile de remonter les $16 avant)

		; ----------------------------------------------------------------------------
		; SyncTape: Modifié (31 octets /37)
		; ----------------------------------------------------------------------------
		-SyncTape:
		.(
			; Il faut vérifier si on à déjà ouvert un fichier ou non
			; pour le multitap
			jmp SyncTape_loop			; Point d'entrée direct, on suppose du multitap
			jsr OpenForRead			; Point d'entrée depuis TapeSync, multitap uniquement si on fait CLOAD ""
			;jsr	SetFilename2
			;jsr	FileOpen
			beq *+5
		SyncTape_error:
			jmp NotFound

		SyncTape_loop:
			jsr	GetTapeByte
			; Tester C=1
			bcs SyncTape_error
		suite:
			cmp	#$16
			bne	SyncTape_loop

			; $03-1 pour pouvoir charger les .tap qui n'ont
			; que 3x$16 au lieu de 4 minimum
		        ldx     #$03 -1                         ; E74D A2 03
		LE74F:
		        jsr     GetTapeByte                     ; E74F 20 C9 E6
			; Tester C=1?
		        cmp     #$16                            ; E752 C9 16
		        bne     SyncTape                        ; E754 D0 DF
		        dex                                     ; E756 CA
		        bne     LE74F                           ; E757 D0 F6
			rts
		.)


	; Actuellement: $E756
	LE75A:
	; WriteLeader
;#print *
#if * > $e75a
#print "*** ERROR SyncTape too long"
#endif


;
; Commun
;
;---------------------------------------------------------------------------
; InitCH376:
; Verifie la presence du CH376 et monte la cle
;
; Entree:
;
; Sortie:
;
;---------------------------------------------------------------------------
; 34 Octets
;---------------------------------------------------------------------------
;	new_patch(SetupTape,LE7AF)
;
;		-SetupTape:
;			jsr _SetupTape
;	LE7AF:


;---------------------------------------------------------------------------
;  1 Octet : Patch pour CheckFoundName, retourne OK
; Esapce disponible: $e795-$e7ae (26 octets)
;---------------------------------------------------------------------------
	new_patchl(CheckFoundName+4,1)
		rts


	new_patchl(CheckFoundName+5,25)
		;---------------------------------------------------------------------------
		; ReadUSBData(25 octets)
		;---------------------------------------------------------------------------
		; Charge un bloc en mémoire
		;
		; Entree:
		;	AY: Adresse de chargement
		;
		; Sortie:
		;	C: 0->Ok, 1->aucun octet lu
		;	A: Modifié
		;	X: 0
		;	Y: Nombre d'octets lus
		;
		; Modifie:
		;	INTTMP: Pointeur vers l'adresse de chargement
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	-
		;---------------------------------------------------------------------------
		ReadUSBData:
		.(
			; On peut supprimer les sta/sty si on supprime les lda/ldy de load_data
			; et que INTTMP est à jour avant l'appel
		        ;sta INTTMP
		        ;sty INTTMP+1

		        ldy #0

		        lda #CH376_CMD_RD_USB_DATA0
		        sta CH376_COMMAND
		        ldx CH376_DATA

		        beq ZZZ002

		ZZZ003:
		        lda CH376_DATA
		        sta (INTTMP),Y
		        iny
		        dex
		        bne ZZZ003
                        clc
                        .byte $24
		ZZZ002:
			sec
		        rts
		.)

	; Actuellement: $E7AE
	LE7AF:
;#print *
#if * > $e7af
#print "*** ERROR CheckFoundName too long"
#endif

;---------------------------------------------------------------------------
;  8 Octets : Patch routine existante
;---------------------------------------------------------------------------
;	new_patchl($e93d,3)
;
;		LE93D:
;			; E93D - E945: 9 octets
;			; RestaureVIA
;			; En fait on ne change que l'intruction en $E93D
;			; Ok: 6/9 octets
;			jsr	_ClrTapeStatus
;		        ;jsr     ResetVIA                        ; E940 20 AA F9
;		        ;jmp     SetupTimer                      ; E943 4C E0 ED



;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;	jmp	$D4DA			; "?UNDEF'D FUNCTION ERROR"
;
;	ldx	#$D7
;	jmp	$C47E			; "?CAN'T CONTINUE ERROR"

;---------------------------------------------------------------------------
;			Patch de la routine StartBASIC
;---------------------------------------------------------------------------
#ifdef ORIX_CLI
	new_patch((StartBASIC+$B7),LED86)
		; jmp BackToBASIC
		jmp ORIX_AUTOLOAD
	LED86:
#endif

;---------------------------------------------------------------------------
;			Patch de la routine RamTest
;---------------------------------------------------------------------------
;#ifdef NORAMCHECK
	;
	; Supprime le test de la RAM
	; pour accélérer le démarrage
	;
	; Libère de $FA2C à $FA85 soit 90 octets
	;
	new_patch(RamTest,LFA86)
			; 24 octets
			ldy	#$00
			sty	RAMFAULT
			sty	RAMSIZEFLAG
			sty	$0500
			sty	HIMEM_PTR
			sty	HIMEM_MAX
			lda	#$c0-$28
			sta	HIMEM_PTR+1
			sta	HIMEM_MAX+1
			rts

#ifdef ORIX_CLI
		; 27 octets
		ORIX_AUTOLOAD:
			; InitCH376: inutile car fait pour le chargement
			; du jeu de caractères
			; jsr InitCH376
			lda #$01			; Indique fichier fermé
			sta OPENFFLAG
			lda #<(BUFEDT+6)
			sta TXTPTR
			lda #>(BUFEDT+6)
			sta TXTPTR+1
			jsr CharGet
			beq *+8
			jsr CLOAD
			jmp DoNextLine
			jmp BackToBASIC
#endif

#ifdef BASIC_QUIT
		; 25 octets (13+12)
		QUIT:
			ldy	#$0C
		boucle:
			lda	BackToOrix,y
			sta	$00,y
			dey
			bpl	boucle
			jmp	$0000

		BackToOrix:
			sei
			lda	#$07
			sta	VIA2_IORA
			sta	VIA2_DDRA
			jmp	(RESET_VECTOR)
#endif

#ifdef LOAD_CHARSET
		;---------------------------------------------------------------------------
		; load_charset (34 octets)
		;---------------------------------------------------------------------------
		; Charge le jeu de caractères par défaut en RAM
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;
		; Modifie:
		;	PROGSTART: Pointeur vers l'adresse de chargement
		;	PROGEND  : Pointeur vers l'adresse de fin de chargement
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	open_fqn
		;	GetTapeData
		;---------------------------------------------------------------------------
		; $fcae
		load_charset:
		.(
			; Ouverture du fichier
			lda default_chs_len
			ldx #<default_chs
			ldy #>default_chs
			jsr open_fqn
			bne load_charset_error

			; Adresse de chargement
			lda #<$b500
			ldy #>$b500
			sta PROGSTART
			sty PROGSTART+1

			; Adresse de fin
			;lda #<($b500+$300)			; Inutile, le poids faible reste à 0
			ldy #>($b500+$300)
			sta PROGEND
			sty PROGEND+1

			; Chargement du jeu de caractères
			jsr GetTapeData

		load_charset_error:
			rts
		.)
#else
		;---------------------------------------------------------------------------
		; InitCH376 (31 Octets)
		;---------------------------------------------------------------------------
		; Initialisation du CH376
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Code de retour du CH376
		;
		; Modifie:
		;	-
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	Mount
		;---------------------------------------------------------------------------
		; $fd68: '<' -> 'B'

		load_charset:
			jsr	$f982				; Copie ROM->RAM (appelé depuis LF8B8 avec X=5)
		InitCH376:
		Exists:
			ldx	#CH376_CMD_CHECK_EXIST
			stx	CH376_COMMAND
			lda	#$ff
			sta	CH376_DATA
			lda	CH376_DATA
			bne	InitError
		SetUSB:
			lda	#CH376_CMD_SET_USB_MODE
			sta	CH376_COMMAND
#ifndef AUTO_USB_MODE
			ldx	#CH376_USB_MODE
#else
			ldx	CH376_MODE
#endif
			stx	CH376_DATA

			;Wait 10us
			nop
			nop
			jsr	Mount

			;IFF ^.Z THEN InitError;
		;	bne	InitError
		;	rts

		InitError:
			rts
		;	jmp	$d4da
		;	ldx	#$d7
		;	jmp	$c47e			; "?CAN'T CONTINUE ERROR"
		;	jmp	$d35c			; "?OUT OF DATA ERROR"

		;	jmp	$e651			; Si $02B1 != 0 -> jmp $E656
		;	jmp	$e656			; "Errors found" (mais pas de retour au BASIC)

#endif
	RAMCHECK_end:

;#print *
#if * > $fa86
#print "*** ERROR NORAMCHECK too long"
#endif
		; /!\ 3DFongus s'attend à avoir un RTS en $FA85 pour détecter un Atmos
		.dsb $fa86-*, $60
	LFA86:
;#endif



;---------------------------------------------------------------------------
;			Patch pour la gestion du joystick
;			Placé dans le jeu de caractères
;---------------------------------------------------------------------------
#ifdef NO_CHARSET

#ifndef HOBBIT
	new_patch((CharSet+$18), CharSet_end)
#endif

;---------------------------------------------------------------------------
;		Patch pour le chargment du jeu de caractère par défaut
;			Placé dans le jeu de caractères
;---------------------------------------------------------------------------
;Majuscules
;Minuscules
;' '
;:
;.
;?
;>
;?
;+
;"
;'
;,
;
;--------------------------------------------------------------------------------
;
;
;$FC78	   !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
;	         ======   =     =======        =     =		-> 3*8 + 8 + 3*8 + 8 + 8 = 24 + 8 + 24 + 8 + 8
;
;$FCF8	0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
;        =============================    ========		-> 10*8 + 3*8 = 80 + 24
;
;$FD78	@  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
;	=
;
;$FDF8	P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
;	                                 ===============	-> 5*8=40
;
;$FE78	(c)a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
;	==							-> 8
;
;$FEF8	p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~  <del>
;	                                 ===============	-> 5*8=40
;
;$FF78
;								Total: 264
;
; Joystick:
;	Fire2:	$f3
;	Fire3:	$f4
;	Down:	$f5
;	Right:	$f6
;	Left:	$f7
;	Fire:	$f8
;	Up:	$f9
;
; Touches:
;	[ESC]	$A9
;	[SPACE]	$84
;	[ENTER]	$AF
;	[DOWN] 	$B4
;	[RIGHT]	$BC
;	[LEFT]	$AC
;	[UP]	$9C
;
; Spéciales:
;	[SHIFT_L]	$A4
;	[SHIFT_R]	$A7
;	[CTRL_L]	$A2
;	[CTRL_R]	$A0	/!\ Spécifique Oricutron
;	[FUNCT]		$A5


		; Spécial pour The Hobbit qui vérifie la valeur en $FC78
		; pour savoir si il s'agit d'un Oric-1 ou d'un Atmos
		;.byte $00
		; Psychiatric fait le même test

		; $fc90-$fcad: 30 octets
		; # $ % &
#ifdef LOAD_CHARSET
		default_chs_len:
			.byte default_chs_end-default_chs-1
		default_chs:
			.byte DEFAULT_CHARSET,0
		default_chs_end:



		;---------------------------------------------------------------------------
		; open_fqn (103 octets -3)
		;---------------------------------------------------------------------------
		; Ouvre un fichier (chemin absolu ou relatif sans ../)
		; Les paramètres en entrée sont les mêmes que ceux en sortie de jsr CheckStr/ReleaseVarStr
		; Ce qui permet d'appeler open_fqn ainsi (Cf: CD.pl65)
		;		jsr EvalExpr
		;		jsr CheckStr
		;		beq erreur
		;		jsr open_fqn
		;
		; Entree:
		;	XY: Adresse de la chaine
		;	A: Longueur de la chaine
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;	PTR1: Adresse de la chaine
		;
		; Modifie:
		;	INTTMP: Longueur de la chaine (remis à sa valeur initiale en fin de procédure)
		;	INTTMP+1: Index dans la chaine (remis à sa valeur initiale en fin de procédure)
		;	PTR1: Adresse de la chaine
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	InitCH376
		;	FileOpen
		;---------------------------------------------------------------------------
		; $fcae: '&' -> '6'
		open_fqn:
		.(
			stx PTR1
			sty PTR1+1

			; Longueur de la chaîne
			sta INTTMP
										; PTR1+3 = 0;
			lda #$00
			sta INTTMP+1
			; Note: InitCH376 fait un Mount USB qui replace le répertoire par
			; defaut a '/'
			; A modifier pour autoriser un repertoire relatif
										; CALL InitCH376;
			jsr InitCH376
										; IF .Z THEN
			bne ZZ1002
										; BEGIN;
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
										; IF &PTR1 = '/' THEN
			ldy #$00
			lda #'/'
			cmp (PTR1),Y
			;beq  *+5
			;jmp ZZ1003
			bne ZZ1003
										; BEGIN;
			; Apres le test, .A contient '/' soit $2F
										; CH376_COMMAND = .A; " SetFilename";
			sta CH376_COMMAND
										; CH376_DATA = .A;
			sta CH376_DATA
										; CH376_DATA = $00;
;			lda #$00
;			sta CH376_DATA
										; CALL FileOpen; " Detruit X et Y";
;			jsr FileOpen
; Optimisation taille: Gain 5 Octets
			jsr ZZ0006
										; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
			cmp #ERR_OPEN_DIR
			bne CD_End
										; INC PTR1+3;
			inc INTTMP+1
										; END;
										; IF PTR1+3 < PTR1+2 THEN CH376_COMMAND = $2F; " SetFilename";
		ZZ1003:
;			lda INTTMP
;			cmp INTTMP+1
;			beq  *+4
;			bcs  *+5
;			jmp ZZ1004
; Optimisation en inversant le test: Gain 5 Octets
			lda INTTMP+1
			cmp INTTMP
			bcs ZZ0006

			lda #$2F
			sta CH376_COMMAND
		ZZ1004:
			; Remplacer BCC *+5/JMP ZZnnnnn par BCS ZZnnnnn
										; WHILE PTR1+3 < PTR1+2
		ZZ1005:
			ldy INTTMP+1
			cpy INTTMP
			;bcc  *+5
			;jmp ZZ0006
			bcs ZZ0006
										; DO;
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
			; IF &PTR1[PTR1+3] = '/' THEN
										; .Y = PTR1+3;
			; Optimisation
			;ldy INTTMP+1
										; .A = @PTR1[.Y];
			lda (PTR1),Y
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
										; IF .A = '/' THEN
			cmp #'/'
			;beq  *+5
			;jmp ZZ0007
			bne ZZ0007
										; BEGIN;
										; CH376_DATA = 0;
;			lda #$00
;			sta CH376_DATA
										; CALL FileOpen;
;			jsr FileOpen
; Optimisation taille: Gain 5 Octets
			jsr ZZ0006
										; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
			cmp #ERR_OPEN_DIR
			bne CD_End
										; INC PTR1+3;
			inc INTTMP+1
											; IF PTR1+3 < PTR1+2 THEN CH376_COMMAND = $2F; " SetFiPTR1+2ame";
;			lda INTTMP
;			cmp INTTMP+1
;			beq  *+4
;			bcs  *+5
;			jmp ZZ0008
; Optimisation en inversant le test: Gain 5 Octets
			ldy INTTMP+1
			cpy INTTMP
			bcs ZZ0008

			lda #$2F
			sta CH376_COMMAND
		ZZ0008:
										; .Y = PTR1+3;
			; Optimisation
			;ldy INTTMP+1
										; .A = @PTR1[.Y];
			lda (PTR1),Y
										; END;
										; CH376_DATA = .A;
		ZZ0007:
			sta CH376_DATA
										; INC PTR1+3;
			inc INTTMP+1
										; END;
			jmp ZZ1005

		ZZ0006:
										; CH376_DATA = $00;
			lda #$00
			sta CH376_DATA
										; CALL FileOpen;
			jsr FileOpen
										; CD_End:
		CD_End
										; END;
;			; .AY = Code erreur, poids faible dans .A
		ZZ1002:
										; .Y = .A;
;			tay
										; CLEAR .A;
;			lda #$00
										;RETURN;
			rts
		.)

#endif

; [---
#ifdef HOBBIT
	new_patchl($fe50,48)
#endif
		;---------------------------------------------------------------------------
		; SetByteReadWrite (33 octets +15)
		;---------------------------------------------------------------------------
		; Calcule la taille du programme et effectue un SetByteRead ou SetByteWrite
		;
		; Entree:
		;	SetByteReadWrite: SetByteRead
		;	SetByteReadWrite+1: SetByteWrite
		;
		; Sortie:
		;	A: Code de retour du CH376
		;	X: Modifié
		;	Y: Modifié
		;
		; Modifie:
		;	-
		; Utilise:
		;	PROGSTART: Adresse de début du programme
		;	PROGEND: Adresse de fin du programme
		;
		; Sous-routines:
		;	SetByteRead
		;	SetByteWrite
		;---------------------------------------------------------------------------
		; $fd2d: '6' -> ':'
		; $fe50: '[' -> '^' (Hobbit)
		SetByteReadWrite
		.(
			sec				; Point d'entrée pour une lecture
			.byte $24
			clc				; Point d'entrée pour une écriture

			php				; Sauvegarde P pour plus tard

		_CalcPgmLength:
			sec				; Calcule la taille du programme
			lda	PROGEND
			sbc	PROGSTART
			tax

			lda	PROGEND+1
			sbc	PROGSTART+1
			tay

		_WriteLength:
			inx				; +1
			bne	*+3
			iny

			txa

			plp
			bcc *+5
			jmp SetByteRead
			jmp SetByteWrite
		.)


		; Message d'erreur (15 octets)
		; $fdbf: 'I' -> 'J'
		; $fe71: 'Livre' -> '(c)' (Hobbit)
		FileNotFound_msg
			.byte "FILE NOT FOUND",00
; ---]



#ifdef LOAD_CHARSET
		;---------------------------------------------------------------------------
		; InitCH376 (31 Octets)
		;---------------------------------------------------------------------------
		; Initialisation du CH376
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Code de retour du CH376
		;
		; Modifie:
		;	-
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	Mount
		;---------------------------------------------------------------------------
		; $fd68: '<' -> 'B'
		InitCH376:
		Exists:
			ldx	#CH376_CMD_CHECK_EXIST
			stx	CH376_COMMAND
			lda	#$ff
			sta	CH376_DATA
			lda	CH376_DATA
			bne	InitError
		SetUSB:
			lda	#CH376_CMD_SET_USB_MODE
			sta	CH376_COMMAND
#ifndef AUTO_USB_MODE
			ldx	#CH376_USB_MODE
#else
			ldx	CH376_MODE
#endif
			stx	CH376_DATA

			;Wait 10us
			nop
			nop
			jsr	Mount

			;IFF ^.Z THEN InitError;
		;	bne	InitError
		;	rts

		InitError:
			rts
		;	jmp	$d4da
		;	ldx	#$d7
		;	jmp	$c47e			; "?CAN'T CONTINUE ERROR"
		;	jmp	$d35c			; "?OUT OF DATA ERROR"

		;	jmp	$e651			; Si $02B1 != 0 -> jmp $E656
		;	jmp	$e656			; "Errors found" (mais pas de retour au BASIC)
#endif


; [---
#ifdef HOBBIT
	new_patchl($fcb8, 29)
;	new_patchl($fcb8, 20)
#endif
		;---------------------------------------------------------------------------
		; ReadUSBData3 (29 octets)
		;---------------------------------------------------------------------------
		; Lit un caractère depuis la K7
		;
		; Note: Optimisation impossible pour Hobbit qui utilise INTTMP pendant le
		;       chargement (Lone Raider aussi).
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	C: 0->Ok, 1-> Erreur
		;	A: Caractère lu
		;	X: 0
		;	Y: 1
		;	$2f: Caractère lu
		;
		; Modifie:
		;	INTTMP: valeur: $002f
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	-
		;---------------------------------------------------------------------------
		; $fd4e: ':' -> '='
		; $fcb8: '(' -> '+' (Hobbit)
                ReadUSBData3:
                .(
			; On lit 1 caractère
			lda	#$01
			ldy	#$00
;			sty	INTTMP+1
			jsr	SetByteRead
			bne	fin_erreur
#if 1
                        lda     #CH376_CMD_RD_USB_DATA0
                        sta     CH376_COMMAND
			lda	CH376_DATA			; Nombre de caractère à lire
                        lda     CH376_DATA			; Caractère lu
                        sta     $2f
			jsr     ByteRdGo			; Nécessaire en réel, sinon le CH376 boucle sur son buffer
			clc					; Indique pas d'erreur de lecture
			.byte $24
#else
			lda	#$2f				; On veut le caractère lu dans $2F
			sta	INTTMP
			jmp	ReadUSBData
#endif
		fin_erreur:
			sec
                        rts
		.)

#ifdef HOBBIT
	new_patchl($fc90,32)
#endif
		;---------------------------------------------------------------------------
		; 32 Octets
		;---------------------------------------------------------------------------
		; $fd8c: 'B' -> 'E'
		; $fc90: '#' -> '&' (Hobbit)
		SetByteWrite:
			ldx	#CH376_CMD_BYTE_WRITE
			jsr	CH376_Cmd2
			cmp	#INT_SUCCESS
			rts

		SetByteRead:
			ldx	#CH376_CMD_BYTE_READ

		CH376_Cmd2:
			stx	CH376_COMMAND
			sta	CH376_DATA
			sty	CH376_DATA

		CH376_CmdWait2:
			jsr	WaitResponse
			cmp	#INT_DISK_READ
			rts
		;---------------------------------------------------------------------------
		ByteRdGo:
			lda	#CH376_CMD_BYTE_RD_GO
			sta	CH376_COMMAND
			bne	CH376_CmdWait2

#ifdef HOBBIT
	new_patchl($fd50, 24)
#endif
		;---------------------------------------------------------------------------
		; (24 octets)
		;---------------------------------------------------------------------------
		;
		; Efface la ligne de status + 'FILE NOT FOUND ERROR'
		; Utilisé pour indiquer une erreur lors de la lecure d'un fichier
		;---------------------------------------------------------------------------
		; $fda2: 'F' -> 'H'
		; $fd50: ";" -> '=' (Hobbit)
		_FileNotFound:
			jsr LE93D
;			jmp $d35c
			; Reprend le début de PrintErrorX
		        jsr     SetScreen                       ; C47E 20 2F C8
		        lsr     KBD_flag                        ; C481 46 2E
		        jsr     NewLine                         ; C483 20 F0 CB
		        jsr     LCCD7                           ; C486 20 D7 CC

			lda #<FileNotFound_msg
			ldy #>FileNotFound_msg
			jsr PrintString
			; Retour à PrintErrorX
			jmp LC496

; --]

; [---
#ifdef HOBBIT
	new_patchl($ff50,31)
#endif
		;---------------------------------------------------------------------------
		; OpenForRead (17 octets) +8
		;---------------------------------------------------------------------------
		; Ouvre un fichier en lecture
		;
		; TODO: A voir si il faut conserver tous les tests pour la version "normale"
		;        de la rom basic11 ou si il ne faut conserver que le premier test
		;        et faire du #ifdef HOBBIT le cas général et la partie #else le cas
		;        pour la version GAMES
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Code de retour du CH376
		;
		; Modifie:
		;	OPENFFLAG: Flag fichier ouvert/fermé
		;	MULTIPFLAG: Flag pour le multipart
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	CloseOpenedFile
		;	FileOpen
		;---------------------------------------------------------------------------
		; $fdba: 'H' -> 'L'
		; $ff50: '{' -> 'Damier' (Hobbit)

		OpenForRead:
		.(
			lda PROGNAME			; Si CLOAD "" => fin (multipart)
			beq fin
#ifdef HOBBIT
			jsr CloseOpenedFile
			lda #$00
#else

#ifdef GAMES
			; Le jeu "Them" utilise un CLOAD " " pour charger le second module
			; => si le premier caractère du nom du fichier est ' ' on suupose du multipart
			; /!\ On ne teste que le premier caractère
			cmp #' '
			beq fin
#endif
			; Test pour Hellion, Frelon, Psy...
			; Ces jeux chargent le second programme en faisant
			; un appel direct en $E867 (Atmos)
			; Ne peut pas être intégré dans le cas de la rom "Hobbit"
			; car modifie des caractères utilisés par le jeu
			; (Sauf à déplacer OpenForRead ailleurs)
			;
			; Test non valable dans le cas de Harrier Attack qui force TAPE_SPEED à 0 sans passer par GetTapeParams
;			bit TAPE_SPEED
;			bvc *+6
;			lda #$00
			lda MULTIPFLAG			; Si on n'est pas passé par GetTapeParams => fin (multipart, appel direct aux routines de la ROM)
			beq fin
			jsr CloseOpenedFile
			;jsr SetFilename2

			; Initialise TAPE_SPEED avec $40 pour la détection d'un CLOAD sans
			; passer par la procédure normale (Hellion, Frelon, Psy...)
			; TAPE_SPEED est initialisé à 0 ou 'S' par GetTapeParams
			; (paramètres Slow)
			; --- PAS VALABLE POUR HARRIER ATTACK ---
;			lda #$40
;			sta TAPE_SPEED
			lda #$00			; Indique fichier ouvert (CLOAD "xxx", RECALL v$,"XXX")
			sta MULTIPFLAG
#endif

;			lda #$00
			sta OPENFFLAG			; Indique fichier ouvert
			jmp	FileOpen

		fin:
			rts
		.)

#if 0
		;---------------------------------------------------------------------------
		; OpenForWrite ( 6 octets)
		;---------------------------------------------------------------------------
		; Ouvre un fichier en écriture
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Code de retour du CH376
		;
		; Modifie:
		;	OPENFFLAG: Flag fichier ouvert
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	CloseOpenedFile
		;	FileCreate
		;---------------------------------------------------------------------------
		; Transféré en $e6c1 pour libérer le caractère 127 utilisé par la démo VOLCANIC4
		; (surtout valable pour la rom Hobbit)
		;---------------------------------------------------------------------------
		; $fdd3: 'K' -> 'L'
		; $ff61: '}' -> '}' (Hobbit)
		OpenForWrite:
		.(
			jsr CloseOpenedFile
			;jsr SetFilename2
			jmp	FileCreate
		.)
#endif
		;---------------------------------------------------------------------------
		; CloseOpenedFile ( 13 octets)
		;---------------------------------------------------------------------------
		; Ferme le fichier actuellement ouvert et prépare l'ouverture d'un fichier
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	-
		;
		; Modifie:
		;	OPENFFLAG: Flag fichier ouvert
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	FileClose
		;---------------------------------------------------------------------------
		; $fdd7: 'L' -> 'M'
		; $ff61: '}' -> 'Damier' (Hobbit)
		; Note: VOLCANIC4 nécessite la rom Hobbit et utilise le caractère "Plein"
		CloseOpenedFile:
		.(
			lda OPENFFLAG			; Fichier ouvert?
			bne suite
			; Fermeture du fichier actuel
			;lda #$01			; Indique fichier fermé
			;sta OPENFFLAG
			inc OPENFFLAG			; Indique fichier fermé
			jsr FileClose
		suite:
			jmp SetFilename2
		.)
; ---]


#ifdef JOYSTICK_DRIVER
		;---------------------------------------------------------------------------
		; CheckJoystick (78 octets)
		;---------------------------------------------------------------------------
		; Scrute le Joystick
		;
		; Entrée:
		;	A: ($208) & $87 'N° de ligne de la dernière touche appuyée)
		;	X: ($020A)
		;	Y: -
		;	$0208: Code dernière touche appuyée
		;	$020A: Colonne dernière touche appuyée (pour vérification)
		;	$0210: ($0208) & $87
		;
		; Sortie:
		;	A:
		;	X:
		;	Y:
		;	$0208:
		;	$020A:
		;	$0210: Colonne touche actuellement appuyée
		;
		; Appel: jsr xxx (remplace le jsr ReadKbdCol)
		;---------------------------------------------------------------------------
		; $fde5: 'M' -> '\'
		CheckJoystick:
		.(
			; Ne pas modifier A et X pour pouvoir appeler ReadKbdCol

			; Gestion des boutons 2 et 3
			lda VIA2_IORA
			rol
			bcs B2
			lda JOY_TBL
			bcc Check_B2B3
		B2:
			rol
			rol
			bcs J1
			lda JOY_TBL+1

		Check_B2B3:
			bpl B2B3_invalid
			; Touche spéciale? (Shift, Ctrl, Funct)
			tay			; sauvegarde la touche pour plus tard
			and #%00111000
			cmp #%00100000
		;	bne normal
			beq special

		normal
			tya			; Restaure le code de la touche
			bne repetition_test	; vers le cmp $0208


		special
			tya
			sta $0209
			clc			; Indique B2/B3 appuyé (on doit remettre C=0 à cause du cmp #%00100000 qui l'a mis à 1
			bne J1			; Ou: BIT xx pour gagner un octet

		B2B3_invalid
			sec			; Indique B2/B3 non appuyé

			; Gestion du Joystick
		J1:
			php			; C=0 indique l'appui sur B2 ou B3 (sauvegarde P pour plus tard)
			ldy #$02		; Si on peut modifier Y
			lda VIA2_IORB		; 35 Octets
			and #$1f
			lsr
			bcc right
			lsr
			bcc left
			lsr
			bcc fire
			lsr
			bcc down
			lsr
			bcc up

		retour
			plp			; Restaure P pour savoir si on a appuyé sur B2 ou B3 (touche spéciale)
			lda $0208		; Instruction supprimée de ReadKbd
			; B2 ou B3 appuyé?
			; Autorise combo <touche>+<B2/B3> en plus de <direction>+>B2/B3> et >B2/B3>+>direction> (<B2/B3>+>touche> => <touche> non pris en compte)
			;bcc repetition
			;bcc fin
			bcc autre_direction
			rts			; Retour à ReadKbd

		up
			iny
		fire
			iny
		left
			iny
		right
			iny
		down
;			plp
			lda JOY_TBL,y		; La table doit contenir le code de la touche
			; Tester si il s'agit de la même direction
			; Si oui -> rts possible
			; Si non -> initialiser $020E, mettre à jour $0208 et $020A puis retour à faire en LF4C6
			bpl retour		; Si la touche n'est pas définie, on repart vers ReadKbd
			;beq retour		; Si la touche n'est pas définie, on repart vers ReadKbd
			;ora $80		; b7=1 pour indiquer qu'une touche est appuyée
			plp

		repetition_test
			cmp $0208
			bne autre_direction

		repetition
			tay
			pla			; Oublie l'adresse de retour
			pla
			tya
			jmp ReadKbd+26		; Retour, gestion répétition

			; calculer le masque pour la colonne et le mettre dans $020A
		autre_direction
			;ora $80		; b7=1 pour indiquer qu'une touche est appuyée
			sta $0208		; Sauvegarde le code de la touche dans $0208

			; On calcule le masque pour la ligne
			; correspondant à la touche
			and #$07		; N° de ligne de la touche
			tay			; Sert de compteur
			iny

			clc
			lda #$ff
		loop
			rol
			dey
			bne loop
			sta $210		; Masque de la ligne dans $0210

			lda $024e		; Initialise le compteur pour la répétition
			sta $020e
		;fin:
			pla			; Oublie l'adresse de retour
			pla

			lda $0208		; Replace le code de la touche dans A

			jmp LF4C6		; Retour à ReadKbd

		.)
#endif

#ifdef SET_CHROOT
	SetChroot:
	.(
			lda CHROOT_PATH
			ldx #<(CHROOT_PATH+1)
			ldy #>(CHROOT_PATH+1)
			jsr open_fqn
			cmp #ERR_OPEN_DIR
			rts

	; TEMPORAIRE POUR COMPATIBILITE
	; TODO: Déplacer CHROOT_PATH VERS UNE ADRESSE FIXE A LA FIN DE CHARSET
	.dsb $fe6f-*, $ea

		CHROOT_PATH:
			.byte PATH_END-*-1
			.byte ROOT_DIR

		PATH_END:
			.dsb 33-(*-CHROOT_PATH),0
	.)
#endif

#ifdef ADD_DEF_CHAR
#echo "Add experimental DEF CHAR instruction"
#define Token_USR  $D9
#define Token_CHAR $B0

DEF_CHAR:
	cmp #Token_CHAR
	beq _DEF_CHAR
	cmp #Token_USR
	bne *+5
	jmp DEF_USR
	jmp DEF_FN

#if 1
	; Optimisation de la routine: gain -> 30 octets
_DEF_CHAR:
.(
	LF171 = $f171				; Calcule l'adresse d'un caractère dans le jeu de caractères
						; La routine considère qu'elle appelée en mode HIRES

	jsr GetByteExpr
	txa
	beq getCharCode			; Jeu N°0 -> suite
	cpx #$02				;
	bcs Erreur				; >=2? -> Syntax Error

getCharCode:
	sta PARAM2				; N° jeu de caractères
	jsr EvalComma

	jsr GetByteExpr+3			; Récupère une valeur [0,255]
	txa
	jsr LF171+13				; Calcule l'adresse du caractère (résultat dans $0c-0d, ACC=($0d))
	ldx fTextMode
	bne suite
	adc #($B5-$99)				; Ajoute l'offset en fonction du mode TEXT ou HIRES
suite:
	sta $0f
;	dec $0f				; Correction de l'adresse à cause du +$f8
	lda $0c
	sta $0e
	; Modifie le caractère
	; /!\ ATTENTION: comme on ne passe pas par un buffer
	;     le caractère sera en partie modifié en cas
	;     d'erreur de syntaxe
;	lda #$f8				; -8
	lda #$00
	sta $2f
loop:
	jsr EvalComma
	jsr GetByteExpr+3			; Valeur en X (ILLEGAL QUANTITY si > 255)
	ldy $2f
	txa
	and #$3f				; On masque les 2 premiers bits inutilisés par l'Oric :-(
						; Ou on pourrait générer une erreur "ILLEGAL QUANTITY"
	sta ($0e),y
	; iny
	; sty $00
	inc $2f
	cpy #$07
	bne loop

	rts

Erreur:
	jmp SyntaxError				; Renvoyer une erreur 27001 si ce qui suit le LET n'est pas valide
.)

#else
_DEF_CHAR:
.(
	lda fTextMode				; Mode TEXT?
	bne *+5
	lda #($b5-1)				; Adresse Jeu de caractère normal en mode TEXT: $b500-$b7ff, Jeu LORES 1: $b900-$bb7f (mais $bb00-bb7f initialisé à $55)
	.byte $2c
	lda #($99-1)				; Adresse Jeu de caractère normal en mode HIRES: $9900; Jeu LORES 1: $9d00
	sta $0f

	jsr GetByteExpr				; Récupère le n° du jeu de caractères
	txa
	beq getCharCode			; Jeu N°0 -> suite
	cpx #$02				;
	bcs Erreur				; >=2? -> Syntax Error
	lda #$04				; Ici, jeu N°1, on ajoute $04 à la page du jeu de caractères
	adc $0f
	sta $0f
getCharCode:
	jsr EvalComma

;
; Version 1:
; Prend le code ASCII du caractère suivant
;
;	jsr CharGet				; /!\ Récupère le caractère à redéfinir, ne peut être un ' '
;	beq Erreur

;
; Version 2:
; Prends la valeur d'une expression numérique
;
	jsr GetByteExpr+3			; Récupère une valeur [0,255]
	txa

;
; Version 3
; Prends le code ASCII du premier caractère d'une chaine
; ou une valeur numérique
;
;	jsr EvalExpr
;	bit $28
;	beq numerique
;
;numerique:

	sec
	sbc #' '				; Doit être [0,$5f] pour le jeux normal et [0,$4d] pour le jeux LORES 1
	bmi Erreur
	cmp #$20
	bmi suite
	sbc #$20
	inc $0f
	cmp #$20
	bmi suite
	sbc #$20
	inc $0f
suite:
	asl					; x2
	asl					; x4
	asl					; x8

	clc					; +8 pour compenser le -$100 du début
	adc #$08

	sta $0e
	bcc suite2
	inc $0f

suite2:
	lda #$f8				; -8
	sta $2f
;
; Inutile si version 2
;	jsr CharGet				; Il faudrait ajouter un paramètre pour le N° de jeu de caractères (<0 pour réinitialisation du caractère?)

	; Modifie le caractère
	; /!\ ATTENTION: comme on ne passe pas par un buffer
	;     le caractère sera en partie modifié en cas
	;     d'erreur de syntaxe
loop:
	jsr EvalComma
	jsr GetByteExpr+3			; Valeur en X (ILLEGAL QUANTITY si > 255)
	ldy $2f
	txa
	and #$3f				; On masque les 2 premiers bits inutilisés par l'Oric :-(
						; Ou on pourrait générer une erreur "ILLEGAL QUANTITY"
	sta ($0e),y
	; iny
	; sty $00
	inc $2f
	bne loop

	rts

Erreur:
	jmp SyntaxError				; Renvoyer une erreur 27001 si ce qui suit le LET n'est pas valide
.)
#endif

#endif

		;---------------------------------------------------------------------------
		; Table de conversion pour ERROR n
		;---------------------------------------------------------------------------
#ifdef ADD_ERROR
		ErrTbl:
			.byte $00,$10,$16,$2a,$35,$45,$4d,$5a
			.byte $6b,$78,$85,$95,$a3,$a8,$b5,$c4
			.byte $d7,$e5,$f5

#endif

#ifdef ADD_ONERROR
	;---------------------------------------------------------------------------
	; BUG: A=1:A=A/0 => A=10
	; Correction: sauvegarder VARNAME ($B4-B5) et/ou $B6-$B7
	;---------------------------------------------------------------------------
		SetBasicVar:
		.(
			; Entrée avec X=Code erreur
			; 14 Octets
			jsr BasicErrToEn
			;txa
			tay
			lda #$00
			tax
			jsr SetVar
			; N° de la ligne
			ldy CURLINE
			lda CURLINE+1
			;ldx #$01
			ldx #$02

		SetVar:
			; 23 octets
			pha
			txa
			;asl
			lda VarTbl,x
			sta VARNAME
			lda VarTbl+1,x
			sta VARNAME+1
			pla


			jsr GIVAYF
			jsr FindVar
			tax
			jmp MOVMF

		;VarTbl:
		;	; 4 octets
		;	.byte "EN","EL"
		.)
#endif

#ifdef ADD_ONERROR
#echo "Add experimental ON ERROR instruction"

Token_ERROR = $85
Token_GOTO = $97
Token_CONT = $bb
Token_STOP = $b3
err_line = $00
;err_line = TXTPTR
UndefdStatementError = $ca23
FindEndOfStatement = $ca4e
EvalAcc = $D067
FACC5 = $00cb
		ON_ERROR:
		.(
			cmp #Token_ERROR
			beq ok
			jmp GetByteExpr+3

		ok:
			jsr CharGet
			cmp #Token_CONT
			beq cont
			cmp #Token_STOP
			beq break

			; Rétabli ON ERROR STOP au cas où...
			lda #$00
			sta err_line+1

			lda #Token_GOTO
			jsr EvalAcc
			jsr GetWord
			jsr FindLine
			bcc error8
			; Sauvegarde l'adresse de début de la ligne
			; de façon à pouvoir faire un GOTO sans devoir
			; chercher à chaque l'adresse de la ligne
			lda FACC5+3
			sbc #$01
			sta err_line
			lda FACC5+4
			sbc #$00
			sta err_line+1

			; Oublie l'adresse de retour vers ON
			; En principe ACC ne peut pas être à 0
			bne fin
;		fin:
;			rts

		cont:
			; err_line := $fe $ff
			ldx #$fe
			.byte $2c
		break:
			; err_line := $ff $00
			ldx #$ff
			stx err_line
			inx
		fin2:
			stx err_line+1
			pla
			pla
			jmp CharGet

		error8:
			jmp UndefdStatementError

		&PrintErrorX2:
			ldy err_line+1
			; ON ERROR STOP?
			beq error
			iny
			; ON ERROR CONT?
			beq skip
			; ON ERROR GOTO
			dey
			sty TXTPTR+1
			lda err_line
			sta TXTPTR
		fin:
			; Oublie l'adresse de retour vers PrintErrorX
			pla
			pla
			jmp SetBasicVar
		skip:
			; Oublie l'adresse de retour vers PrintErrorX
			; et saute à l'instruction suivante
			pla
			pla
			jsr SetBasicVar
			jmp FindEndOfStatement

		error:
			; Retour à PrintErrorX
			;cpx #$13
			;bcs skip
			jmp SetScreen
		.)

#endif

CharSet_end:

#if * > KeyCodeTab
#print "*** ERROR Charset too long"
#endif
;			.dsb KeyCodeTab-*,$ff

		; #ifdef JOYSTICK_DRIVER
;#endif
	; #ifdef JOYSTICK_READKBDCOL
;#endif

; #ifdef NO_CHARSET
#endif
;---------------------------------------------------------------------------
;			Personnalisation de la ROM
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	; Message de Copyright
	;---------------------------------------------------------------------------
	new_patch($ed96,LEDC4)
		; Maxi 44 octets
		Copyright:
			.byte COPYRIGHT_MSG

#if * > $EDC3
#print "*** ERROR 'COPYRIGHT_MSG' too long"
#endif

			.dsb $EDC4-*,$00
	LEDC4:


	;---------------------------------------------------------------------------
	; Couleur Papier/Encre au boot
	;---------------------------------------------------------------------------
	new_patchl($f914,10)

			lda	#DEFAULT_INK
			sta	INK_VAL
			lda	#$10+DEFAULT_PAPER
			sta	PAPER_VAL


;---------------------------------------------------------------------------
;			Modifications ROM 1.22
;---------------------------------------------------------------------------
#ifdef ROM_122
#echo "Patchs ROM 1.2x activés:"

	;---------------------------------------------------------------------------
	; Ajoute l'instruction RESTORE n
	;---------------------------------------------------------------------------
#echo "    RESTORE n (_PATCHRESTN)"
	new_patchl($c03a,2)
			.word _PATCHRESTN-1

	;---------------------------------------------------------------------------
	; Correction bug: dé-sélectionne l'imprimante avant le message 'Ready'
	;---------------------------------------------------------------------------
#echo "    Ready (_PATCHREADY)"
	new_patchl(BackToBASIC,3)
			; lsr IF_Flag
			jsr _PATCHREADY

	;---------------------------------------------------------------------------
	; Autorise la saisie en minuscules
	;---------------------------------------------------------------------------
#echo "    minuscules (_PATCH2UP)"
	new_patchl($c638,3)
			jsr _PATCH2UP

	;---------------------------------------------------------------------------
	; Correction bug REM: aps d'encodage des instructions au delà du '
	;---------------------------------------------------------------------------
#echo "    REM (_PATCHREM)"
	new_patchl($c65c,3)
			jsr _PATCHREM

	;---------------------------------------------------------------------------
	; Correction bug IF/THEN/ELSE
	;
	;	IF test THEN instr1:instr2 ELSE instr3:instr4
	;	Exécute instr1 & instr2 si test est vrai et instr3 & instr4 sinon
	; BUG: exécute instr4 dans tous les cas
	;
	; Ce patch libère $CAB1->$CABE inclus (14 octets)
	;---------------------------------------------------------------------------
#echo "    IF/THEN/ELSE"
	new_patchl($c93c,3)
			; jsr LCAB1
			jsr	REM

	;---------------------------------------------------------------------------
	; Correction bug initialisation de htab ($30) lors d'un PRINT @
	;---------------------------------------------------------------------------
#echo "    PRINT @"
	new_patchl($cc8d,9)
			; txa
			; sta SCREENY
			; jsr RowCalc
			; lda $1f
			sta CURPOS
			txa
			sta SCREENY
			jsr RowCalc

	;---------------------------------------------------------------------------
	; Correction bug: initialise bien hpos à 0 quand un CR est envoyé à
	; l'imprimante.
	; Remarque: Cf _PATCHTAB
	;---------------------------------------------------------------------------
#echo "    Bug TAB
	new_patchl($ccc7,3)
			; jsr LCC0B	; -> rts
			jsr _PATCHTAB

	;---------------------------------------------------------------------------
	; Utilisation de VDU_hook à la place de l'appel direct de Char2Scr
	; dans la routine en $CCFB
	;---------------------------------------------------------------------------
#echo "    XVDU"
	new_patchl($ccfe,3)
			; jsr Char2Scr
			jsr VDU_hook


	;---------------------------------------------------------------------------
	; Correction bug POS(): renvoit la bonne valeur même pour l'imprimante
	;---------------------------------------------------------------------------
#echo "    POS()"
	new_patchl(POS+3,9)
			ldy SCREENX
			txa
			beq $d4b6
			jsr _PATCHPOS

	;---------------------------------------------------------------------------
	; Optimisation de l'instruction WAIT
	;---------------------------------------------------------------------------
#echo "    Optimsation WAIT"
	new_patch(WAIT,LD967)
		-WAIT:
			; jsr GetExpr
			; jsr FP2Int
			; ldy INTTMP
			; lda INTTMP+1
			; lda #$02
			; jmp Delay
			jsr GetWord
			tax
			lda #$02
			jmp Delay

	;---------------------------------------------------------------------------
	; Correction bug 'Ready': désactive l'imprimante AVANT l'affichage de Ready
	;---------------------------------------------------------------------------
#iflused _PATCHREADY
#echo "        _PATCHREADY"
		_PATCHREADY:
			lsr IF_flag
			jmp SetScreen
#else
			.dsb 6, $ea
#endif
		LD967:

	;---------------------------------------------------------------------------
	; Optimisation TAN
	;---------------------------------------------------------------------------
#echo "    Optimisation TAN"
	new_patchl($e3e9,3)
			; jsr LE388	; -> jmp LDEAD
			jsr MOVMF

	;---------------------------------------------------------------------------
	; Correction bug: la fermeture du relais pour le magnétophone génère aussi
	; un STROBE pour l'imprimante (routine SetupTape)
	;---------------------------------------------------------------------------
#echo "    SetupTape (STROBE)"
	new_patchl($e77c,2)
			; lda #$40
			lda #$50

	;---------------------------------------------------------------------------
	; Correction instruction POINT(x,y) pour n'accepter qu'ne valeur numérique
	; pour x et y
	;---------------------------------------------------------------------------
#echo "    POINT(x,y)"
	new_patchl(POINT+3,3)
			; jsr EvalExpr
			jsr GetExpr

	new_patchl(POINT+34,3)
			; jsr EvalExpr
			jsr GetExpr

	;---------------------------------------------------------------------------
	; Optimisation routine GetChar: gain 9 cycles et 1 octet ($F2)
	;---------------------------------------------------------------------------
#echo "    Optimisation GetChar"
	new_patchl(LEC9C+13,3)
			; jsr LECB9
			; rts
			jmp	LECB9

	;---------------------------------------------------------------------------
	; Correction bug hpos: ne peut être mis si on utilise une configuration par
	; défaut du joystick (utilise la même zone rom)
	; Ecrase également la valeur d'init de RND
	;
	; Peut être déplacé en $FBB5 si optimisation de SOUND
	; ou en $CAB1 si correction du bug IF/THEN/ELSE
	;---------------------------------------------------------------------------
#iflused _PATCHTAB
#echo "        _PATCHTAB"
;	new_patchl(LEC9C+17,10)
	new_patchl($cab1,10)
		_PATCHTAB:
			bit PRINTERFLG
			bpl LECB6
			lda #$00
			sta CURPOS
		LECB6:	rts
#endif

	;---------------------------------------------------------------------------
	; Amélioration DRAW
	;
	; Remarque: Utilise des octets supplémentaires en page 0 ($06-$0f)
	;---------------------------------------------------------------------------
#echo "    Améliorations DRAW"
	new_patch((DrawLine+4),LEFB1)

		LEEFC:
		.(
			; draw vectors
			Ivect = $06;
			Jvect = $09;

			; draw variables
			intlen = $0D	; length of segments, int part
			fraclen = $0C	; length of segments, fract part
			lcount = $0F	; line count
			fracsum = $0E	; cumulative sum of fractionary parts

			_HRSPRVPIX = $f0b2
			_HRSPRVLINE = $f095
			_0CDIV200 = $efc8
			_ROUND0C = $effa
			_HRSNXTPIX = $f0a1
			_HRSNXTLINE = $f089

			; *= $EEFC	; location in Oric ROM
			LDX #$06
		_drwinivect
			LDA _drwvect-1,X
			STA Ivect-1,X
			DEX
			BNE _drwinivect
			BIT PARAMS+2	; test sign of dx
			BPL _testy	; if positive, continue
			LDA #$FF	; if negative
			EOR PARAMS+1
			TAX
			INX
			STX PARAMS+1	; dx.b=-dx
			LDA #<_HRSPRVPIX; change Ivect (low byte only)
			STA Ivect+1
		_testy
			BIT PARAMS+4	; test sign of dy
			BPL _testxy
			LDA #$FF
			EOR PARAMS+3
			TAX
			INX
			STX PARAMS+3	; dy.b=-dy
			LDA #<_HRSPRVLINE; change Jvect (low byte only)
			STA Jvect+1
		_testxy
			LDX PARAMS+1	; X=dx
			LDY PARAMS+3	; Y=dy
			CPY PARAMS+1	; compare dy and dx
			BCC _divxy		; if dy < dx, jump
			TXA
			PHA
			LDA Ivect+1		; else, swap Ivect & Jvect (low bytes)
			LDX Jvect+1
			STX Ivect+1
			STA Jvect+1
			TYA		; and swap dx and dy
			TAX
			PLA
			TAY
		_divxy
			CPX #$00
			BEQ _drwend		; if dx = 0, end (nothing to draw !)
			LDA #$00
			STA $0C
			STA $201
			INX
			STX $0D		; $0C.w = 256*(dx+1)
			INY
			STY $200		; $200.w = dy+1
			JSR _0CDIV200	; $0C.w=int((dx+1)/(dy+1))
			JSR _ROUND0C
			STY lcount		; line counter = dy+1
			LDX intlen		; X=normal length of segments
			CLC
			LDA #$80		; A=0.5: add 1/2 a pixel at start
			ADC fraclen
			STA fracsum
			BCC _1stsegm	; if fract. part < 0.5, continue
			INX		; if fract. part >=0.5 => add 1 point to 1st segment
		_1stsegm			; draw first segment
			DEX		; => substract one pixel (from previous CURSET)
			BEQ _nextsegm	; if 0 pix, jump to next segment
		_nextpix
			JSR Ivect
			JSR _DRWSETPIX	; set pixel (modify A and Y!)
			DEX
			BNE _nextpix
		_nextsegm
			LDX intlen		; re-init segment length
			CLC
			LDA fracsum		; cumulate fract. parts
			ADC fraclen
			STA fracsum
			BCC _stdsegm	; if no carry, standard segment
			INX		; else, add 1 point to current segment
		_stdsegm
			DEC lcount
			BEQ _drwend		; no more line ? => end
			JSR Jvect		; goto next line
			JMP _nextpix
		_drwend
			RTS

		_drwvect
			JMP _HRSNXTPIX	; draw vector init table
			JMP _HRSNXTLINE
		;--------------------------------------------------------------------
		; Name:		_DIVA0D
		; Function:	divide A/$0D (quick 8 bit divide)
		;
		; Input:	- A = dividend
		; 	- $0D = divider
		;
		; Output:	- A = result
		;         - $0E = remainder
		;	- $0C = copy of the result
		;
		; Side effects:	- $0C is affected: contains a copy of the result
		;		- X and Y remain unchanged
		;
		;--------------------------------------------------------------------
		; div variables
		remain = $0E
		result = $0C
		divid = $0D

		&_DIVA0D:
			STA result		; result = A
			TXA
			PHA		; save X
			LDA #$00		; remainder = 0
			LDX #$08		; X=#$08, loop 8 times (8 bit word)
		_divloop
			ASL result		; result * 2
			ROL		; remainder*2 + carry from N
			CMP divid
			BCC _divcont1	; continue if rem.<divider
			SBC divid		; else remainder = remainder-divider
					; (C=1 after BCC!)
			INC result		; result++: add 1 to result
		_divcont1
			DEX	 	; next bit
			BNE _divloop	; loop
			STA remain		; save remainder in $0E
			PLA
			TAX		; restore X
			LDA result		; A=result
		LEFB0	RTS
		.)
	LEFB1:

	;---------------------------------------------------------------------------
	; Espace inutilisé: LEFB1 -> LEFC7 inclus (23 octets)
	;---------------------------------------------------------------------------
	;LEFC7:

	;---------------------------------------------------------------------------
	; Espace inutilisé: LF016 -> LF01B inclus (6 octets)
	;---------------------------------------------------------------------------

	new_patchl($f01c,8)
		_DRWSETPIX:	; set current pixel when drawing
		.(
			_DRWPAT = $0214
			ASL _DRWPAT		; get bit#7 in C, and clear bit#0
			BCC $F03C		; if 0, end
			INC _DRWPAT		; else set pattern bit#0 to 1 (=C)
					; ... and set the pixel
		.)
	new_patchl($f05a,12)
		.(
			divid = $0D
			LDA #$06
			STA divid
			TXA
			JSR _DIVA0D	; A=X/6 : quick div
			CLC
			JMP $F06E
		.)

	new_patchl($f400,3)
			JSR _DRWSETPIX	; call new _DRWSETPIX !

	;---------------------------------------------------------------------------
	; Correction bug
	;---------------------------------------------------------------------------
#echo "    Bug arrondir quotient ($EFFA...)"
	new_patchl(LEFFA,7)
			; pha
			; asl $0200		; $0200.w x2
			; rol $0201
			pha
			lsr $0201		; $0200.w /2
			ror $0200

	;---------------------------------------------------------------------------
	; Optimisation routine ReadKbdCol: gain 19 cycles et 2 octet ($F576-$F577)
	;---------------------------------------------------------------------------
#echo "    Optimisation ReadKbdCol"
	new_patch((ReadKbdCol+18),LF578)
			;ldy	#$04
			;dey
			;bne	*-3
			jmp	LF578
			nop
			nop
		LF578:

;#ifdef ROM_122
#endif

	;---------------------------------------------------------------------------
	; Déplacement du CLI APRES l'initialisation des vecteurs en ram
	;---------------------------------------------------------------------------
#echo "    Bug: initialisaton des vecteurs"
	new_patchl(Reset+3,13)
			;ldx	#$FF
			;txs
			;cli
			cld
			ldx	#$12
		LF896:
			lda	$F87C,x
			sta	VDU_hook,x                      ; F899 9D 38 02
			dex
			bpl	LF896
			cli			; Correction
			;lda	#$20
			;sta	$024E
			;lda	#$04
			;sta	$024F
			;jsr	RamTest
			;jsr	LF8B8

	;---------------------------------------------------------------------------
	; Minuscules
	; /!\ Activer  _PATCH2UP sinon ça ne sert à rien
	;---------------------------------------------------------------------------
#ifdef ROM_122
#echo "    minuscules par défaut"
	new_patchl($f8c8,2)
			; lda #$ff		; MAJUSCULES par défaut
			lda #$7f		; minuscules par défaut

	;---------------------------------------------------------------------------
	; Correction bug: supprime la génération d'un STROBE lors de l'initialisation
	; du VIA
	;---------------------------------------------------------------------------
#echo "    ResetVIA (STROBE)"
	new_patchl(ResetVIA,15)
			; lda     #$FF                            ; F9AA A9 FF
			; sta     VIA_DDRA                        ; F9AC 8D 03 03
			; lda     #$F7                            ; F9AF A9 F7
			; sta     VIA_DDRB                        ; F9B1 8D 02 03
			; lda     #$B7                            ; F9B4 A9 B7
			; sta     VIA                             ; F9B6 8D 00 03
			lda     #$FF
			sta     VIA_DDRA
			lda     #$B7
			sta     VIA
			lda     #$F7
			sta     VIA_DDRB

	;---------------------------------------------------------------------------
	; Optimisation instruction SOUND (pour libérer de la place pour les autres
	; patches)
	;---------------------------------------------------------------------------
#echo "    Optimisation SOUND"
	new_patch(SOUND,LFB7E)
		-SOUND:		; This function has been optimized in order to free
				; as much memory as possible to put my patches
			LDX PARAM2	; X = sound period (LSB)
			LDY PARAM1	; Y = channel# (c)
			BEQ LFB7A	; if null, error
			CPY #$04	; noise channel (c>3) ?
			BCS LFB6E	; yes: jump
			DEY		; Y = c-1
			TYA
			PHA		; push c-1
			ASL		; x2 => A=period register of channel (LSB)
			PHA 		; push
			JSR $F590	; write X in reg.A of W8912
			PLA		; restore A
			CLC
			ADC #$01	; +1 => A=next register
			LDX PARAM2+1	; X = MSB of period (4 bits used)
		LFB5B:	JSR $F590	; write X in reg. A
			LDA PARAM3	; A = volume
			AND #$0F	; mod.16
			BNE LFB67
			LDA #$10	; if 0, then 16 (envelop)
		LFB67:	TAX		; into X
			PLA		; restore A (A=c-1)
			ORA #$08	; +8 => A=volume register
			JMP $F590	; write X in reg.A and return
		LFB6E:	CPY #$07	; if channel >6
			BCS LFB7A	; branch to error
			TYA		; A=c
			AND #$FB	; -4 =>A=c-1 with no noise
			PHA 		; push c-1
			LDA #$06	; A=6, noise period reg. (5 bits sign.)
			BNE LFB5B	; in fact a BRA(!):set period & vol.
		LFB7A:	INC SOUNDHIRES_ERR	; indicate error
			RTS 		; return (and WIN 82 extra FREE bytes!)
		LFB7E:

	;---------------------------------------------------------------------------
	; Correction bug REM: ne code pas les instructions au delà de '
	; (Inclus les 5 patches suivants)
	;
	; /!\ Ne peut être activer que si le patch SOUND a été également activé
	;---------------------------------------------------------------------------
#iflused _PATCHREM
#echo "        _PATCHREM"
	; new_patch(LFB7E,LFBB5)
	new_patch(LFB7E,LFBCF)
		_PATCHREM:		; patch not to code remarks after " ' "
					; (correct a BUG of ROM v1.1)
			SEC		; set Z=1 if current token is REM or "'"
			SBC #$63	; = REM ?
			BEQ LFB85	; yes, Z=1, return
			SBC #$8A	; = "'" ?
		LFB85:	RTS 		; return
#endif

	;---------------------------------------------------------------------------
	; Autorise la saisie en MAJUSCULES et en minuscules
	; /?\ Utile?
	;---------------------------------------------------------------------------
#iflused _PATCH2UP
#echo "        _PATCH2UP"
		_PATCH2UP:		; conv.lower cases to upper
					; =>allows typing commands of BASIC & DOS in lower cases
			LDA $00,X	; A=current char
			CMP #$61	; 'a'
			BCC LFB94	; if <'a', do nothing
			CMP #$7B	; 'z'+1
			BCS LFB95	; if >'z', do nothing
			SBC #$1F	; else substract $20 ($20=$1F + carry!!)
			STA $00,X	; store converted char
		LFB94:	SEC		; set C=1 for compatibility
		LFB95:	RTS		; return (always with C=1)
#endif

	;---------------------------------------------------------------------------
	; Correction bug POS(): renvoit la bonne valeur même pour l'imprimante
	;---------------------------------------------------------------------------
#iflused _PATCHPOS
#echo "        _PATCHPOS"
		_PATCHPOS:		; get the correct value for POS if printer is ON
					; (BUG v1.1)
			LDY LPRPOS	; get the correct horiz.pos value
			BIT PRINTERFLG	; for compatibility...
			RTS		; return
#endif

	;---------------------------------------------------------------------------
	; Correction bug REM: ne code pas les instructions au delà de REM
	;---------------------------------------------------------------------------
#iflused _PATCHRESTN
#echo "        _PATCHRESTN"
		_PATCHRESTN:		; offers a RESTORE n to your ATMOS!
			BNE LFBA2	; a parameter after RESTORE ?
			JMP RESTORE	; no: jump to classic RESTORE
		LFBA2:	JSR GetWord	; yes: get num parameter
			JSR FindLine	; find that line (or next available)
			LDA $CE	; make AY point to it
			LDY $CF
			SEC
			SBC #$01	; -1 to the LSB
			JMP RESTORE+7	; finish the substract (MSB!!),
					; and update RESTORE pointer
			; LFBB2 -> LFBCF: disponible
		LFBB2:
			;nop
			;nop
			;nop
		LFBB5:
#endif

	;---------------------------------------------------------------------------
	; Si optimisation de SOUND, $FBB5 -> $FBCF: libre (27 octets)
	;---------------------------------------------------------------------------
#ifdef ADD_ERROR
#echo "Add experimental ERROR instruction"
		ERROR:
		.(
			; 19 Octets
			jsr GetByteExpr+3
			txa
			beq Skip
			cpx #$14
			bcs UserError
			dex
			lda ErrTbl,x
		OnError:
			tax
			jmp PrintErrorX

		UserError:
			;jmp SyntaxError
			lda #$15
			ldy err_line+1
			; ON ERROR STOP?
			beq OnError
			iny
			; ON ERROR CONT?
			;beq Skip
			;jmp $c496
			bne OnError+1
		Skip:
			rts
		.)
#endif


#if * > $fbcf
#print "*** ERROR PATCH SOUND too long"
#endif

	LFBCF:
; #ifdef ROM_122
#endif

#ifdef ADD_ONERROR
	;---------------------------------------------------------------------------
	; Entréé:
	;	X: Code erreur pour PrintErreurX
	;
	; Sortie:
	;	A: Code erreur traduit
	;---------------------------------------------------------------------------
	new_patch($efb1,LEFC7)
		BasicErrToEn:
		.(
			txa
			ldy #$00
		loop:
			iny
			cpy #$14
			beq fin
			cmp ErrTbl-1,y
			bne loop
			tya
		fin:
			;tax
			rts
		.)

		VarTbl:
			; 4 octets
			.byte "EN","EL"

		LEFC7:
#if * > $efc7
#print "*** ERROR PATCH ON ERROR (EFB1) too long"
#endif
#endif

;---------------------------------------------------------------------------
;			Modifications pour Orix
;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	; Pointe vers le message de Copyright
	; Pour Telestrat (signature de la banque)
	;
	; /!\ ATTENTION: Frelon, Hellion, Harrier,... testent $fff9 pour savoir si il s'agit
	;                d'un Atmos ($01) ou non
	;---------------------------------------------------------------------------
#ifdef ORIX_SIGNATURE
		new_patchl($fff8,2)
				.word Copyright
#endif

	;---------------------------------------------------------------------------
	; Modification pour la commande 'bank' de Orix
	; qui fait un 'jmp $c000' et non un 'jmp ($fffc)
	;---------------------------------------------------------------------------
		new_patchl($c000,3)
				jmp	Reset


;---------------------------------------------------------------------------
;Commande de retour à Orix
;---------------------------------------------------------------------------
;#ifdef BASIC_LET_IS_QUIT
;	;---------------------------------------------------------------------------
;	; Remplace LET par OUT
;	;---------------------------------------------------------------------------
;	new_patchl($c149,3)
;			.byte "OU","T"+$80
;
;	;---------------------------------------------------------------------------
;	; Modifie adresses d'exécution LET -> QUIT
;	;---------------------------------------------------------------------------
;	new_patchl($c032,2)
;			.word QUIT-1
;#endif

#ifdef BASIC_QUIT
	;---------------------------------------------------------------------------
	; Remplace TRON par QUIT
	;---------------------------------------------------------------------------
	new_patchl($c0fc,4)
			.byte "QUI","T"+$80

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TRON -> QUIT
	;---------------------------------------------------------------------------
	new_patchl($c00e,2)
			.word QUIT-1

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TROFF -> QUIT
	; au cas ou...
	;---------------------------------------------------------------------------
	new_patchl($c010,2)
			.word QUIT-1

	;---------------------------------------------------------------------------
	; 9 octets disponibles de $CD16 à $CD1E inclus
	; Peut être transféré vers _FileNotFound ou MICROSOFT!
	;---------------------------------------------------------------------------
	new_patch(TRON, LCD1F)
		NotFound:
			; jsr SyncTape
			pla
			pla
			; jsr TapeSync
			pla
			pla
			; php
			pla

			jmp _FileNotFound
			nop
		LCD1F
#endif

;---------------------------------------------------------------------------
;			Ajout Driver Joystick Telestrat
;---------------------------------------------------------------------------
#ifdef JOYSTICK_DRIVER
	;---------------------------------------------------------------------------
	; Patch pour la routine par défaut en $02B (Kbd_hook)
	;---------------------------------------------------------------------------
	;new_patchl($f87f,3)
	;	jmp CheckJoystick

	;---------------------------------------------------------------------------
	; Patch pour de la routine ReadKbdCol
	;---------------------------------------------------------------------------
#echo "Joystick driver: ReadKbdCol"

	; Patch de la routine CheckKbd
	new_patchl(ReadKbd+5,3)
		jsr CheckJoystick

#ifdef JOYSTICK_EXTERNAL_CONF
#echo "Joystick driver: Keep external config (no RND init)"

	; Permet de ne pas écraser une conf qui aurait été chargée avant le boot
	; de la rom par la commande basic11 en ne copiant que CharGet en RAM
	; /!\ Avec ce patch, la valeur initiale de RND n'est pas copiée en RAM
	;
	; Valeur initiale de RND: 0.811635171
	;.byte   $80                             ; ECB4 80
	;.byte   $4F                             ; ECB5 4F
	;.byte   $C7                             ; ECB6 C7
	;.byte   $52                             ; ECB7 52
	;.byte   $58                             ; ECB8 58 (non copié par ColdStart)

	new_patchl(StartBASIC+45,2)
		ldx #$11

#endif

#ifdef JOYSTICK_DEFAULT_CONF
#echo "Joystick driver: Add default configuration"

	; Ajoute une configuration par défaut
	; Copiée automatiquement au démarrage par la Coldstart en $ECFB
	; qui copie Charget et RND en RAM
	new_patchl(LEC9C+17,7)
		.byte $AF	; Fire 2 => [Enter]
		.byte $A9	; Fire 3 => [Esc]
		.byte $B4	; Down   => [Down_arrow]
		.byte $BC	; Right  => [Right_arrow]
		.byte $AC	; Left   => [Left_arrow]
		.byte $84	; Fire   => [Space]
		.byte $9C	; Up     => [Up_arrow]
#endif

#endif

;---------------------------------------------------------------------------
;		Ajout chargement dynamique du jeu de caractères
;---------------------------------------------------------------------------
#ifdef NO_CHARSET
	; Patche de la routine d'init pour ne pas
	; copier le jeu de caractères depuis la rom vers la ram.
	; On suppose que l'Oric a déjà démarré et que le jeu est en place
	; Initialise le CH376 au lieu d copier le jeu ROM->RAM
	new_patchl(LF8B8+26,3)
	;jsr InitCH376
	jsr load_charset
#endif

;---------------------------------------------------------------------------
;		Ajout chargement dynamique du jeu de caractères
;---------------------------------------------------------------------------
#ifdef LOAD_CHARSET
	; Patche de la routine d'init pour ne pas
	; copier le jeu de caractères depuis la rom vers la ram.
	; On suppose que l'Oric a déjà démarré et que le jeu est en place
	; Charge un jeu decaractères depuis la carte SD/USB
	new_patchl(LF8B8+26,3)
;#ifdef FORCE_ROOT_DIR
	jsr load_charset
;#else
;	jsr load_charset2
;#endif

#endif

;---------------------------------------------------------------------------
;		Ajout instruction DEF CHAR
;---------------------------------------------------------------------------
#ifdef ADD_DEF_CHAR
	new_patchl(DEF,3)
	jmp DEF_CHAR
#endif

;---------------------------------------------------------------------------
;		Ajout instruction ERROR
;---------------------------------------------------------------------------
#ifdef ADD_ERROR
	;---------------------------------------------------------------------------
	; Remplace TROFF par ERROR
	;---------------------------------------------------------------------------
	new_patchl($c100,5)
			.byte "ERRO","R"+$80

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TROFF -> QUIT
	; au cas ou...
	;---------------------------------------------------------------------------
	new_patchl($c010,2)
			.word ERROR-1

#endif

;---------------------------------------------------------------------------
;		Ajout instruction ON ERROR STOP|CONT|GOTO
;---------------------------------------------------------------------------
#ifdef ADD_ONERROR
	;---------------------------------------------------------------------------
	; Patch de l'instruction ON x GOTO/GOSUB
	;---------------------------------------------------------------------------
	new_patchl($cac2,3)
			jsr ON_ERROR


	;---------------------------------------------------------------------------
	; Patch de la routine PrintErrorX
	;---------------------------------------------------------------------------
	new_patchl(PrintErrorX,3)
			jsr PrintErrorX2
#endif
