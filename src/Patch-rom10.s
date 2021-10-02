; vim: set ft=asm6502-2 ts=8 et:

.feature pc_assignment
.feature string_escapes

.include "macros/patch.mac"
.include "include/basic.inc"
.include "include/system.inc"
.include "include/CH376.inc"
.include "include/basic_rom.inc"
.include "config/orix-1xx.inc"


.if 0
::HOBBIT .set 1
::GAMES .set 1
::SET_CHROOT .set 1
::FORCE_ROOT_DIR .set 1
::FORCE_UPPERCASE .set 1

.define ROOT_DIR "/HOME/BASIC"

AUTO_USB_MODE .set 0
CH376_USB_MODE = 3

OPENFFLAG	= $020f			; Flag pour détecter si un fichier .tap a été ouvert (0: Fichier ouvert, 1: Fichier fermé)
MULTIPFLAG	= $0267			; Flag pour Multipart (0: Fichier ouvert, 1: GetTapeParams a été appelé)


;SyncTape (36)
;        - SyncTape      (33)
;
;GetTapeByte + GetTapeBit + GetTapeSignal (102)
;        - GetTapeByte   (14)
;        - SetFilename2  (49 +5 si Chroot)
;        - CH376_2       (28+11)

.endif

;---------------------------------------------------------------------------
;			Patch de la routine StartBASIC
;---------------------------------------------------------------------------
.if ORIX_CLI
	new_patch (StartBASIC+$E5),LEB41
		; jmp BackToBASIC
		jmp ORIX_AUTOLOAD
	LEB41:
.endif


;---------------------------------------------------------------------------
;			Personnalisation de la ROM
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	; Message de Copyright
	;---------------------------------------------------------------------------
	new_patch BasicVersMsg,LEB7E
		; Maxi 44 octets
		Copyright:
			.byte COPYRIGHT_MSG

        assert_address "COPYRIGHT_MSG", $EB7D

			.res $EB7E-*,$00
	LEB7E:


	;---------------------------------------------------------------------------
	; Couleur Papier/Encre au boot
	;---------------------------------------------------------------------------
	new_patchl $f8d7,10

			lda	#DEFAULT_INK
			sta	INK_val
			lda	#$10+DEFAULT_PAPER
			sta	PAPER_val

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
.if ORIX_SIGNATURE
		new_patchl $fff8,2
				.word Copyright
.endif

	;---------------------------------------------------------------------------
	; Modification pour la commande 'bank' de Orix
	; qui fait un 'jmp $c000' et non un 'jmp ($fffc)
	;---------------------------------------------------------------------------
;		new_patchl $c000,3
;				jmp	Reset

.if BASIC_QUIT
	;---------------------------------------------------------------------------
	; Remplace TRON par QUIT
	;---------------------------------------------------------------------------
	new_patchl $c0fe, 4
			string80 "QUIT"

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TRON -> QUIT
	;---------------------------------------------------------------------------
	new_patchl $c00e,2
			.word QUIT-1

	;---------------------------------------------------------------------------
	; Modifie adresses d'exécution TROFF -> QUIT
	; au cas ou...
	;---------------------------------------------------------------------------
	new_patchl $c010,2
			.word QUIT-1

	;---------------------------------------------------------------------------
	; 9 octets disponibles de $CD16 à $CD1E inclus
	; Peut être transféré vers _FileNotFound ou MICROSOFT!
	;---------------------------------------------------------------------------
	new_patch TRON, LCC95
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
		LCC95:

        ;---------------------------------------------------------------------------
        ;			Patch de la routine BackToBASIC
        ; v1.0 uniquement
        ;---------------------------------------------------------------------------
        new_patchl BackToBASIC,3
                ; Supprime le jmp TROFF etle remplace par un LSR
                lsr     TRACEFLG
.endif

;---------------------------------------------------------------------------
;			Ajout Driver Joystick Telestrat
;---------------------------------------------------------------------------
.if JOYSTICK_DRIVER
	;---------------------------------------------------------------------------
	; Patch pour la routine par défaut en $02B (Kbd_hook)
	;---------------------------------------------------------------------------
	;new_patchl $f87f,3
	;	jmp CheckJoystick

	;---------------------------------------------------------------------------
	; Patch pour de la routine ReadKbdCol
	;---------------------------------------------------------------------------
	.out "Joystick driver: ReadKbdCol"

		; Patch de la routine CheckKbd
		new_patchl ReadKbd+5,3
			jsr CheckJoystick

	.if JOYSTICK_EXTERNAL_CONF
	.out "Joystick driver: Keep external config (no RND init)"

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

		new_patchl StartBASIC+53,2
			ldx #$11

	.endif

	.if JOYSTICK_DEFAULT_CONF
	.out "Joystick driver: Add default configuration"

		; Ajoute une configuration par défaut
		; Copiée automatiquement au démarrage par la Coldstart en $ECFB
		; qui copie Charget et RND en RAM
		new_patchl LEA24+17,7
			.byte $AF	; Fire 2 => [Enter]
			; .byte $A9	; Fire 3 => [Esc]
                        .byte $00	; Fire 3 => N/A (Teporaire)
			.byte $B4	; Down   => [Down_arrow]
			.byte $BC	; Right  => [Right_arrow]
			.byte $AC	; Left   => [Left_arrow]
			.byte $84	; Fire   => [Space]
			.byte $9C	; Up     => [Up_arrow]
	.endif

.endif


;---------------------------------------------------------------------------
;		Ajout chargement dynamique du jeu de caractères
;---------------------------------------------------------------------------
.if NO_CHARSET
	; Patche de la routine d'init pour ne pas
	; copier le jeu de caractères depuis la rom vers la ram.
	; On suppose que l'Oric a déjà démarré et que le jeu est en place
	; Initialise le CH376 au lieu d copier le jeu ROM->RAM
	new_patchl LF888+21,3
	;jsr InitCH376
	jsr load_charset
.endif

;---------------------------------------------------------------------------
;		Ajout chargement dynamique du jeu de caractères
;---------------------------------------------------------------------------
.if LOAD_CHARSET
	; Patche de la routine d'init pour ne pas
	; copier le jeu de caractères depuis la rom vers la ram.
	; On suppose que l'Oric a déjà démarré et que le jeu est en place
	; Charge un jeu decaractères depuis la carte SD/USB

	; Original: Patch de la routine d'init
	;	new_patchl LF8B8+26,3
	;	jsr load_charset

	; Patch de la routine de copie de bloc(PATCH_MoveCharset teste X=5)
	.out "Characters set init: load from file"
		new_patch MoveCharset, LF94E
		; LF93E
		jmp     PATCH_MoveCharset
        LF940:
                lda     ROMRAM_table,x                  ; F940 BD 4E F9
                sta     STACK+255,y                     ; F943 99 FF 01
                dex                                     ; F946 CA
                dey                                     ; F947 88
                bne      LF940                          ; F948 D0 F6
                ; jsr     CopyMem_vector                  ; F94A 20 D9 EB
                jsr     CopyMem                         ; F94A 20 D9 EB
                rts                                     ; F94D 60
	LF94E:

.endif

;---------------------------------------------------------------------------
;				CLOAD
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	; Patch la détection multipart de certains jeux qui ne passe pas par CLOAD
	;---------------------------------------------------------------------------
.if .not FORCE_MULTIPART
	new_patchl (CLOAD+9),3
		jsr CloadMultiPart
.endif

        ;---------------------------------------------------------------------------
        ; Patch l'appel à SyncTape pour détecter l'appel direct
        ;---------------------------------------------------------------------------
        new_patchl TapeSync,3
	        jsr SyncTape+3

        ; ============================================================================
        ;                             SyncTape (33 octets)
        ; ============================================================================
	        new_patch SyncTape,LE6BA

                .proc _SyncTape
	                        ; Il faut vérifier si on à déjà ouvert un fichier ou non
	                        ; pour le multitap
	                        jmp SyncTape_loop			; Point d'entrée direct, on suppose du multitap
	                        jsr OpenForRead			; Point d'entrée depuis TapeSync, multitap uniquement si on fait CLOAD ""
	                        ;jsr	SetFilename2
	                        ;jsr	FileOpen
	                        beq SyncTape_loop
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
                .endproc
                LE6BA:

                assert_address "SyncTape", $E6BA

        ; ============================================================================
        ;                               GetTapeData
        ; 24 octets disponibles
        ; ============================================================================
        .if FAST_LOAD
                .out "Mode Fast Load        : activé"

                new_patchl GetTapeData,3
                        ;---------------------------------------------------------------------------
                        ; GetTapeData (40 octets avec les nop / 43 octets pour la version BASIC 1.1)
                        ; 38 octets pour BASIC 1.0
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
                        ;	TAPE_START
                        ;
                        ; Sous-routines:
                        ;	ReadUSBData
                        ;	ByteRdGo
                        ;---------------------------------------------------------------------------
                        jmp     _GetTapeData

                        assert_address "GetTapeData", $E503
        .endif

        ; ============================================================================
        ;                               GetTapeByte
        ; ============================================================================
        ; [ --- E630 (102 octets dispponibles)
	; ----------------------------------------------------------------------------
	; GetTapeByte: Modifié (14 octets+1)
	; ----------------------------------------------------------------------------
	new_patch GetTapeByte,LE696

        .proc _GetTapeByte
                        tya                                     ; E6C9 98
                        pha                                     ; E6CA 48
                        txa                                     ; E6CB 8A
                        pha                                     ; E6CC 48

	                jsr 	ReadUSBData3			; Lit un caractère, résultat dans CONVERT_TMP
                        ; temporaire pour v1.0 sans FAST_LOAD
                        ; à voir si on pourra suuprimer ce clc par la suite
                        clc
                        ;       fin_erreur:

	        fin:
	                pla                                     ; E6F5 68
	                tax                                     ; E6F6 AA
	                pla                                     ; E6F7 68
	                tay                                     ; E6F8 A8
	                lda     CONVERT_TMP                     ; E6F9 A5 2F
	                rts                                     ; E6FB 60
        .endproc

        ; ============================================================================
        ;                               SetFilename2
        ; ============================================================================
		        ;---------------------------------------------------------------------------
		        ; 35 Octets + 5 en ZZD001 (ou 45+5 si FORCE_UPPERCASE)
		        ; 49 octets + 5 si SET_CHROOT + 3 si FORCE_ROOT_DIR + 10 si FORCE_UPPERCASE
		        ;---------------------------------------------------------------------------
        .proc SetFilename2
		        ;sta PTR_READ_DEST
		        ;sty PTR_READ_DEST+1

                .if ::SET_CHROOT
		        jsr	SetChroot
		        bne	fin
                .endif
		        lda	#CH376_CMD_SET_FILE_NAME
		        sta	CH376_COMMAND

                .if ::FORCE_ROOT_DIR
		        sta	CH376_DATA		; Pour ouverture de '/'
                .endif

		        ldy	#$ff
		        ;---
		        sty	CONVERT_TMP             ; Flag pour détection du '.'
	        ZZ0003:
		        iny
		        ;lda (PTR_READ_DEST),y
		        lda	TAPE_SNAME,y
		        beq	ZZ0004

		        cmp	#'.'
		        bne	*+4
		        sty	CONVERT_TMP

		        sta	CH376_DATA
                ;       bne	ZZ0003
		        jmp	ZZ0003

	        ZZ0004:
		        bit	CONVERT_TMP		; '.' vu?
		        sty	CONVERT_TMP		; Sauvegarde la longueur (utilisée par CSAVE)
		        bmi	ZZ0005-2			; Non -> ajoute '.TAP'
		        lda	#$00			; Ajoute <NULL>
		        beq	fin_null

		        ldy	#$ff			; Ajoute '.TAP'
	        ZZ0005:
		        iny
		        lda	ZZD001,y

                .if ::FORCE_UPPERCASE
	                ; Force le nom du fichier .tap en majuscules
                        cmp     #'a'
                        bcc     bk2
                        cmp     #'z'+1
                        bcs     bk2
                        eor     #'a'-'A'
                bk2:
                .endif

                fin_null:
                        sta	CH376_DATA
                        bne	ZZ0005
                fin:
                        rts
        .endproc

        ; ============================================================================
        ;                               CH376_2 (39 octets)
        ; ============================================================================
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


        LE696:
        assert_address "GetTapeByte", $E696


; ============================================================================
; CheckFoundName
; 1 Octet : Patch pour CheckFoundName, retourne OK
; Esapce disponible: $e6f0-$e70d (30 octets)
; suivi par EasterEgg (20 octets)
; ============================================================================
	new_patchl CheckFoundName+4,1
		rts

	new_patchl CheckFoundName+5,25
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
                .proc ReadUSBData
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
                .endproc

                LE70E:
                assert_address "ReadUSBData", $E70E

; ============================================================================
; charset.inc
; ============================================================================
.if NO_CHARSET
.out "\n+-------------+"
.out "|   charset   |"
.out "+-------------+\n"

	.if .not HOBBIT
		new_patch (CharSet+$18), CharSet_end
	.endif

        ; ============================================================================
        ;                               FileNotFound (30/24 octets)
        ; ============================================================================

        ;---------------------------------------------------------------------------
        ; (24 octets)
        ;---------------------------------------------------------------------------
        ;
        ; Efface la ligne de status + 'FILE NOT FOUND ERROR'
        ; Utilisé pour indiquer une erreur lors de la lecure d'un fichier
        ;---------------------------------------------------------------------------
        ; $fda2: 'F' -> 'H'
        ; $fd50: ";" -> '=' (Hobbit)
        .out "\t_FileNotFound"
        .proc _FileNotFound
                        jsr     LE804
        ;               jmp     $d35c

                        ; Reprend le début de PrintErrorX
                        lsr     KBD_flag                        ; C485 46 2E
                        lsr     PRINTERFLG                      ; C487 4E F1 02
                        lsr     LISTRETURNFLAG                  ; C48A 4E F2 02
                        lsr     TRACEFLG                        ; C48D 4E F4 02
                        jsr     NewLine                         ; C490 20 9F CB
                        jsr     LCC10                           ; C493 20 10 CC

                        lda     #<FileNotFound_msg
                        ldy     #>FileNotFound_msg
                        jsr     PrintString
                        ; Retour à PrintErrorX
                        jmp     LC4A3
        .endproc

        ; ============================================================================
        ; 15 octets
        ; ============================================================================

                ; Message d'erreur (15 octets)
                FileNotFound_msg:
                        .byte "FILE NOT FOUND",00


        ; ============================================================================
        ;                               OpenForRead
        ; HOBBIT: 16/17
        ; GAMES:  28/29
        ; NORMAL: 24/25
        ; ============================================================================

        ;---------------------------------------------------------------------------
        ; OpenForRead (17 octets) +8
        ; HOBBIT: 17
        ; GAMES:  29
        ; NORMAL: 25
        ;---------------------------------------------------------------------------
        ; Ouvre un fichier en lecture
        ;
        ; TODO: A voir si il faut conserver tous les tests pour la version "normale"
        ;        de la rom basic11 ou si il ne faut conserver que le premier test
        ;        et faire du .ifdef HOBBIT le cas général et la partie .else le cas
        ;        pour la version GAMES
        ;
        ; Entree:
        ;        -
        ;
        ; Sortie:
        ;        A: Code de retour du CH376
        ;
        ; Modifie:
        ;        OPENFFLAG: Flag fichier ouvert/fermé
        ;        MULTIPFLAG: Flag pour le multipart
        ;
        ; Utilise:
        ;        -
        ; Sous-routines:
        ;        CloseOpenedFile
        ;        FileOpen
        ;---------------------------------------------------------------------------
        ; $fdba: 'H' -> 'L'
        ; $ff50: '{' -> 'Damier' (Hobbit)
        .out "\tOpenForRead"

        .proc OpenForRead
                        lda     TAPE_SNAME                        ; Si CLOAD "" => fin (multipart)
                        beq     fin
                .if ::HOBBIT
                                jsr     CloseOpenedFile
                                lda     #$00
                .else

;                        .if ::GAMES
                                ; Le jeu "Them" utilise un CLOAD " " pour charger le second module
                                ; => si le premier caractère du nom du fichier est ' ' on suupose du multipart
                                ; /!\ On ne teste que le premier caractère
                                cmp     #' '
                                beq     fin
;                        .endif
                                ; Test pour Hellion, Frelon, Psy...
                                ; Ces jeux chargent le second programme en faisant
                                ; un appel direct en $E867 (Atmos)
                                ; Ne peut pas être intégré dans le cas de la rom "Hobbit"
                                ; car modifie des caractères utilisés par le jeu
                                ; (Sauf à déplacer OpenForRead ailleurs)
                                ;
                                ; Test non valable dans le cas de Harrier Attack qui force TAPE_SPEED à 0 sans passer par GetTapeParams
        ;                        bit     TAPE_SPEED
        ;                        bvc     *+6
        ;                        lda     #$00
                                lda     MULTIPFLAG                        ; Si on n'est pas passé par GetTapeParams => fin (multipart, appel direct aux routines de la ROM)
                                beq     fin
                                jsr     CloseOpenedFile
                                ;jsr     SetFilename2

                                ; Initialise TAPE_SPEED avec $40 pour la détection d'un CLOAD sans
                                ; passer par la procédure normale (Hellion, Frelon, Psy...)
                                ; TAPE_SPEED est initialisé à 0 ou 'S' par GetTapeParams
                                ; (paramètres Slow)
                                ; --- PAS VALABLE POUR HARRIER ATTACK ---
        ;                        lda     #$40
        ;                        sta     TAPE_SPEED
                                lda     #$00                        ; Indique fichier ouvert (CLOAD "xxx", RECALL v$,"XXX")
                                sta     MULTIPFLAG
                .endif

        ;                lda     #$00
                        sta     OPENFFLAG                        ; Indique fichier ouvert
                        jmp     FileOpen

                fin:
                        rts
        .endproc

        ; ============================================================================
        ;                               CloseOpenedFile (14 octets)
        ; ============================================================================

        ;---------------------------------------------------------------------------
        ; CloseOpenedFile ( 13 octets)
        ;---------------------------------------------------------------------------
        ; Ferme le fichier actuellement ouvert et prépare l'ouverture d'un fichier
        ;
        ; Entree:
        ;        -
        ;
        ; Sortie:
        ;        -
        ;
        ; Modifie:
        ;        OPENFFLAG: Flag fichier ouvert
        ;
        ; Utilise:
        ;        -
        ; Sous-routines:
        ;        FileClose
        ;---------------------------------------------------------------------------
        ; $fdd7: 'L' -> 'M'
        ; $ff61: '}' -> 'Damier' (Hobbit)
        ; Note: VOLCANIC4 nécessite la rom Hobbit et utilise le caractère "Plein"
        .out "\tCloseOpenedFile"
        .proc CloseOpenedFile
                        lda     OPENFFLAG                        ; Fichier ouvert?
                        bne     suite
                        ; Fermeture du fichier actuel
                        ;lda     #$01                        ; Indique fichier fermé
                        ;sta     OPENFFLAG
                        inc     OPENFFLAG                        ; Indique fichier fermé
                        jsr     FileClose
                suite:
                        jmp     SetFilename2
        .endproc



        ; ============================================================================
        ;                               SetChroot (13+33 octets)
        ; ============================================================================
        .out "\tSetChroot"

        .proc SetChroot
                        lda     CHROOT_PATH
                        ldx     #<(CHROOT_PATH+1)
                        ldy     #>(CHROOT_PATH+1)
                        jsr     open_fqn
                        cmp     #ERR_OPEN_DIR
                        rts

                        ; TEMPORAIRE POUR COMPATIBILITE
                        ; TODO: Déplacer CHROOT_PATH VERS UNE ADRESSE FIXE A LA FIN DE CHARSET
        ;                .res    $fe6f-*, $ea

                CHROOT_PATH:
                        .byte   PATH_END-*-1
                        .byte   ROOT_DIR

                PATH_END:
                        .res    33-(*-CHROOT_PATH),0
        .endproc


        .if LOAD_CHARSET

                default_chs_len:
	                .byte default_chs_end-default_chs-1
                default_chs:
	                .byte DEFAULT_CHARSET,0
                default_chs_end:


                ; ============================================================================
                ;                       Open_fqn (100 octets)
                ; ============================================================================
                ;---------------------------------------------------------------------------
                ; open_fqn (103 octets -3)
                ;---------------------------------------------------------------------------
                ; Ouvre un fichier (chemin absolu ou relatif sans ../)
                ; Les paramètres en entrée sont les mêmes que ceux en sortie de jsr CheckStr/ReleaseVarStr
                ; Ce qui permet d'appeler open_fqn ainsi (Cf: CD.pl65)
                ;                jsr EvalExpr
                ;                jsr CheckStr
                ;                beq erreur
                ;                jsr open_fqn
                ;
                ; Entree:
                ;        XY: Adresse de la chaine
                ;        A: Longueur de la chaine
                ;
                ; Sortie:
                ;        AY: Code erreur CH376 ($41 si Ok)
                ;        PTR1: Adresse de la chaine
                ;
                ; Modifie:
                ;        INTTMP: Longueur de la chaine (remis à sa valeur initiale en fin de procédure)
                ;        INTTMP+1: Index dans la chaine (remis à sa valeur initiale en fin de procédure)
                ;        PTR1: Adresse de la chaine
                ;
                ; Utilise:
                ;        -
                ; Sous-routines:
                ;        InitCH376
                ;        FileOpen
                ;---------------------------------------------------------------------------
                ; $fcae: '&' -> '6'
                .out "\topen_fqn"
                .proc open_fqn
                                stx     PTR1
                                sty     PTR1+1

                                ; Longueur de la chaîne
                                sta     INTTMP
                                                                                        ; PTR1+3 = 0;
                                lda     #$00
                                sta     INTTMP+1
                                ; Note: InitCH376 fait un Mount USB qui replace le répertoire par
                                ; defaut a '/'
                                ; A modifier pour autoriser un repertoire relatif
                                                                                        ; CALL InitCH376;
                                jsr     InitCH376
                                                                                        ; IF .Z THEN
                                bne     ZZ1002
                                                                                        ; BEGIN;
                                ; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
                                                                                        ; IF &PTR1 = '/' THEN
                                ldy     #$00
                                lda     #'/'
                                cmp     (PTR1),Y
                                ;beq      *+5
                                ;jmp     ZZ1003
                                bne     ZZ1003
                                                                                        ; BEGIN;
                                ; Apres le test, .A contient '/' soit $2F
                                                                                        ; CH376_COMMAND = .A; " SetFilename";
                                sta     CH376_COMMAND
                                                                                        ; CH376_DATA = .A;
                                sta     CH376_DATA
                                                                                        ; CH376_DATA = $00;
                                ;        lda     #$00
                                ;        sta     CH376_DATA
                                                                                                        ; CALL FileOpen; " Detruit X et Y";
                                ;        jsr     FileOpen
                                ; Optimisation taille: Gain 5 octets
                                jsr     ZZ0006
                                                                                        ; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
                                cmp     #ERR_OPEN_DIR
                                bne     CD_End
                                                                                        ; INC PTR1+3;
                                inc     INTTMP+1
                                                                                        ; END;
                                                                                        ; IF PTR1+3 < PTR1+2 THEN CH376_COMMAND = $2F; " SetFilename";
                        ZZ1003:
                                ;        lda     INTTMP
                                ;        cmp     INTTMP+1
                                ;        beq      *+4
                                ;        bcs      *+5
                                ;        jmp     ZZ1004
                                ; Optimisation en inversant le test: Gain 5 octets
                                lda     INTTMP+1
                                cmp     INTTMP
                                bcs     ZZ0006

                                lda     #$2F
                                sta     CH376_COMMAND
                        ZZ1004:
                                ; Remplacer BCC *+5/JMP ZZnnnnn par BCS ZZnnnnn
                                                                                        ; WHILE PTR1+3 < PTR1+2
                        ZZ1005:
                                ldy     INTTMP+1
                                cpy     INTTMP
                                ;bcc      *+5
                                ;jmp     ZZ0006
                                bcs     ZZ0006
                                                                                        ; DO;
                                ; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
                                ; IF &PTR1[PTR1+3] = '/' THEN
                                                                                        ; .Y = PTR1+3;
                                ; Optimisation
                                ;ldy     INTTMP+1
                                                                                        ; .A = @PTR1[.Y];
                                lda     (PTR1),Y
                                ; Remplacer BEQ *+5/JMP ZZnnnnn par BNE ZZnnnnn
                                                                                        ; IF .A = '/' THEN
                                cmp     #'/'
                                ;beq      *+5
                                ;jmp     ZZ0007
                                bne     ZZ0007
                                                                                        ; BEGIN;
                                                                                        ; CH376_DATA = 0;
                                ;        lda     #$00
                                ;        sta     CH376_DATA
                                                                                                ; CALL FileOpen;
                                ;        jsr     FileOpen
                                ; Optimisation taille: Gain 5 octets
                                jsr     ZZ0006
                                                                                        ; IFF .A ^= #ERR_OPEN_DIR THEN CD_End;
                                cmp     #ERR_OPEN_DIR
                                bne     CD_End
                                                                                        ; INC PTR1+3;
                                inc     INTTMP+1
                                                                                                        ; IF PTR1+3 < PTR1+2 THEN CH376_COMMAND = $2F; " SetFiPTR1+2ame";
                                ;        lda     INTTMP
                                ;        cmp     INTTMP+1
                                ;        beq      *+4
                                ;        bcs      *+5
                                ;        jmp     ZZ0008
                                ; Optimisation en inversant le test: Gain 5 octets
                                ldy     INTTMP+1
                                cpy     INTTMP
                                bcs     ZZ0008

                                lda     #$2F
                                sta     CH376_COMMAND
                        ZZ0008:
                                                                                                ; .Y = PTR1+3;
                                ; Optimisation
                                ;ldy     INTTMP+1
                                                                                        ; .A = @PTR1[.Y];
                                lda     (PTR1),Y
                                                                                        ; END;
                                                                                        ; CH376_DATA = .A;
                        ZZ0007:
                                sta     CH376_DATA
                                                                                        ; INC PTR1+3;
                                inc     INTTMP+1
                                                                                        ; END;
                                jmp     ZZ1005

                        ZZ0006:
                                                                                        ; CH376_DATA = $00;
                                lda     #$00
                                sta     CH376_DATA
                                                                                        ; CALL FileOpen;
                                jsr     FileOpen
                                                                                        ; CD_End:
                        CD_End:
                                                                                        ; END;
                                ;        ; .AY = Code erreur, poids faible dans .A
                        ZZ1002:
                                                                                        ; .Y = .A;
                                ;        tay
                                                                                                ; CLEAR .A;
                                ;        lda     #$00
                                                                                                ;RETURN;
                                rts
                .endproc
        .endif

        .if LOAD_CHARSET
                ; ============================================================================
                ;                               InitCh376 (32+3 octets)
                ; ============================================================================
                ;---------------------------------------------------------------------------
                ; InitCH376 (31 octets)
                ;---------------------------------------------------------------------------
                ; Initialisation du CH376
                ;
                ; Entree:
                ;        -
                ;
                ; Sortie:
                ;        A: Code de retour du CH376
                ;
                ; Modifie:
                ;        -
                ;
                ; Utilise:
                ;        -
                ; Sous-routines:
                ;        Mount
                ;---------------------------------------------------------------------------
                ; $fd68: '<' -> 'B'
                .out "\tInitCh376, Exists, SetUSB"

                ;load_charset:
                ;        jsr     MoveCharset                                ; Copie ROM->RAM (appelé depuis LF8B8 avec X=5)
                InitCH376:
                Exists:
                        ldx     #CH376_CMD_CHECK_EXIST
                        stx     CH376_COMMAND
                        lda     #$ff
                        sta     CH376_DATA
                        lda     CH376_DATA
                        bne     InitError
                SetUSB:
                        lda     #CH376_CMD_SET_USB_MODE
                        sta     CH376_COMMAND
                .if .not AUTO_USB_MODE
                        ldx     #CH376_USB_MODE
                .else
                        ldx     CH376_MODE
                .endif
                        stx     CH376_DATA

                        ;Wait 10us
                        nop
                        nop
                        jsr     Mount

                ;IFF ^.Z THEN InitError;
                ;        bne        InitError
                ;        rts

                InitError:
                        rts
        .endif

        ; ============================================================================
        ;                               ReadUSBData3 (29 octets)
        ; ============================================================================

        ;---------------------------------------------------------------------------
        ; ReadUSBData3 (29 octets)
        ;---------------------------------------------------------------------------
        ; Lit un caractère depuis la K7
        ;
        ; Note: Optimisation impossible pour Hobbit qui utilise INTTMP pendant le
        ;       chargement (Lone Raider aussi).
        ;
        ; Entree:
        ;        -
        ;
        ; Sortie:
        ;        C: 0->Ok, 1-> Erreur
        ;        A: Caractère lu
        ;        X: 0
        ;        Y: 1
        ;        $2f: Caractère lu
        ;
        ; Modifie:
        ;        INTTMP: valeur: $002f
        ;
        ; Utilise:
        ;        -
        ; Sous-routines:
        ;        -
        ;---------------------------------------------------------------------------
        ; $fd4e: ':' -> '='
        ; $fcb8: '(' -> '+' (Hobbit)
        .out "\tReadUSBData3"
        .proc ReadUSBData3
                        ; On lit 1 caractère
                        lda     #$01
                        ldy     #$00
        ;               sty     INTTMP+1
                        jsr     SetByteRead
                        bne     fin_erreur
                .if 1
                        lda     #CH376_CMD_RD_USB_DATA0
                        sta     CH376_COMMAND
                        lda     CH376_DATA                        ; Nombre de caractère à lire
                        lda     CH376_DATA                        ; Caractère lu
                        sta     $2f
                        jsr     ByteRdGo                        ; Nécessaire en réel, sinon le CH376 boucle sur son buffer
                        clc                                        ; Indique pas d'erreur de lecture
                        .byte    $24
                .else
                        lda     #$2f                                ; On veut le caractère lu dans $2F
                        sta     INTTMP
                        jmp     ReadUSBData
                .endif
                fin_erreur:
                        sec
                        rts
        .endproc


        ; ============================================================================
        ;                               CH376_1 (32 octets)
        ; ============================================================================

        ;---------------------------------------------------------------------------
        ; 32 octets
        ;---------------------------------------------------------------------------
        ; $fd8c: 'B' -> 'E'
        ; $fc90: '#' -> '&' (Hobbit)
        .out "\tSetByteWrite, SetByteRead, ByteRdGo"
        SetByteWrite:
                ldx     #CH376_CMD_BYTE_WRITE
                jsr     CH376_Cmd2
                cmp     #INT_SUCCESS
                rts

        SetByteRead:
                ldx     #CH376_CMD_BYTE_READ

        CH376_Cmd2:
                stx     CH376_COMMAND
                sta     CH376_DATA
                sty     CH376_DATA

        CH376_CmdWait2:
                jsr     WaitResponse
                cmp     #INT_DISK_READ
                rts
        ;---------------------------------------------------------------------------
        ByteRdGo:
                lda     #CH376_CMD_BYTE_RD_GO
                sta     CH376_COMMAND
                bne     CH376_CmdWait2


        ;---------------------------------------------------------------------------
        ;
        ;---------------------------------------------------------------------------
        .if LOAD_CHARSET
                ; ******************************************************************************
                ; TRANSFERT POSSIBLE JUSTE AVANT CHROOT_PATH SI ON DECALE CHROOT_PATH DE 2 OCTETS
                ; Patch pour la copie du jeu de caractères ROM -> RAM
                .out "\tPATCH MoveCharset"

                .proc PATCH_MoveCharset
	                ldy #$06
	                cpx #$05		; X=5 si copie du jeu de caractère
	                beq suite
	                jmp LF940

                suite:
	                jmp load_charset
             .endproc
        .endif

        ;---------------------------------------------------------------------------
        ; SetByteReadWrite (29 octets +15)
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
        ;	TAPE_START: Adresse de début du programme
        ;	TAPE_END: Adresse de fin du programme
        ;
        ; Sous-routines:
        ;	SetByteRead
        ;	SetByteWrite
        ;---------------------------------------------------------------------------
        ; $fd2d: '6' -> ':'
        ; $fe50: '[' -> '^' (Hobbit)
        .out "\tSetByteReadWrite"
        .proc SetByteReadWrite
                sec				; Point d'entrée pour une lecture
                .byte     $24
                clc				; Point d'entrée pour une écriture

                php				; Sauvegarde P pour plus tard

        _CalcPgmLength:
                sec				; Calcule la taille du programme
                lda	TAPE_END
                sbc	TAPE_START
                tax

                lda	TAPE_END+1
                sbc	TAPE_START+1
                tay

        _WriteLength:
                inx				; +1
                bne	*+3
                iny

                txa

                plp
                bcc     *+5
                jmp     SetByteRead
                jmp     SetByteWrite
        .endproc

	.if JOYSTICK_DRIVER
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
                .out "\tCheckJoystick"
                .proc CheckJoystick
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

                normal:
	                tya			; Restaure le code de la touche
	                bne repetition_test	; vers le cmp $0208


                special:
	                tya
	                sta $0209
	                clc			; Indique B2/B3 appuyé (on doit remettre C=0 à cause du cmp #%00100000 qui l'a mis à 1
	                bne J1			; Ou: BIT xx pour gagner un octet

                B2B3_invalid:
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

                retour:
	                plp			; Restaure P pour savoir si on a appuyé sur B2 ou B3 (touche spéciale)
	                lda $0208		; Instruction supprimée de ReadKbd
	                ; B2 ou B3 appuyé?
	                ; Autorise combo <touche>+<B2/B3> en plus de <direction>+>B2/B3> et >B2/B3>+>direction> (<B2/B3>+>touche> => <touche> non pris en compte)
	                ;bcc repetition
	                ;bcc fin
	                bcc autre_direction
	                rts			; Retour à ReadKbd

                up:
	                iny
                fire:
	                iny
                left:
	                iny
                right:
	                iny
                down:
                        ; plp
	                lda JOY_TBL,y		; La table doit contenir le code de la touche
	                ; Tester si il s'agit de la même direction
	                ; Si oui -> rts possible
	                ; Si non -> initialiser $020E, mettre à jour $0208 et $020A puis retour à faire en LF4C6
	                bpl retour		; Si la touche n'est pas définie, on repart vers ReadKbd
	                ;beq retour		; Si la touche n'est pas définie, on repart vers ReadKbd
	                ;ora $80		; b7=1 pour indiquer qu'une touche est appuyée
	                plp

                repetition_test:
	                cmp $0208
	                bne autre_direction

                repetition:
	                tay
	                pla			; Oublie l'adresse de retour
	                pla
	                tya
	                jmp ReadKbd+26		; Retour, gestion répétition

	                ; calculer le masque pour la colonne et le mettre dans $020A
                autre_direction:
	                ;ora $80		; b7=1 pour indiquer qu'une touche est appuyée
	                sta $0208		; Sauvegarde le code de la touche dans $0208

	                ; On calcule le masque pour la ligne
	                ; correspondant à la touche
	                and #$07		; N° de ligne de la touche
	                tay			; Sert de compteur
	                iny

	                clc
	                lda #$ff
                loop:
	                rol
	                dey
	                bne loop
	                sta $210		; Masque de la ligne dans $0210

	                lda $f464		; Initialise le compteur pour la répétition
	                sta $020e
                ;fin:
	                pla			; Oublie l'adresse de retour
	                pla

	                lda $0208		; Replace le code de la touche dans A

	                jmp LF46B		; Retour à ReadKbd

                .endproc
	.endif

        ; ============================================================================
        ;                              WaitResponse
        ; A déplacer dans PutTapeByte
        ; ============================================================================
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
        .out "\tWaitResponse"
        .proc WaitResponse
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
        .endproc


        ; /!\ A déplacer dans WriteLeader
	; Utilisé par SetFilename2
	; 5 octets
	ZZD001:
		.byte ".TAP",0

        ;---------------------------------------------------------------------------
        ; 11 Octets
        ; Ne peut être dans GetTapeByte en version 1.0 (il manque 5 octets)
        ;---------------------------------------------------------------------------
        .out "\tByteWrGo"
        ByteWrGo:
                lda	#CH376_CMD_BYTE_WR_GO
                sta	CH376_COMMAND
                jsr	WaitResponse
                cmp	#INT_DISK_WRITE
                rts

	;---------------------------------------------------------------------------
	; 8 octets
	; A déplacer dans PutTapeByte
	;---------------------------------------------------------------------------
        .out "\tCloadMultiPart"
	CloadMultiPart:
			lda	#$01
			sta	MULTIPFLAG
			jmp	GetTapeParams


        CharSet_end:
        assert_address "Charset", KeyCodeTab

.endif

; ============================================================================
; ramtest.s
; ============================================================================
.out "\n+-------------+"
.out "|   ramtest   |"
.out "+-------------+\n"

        ;---------------------------------------------------------------------------
        ;			Patch de la routine RamTest
        ;---------------------------------------------------------------------------
        ;.ifdef NORAMCHECK
	        ;
	        ; Supprime le test de la RAM
	        ; pour accélérer le démarrage
	        ;
	        ; Libère de $FA06 à $FA6B soit 156 octets
	        ;
	        new_patch RamTest,LFA6C

	        lda     #$bf
                sta     PARAM1+1                        ; F9FD 8D E2 02
                lda     #$FF                            ; FA00 A9 FF
                sta     PARAM1                          ; FA02 8D E1 02
.if FORCE_MULTIPART
                sta     MULTIPFLAG
.endif
	        lda     #$00
	        sta     RAMSIZEFLG
                rts                                     ; FA05 60

        .if ORIX_CLI
                .out "\tORIX_AUTOLOAD"
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
        .endif

        .if BASIC_QUIT
                .out "\tBASIC_QUIT"
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
                        jmp	(RST_vector)
        .endif

        ; ============================================================================
        ;                               load_charset
        ; ============================================================================
        .if LOAD_CHARSET
                .out "\tload_charset"

                ;---------------------------------------------------------------------------
                ; load_charset (30 octets)
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
                ;	TAPE_START: Pointeur vers l'adresse de chargement
                ;	TAPE_END  : Pointeur vers l'adresse de fin de chargement
                ;
                ; Utilise:
                ;	-
                ; Sous-routines:
                ;	open_fqn
                ;	GetTapeData
                ;---------------------------------------------------------------------------
                ; $fcae
                .proc load_charset
                        ; Ouverture du fichier
                        lda default_chs_len
                        ldx #<default_chs
                        ldy #>default_chs
                        jsr open_fqn
                        bne load_charset_error

                        ; Adresse de chargement
                        lda #<$b500
                        ldy #>$b500
                        sta TAPE_START
                        sty TAPE_START+1

                        ; Adresse de fin
                        ;lda #<($b500+$300)			; Inutile, le poids faible reste à 0
                        ldy #>($b500+$300)
                        sta TAPE_END
                        sty TAPE_END+1

                        ; Chargement du jeu de caractères
                        jsr GetTapeData

                load_charset_error:
                        rts
                .endproc
        .endif

        ; ============================================================================
        ;                               GetTapeData
        ; ============================================================================
        .if FAST_LOAD
                .out "\tGetTapeData"
                ;---------------------------------------------------------------------------
                ; GetTapeData (40 octets avec les nop / 43 octets pour la version BASIC 1.1)
                ; 38 octets pour BASIC 1.0
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
                ;	TAPE_START
                ;
                ; Sous-routines:
                ;	ReadUSBData
                ;	ByteRdGo
                ;---------------------------------------------------------------------------
                ;GetTapeData:
                .proc _GetTapeData
                        jsr	SetByteReadWrite
                        bne	_GetTapeData_error

                        lda     TAPE_START
                        ldy     TAPE_START+1
                        sta     INTTMP
                        sty     INTTMP+1

                        ; Boucle de chargement du fichier (25 octets avec les 3 nop)
                loop:
                        jsr     ReadUSBData
                        bcs     fin

                        ; Ajuste le pointeur
                        tya
                .if ::GAMES
                        bne     *+4				; Saute les 2 octets suivants
                        nop					; Poopy place $35 ici
                        nop					; Poopy place $A4 ici
                .endif
                        adc     INTTMP
                        sta     INTTMP
                        bcc     *+4
                        inc     INTTMP+1

                        jsr     ByteRdGo
                        beq     loop

                fin:
                _GetTapeData_error:
                        rts					; Poopy place $60 ici :)
                .if ::GAMES
                        nop					; Poopy place $A4 ici
                .endif
                .endproc
        LE503:
        .endif

        LFA6C:
        assert_address "RamTest", $FA6C

.if 0
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
		.scope
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
		.endscope

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
		.scope
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
		.endscope

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
	        .scope
			; On lit 1 caractère
			lda	#$01
			ldy	#$00
;			sty	INTTMP+1
			jsr	SetByteRead
			bne	fin_erreur			; A remplacer par un bne ZZZ002 pour gagner 2 octets (fin_erreur devient inutile)
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
		.endscope


; ============================================================================
; ============================================================================
			;---------------------------------------------------------------------------
			; OpenForRead (Normal: 24 octets / Hobbit: 16 / Games: 28)
			;---------------------------------------------------------------------------
			; Ouvre un fichier en lecture
			;
			; TODO: A voir si il faut conserver tous les tests pour la version "normale"
			;        de la rom basic11 ou si il ne faut conserver que le premier test
			;        et faire du .ifdef HOBBIT le cas général et la partie .else le cas
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
			.scope
				lda TAPE_SNAME			; Si CLOAD "" => fin (multipart)
				beq fin
	.if ::HOBBIT
				jsr CloseOpenedFile
				lda #$00
	.else

		.if ::GAMES
				; Le jeu "Them" utilise un CLOAD " " pour charger le second module
				; => si le premier caractère du nom du fichier est ' ' on suupose du multipart
				; /!\ On ne teste que le premier caractère
				cmp #' '
				beq fin
		.endif
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
	.endif

	;			lda #$00
				sta OPENFFLAG			; Indique fichier ouvert
				jmp	FileOpen

			fin:
				rts
			.endscope


		;---------------------------------------------------------------------------
		; CloseOpenedFile ( 14 octets)
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
		.scope
			lda OPENFFLAG			; Fichier ouvert?
			bne suite
			; Fermeture du fichier actuel
			;lda #$01			; Indique fichier fermé
			;sta OPENFFLAG
			inc OPENFFLAG			; Indique fichier fermé
			jsr FileClose
		suite:
			jmp SetFilename2
		.endscope



		;---------------------------------------------------------------------------
		; SetByteReadWrite (29 octets +15)
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
		;	TAPE_START: Adresse de début du programme
		;	TAPE_END: Adresse de fin du programme
		;
		; Sous-routines:
		;	SetByteRead
		;	SetByteWrite
		;---------------------------------------------------------------------------
		; $fd2d: '6' -> ':'
		; $fe50: '[' -> '^' (Hobbit)
		SetByteReadWrite:
		.scope
			sec				; Point d'entrée pour une lecture
			.byte $24
			clc				; Point d'entrée pour une écriture

			php				; Sauvegarde P pour plus tard

		_CalcPgmLength:
			sec				; Calcule la taille du programme
			lda	TAPE_END
			sbc	TAPE_START
			tax

			lda	TAPE_END+1
			sbc	TAPE_START+1
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
		.endscope


; ============================================================================
; ============================================================================

;	;---------------------------------------------------------------------------
;	; 6 octets
;	;---------------------------------------------------------------------------
;	CloadMultiPart:
;			jsr	MultiPart
;			jmp	GetTapeParams
;
;	;---------------------------------------------------------------------------
;	; 6 Octets à l'emplacement de "MICROSOFT!"
;	;
;	; Spécifique MultiPart (Harrier Attack)
;	;---------------------------------------------------------------------------
;	new_patch $e435,LE43F
;			; Place un flag pour la détection multipart
;			; pour certains programmes de Jeu
;	MultiPart:
;			lda	#$01
;			sta	MULTIPFLAG
;			rts

	;---------------------------------------------------------------------------
	; 8 octets
	;---------------------------------------------------------------------------
	CloadMultiPart:
			lda	#$01
			sta	MULTIPFLAG
			jmp	GetTapeParams


	;---------------------------------------------------------------------------
	; Patch la détection multipart de certains jeux qui ne passe pas par CLOAD
	;---------------------------------------------------------------------------
	new_patchl (CLOAD+1),3
		jsr CloadMultiPart


	;---------------------------------------------------------------------------
	; 16 octets / 172 => reste 156
	;---------------------------------------------------------------------------
ramtest:
	lda     #$00
	sta     RAMSIZEFLG
	lda     #$bf
        sta     PARAM1+1                        ; F9FD 8D E2 02
        lda     #$FF                            ; FA00 A9 FF
        sta     PARAM1                          ; FA02 8D E1 02
        rts                                     ; FA05 60


	;---------------------------------------------------------------------------
	; 9 octets disponibles de $CD16 à $CD1E inclus
	; Peut être transféré vers _FileNotFound ou MICROSOFT!
	;---------------------------------------------------------------------------
	new_patch TRON, LCD1F
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
		LCD1F:


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
			jmp LC4A1

		; Message d'erreur (15 octets)
		; $fdbf: 'I' -> 'J'
		; $fe71: 'Livre' -> '(c)' (Hobbit)
		FileNotFound_msg:
			.byte "FILE NOT FOUND",00


.if FAST_LOAD
	.out "Mode Fast Load        : activé"

	new_patch GetTapeData,LE50A
		;---------------------------------------------------------------------------
		; GetTapeData (40 octets avec les nop / 43 octets pour la version BASIC 1.1)
		; 38 octets pour BASIC 1.0
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
		;	TAPE_START
		;
		; Sous-routines:
		;	ReadUSBData
		;	ByteRdGo
		;---------------------------------------------------------------------------
		;GetTapeData:
		.scope
			jsr	SetByteReadWrite
			bne	_GetTapeData_error

			lda TAPE_START
			ldy TAPE_START+1
			sta INTTMP
			sty INTTMP+1

			; Boucle de chargement du fichier (25 octets avec les 3 nop)
		loop:
			jsr ReadUSBData
			bcs fin

			; Ajuste le pointeur
			tya
		.if ::GAMES
			bne *+4				; Saute les 2 octets suivants
			nop					; Poopy place $35 ici
			nop					; Poopy place $A4 ici
		.endif
			adc INTTMP
			sta INTTMP
			bcc *+4
			inc INTTMP+1

			jsr ByteRdGo
			beq loop

		fin:
		_GetTapeData_error:
			rts					; Poopy place $60 ici :)
		.if ::GAMES
			nop					; Poopy place $A4 ici
		.endif
		.endscope

	; Actuellement: $E503, $E508 si GAMES
	LE50A:

	;#print *
	.if * > $e50a
		.error .sprintf("*** ERROR GetTapeData too long: $%X", *)
	.endif

