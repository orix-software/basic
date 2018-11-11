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
; Codes d'erreur du CH376
;
;---------------------------------------------------------------------------
#define SUCCESS $12
#define INT_SUCCESS $14
#define INT_DISK_READ $1D
#define INT_DISK_WRITE $1E
#define ABORT $5F


;---------------------------------------------------------------------------
;
; Variables en page 0
;
;---------------------------------------------------------------------------
        *=$F3
PTR  *=*+1
PTR_MAX  *=*+1
PTW  *=*+1
PTW_MAX  *=*+1


;---------------------------------------------------------------------------
;
; Variables en page 2
;
;---------------------------------------------------------------------------
        *=$27F
TNAME  *=*+17
        *=$293
TH_NAME  *=*+17
TH_DUMMY  *=*+4
TH_UNUSED  *=*+1
TH_START  *=*+2
	TH_START_L=TH_START
	TH_START_H=TH_START+1
TH_END  *=*+2
	TH_END_L=TH_END
	TH_END_H=TH_END+1
TH_AUTO  *=*+1
TH_TYPE  *=*+1
TH_STRING_FLAG  *=*+1
TH_INTEGER_FLAG  *=*+1
TH_ERROR  *=*+1


;---------------------------------------------------------------------------
;
; Adresse de l'interface CH376
;
;---------------------------------------------------------------------------
CH376_COMMAND=$341
CH376_DATA=$340

;---------------------------------------------------------------------------
;			Routines ROM v1.1
;---------------------------------------------------------------------------

ClrTapeStatus = $E5F5

;#ifdef CSAVE
;---------------------------------------------------------------------------
;				CSAVE
;---------------------------------------------------------------------------
	; Pour CSAVE

;---------------------------------------------------------------------------
; Patch routine existante: détournement vers OpenTapeWrite qui repassera
; ensuite en $E60A
; Sinon, il faut modifier les routines qui appelle WriteFileHeader pour
; qu'elles appellent OpenTapeWrite
;
; MIEUX: modifier WriteLeader pour appeler OpenTapeWrite
;---------------------------------------------------------------------------
	new_patchl($E607,3)

WriteFileHeader
		jmp OpenTapeWrite

;---------------------------------------------------------------------------
; 22 Octets
;---------------------------------------------------------------------------
	new_patch($E65E, LE6C9)

PutTapeByte
		; Doit conserver X et Y
		sta CH376_DATA
		dec PTW
		bne ZZ0001
		tya			; Sauvegarde de X et Y
		pha
		txa
		pha
		jsr ByteWrGo
		jsr WriteRqData
		pla			; Restaure X et Y
		tax
		pla
		tay
ZZ0001
		rts


;---------------------------------------------------------------------------
; 58 Octets
;---------------------------------------------------------------------------
	; Sauvegarde de l'entête
OpenTapeWrite
		;lda #<TNAME		; Forcé dans SetFilename2
		;ldy #>TNAME
		jsr SetFilename2
		jsr FileCreate

		lda $2f		; longueur du nom sans le 0 final, d'où le +1
		clc
		adc #14+1		; +14+1 -> longueur de l'entête avec 4x16
		ldy #$00

; On remplace les 3 jsr par jsr WriteLeader2
;		jsr SetByteAndWrite
;		jsr WriteLeader	; Ecriture de l'amorce
;		jsr WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
		; jsr WriteRqData	; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)

		jsr WriteLeader2

		; Test STORE
		bit TH_TYPE		; STORE?
		bvc CalcPgmLength	; Non -> Calcule la longueur du programme
		jmp CalcArrayLength	; Oui -> Calcule la longueur du tableau

		; Optimisé (15+5)
CalcPgmLength
		sec			; Calcule la taille du programme
		lda TH_END
		sbc TH_START
		tax

		lda TH_END+1
		sbc TH_START+1
		tay

WriteLength
		inx			; +1
		bne *+3
		iny

		txa
SetByteAndWrite
		jsr SetByteWrite

