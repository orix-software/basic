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
#define new_patch(a,f) *=a-3 : .word a : .byte f-a
#define new_patchl(a,l) *=a-3 : .word a : .byte l

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
#undef CHECKRAM_16K
#endif

;---------------------------------------------------------------------------
;
;			Variables en page 0
;
;---------------------------------------------------------------------------
HIMEM_PTR       = $a6

TXTPTR          = $e9
PTR             = $f3
PTR_MAX         = $f4
PTW             = $f5
PTW_MAX         = $f6


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

BackToBASIC     = $c4a8

ClrTapeStatus   = $e5f5
WriteFileHeader = $e607
PutTapeByte     = $e65e
WriteLeader     = $e75a
GetTapeByte     = $e6c9
SyncTape        = $e735
SetupTape       = $e76a

CLOAD           = $e85b

CheckKbd        = $eb78

StartBASIC      = $eccc

RamTest         = $fa14
TRON            = $cd16

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


		;---------------------------------------------------------------------------
		; 58 Octets
		;---------------------------------------------------------------------------
		; Sauvegarde de l'entête
		OpenTapeWrite:
			;lda #<PROGNAME			; Forcé dans SetFilename2
			;ldy #>PROGNAME
			jsr	SetFilename2
			jsr	FileCreate

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
			nop
			nop
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
		ZZD001:
			.byte ".TAP",0

	LE76A:

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

	;LE4AC
	; Chargement de l'entête => supprime le test nom demandé == nom trouvé

	new_patchl($e4d9,3)

		; TapeSync +45
		LE4D9:
			ldx	#$00			; Indique que les noms sont identiques
			nop

		;LE4E0
		; Chargement du programme => pas de changement


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
			lda	CH376_DATA
			pha				; Sauvegarde A
			dec	PTR
			bne	ZZ0002
			tya				; Sauvegarde X,Y
			pha
			txa
			pha
			jsr	ByteRdGo
			jsr	ReadUSBData3
			pla				; Restaure X,Y
			tax
			pla
			tay
		ZZ0002:
			pla				; Restaure ACC et les flags en fonction de ACC
			rts
		; E6E1

		;---------------------------------------------------------------------------
		; 35 Octets + 5 en ZZD001
		;---------------------------------------------------------------------------
			; SetFilename2: 38 octets
		SetFilename2:
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
			sta	CH376_DATA
			bne	ZZ0005
			rts


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

		WriteLeader2:
			jsr	SetByteAndWrite
			jsr	WriteLeader		; Ecriture de l'amorce
			jsr	WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
			; jsr	WriteRqData		; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)
			rts

		; E72b
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

		; Ok: 36/37 octets
		-SyncTape:
			;lda	#<PROGNAME			; Forcé dans SetFilename2
			;ldy	#>PROGNAME
			jsr	SetFilename2
			jsr	FileOpen

#ifdef BASIC_TRON_IS_QUIT
			beq *+5
			jmp NotFound
#endif

			lda	#$ff
			tay
			jsr	SetByteRead
			jsr	ReadUSBData3
			jsr	GetTapeByte
			ldx	#$00			; Sortir avec X=0 car utilisé en $E4B6 pour le Flag d'erreur
			rts

		ReadUSBData3:
			lda	#$27
			sta	CH376_COMMAND
			lda	CH376_DATA
			sta	PTR
			rts
		; E755
#ifndef BASIC_TRON_IS_QUIT
			nop
			nop
			nop
			nop
			nop
#endif
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
	new_patch(SetupTape,LE7AF)

		-SetupTape:
			; E76A - E781: 24 octets
			;InitVIA
			; Ok: 10/24 octets

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
		; ATTENTION: Déborde sur la routine "Comparer nom demandé et nom trouvé"
		; en $E790 - $E7AE, d'ou le patch de la routine $E4AC
		;---------------------------------------------------------------------------
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
		; Efface la ligne de status + 'OUT OF DATA ERROR'
		; Utilisé pour indiquer une erreur lors de la lecure d'un fichier
		LE790:
		; E7A9
			jsr LE93D
			jmp $d35c
