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
#define ABORT $5F

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
	;---------------------------------------------------------------------------
#ifdef BASIC_LET_IS_QUIT
#undef BASIC_TRON_IS_QUIT
#undef BASIC_TROFF_IS_QUIT
#define BASIC_QUIT
#endif

#ifdef BASIC_TRON_IS_QUIT
#undef BASIC_LET_IS_QUIT
#undef BASIC_TROFF_IS_QUIT
#define BASIC_QUIT
#endif

#ifdef BASIC_TROFF_IS_QUIT
#undef BASIC_LET_IS_QUIT
#define BASIC_TRON_IS_QUIT
#define BASIC_QUIT
#endif

	;---------------------------------------------------------------------------
	;			Gestion Joystick
	;---------------------------------------------------------------------------
#ifdef JOYSTICK_DRIVER
#define JOYSTICK_READKBDCOL
#define JOY_TBL $f5
#define NO_CHARSET
#undef CHECKRAM_16K
#endif


	;---------------------------------------------------------------------------
	;			Chargement du jeu de caractères
	;---------------------------------------------------------------------------
#ifdef NO_CHARSET
#ifndef DEFAULT_CHARSET
#define DEFAULT_CHARSET "/USR/SHARE/FONTS/DEFAULT.CHS"
#endif
#echo "Default charset: DEFAULT_CHARSET"
#endif

;---------------------------------------------------------------------------
;
;			Variables en page 0
;
;---------------------------------------------------------------------------
KBD_flag        = $2e
INTTMP          = $33			; $33-$34: Utilisé par GetTapeData

HIMEM_PTR       = $a6

TXTPTR          = $e9
PTR             = $f3
PTW             = $f4
;PTR_MAX         = $f4
;PTW             = $f5
;PTW_MAX         = $f6


;---------------------------------------------------------------------------
;
;			Variables en page 2
;
;---------------------------------------------------------------------------
RAMSIZEFLAG     = $0220
RAMFAULT        = $0260

PAPER_VAL       = $026b
INK_VAL         = $026c

PROGNAME        = $027f

HIMEM_MAX       = $02c1

PROGSTART       = $02a9
PROGEND         = $02ab
PROGTYPE        = $02ae

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

NewLine         = $cbf0
PrintString     = $ccb0
LCCD7           = $ccd7

TRON            = $cd16

TapeSync        = $e4ac
GetTapeData     = $e4e0

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
	; 22 Octets
	;---------------------------------------------------------------------------
	new_patch(PutTapeByte, LE6C9)

		-PutTapeByte:
		.(
			; Doit conserver X et Y
			sta	CH376_DATA
			dec	PTW
			bne	ZZ0001
			tya				; Sauvegarde de X et Y
			pha
			txa
			pha
			jsr	ByteWrGo
			jsr	WriteRqData
			pla				; Restaure X et Y
			tax
			pla
			tay
		ZZ0001:
			rts
		.)

		;---------------------------------------------------------------------------
		; 58 Octets
		;---------------------------------------------------------------------------
		; Sauvegarde de l'entête
		OpenTapeWrite:
			;lda #<PROGNAME			; Forcé dans SetFilename2
			;ldy #>PROGNAME
			jsr	OpenForWrite
			;jsr	FileCreate

			lda	$2f			; longueur du nom sans le 0 final, d'où le +1
			clc
			adc	#14+1			; +14+1 -> longueur de l'entête avec 4x16
			ldy	#$00

		; On remplace les 3 jsr par jsr WriteLeader2
		;	jsr	SetByteAndWrite
		;	jsr	WriteLeader		; Ecriture de l'amorce
		;	jsr	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
			; jsr	WriteRqData		; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)

			jsr	WriteLeader2

			; Test STORE
			bit	PROGTYPE			; STORE?
			bvc	CalcPgmLength		; Non -> Calcule la longueur du programme
			jmp	CalcArrayLength		; Oui -> Calcule la longueur du tableau

			; Optimisé (15+5)
		CalcPgmLength:
			sec				; Calcule la taille du programme
			lda	PROGEND
			sbc	PROGSTART
			tax

			lda	PROGEND+1
			sbc	PROGSTART+1
			tay

		WriteLength:
			inx				; +1
			bne	*+3
			iny

			txa
		SetByteAndWrite:
			jsr	SetByteWrite

		WriteRqData:
			lda	#$2d			; WriteReqData
			sta	CH376_COMMAND
			lda	CH376_DATA
			sta	PTW			; Nombre d'octets attendu
			rts

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
			lda	#$22
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
		;	lda	#$22
		;	sta	CH376_COMMAND
		;										; .A = CH376_DATA;
		;	lda	CH376_DATA
		;										; RETURN;
		;	rts

	LE6C9:


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


	;---------------------------------------------------------------------------
	; 10 Octets à l'emplacement de "MICROSOFT!"
	;---------------------------------------------------------------------------
	new_patch($e435,LE43F)

		CalcArrayLength:
			ldx	PROGSTART
			ldy	PROGSTART+1
			jmp	WriteLength
			nop
	LE43F:



;---------------------------------------------------------------------------
;				CLOAD
;---------------------------------------------------------------------------
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
	LE50A:

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
		; GetTapeByte: Modifié (28 octets)
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
		; 35 Octets + 5 en ZZD001
		;---------------------------------------------------------------------------
			; SetFilename2: 38 octets
		SetFilename2:
		.(
			;sta PTR_READ_DEST
			;sty PTR_READ_DEST+1
			lda	#$2f
			sta	CH376_COMMAND
			sta	CH376_DATA		; Pour ouverture de '/'
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

			lda	#$2f
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
			lda	#$31
			.byte $2c

		FileOpen:
			lda	#$32
			.byte $2c

		FileCreate:
			lda	#$34

		CH376_Cmd:
			sta	CH376_COMMAND

		CH376_CmdWait:
			jsr	WaitResponse
			cmp	#INT_SUCCESS
			rts
		;---------------------------------------------------------------------------
		FileClose:
			ldx	#$36
			stx	CH376_COMMAND
			sta	CH376_DATA

			clc				; Saut inconditionel
			bcc	CH376_CmdWait


		;---------------------------------------------------------------------------
		; 11 Octets
		;---------------------------------------------------------------------------
		ByteWrGo:
			lda	#$3d
			sta	CH376_COMMAND
			jsr	WaitResponse
			cmp	#INT_DISK_WRITE
			rts

		;---------------------------------------------------------------------------
		; 10 Octets
		;---------------------------------------------------------------------------
		WriteLeader2:
			jsr	SetByteAndWrite
			jsr	WriteLeader		; Ecriture de l'amorce
			jmp	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
			; jsr	WriteRqData		; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)

		;---------------------------------------------------------------------------
		; 6 Octets
		;---------------------------------------------------------------------------
		; Fermeture du fichier après sauvegarde
		;---------------------------------------------------------------------------
		WriteClose:
			lda #$00
			sta $020f			; Indique pas de fichier ouvert
			jsr FileClose
			jmp LE93D
	LE735:

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
			jmp SyncTape_loop			; Point d'entrée direct
			jsr OpenForRead			; Point d'entrée depuis TapeSync
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


	LE75A:
	; WriteLeader


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

		ReadUSBData2:
		        ldy #0

		        lda #$27
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
	LE7AF:

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
	new_patch((StartBASIC+$B7),LED86)
		; jmp BackToBASIC
		jmp ORIX_AUTOLOAD
	LED86:


;---------------------------------------------------------------------------
;			Patch de la routine RamTest
;---------------------------------------------------------------------------
#ifdef NORAMCHECK
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
;#ifdef CHECKRAM_16K
;			; Test 48Ko
;			dey
;			sty	$4500
;			lda	$0500
;			bne	LFA31
;#endif
			lda	#$c0-$28
;#ifdef CHECKRAM_16K
;			bne	LFA36
;		LFA31:
;			; 16Ko seulement
;			inc	RAMSIZEFLAG
;			lda	#$40-$28
;#endif
;		LFA36:
			sta	HIMEM_PTR+1
			sta	HIMEM_MAX+1
			rts
;	LFA3C:
		; 27 octets
		ORIX_AUTOLOAD:
			; InitCH376: inutile car fait pour le chargement
			; du jeu de caractères
			; jsr InitCH376
			lda #$00
			sta $020f
			lda #<(BUFEDT+6)
			sta TXTPTR
			lda #>(BUFEDT+6)
			sta TXTPTR+1
			jsr CharGet
			beq *+8
			jsr CLOAD
			jmp DoNextLine
			jmp BackToBASIC

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

		;---------------------------------------------------------------------------
		; load_charset (36 octets)
		;---------------------------------------------------------------------------
		; Charge un le jeu de caractère par défaut en RAM
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;
		; Modifie:
		;	rwpoin: Pointeur vers l'adresse de chargement
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
			ldx default_chs_len
			lda #<default_chs
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

			; Chargement du jeux de caractères
			jsr GetTapeData

		load_charset_error:
			rts
		.)

	RAMCHECK_end:

;#print *
#if * > $fa86
#print "*** ERROR NORAMCHECK too long"
#endif
		.dsb $fa86-*, $EA
	LFA86:
#endif



;---------------------------------------------------------------------------
;			Patch pour la gestion du joystick
;			Placé dans le jeu de caractères
;---------------------------------------------------------------------------
#ifdef NO_CHARSET
#ifdef JOYSTICK_DRIVER

; Si Détournement de l'appel ReadKbdCol
#ifdef JOYSTICK_READKBDCOL
	new_patch((CharSet+$18), CharSet_end)

;---------------------------------------------------------------------------
;		Patch pour le chargment du jeu de caractère par défaut
;			Placé dans le jeu de caractères
;---------------------------------------------------------------------------
rwpoin = $00f3		; PTR
;H91 = rwpoin
ERR_OPEN_DIR=$41

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



		; Spécial pour The Hobbit qui vérifie la valeur en $FC78
		; pour savoir si il s'agit d'un Oric-1 ou d'un Atmos
		;.byte $00

		; $fc90-$fcad: 30 octets
		; # $ % &
		default_chs_len:
			.byte default_chs_end-default_chs-1
		default_chs:
			.byte DEFAULT_CHARSET,0
		default_chs_end:

#if 0
; Transféré dans RamTest
		;---------------------------------------------------------------------------
		; load_charset (36 octets)
		;---------------------------------------------------------------------------
		; Charge un le jeu de caractère par défaut en RAM
		;
		; Entree:
		;	-
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;
		; Modifie:
		;	rwpoin: Pointeur vers l'adresse de chargement
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
			ldx default_chs_len
			lda #<default_chs
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

			; Chargement du jeux de caractères
			jsr GetTapeData

		load_charset_error:
			rts
		.)
#endif


		;---------------------------------------------------------------------------
		; open_fqn (127 octets)
		;---------------------------------------------------------------------------
		; Ouvre un fichier (chemin absolu ou relatif sans ../)
		;
		; Entree:
		;	AY: Adresse de la chaine
		;	X: Longueur de la chaine
		;
		; Sortie:
		;	AY: Code erreur CH376 ($41 si Ok)
		;	rwpoin: Adresse de la chaine
		;
		; Modifie:
		;	INTTMP: Longueur de la chaine (remis à sa valeur initiale en fin de procédure)
		;	INTTMP+1: Index dans la chaine (remis à sa valeur initiale en fin de procédure)
		;	rwpoin: Adresse de la chaine
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
			; Sauvegarde la longueur de la chaine, le temps
			; de mettre à l'abri $F5 et $F6
;			tay

			; Sauvegarde $F5 et $F6 car utilisés par le Joystick
;			lda rwpoin+2
;			pha
;			lda rwpoin+3
;			pha


			sta rwpoin
			sty rwpoin+1

			; Longueur de la chaîne
			stx INTTMP
										; rwpoin+3 = 0;
			lda #0
			sta INTTMP+1
			; Note: InitCH376 fait un Mount USB qui replace le répertoire par
			; defaut a '/'
			; A modifier pour autoriser un repertoire relatif
										; CALL InitCH376;
			jsr InitCH376
										; IF .Z THEN
			bne ZZ1002
										; BEGIN;
			; La suite est faite dans InitCH376 de la rom
			;jsr SetSD
			;nop
			;nop
			;jsr Mount
			;bne ZZ1002

			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
										; IF &rwpoin = '/' THEN
			ldy #0
			lda #'/'
			cmp (rwpoin),Y
			;beq  *+5
			;jmp ZZ1003
			bne ZZ1003
										; BEGIN;
			; Apres le test, .A contient '/' soit $2F
										; CH376_COMMAND = .A; " SetFirwpoin+2ame";
			sta CH376_COMMAND
										; CH376_DATA = .A;
			sta CH376_DATA
										; CH376_DATA = $00;
			lda #$00
			sta CH376_DATA
										; CALL FileOpen; " Detruit X et Y";
			jsr FileOpen
										; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
			cmp #ERR_OPEN_DIR
			bne CD_End
										; INC rwpoin+3;
			inc INTTMP+1
										; END;
										; IF rwpoin+3 < rwpoin+2 THEN CH376_COMMAND = $2F; " SetFirwpoin+2ame";
		ZZ1003:
			lda INTTMP
			cmp INTTMP+1
			beq  *+4
			bcs  *+5
			jmp ZZ1004
			lda #$2F
			sta CH376_COMMAND
		ZZ1004:
			; Remplacer BCC *+5/JMP ZZnnnnn par BCS ZZnnnnn
										; WHILE rwpoin+3 < rwpoin+2
		ZZ1005:
			lda INTTMP+1
			cmp INTTMP
			;bcc  *+5
			;jmp ZZ0006
			bcs ZZ0006
										; DO;
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
			; IF &rwpoin[rwpoin+3] = '/' THEN
										; .Y = rwpoin+3;
			ldy INTTMP+1
										; .A = @rwpoin[.Y];
			lda (rwpoin),Y
			; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
										; IF .A = '/' THEN
			cmp #'/'
			;beq  *+5
			;jmp ZZ0007
			bne ZZ0007
										; BEGIN;
										; CH376_DATA = 0;
			lda #0
			sta CH376_DATA
										; CALL FileOpen;
			jsr FileOpen
										; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
			cmp #ERR_OPEN_DIR
			bne CD_End
										; INC rwpoin+3;
			inc INTTMP+1
											; IF rwpoin+3 < rwpoin+2 THEN CH376_COMMAND = $2F; " SetFirwpoin+2ame";
			lda INTTMP
			cmp INTTMP+1
			beq  *+4
			bcs  *+5
			jmp ZZ0008
			lda #$2F
			sta CH376_COMMAND
		ZZ0008:
										; .Y = rwpoin+3;
			ldy INTTMP+1
										; .A = @rwpoin[.Y];
			lda (rwpoin),Y
										; END;
										; CH376_DATA = .A;
		ZZ0007:
			sta CH376_DATA
										; INC rwpoin+3;
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
			; .AY = Code erreur, poids faible dans .A
		ZZ1002:
										; .Y = .A;
			tay
										; CLEAR .A;
			; Restaure $F5 et $F6