.endif

			; Utilisé par SetFilename2
			; 5 octets
		ZZD001:
			.byte ".TAP",0

	;---------------------------------------------------------------------------
	; 24 Octets
	;---------------------------------------------------------------------------
	new_patch GetTapeByte,LE735
		;LE6C9
		; E6C9 - E6FB: 51 octets
		; Chargement d'un octet
		; Doit conserver X et Y
		; Octet lu dans ACC (utilise $2F comme zone temporaire pour ACC)
		; Sortir avec C=0 et $2B1=0 (pas d'erreur de parité) (2B1 doit être mise à 0 quelque part avant...)

		; Ok: 24/51 octets
		;GetTapeByte:
		; ----------------------------------------------------------------------------
		; GetTapeByte: Modifié (14 octets)
		; ----------------------------------------------------------------------------
		.scope
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
		.endscope

		;---------------------------------------------------------------------------
		; 35 Octets + 5 en ZZD001 (ou 45+5 si FORCE_UPPERCASE)
		;---------------------------------------------------------------------------
			; SetFilename2: 38 octets
		SetFilename2:
		.scope
			;sta PTR_READ_DEST
			;sty PTR_READ_DEST+1
.if ::SET_CHROOT
			jsr	SetChroot
			bne	fin
.endif
			lda	#CH376_CMD_SET_FILE_NAME
			sta	CH376_COMMAND

.if ::FORCE_ROOT_DIR
			sta	CH376_DATA		; Pour ouverture de '/'
.endif

			ldy	#$ff
			;---
			sty	$2f			; Flag pour détection du '.'
		ZZ0003:
			iny
			;lda (PTR_READ_DEST),y
			lda	TAPE_SNAME,y
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
.if ::FORCE_UPPERCASE
			; Force le nom du fichier .tap en majuscules
		        cmp     #'a'
		        bcc     bk2
		        cmp     #'z'+1
		        bcs     bk2
		        eor     #'a'-'A'
		bk2:
.endif
		fin_null:
			sta	CH376_DATA
			bne	ZZ0005
		fin:
			rts
		.endscope

	;---------------------------------------------------------------------------
	; 33 Octets
	;---------------------------------------------------------------------------
	new_patch SyncTape,LE75A
		;LE735
		; E735 - E759: 37 octets
		; Saute la bande amorce
		; Sortie ACC: octet trouvé
		; On pourrait sortir quand on a trouvé un $24 (inutile de remonter les $16 avant)

		; ----------------------------------------------------------------------------
		; SyncTape: Modifié (33 octets /37)
		; ----------------------------------------------------------------------------
		;SyncTape:
		.scope
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
		.endscope

;---------------------------------------------------------------------------
;  1 Octet : Patch pour CheckFoundName, retourne OK
; Esapce disponible: $e6f0-$e70d (30 octets)
; suivi par EasterEgg (20 octets)
;---------------------------------------------------------------------------
	new_patchl CheckFoundName+4,1
		rts



;---------------------------------------------------------------------------
;			Patch de la routine StartBASIC
;---------------------------------------------------------------------------
.if ORIX_CLI
	new_patch (StartBASIC+$B7),LED86
		; jmp BackToBASIC
		jmp ORIX_AUTOLOAD
	LED86:
.endif

;---------------------------------------------------------------------------
;			Patch de la routine RamTest
;---------------------------------------------------------------------------
;.ifdef NORAMCHECK
	;
	; Supprime le test de la RAM
	; pour accélérer le démarrage
	;
	; Libère de $FA2C à $FA85 soit 90 octets
	;
	new_patch RamTest,LFA86
			; 24 octets
			ldy	#$00
			sty	RAMFAULT
			sty	RAMSIZEFLG
			sty	$0500
			sty	MEMSIZ
			sty	HIMEM_MAX
			lda	#$c0-$28
			sta	MEMSIZ+1
			sta	HIMEM_MAX+1
			rts

.if ORIX_CLI
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
.endif

.if BASIC_QUIT
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
			jmp	(RST_vector)
.endif

.if LOAD_CHARSET
		;---------------------------------------------------------------------------
		; load_charset (30 octets)
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
		;	TAPE_START: Pointeur vers l'adresse de chargement
		;	TAPE_END  : Pointeur vers l'adresse de fin de chargement
		;
		; Utilise:
		;	-
		; Sous-routines:
		;	open_fqn
		;	GetTapeData
		;---------------------------------------------------------------------------
		; $fcae
		load_charset:
		.scope
			; Ouverture du fichier
			lda default_chs_len
			ldx #<default_chs
			ldy #>default_chs
			jsr open_fqn
			bne load_charset_error

			; Adresse de chargement
			lda #<$b500
			ldy #>$b500
			sta TAPE_START
			sty TAPE_START+1

			; Adresse de fin
			;lda #<($b500+$300)			; Inutile, le poids faible reste à 0
			ldy #>($b500+$300)
			sta TAPE_END
			sty TAPE_END+1

			; Chargement du jeu de caractères
			jsr GetTapeData

		load_charset_error:
			rts
		.endscope
.else
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
	.if .not AUTO_USB_MODE
			ldx	#CH376_USB_MODE
	.else
			ldx	CH376_MODE
	.endif
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

.endif



.endif