;			nop
;			nop
;			nop
;			nop
;			nop
;			nop
	LE7AF:


;---------------------------------------------------------------------------
;  8 Octets : Patch routine existante
;---------------------------------------------------------------------------
	new_patch($e93d,LE946)

		LE93D:
			; E93D - E945: 9 octets
			; RestaureVIA
			; En fait on ne change que l'intruction en $E940
			; Ok: 6/9 octets
			jsr	ClrTapeStatus
			lda	#$01			; Fermeture avec mise à jour de la taille
			jmp	FileClose
		; E945
			nop
	LE946:
		; CALL



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
	; Libère de $FA3C à $FA85 soit 74 octets
	;
	new_patch(RamTest,LFA86)
			ldy	#$00
			sty	RAMFAULT
			sty	RAMSIZEFLAG
			sty	$0500
			sty	HIMEM_PTR
			sty	HIMEM_MAX
#ifdef CHECKRAM_16K
			; Test 48Ko
			dey
			sty	$4500
			lda	$0500
			bne	LFA31
#endif
			lda	#$c0-$28
#ifdef CHECKRAM_16K
			bne	LFA36
		LFA31:
			; 16Ko seulement
			inc	RAMSIZEFLAG
			lda	#$40-$28
#endif
		LFA36:
			sta	HIMEM_PTR+1
			sta	HIMEM_MAX+1
			rts
	LFA3C:
		ORIX_AUTOLOAD:
			lda #<(BUFEDT+6)
			sta TXTPTR
			lda #>(BUFEDT+6)
			sta TXTPTR+1
			jsr CharGet
			beq *+5
			jmp CLOAD
			jmp BackToBASIC

#ifdef BASIC_QUIT
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

#ifdef JOYSTICK_DRIVER
VIA2_IORB=$320
; Si Détournement en CheckKbd
#ifndef USE_CHECKKBD
		CheckJoystick:
			lda $02df
			bpl *+3
			rts
			;ldx #$00		; Si on peut modifier X
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
		;	bcc up
		;	rts
			bcs CheckJoystick+5
#else
ReadKbd = $f495
		CheckJoystick:
			pha
			ldx #$ff		; Si on peut modifier Y
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
			pla
			jmp ReadKbd
		up
			inx
		right
			inx
		left
			inx
		fire
			inx
		down
			inx
			lda $00,x
			beq up-4
			tax
			pla
			rts
#endif
#if 0
; Valeurs Fixes
		up
			lda #'U'+$80
			rts
		right
			lda #'R'+$80
			rts
		left
			lda #'L'+$80
			rts
		fire
			lda #'F'+$80
			rts
		down
			lda #'D'+$80
			rts
#endif

#if 0
; valeurs dans une table
; (15 octets)
		up
			lda $00
			rts
		right
			lda $01
			rts
		left
			lda $02
			rts
		fire
			lda $03
			rts
		down
			lda $04
			rts
#endif

#if 0
; valeurs dans une table (version optimisée)
; A condition de pouvoir modifier X
; 7 Octets +2
		up
			inx
		right
			inx
		left
			inx
		fire
			inx
		down
			inx
			lda $00,x
			rts
#endif

#if 0
; valeurs dans une table (version optimisée)
; A condition de pouvoir modifier Y
; 7 Octets +2
		up
			; iny
		right
			iny
		left
			iny
		fire
			iny
		down
			iny
			lda $00,y
			rts
#endif

; Si Détournement en CheckKbd
#if 1
; valeurs dans une table (version optimisée)
; A condition de pouvoir modifier Y
; 7 Octets +2
		up
			iny
		fire
			iny
		left
			iny
		right
			iny
		down
			lda $00,y
			rts
#endif

#endif

;#print *
#if * > $fa86
#print "*** ERROR NORAMCHECK too long"
#endif
		.dsb $fa86-*, $EA
	LFA86:
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

			jmp LE790
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
	new_patchl(CheckKbd,3)
;	new_patchl($EE62,3)
		jsr CheckJoystick

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

