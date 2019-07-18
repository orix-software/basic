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

#define SDCARD_MODE $03
#define USB_HOST_MODE $06

#ifndef CH376_USB_MODE
#define CH376_USB_MODE USB_HOST_MODE
#endif

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

#ifndef DEFAULT_INK
#define DEFAULT_INK YELLOW
#endif

#ifndef DEFAULT_PAPER
#define DEFAULT_PAPER BLACK
#endif

;---------------------------------------------------------------------------
;
;			Variables en page 0
;
;---------------------------------------------------------------------------
HIMEM_PTR       = $a6

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
VIA2_IORA    = $0321

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

ClrTapeStatus   = $e5f5
WriteFileHeader = $e607
PutTapeByte     = $e65e
WriteLeader     = $e75a
GetTapeByte     = $e6c9
SyncTape        = $e735
SetupTape       = $e76a

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
			.byte '.TAP',0

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
			nop
			nop
			nop
			nop
			nop
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
		; ATTENTION: Déborde sur la routine "Comparer nom demandé et non trouvé"
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

		LE790:
		; E7A7

#ifdef ORIX

		BackToOrix:
			lda	#$07
			sta	VIA2_IORA
			jmp	(RESET_VECTOR)
#else
		;	nop
		;	nop
			nop
			nop
			nop
			nop
			nop
			nop
#endif
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
;			Personalisation de la ROM
;---------------------------------------------------------------------------
	;
	; Message de Copyright
	;
	new_patch($ed96,LEDC4)

		; Maxi 44 octets
		Copyright:
			.byte "ORIC EXTENDED BASIC V1.1", $0D, $0A
			.byte $60," 1983 TANGERINE", $0D, $0A
			.byte $00,$00
	LEDC4:

	;
	; Couleur Papier/Encre au boot
	;
	new_patchl($f914,10)

			lda	#DEFAULT_INK
			sta	INK_VAL
			lda	#$10+DEFAULT_PAPER
			sta	PAPER_VAL

#ifdef NORAMCHECK
	;
	; Supprime le test de la RAM
	; pour accélérer le démarrage
	;
	; Libère de $FA3C à $FA85 soit 74 octets
	;
	new_patch(RamTest,LFA3C)
			ldy	#$00
			sty	RAMFAULT
			sty	RAMSIZEFLAG
			sty	$0500
			sty	HIMEM_PTR
			sty	HIMEM_MAX
			dey
			sty	$4500
			lda	$0500
			bne	LFA31
			lda	#$c0-$28
			bne	LFA36
		LFA31:
			inc	RAMSIZEFLAG
			lda	#$40-$28
		LFA36:
			sta	HIMEM_PTR+1
			sta	HIMEM_MAX+1
			rts
	LFA3C:

#endif

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


#ifdef ORIX
	;---------------------------------------------------------------------------
	; Remplace TRON par QUIT
	;---------------------------------------------------------------------------
	new_patchl($c0fc,4)
			.byte 'QUI','T'+$80

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TROFF -> QUIT
	; au cas ou...
	;---------------------------------------------------------------------------
	new_patchl($c010,2)
			.word TRON-1

	;---------------------------------------------------------------------------
	; Modification de TRON pour retour vers ORIX
	; /|\ Seulement 9 octets disponibles de $CD16 à $CD1E inclus
	;---------------------------------------------------------------------------
	new_patch(TRON,LCD1F)

			ldy	#$07
		boucle:
			lda	BackToOrix,y
			sta	$00,y
			dey
			bpl	boucle
			jmp	$0000
	LCD1F:
#endif
