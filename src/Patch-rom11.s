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

	;---------------------------------------------------------------------------
	;				Commun
	;---------------------------------------------------------------------------
#define NO_CHARSET
#define ORIX_CLI
#define LOAD_CHARSET
#define ORIX_SIGNATURE
#define FORCE_ROOT_DIR
#undef MULTIPART_SAVE

#define ROM_122

	;---------------------------------------------------------------------------
	;			Configuration "Hobbit"
	;---------------------------------------------------------------------------
#ifdef HOBBIT
#undef JOYSTICK_DRIVER
#undef EXPERIMENTAL
#undef LOAD_CHARSET
#define ORIX_SIGNATURE
#undef ROM_122
#undef MULTIPART_SAVE
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
#endif

	;---------------------------------------------------------------------------
	;			Chargement du jeu de caractères
	;---------------------------------------------------------------------------
#ifdef NO_CHARSET
#ifdef LOAD_CHARSET
#ifndef DEFAULT_CHARSET
#define DEFAULT_CHARSET "/USR/SHARE/FONTS/DEFAULT.CHS"
#endif
#echo "Default charset: DEFAULT_CHARSET"
#endif
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

HIMEM_PTR       = $a6

TXTPTR          = $e9
JOY_TBL         = $f5

;---------------------------------------------------------------------------
;
;			Variables en page 2
;
;---------------------------------------------------------------------------
fTextMode	= $021f			; 0:TEXT, 1:HIRES (pour DEF CHAR)

RAMSIZEFLAG     = $0220
RAMFAULT        = $0260

TAPE_SPEED	= $024d			; 0: Fast, 'S': Slow (mis à jour par GetTapeParams)


PAPER_VAL       = $026b
INK_VAL         = $026c

PROGNAME        = $027f

HIMEM_MAX       = $02c1

PROGSTART       = $02a9
PROGEND         = $02ab
PROGTYPE        = $02ae

;---------------------------------------------------------------------------
;
;			Spécifique Multi-Part
; Non utilisées par le BASIC
;---------------------------------------------------------------------------
OPENFFLAG	= $020f			; Flag pour détecter si un fichier .tap a été ouvert (0: Fichier ouvert, 1: Fichier fermé)
MULTIPFLAG	= $0267			; Flag pour Multipart (0: Fichier ouvert, 1: GetTapeParams a été appelé)

;---------------------------------------------------------------------------
;
;			Spécifique Telestrat
;
;---------------------------------------------------------------------------
VIA2_IORB    = $0320
VIA2_DDRA    = $0323
VIA2_IORA    = $032f
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
DEF		= $D4BA
DEF_USR		= $D4BE
DEF_FN		= $D4DF
GetByteExpr	= $d8c5

TapeSync        = $e4ac
GetTapeData     = $e4e0
GetTapeParams   = $e7b2
GetStoreRecallParams = $ea57

ClrTapeStatus   = $e5f5
WriteFileHeader = $e607
PutTapeByte     = $e65e
WriteLeader     = $e75a
GetTapeByte     = $e6c9
SyncTape        = $e735
SetupTape       = $e76a
CheckFoundName  = $e790

CLOAD           = $e85b
CSAVE           = $e909
STORE           = $e987
RECALL          = $e9d1
LE93D           = $e93d
CheckKbd        = $eb78

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
			jmp OpenTapeWrite

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
		; 9 Octets
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
			jsr	WriteLeader
			jmp	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
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
			bne	fin_erreur			; TODO: /!\ Test par rapport à INT_SUCCESS mais SetByteWrite renvoie INT_DISK_WRITE si on écrit un seul octet

                        lda     #CH376_CMD_WR_REQ_DATA		; WriteRqData
                        sta     CH376_COMMAND
			lda	CH376_DATA			; Nombre de caractère à écrire
                        lda     $2f
                        sta     CH376_DATA			; Caractère écrit
			jsr     ByteWrGo			; Nécessaire en réel, sinon le CH376 boucle sur son buffer
			clc					; Indique pas d'erreur de lecture
			.byte $24
		fin_erreur:
			sec
                        rts
		.)