;			pla
;			sta rwpoin+3
;			pla
;			sta rwpoin+2

			lda #0
										;RETURN;
			rts
		.)


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

#if 0
; Transféré dans CheckFoundName
		;---------------------------------------------------------------------------
		; ReadUSBData(26 octets)
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
 		        sta INTTMP
		        sty INTTMP+1

 		ReadUSBData2:
 		        ldy #0

		        lda #$27
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
#endif

		;---------------------------------------------------------------------------
		; ReadUSBData3 (26 octets)
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

;			jsr	ReadUSBData3			; Résultat dans $2f
;			jsr	ByteRdGo
;			bne	fin

                        lda     #$27
                        sta     CH376_COMMAND
			lda	CH376_DATA			; Nombre de caractère à lire
                        lda     CH376_DATA			; Caractère lu
                        sta     $2f
			clc					; Indique pas d'erreur de lecture
			.byte $24
		fin_erreur:
			sec
                        rts
		.)


;		_ClrTapeStatus:
;			jsr	ClrTapeStatus
;; ---HCL---
;			rts
;; ---HCL---
;			lda	#$01			; Fermeture avec mise à jour de la taille
;			jmp	FileClose


;		_SetupTape:
;			jsr	StopTimer

		;---------------------------------------------------------------------------
		; InitCH376 (36 Octets)
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
		;	$D4DA: ?UNDEF'D FUNCTION ERROR
		;---------------------------------------------------------------------------
		; $fd68: '<' -> 'B'
		InitCH376:
		Exists:
			ldx	#6
			stx	CH376_COMMAND
			lda	#$ff
			sta	CH376_DATA
			lda	CH376_DATA
			bne	InitError
		SetUSB:
			lda	#$15
			sta	CH376_COMMAND
			ldx	#CH376_USB_MODE
			stx	CH376_DATA

			;Wait 10us
			nop
			nop
			jsr	Mount

			;IFF ^.Z THEN InitError;
			bne	InitError
			rts

		InitError:
			jmp	$d4da
		;	ldx	#$d7
		;	jmp	$c47e			; "?CAN'T CONTINUE ERROR"
		;	jmp	$d35c			; "?OUT OF DATA ERROR"

		;	jmp	$e651			; Si $02B1 != 0 -> jmp $E656
		;	jmp	$e656			; "Errors found" (mais pas de retour au BASIC)

		;---------------------------------------------------------------------------
		; 27 Octets
		;---------------------------------------------------------------------------
		; $fd8c: 'B' -> 'E'
		SetByteRead:
			ldx	#$3a
			.byte $2c

		SetByteWrite:
			ldx	#$3c

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
			lda	#$3B
			sta	CH376_COMMAND
			bne	CH376_CmdWait2

		;---------------------------------------------------------------------------
		; (24 octets)
		;---------------------------------------------------------------------------
		;
		; Efface la ligne de status + 'OUT OF DATA ERROR'
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

		; Message d'erreur (15 octets)
		; $fdbf: 'I' -> 'J'
		FileNotFound_msg
			.byte "FILE NOT FOUND",00
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop

		;---------------------------------------------------------------------------
		; OpenForRead (17 octets)
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
		;	$020f: Flag fichier ouvert
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	SetFilename2
		;	FileOpen
		;---------------------------------------------------------------------------
		; $fdce: 'J' -> 'L'