WriteRqData
		lda #$2d		; WriteReqData
		sta CH376_COMMAND
		lda CH376_DATA
		sta PTW		; Nombre d'octets attendu
		rts

;---------------------------------------------------------------------------
; 26 Octets - Calcul du nombre d'octets à écrire dans le fichier
;---------------------------------------------------------------------------
		; 11 Octets
;		lda TH_END
;		ldy TH_END+1
;		bit TH_TYPE		; Commande STORE?
;		bvs Fin			; Oui -> pas de calcul de la taille, c'est déjà fait

		; Optimisé (10+5)
;		sec			; Calcule la taille du programme
		;lda TH_END		; Déjà fait
;		sbc TH_START
;		tax

		;lda TH_END+1
;		tya
;		sbc TH_START+1
;		tay

;		inx			; +1
;		bne *+3
;		iny

;		txa
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
WaitResponse
	LDY #$FF
ZZZ009
	LDX #$FF
ZZZ010
	LDA CH376_COMMAND
	BMI ZZZ011
	LDA #$22
	STA CH376_COMMAND
	LDA CH376_DATA
	RTS
ZZZ011
	DEX
	BNE ZZZ010
	DEY
	BNE ZZZ009
	RTS

;---------------------------------------------------------------------------
; Version sans Timeout: 14 Octets
;---------------------------------------------------------------------------
;										; REPEAT;
;ZZZ010
;										; .A = CH376_COMMAND;
;	lda CH376_COMMAND
;										; UNTIL -;
;	bpl zzz010
;										; CH376_COMMAND = $22;
;	lda #$22
;	sta CH376_COMMAND
;										; .A = CH376_DATA;
;	lda CH376_DATA
;										; RETURN;
;	rts

LE6C9


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

	new_patch($E75A,LE76A)
WriteLeader
		;ldx #$01
		ldy #$04
		lda #$16
		jsr PutTapeByte
		dey
		bne *-6
		;dex
		;bne *-9
		rts

	; Utilisé par SetFilename2
ZZD001
.byte '.TAP',0

LE76A

;---------------------------------------------------------------------------
; 9 Octets à l'emplacement de "MICROSOFT!"
;---------------------------------------------------------------------------
	new_patch($E435,LE43F)

CalcArrayLength
		ldx TH_START
		ldy TH_START+1
		jmp WriteLength
LE43F

;#endif


;#ifdef CLOAD
;---------------------------------------------------------------------------
;				CLOAD
;---------------------------------------------------------------------------

	;LE4AC
	; Chargement de l'entête => supprime le test nom demandé == nom trouvé

	new_patchl($E4D9,3)

; TapeSync +45
LE4D9
		ldx #$00		; Indique que les noms sont identiques
		nop

	;LE4E0
	; Chargement du programme => pas de changement