#if 0
; 38 octets
		-PutTapeData:
		.(
			jsr	SetByteReadWrite+2
			bne	_PutTapeData_error

			lda PROGSTART
			ldy PROGSTART+1
			sta INTTMP
			sty INTTMP+1

			; Boucle de chargement de la fonte (27 octets)
		loop:
			; On peut supprimer les lda/ldy si on supprime les sta/sty de ReadUSBData
			;lda INTTMP
			;ldy INTTMP+1
			jsr WriteUSBData

			;clc
			;bcs WriteNextChunk
			cpy #$00		; Nombre d'octets lus == 0?
			beq fin

			; Ajuste le pointeur
			clc
			tya
			adc INTTMP
			sta INTTMP
			bcc *+4
			inc INTTMP+1

		ReadNextChunk:
			jsr ByteWrGo
			beq loop

		fin:
		_GetTapeData_error:
			rts
		.)

; 22 octets
		WriteUSBData:
		.(
			; On peut supprimer les sta/sty si on supprime les lda/ldy de load_data
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


		; Inutile pour le moment
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

	; Actuellement: $E6C3 si MULTIPART_SAVE
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


	new_patch(GetTapeData,LE50A)
		;---------------------------------------------------------------------------
		; _GetTapeData (43 octets / 43 octets pour la version BASIC 1.1)
		;---------------------------------------------------------------------------
		; Charge un programme en mémoire
		; Doit être appelé APRES SetByteRead
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
		;	-
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

			; Boucle de chargement de la fonte (27 octets)
		loop:
			; On peut supprimer les lda/ldy si on supprime les sta/sty de ReadUSBData
			;lda INTTMP
			;ldy INTTMP+1
			jsr ReadUSBData

			;clc
			;bcs ReadNextChunk
			cpy #$00		; Nombre d'octets lus == 0?
			beq fin

			; Ajuste le pointeur
			clc
			tya
			adc INTTMP
			sta INTTMP
			bcc *+4
			inc INTTMP+1

		ReadNextChunk:
			jsr ByteRdGo
			beq loop

		fin:
		_GetTapeData_error:
			rts
		.)

	; Actuellement: $E506
	LE50A:

;#print *
#if * > $e50a
#print "*** ERROR GetTapeData too long"
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
		; 35 Octets + 5 en ZZD001 (ou 45+5 si FORE_UPPERCASE)
		;---------------------------------------------------------------------------
			; SetFilename2: 38 octets
		SetFilename2:
		.(
			;sta PTR_READ_DEST
			;sty PTR_READ_DEST+1
			lda	#CH376_CMD_SET_FILE_NAME
			sta	CH376_COMMAND
#ifdef FORCE_ROOT_DIR
			sta	CH376_DATA		; Pour ouverture de '/'
#endif
			ldy	#$ff
		ZZ0003:
			iny
			;lda (PTR_READ_DEST),y
			lda	PROGNAME,y
			beq	ZZ0004

			sta	CH376_DATA
			bne	ZZ0003

		ZZ0004:
			sty	$2f			; Sauvegarde la longueur (utilisée par CSAVE)
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
		; 6 Octets
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
	; Actuellement: $E72C si not defined(MULTIPART_SAVE)
	; Actuellement: $E721 si defined(MULTIPART_SAVE)
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


	new_patchl(CheckFoundName+5,22)
		;---------------------------------------------------------------------------
		; ReadUSBData(22 octets)
		;---------------------------------------------------------------------------
		; Charge un bloc en mémoire
		;
		; Entree:
		;	AY: Adresse de chargement
		;
		; Sortie:
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

		ZZZ002:
		        rts
		.)

	; Actuellement: $E7AB
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
		; load_charset (36 octets)
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
			lda #<($b500+$300)
			ldy #<($b500+$300)
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
			ldx	#CH376_USB_MODE
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
;	Down:	$f5
;	Right:	$f6
;	Left:	$f7
;	Fire:	$f8
;	UP:	$f9
;
; Touches:
;	[SPACE]: $84
;	[ENTER]: $AF
;	[DOWN]:  $B4
;	[RIGHT]: $BC
;	[LEFT]: $AC
;	[UP]  : $9C
;


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
		; open_fqn (107 octets -3)
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
			lda INTTMP+1
			cmp INTTMP
			;bcc  *+5
			;jmp ZZ0006
			bcs ZZ0006
										; DO;
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
			; IF &PTR1[PTR1+3] = '/' THEN
										; .Y = PTR1+3;
			ldy INTTMP+1
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
			lda INTTMP+1
			cmp INTTMP
			bcs ZZ0008

			lda #$2F
			sta CH376_COMMAND
		ZZ0008:
										; .Y = PTR1+3;
			ldy INTTMP+1
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
		; SetByteReadWrite (33 octets)
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
			ldx	#CH376_USB_MODE
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
#endif
		;---------------------------------------------------------------------------
		; ReadUSBData3 (29 octets)
		;---------------------------------------------------------------------------
		; Lit un caractère depuis la K7
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	A: Caractère lu
		;	$2f: Caractère lu
		;
		; Modifie:
		;	$2f: Caractère lu
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	-
		;---------------------------------------------------------------------------
		; $fd4e: ':' -> '='
                ReadUSBData3:
                .(
			; On lit 1 caractère
			lda	#$01
			ldy	#$00
			jsr	SetByteRead
			bne	fin_erreur

                        lda     #CH376_CMD_RD_USB_DATA0
                        sta     CH376_COMMAND
			lda	CH376_DATA			; Nombre de caractère à lire
                        lda     CH376_DATA			; Caractère lu
                        sta     $2f
			jsr     ByteRdGo			; Nécessaire en réel, sinon le CH376 boucle sur son buffer
			clc					; Indique pas d'erreur de lecture
			.byte $24
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
		; $fda7: 'F' -> 'H'
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
	new_patchl($ff50,40)
#endif
		;---------------------------------------------------------------------------
		; OpenForRead (17 octets) +8
		;---------------------------------------------------------------------------
		; Ouvre un fichier en lecture
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
		; $fdce: 'J' -> 'L'

		OpenForRead:
		.(
			lda PROGNAME			; Si CLOAD "" => fin (multipart)
			beq fin
#ifdef HOBBIT
			jsr CloseOpenedFile
			lda #$00
#else
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
		; $fddf: 'M' -> 'O'
		OpenForWrite:
		.(
			jsr CloseOpenedFile
			;jsr SetFilename2
			jmp	FileCreate
		.)

		;---------------------------------------------------------------------------
		; CloseOpenedFile ( 17 octets)
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
		CloseOpenedFile:
		.(
			lda OPENFFLAG			; Fichier ouvert?
			bne suite
			; Fermeture du fichier actuel
			lda #$01			; Indique fichier fermé
			sta OPENFFLAG
			jsr FileClose
		suite:
			jsr SetFilename2
			rts
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
		; $fdf6: 'P' -> 'Y'
		CheckJoystick:
		.(
			; Ne pas modifier A et X pour pouvoir appeler ReadKbdCol
			ldy #$00		; Si on peut modifier Y
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
			lda $0208		; Instruction supprimée de ReadKbd
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
			lda JOY_TBL,y		; La table doit contenir le code de la touche
			; Tester si il s'agit de la même direction
			; Si oui -> rts possible
			; Si non -> initialiser $020E, mettre à jour $0208 et $020A puis retour à faire en LF4C6
			bpl retour		; Si la touche n'est pas définie, on repart vers ReadKbd
			;beq retour		; Si la touche n'est pas définie, on repart vers ReadKbd
			;ora $80		; b7=1 pour indiquer qu'une touche est appuyée
			cmp $0208
			bne autre_direction
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

			pla			; Oublie l'adresse de retour
			pla

			lda $0208		; Replace le code de la touche dans A

			jmp LF4C6		; Retour à ReadKbd

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
	;
	; Message de Copyright
	;
	new_patch($ed96,LEDC4)
		; Maxi 44 octets
		Copyright:
			.byte COPYRIGHT_MSG

#if * > $EDC3
#print "*** ERROR 'COPYRIGHT_MSG' too long"
#endif

			.dsb $EDC4-*,$00
	LEDC4:

	;
	; Couleur Papier/Encre au boot
	;
	new_patchl($f914,10)

			lda	#DEFAULT_INK
			sta	INK_VAL
			lda	#$10+DEFAULT_PAPER
			sta	PAPER_VAL


;---------------------------------------------------------------------------
;			Modifications ROM 1.22
;---------------------------------------------------------------------------
#ifdef ROM_122
	;---------------------------------------------------------------------------
	; Correction bug IF/THEN/ELSE
	;---------------------------------------------------------------------------
		new_patchl($c93c,3)
				jsr	REM
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
	jsr InitCH376
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
	jsr load_charset
#endif

;---------------------------------------------------------------------------
;		Ajout instruction DEF CHAR
;---------------------------------------------------------------------------
#ifdef ADD_DEF_CHAR
	new_patchl(DEF,3)
	jmp DEF_CHAR
#endif