#if 1
		OpenForRead:
		.(
			lda PROGNAME
			beq fin
			jsr SetFilename2
			lda #$42
			sta $020f
			jmp	FileOpen

		fin:
			rts
		.)

#endif
#if 0
		OpenForRead:
		.(
			lda $020f
			cmp #$42
			bne *+3
			rts
			jsr SetFilename2
			lda #$42
			sta $020f
			jmp	FileOpen

		fin:
			rts
		.)
#endif
#if 0
		OpenForRead:
		.(
			bit $020f
			bmi fin
			bvs suite
			lda #$20
			sta $020f
		suite
			asl $020f
			jsr SetFilename2
			jsr FileOpen
			rts
		fin:
			asl $020f
			lda #$ff
			rts
		.)
#endif

		;---------------------------------------------------------------------------
		; OpenForWrite ( 23 octets)
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
		;	$020f: Flag fichier ouvert
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	FileClose
		;	SetFilename2
		;	FileCreate
		;---------------------------------------------------------------------------
		; $fddf: 'M' -> 'O'
		OpenForWrite:
		.(
			lda $020f
			cmp #$42
			bne suite
			lda #$00
			sta $020f
			; Fermeture du fichier actuel
			lda #$01
			jsr FileClose
		suite:
			jsr SetFilename2
			jmp	FileCreate
		.)
#if 0
		OpenForWrite:
		.(
			lda $020f
			beq suite
			lda #$00
			sta $020f
			; Fermeture du fichier actuel
			lda #$01
			jsr FileClose
		suite:
			lda #$40
			sta $020f
			jsr SetFilename2
			jmp	FileCreate
		.)
#endif
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
			; correspondant à la touchr
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

CharSet_end:

#if * > KeyCodeTab
#print "*** ERROR Charset too long"
#endif
;			.dsb KeyCodeTab-*,$ff

		; #ifdef JOYSTICK_DRIVER
#endif
	; #ifdef JOYSTICK_READKBDCOL
#endif

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
;			Modifications pour Orix
;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	; Pointe vers le message de Copyright
	; Pour Telestrat (signature de la banque)
	;---------------------------------------------------------------------------
		new_patchl($fff8,2)
				.word Copyright


	;---------------------------------------------------------------------------
	; Modification pour la commande 'bank' de Orix
	; qui fait un 'jmp $c000' et non un 'jmp ($fffc)
	;---------------------------------------------------------------------------
		new_patchl($c000,3)
				jmp	Reset


;---------------------------------------------------------------------------
;Commande de retour à Orix
;---------------------------------------------------------------------------
#ifdef BASIC_LET_IS_QUIT
	;---------------------------------------------------------------------------
	; Remplace LET par OUT
	;---------------------------------------------------------------------------
	new_patchl($c149,3)
			.byte "OU","T"+$80

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution LET -> QUIT
	;---------------------------------------------------------------------------
	new_patchl($c032,2)
			.word QUIT-1
#endif

#ifdef BASIC_TRON_IS_QUIT
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
	; Peut être transféré vers _FileNotFound
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
	; Patch pour de la routine CheckKbd
	;---------------------------------------------------------------------------
#ifdef JOYSTICK_CHECKKBD
#echo "Joystick driver: ChekKbd"
	new_patchl(CheckKbd,3)
;	new_patchl($EE62,3)
		jsr CheckJoystick
#else

#ifdef JOYSTICK_READKBDCOL
#echo "Joystick driver: ReadKbdCol"
	; Patch de la routine CheckKbd
	new_patchl(ReadKbd+5,3)
		jsr CheckJoystick

	; Patche de la routine d'init pour ne pas
	; copier le jeu de caractères depuis la rom vers la ram.
	; On suppose que l'Oric a déjà démarré et que le jeu est en place
	new_patchl(LF8B8+26,3)
	;nop
	;nop
	;nop
	jsr load_charset
#endif

#endif

	;---------------------------------------------------------------------------
	; Patch pour l'instruction GET
	;---------------------------------------------------------------------------
	;new_patchl($cdb5,3)
	;	jsr CheckJoystick

	;---------------------------------------------------------------------------
	; Patch pour l'instruction KEY$
	;---------------------------------------------------------------------------
	;new_patchl($dada,3)
	;	jsr CheckJoystick
#endif