;---------------------------------------------------------------------------
; 24 Octets
;---------------------------------------------------------------------------
	new_patch($E6C9,LE735)
	;LE6C9
	; E6C9 - E6FB: 51 octets
	; Chargement d'un octet
	; Doit conserver X et Y
	; Octet lu dans ACC (utilise $2F comme zone temporaire pour ACC)
	; Sortir avec C=0 et $2B1=0 (pas d'erreur de parité) (2B1 doit être mise à 0 quelque part avant...)

	; Ok: 24/51 octets
GetTapeByte
		lda CH376_DATA
		pha			; Sauvegarde A
		dec PTR
		bne ZZ0002
		tya			; Sauvegarde X,Y
		pha
		txa
		pha
		jsr ByteRdGo
		jsr ReadUSBData3
		pla			; Restaure X,Y
		tax
		pla
		tay
ZZ0002
		pla			; Restaure ACC et les flags en fonction de ACC
		rts
; E6E1

;==========
;---------------------------------------------------------------------------
; 35 Octets + 5 en ZZD001
;---------------------------------------------------------------------------
	; SetFilename2: 38 octets
SetFilename2
		;sta PTR_READ_DEST
		;sty PTR_READ_DEST+1

		lda #$2f
		sta CH376_COMMAND
		sta CH376_DATA		; Pour ouverture de '/'
		ldy #$ff
ZZ0003
		iny
		;lda (PTR_READ_DEST),y
		lda TNAME,y
		beq ZZ0004
		sta CH376_DATA
		bne ZZ0003

ZZ0004
		sty $2f		; Sauvegarde la longueur (utilisée par CSAVE)
		ldy #$ff		; Ajoute '.TAP'
ZZ0005
		iny
		lda ZZD001,y
		sta CH376_DATA
		bne ZZ0005
		rts


#if 0
;---------------------------------------------------------------------------
; Alternative sans extension .TAP et ouverture dans le répertoire courant
;---------------------------------------------------------------------------
; 17 Octets et ZZD001 peut être supprimé (Gain 18+5 = 23 Octets)
;---------------------------------------------------------------------------

SetFilename2
		;sta PTR_READ_DEST
		;sty PTR_READ_DEST+1

		lda #$2f
		sta CH376_COMMAND
		ldy #$ff
ZZ0003
		iny
		;lda (PTR_READ_DEST),y
		lda TNAME,y
		sta CH376_DATA
		bne ZZ0003

		rts
#endif

;---------------------------------------------------------------------------
; 28 Octets
;---------------------------------------------------------------------------
Mount
	LDA #$31
;	BNE CH376_Cmd
	.byte $2c

FileOpen
	LDA #$32
;	BNE CH376_Cmd
	.byte $2c

FileCreate
	LDA #$34
;	BNE CH376_Cmd

CH376_Cmd
	STA CH376_COMMAND

CH376_CmdWait
	JSR WaitResponse
	CMP #INT_SUCCESS
	RTS
;---------------------------------------------------------------------------
FileClose
	LDX #$36
	STX CH376_COMMAND
	STA CH376_DATA

	CLC									; Saut inconditionel
	BCC CH376_CmdWait


;---------------------------------------------------------------------------
; 11 Octets
;---------------------------------------------------------------------------
ByteWrGo
	LDA #$3D
	STA CH376_COMMAND
	JSR WaitResponse
	CMP #INT_DISK_WRITE
	RTS

WriteLeader2
		jsr SetByteAndWrite
		jsr WriteLeader	; Ecriture de l'amorce
		jsr WriteFileHeader+3	; Retour à la routine $E607 pour sauvegarde de l'entête
		; jsr WriteRqData	; Flush du fichier (Inutile, effectué automatiquement par PutTapeByte)
		rts

; E72b
LE735
;==========


;---------------------------------------------------------------------------
; 32 Octets
;---------------------------------------------------------------------------
	new_patch($E735,LE75A)
	;LE735
	; E735 - E759: 37 octets
	; Saute la bande amorce
	; Sortie ACC: octet trouvé
	; On pourrait sortir quand on a trouvé un $24 (inutile de remonter les $16 avant)

	; Ok: 36/37 octets
SyncTape
		;lda #<TNAME		; Forcé dans SetFilename2
		;ldy #>TNAME
		jsr SetFilename2
		jsr FileOpen

		lda #$ff
		tay
		jsr SetByteRead
		jsr ReadUSBData3
		jsr GetTapeByte
		ldx #$00		; Sortir avec X=0 car utilisé en $E4B6 pour le Flag d'erreur
		rts

ReadUSBData3
		lda #$27
		sta CH376_COMMAND
		lda CH376_DATA
		sta PTR
		rts
; E755
LE75A
	; WriteLeader
;#endif


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
	new_patch($E76A,LE790)

SetupTape
	; E76A - E781: 24 octets
	;InitVIA
	; Ok: 10/24 octets

InitCH376
Exists
	LDX #6
	STX CH376_COMMAND
	LDA #$FF
	STA CH376_DATA
	LDA CH376_DATA
	BNE ZZZ001
SetUSB
	LDA #$15
	STA CH376_COMMAND
;	LDX #6
	STX CH376_DATA

	;Wait 10us
	NOP
	NOP
	JSR Mount

	;IFF ^.Z THEN InitError;
	BNE ZZZ001
	RTS

ZZZ001
InitError
	JMP $D4DA
;	ldx #$D7
;	jmp $C47E	; "?CAN'T CONTINUE ERROR"
;	jmp $D35C	; "?OUT OF DATA ERROR"

;	jmp $E651	; Si $02B1 != 0 -> jmp $E656
;	jmp $E656	; "Errors found" (mais pas de retour au BASIC)
;---------------------------------------------------------------------------
; 27 Octets
; ATTENTION: Déborde sur la routine "Comparer nom demandé et non trouvé"
; en $E790 - $E7AE, d'ou le patch de la routine $E4AC
;---------------------------------------------------------------------------
SetByteRead
	LDX #$3A
;	BNE CH376_Cmd2
	.byte $2c

SetByteWrite
	LDX #$3C
;	BNE CH376_Cmd2

CH376_Cmd2
	STX CH376_COMMAND
	STA CH376_DATA
	STY CH376_DATA

CH376_CmdWait2
	JSR WaitResponse
	CMP #INT_DISK_READ
	RTS
;---------------------------------------------------------------------------
ByteRdGo
	LDA #$3B
	STA CH376_COMMAND
	BNE CH376_CmdWait2

LE790
#ifdef ORIX
VIA2_IORA = $0321
RESET = $fffc

BackToOrix
		lda #$07
		sta V2DRA
		jmp (RESET)
#endif
; E7A7
LE7AF


;---------------------------------------------------------------------------
;  8 Octets : Patch routine existante
;---------------------------------------------------------------------------
	new_patch($E93D,LE946)

LE93D
	; E93D - E945: 9 octets
	; RestaureVIA
	; En fait on ne change que l'intruction en $E940
	; Ok: 6/9 octets
		jsr ClrTapeStatus
		lda #$01		; Fermeture avec mise à jour de la taille
		jmp FileClose
; E945
LE946
	; CALL



;---------------------------------------------------------------------------

;#endif






;	jmp $D4DA	; "?UNDEF'D FUNCTION ERROR"
;
;	ldx #$D7
;	jmp $C47E	; "?CAN'T CONTINUE ERROR"

;---------------------------------------------------------------------------
;			Personalisation de la ROM
;---------------------------------------------------------------------------
	;
	; Message de Copyright
	;
	new_patch($ED96,LEDC2)

	; Maxi 44 octets
CopyRight
	.byte "ORIC EXTENDED BASIC V1.1", $0D, $0A
	.byte $60," 1983 TANGERINE", $0D, $0A
	.byte $00,$00
LEDC2

	;
	; Couleur Papier/Encre au boot
	;
	new_patchl($F914,10)

		lda #$03	; Encre jaune
		sta $026c
		lda #$10	; Papier noir
		sta $026b

#ifdef NORAMCHECK
	;
	; Supprime le test de la RAM
	; pour accélérer le démarrage
	;
	new_patchl($FA4E,15)
	.dsb 15, $ea

	new_patchl($FA75,2)
	nop
	nop
#endif

	;
	; Pointe vers le message de Copyright
	; Pour Telestrat (signature de la banque)
	new_patchl($fff8,2)
	.word CopyRight


	;
	; Modification pour la commande 'bank' de Orix
	; qui fait un 'jmp $c000' et non un 'jmp ($fffc)
	;
	new_patchl($c000,3)
	jmp $f88f


#ifdef ORIX
	; Remplace TRON par QUIT
	new_patchl($c0fc,4)
	.byte 'QUI','T'+$80

	; Modifie adresses d'exécution TROFF -> QUIT
	new_patchl($C010,2)
	.word $cd16-1

	; Modification de TRON pour retour vers ORIX
	new_patch($CD16,LCD1F)

		ldy #7
boucle
		lda BackToOrix,y
		sta 0,y
		dey
		bpl boucle
		jmp 0
LCD1F
#endif
