; vim: set ft=asm6502-2 ts=8 et:

	;-------------------------------------------------------------------
	;
	;-------------------------------------------------------------------

.include "macros/patch.mac"

; DANS LE MAKEFILE
; Configuration par défaut
;USB_MODE ?= sdcard
	CH376_USB_MODE .set SDCARD_MODE
;	CH376_USB_MODE .set USB_HOST_MODE
;BACK_TO_ORIX ?= yes
	option BASIC_QUIT, SET
;JOYSTICK ?= yes
	option JOYSTICK_DRIVER, OFF
;EXPERIMENTAL ?= no
	option EXPERIMENTAL, OFF
;ROM122 ?= no
	option ROM_122, OFF
;FAST ?= yes
	option FAST_LOAD, ON
;
; Configuration Par défautt
	option GAMES, OFF
	option HOBBIT, OFF
	option FORCE_UPPERCASE, OFF
	option ADD_DEF_CHAR, OFF
	option ADD_ERROR, OFF
	option ADD_ONERROR, OFF
	option JOYSTICK_EXTERNAL_CONF, OFF

        option FORCE_MULTIPART, OFF

.include "build.inc"

;---------------------------------------------------------------------------
;
;---------------------------------------------------------------------------
.ifndef CONFIG
        .out "Default to BASIC v1.1"
        CONFIG .set 2
.endif

.if VERSION = 100
        option JOYSTICK_DRIVER, ON
	option JOYSTICK_EXTERNAL_CONF, ON
        option ROM_122, OFF
        option EXPERIMENTAL, OFF

.else
        .if CONFIG = 0
                option HOBBIT, ON

        .elseif CONFIG = 1
                option GAMES, ON

        .elseif CONFIG = 2

        .elseif CONFIG = 3
                option ROM_122, ON
                ; option EXPERIMENTAL, ON
        .endif
.endif

;---------------------------------------------------------------------------
;
;			Personnalisation
;
;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
	;			Couleurs par défaut
	;---------------------------------------------------------------------------
.ifndef DEFAULT_INK
	DEFAULT_INK = WHITE
.endif

.ifndef DEFAULT_PAPER
	DEFAULT_PAPER = BLACK
.endif

	;---------------------------------------------------------------------------
	;			Message de Copyright
	;---------------------------------------------------------------------------
.if .not .match(COPYRIGHT_MSG, "COPYRIGHT_MSG")
        .if VERSION = 100
	        .define COPYRIGHT_MSG1 "ORIC EXTENDED BASIC V1.0",$0D,$0A
	        .define COPYRIGHT_MSG2 $60," 1983 TANGERINE",$0D,$0A
	        .define COPYRIGHT_MSG COPYRIGHT_MSG1 , COPYRIGHT_MSG2
        .else
	        .define COPYRIGHT_MSG1 "ORIC EXTENDED BASIC V1.1",$0D,$0A
	        .define COPYRIGHT_MSG2 $60," 1983 TANGERINE",$0D,$0A
	        .define COPYRIGHT_MSG COPYRIGHT_MSG1 , COPYRIGHT_MSG2
        .endif
.endif

	;---------------------------------------------------------------------------
	;			Mode du CH376
	;---------------------------------------------------------------------------
.if .not CH376_USB_MODE
	.define CH376_USB_MODE SDCARD_MODE
.endif

	;---------------------------------------------------------------------------
	;			Commande QUIT
	; Pris en charge par le Makefile
	;---------------------------------------------------------------------------
; .define BASIC_QUIT
; .define ROM_122
; .define FAST_LOAD
; .define ROOT_DIR "/HOME/BASIC11"

	;---------------------------------------------------------------------------
	;				Défaut
	;---------------------------------------------------------------------------
option NO_CHARSET, SET
option ORIX_CLI, SET
option LOAD_CHARSET, SET
option ORIX_SIGNATURE, SET

option FORCE_ROOT_DIR, SET

.if .not GAMES
        .if .not .match(ROOT_DIR, "ROOT_DIR")
	        .if VERSION = 100
		        .define ROOT_DIR "/HOME/BASIC10"
	        .else
		        .define ROOT_DIR "/HOME/BASIC11"
		.endif
	.endif
.endif


.if JOYSTICK_DRIVER
        option JOYSTICK_DEFAULT_CONF, SET
.else
        option JOYSTICK_DEFAULT_CONF, OFF
.endif

option AUTO_USB_MODE, OFF
option MULTIPART_SAVE, OFF
option SET_CHROOT, SET

; Si la carte contient un vrai 6522
option VIA2_6522, OFF
; Si la carte contient juste le  minimum
option VIA2_FAKE, SET

	;---------------------------------------------------------------------------
	;			Configuration "Games"
	;---------------------------------------------------------------------------
.if GAMES
	option HOBBIT, OFF
	option ORIX_SIGNATURE, OFF
	;.define FORCE_ROOT_DIR
	;.define ROOT_DIR "/USR/SHARE/GAMES"
        .if .not .match(ROOT_DIR, "ROOT_DIR")
	        .if VERSION = 100
		        .define ROOT_DIR "/USR/SHARE/BASIC10"
	        .else
		        .define ROOT_DIR "/USR/SHARE/BASIC11"
		.endif
	.endif
	;.define FAST_LOAD
	option EXPERIMENTAL, OFF
	option ROM_122, OFF
	option MULTIPART_SAVE, OFF

	; Cyclotron modifie l'octet en $99, donc on doit forcer le mode du CH376
	;.undef AUTO_USB_MODE

	option JOYSTICK_EXTERNAL_CONF, SET

.endif

	;---------------------------------------------------------------------------
	;			Configuration "Hobbit"
	;---------------------------------------------------------------------------
.if HOBBIT
	option JOYSTICK_DRIVER, OFF
	option JOYSTICK_DEFAULT_CONF, OFF
	option JOYSTICK_EXTERNAL_CONF, OFF
	option FORCE_ROOT_DIR, SET
	.undef ROOT_DIR
	;.define ROOT_DIR "/USR/SHARE/GAMES/"
	option EXPERIMENTAL, OFF
	option LOAD_CHARSET, OFF
	option ROM_122, OFF
	option MULTIPART_SAVE, OFF

	option SET_CHROOT, OFF
.endif

	;---------------------------------------------------------------------------
	;			Gestion Joystick
	; Pris en charge par le Makefile
	;---------------------------------------------------------------------------
.if JOYSTICK_DRIVER
	option HOBBIT, OFF
.endif

	;---------------------------------------------------------------------------
	;			Fonctions expérimentales
	;---------------------------------------------------------------------------
.if EXPERIMENTAL
	option ADD_DEF_CHAR, SET

	.ifdef ROM_122
		option ADD_ERROR, SET
		option ADD_ONERROR, SET
	.endif

.endif


	;---------------------------------------------------------------------------
	; Résumé de la configuration
	;---------------------------------------------------------------------------
.out "---------------------------------------------------------------------------"
.out "|                           Configuration                                 |"
.out "---------------------------------------------------------------------------"
.if GAMES
	.out .sprintf("Type                  : GAMES (v%d/%02d)", VERSION/100, VERSION-(VERSION/100)*100)
.elseif HOBBIT
	.out .sprintf("Type                  : Hobbit (v%d.%02d)", VERSION/100, VERSION-(VERSION/100)*100)
.else
	.out .sprintf("Type                  : Basic (v%d.%02d)", VERSION/100, VERSION-(VERSION/100)*100)
.endif

display_options ADD_DEF_CHAR ADD_ERROR ADD_ONERROR AUTO_USB_MODE BASIC_QUIT
display_options EXPERIMENTAL FAST_LOAD FORCE_ROOT_DIR FORCE_UPPERCASE
display_options FORCE_MULTIPART
display_options GAMES HOBBIT JOYSTICK_DEFAULT_CONF JOYSTICK_DRIVER JOYSTICK_EXTERNAL_CONF
display_options LOAD_CHARSET MULTIPART_SAVE NO_CHARSET ORIX_CLI ORIX_SIGNATURE
display_options ROM_122 SET_CHROOT VIA2_6522 VIA2_FAKE
display_color DEFAULT_INK
display_color DEFAULT_PAPER
.out "---------------------------------------------------------------------------"

	;---------------------------------------------------------------------------
	;			Chargement du jeu de caractères
	;---------------------------------------------------------------------------
.if NO_CHARSET
	.if LOAD_CHARSET
                .if .not .match(DEFAULT_CHARSET, "DEFAULT_CHARSET")
			.if FORCE_ROOT_DIR
				.define DEFAULT_CHARSET "/USR/SHARE/FONTS/DEFAULT.CHS"
			.else
				.define DEFAULT_CHARSET .sprintf("%s/%s", ROOT_DIR, "DEFAULT.CHS")
			.endif
		.endif
		.out .sprintf("Default charset       : %s", DEFAULT_CHARSET)
	.endif
.endif

	;---------------------------------------------------------------------------
	;			Gestion CHROOT
	;---------------------------------------------------------------------------
.if SET_CHROOT
	option FORCE_ROOT_DIR, OFF
	.out .sprintf("Mode 'CHROOT' activé  : %s", ROOT_DIR)
.endif

	;---------------------------------------------------------------------------
	;			Gestion VIA2
	;---------------------------------------------------------------------------
.if VIA2_6522
	option VIA2_FAKE, OFF
	.out "Mode VIA2             : 6522"
.else
	option VIA2_FAKE, SET
	.out "Mode VIA2             : Fake"
.endif

	;---------------------------------------------------------------------------
	;---------------------------------------------------------------------------
.out "\n\n"

;---------------------------------------------------------------------------
;
;			Variables en page 0
;
;---------------------------------------------------------------------------
;rwpoin          = $0C			; word

;KBD_flag        = $2e
;INTTMP          = $33			; $33-$34: Utilisé par GetTapeData

;PTR1            = $91			; Pointeur utilisé notamment par les fonctions
					; de manipulations des chaînes
					; Utilisé ici par open_fqn()

.if AUTO_USB_MODE
	CH376_MODE	= $99			; Mis à jour par Orix lors de l'appel
					; à la rom
					; /!\ doit être 3 ou 6, pas de vérification
.endif

;MEMSIZ       = $a6

;CURLINE         = $A8                        ; Ligne courante
;VAR_name         = $B4                        ; 2 premiers caractères du nom de la variable

;TXTPTR          = $e9
JOY_TBL         = $f3

;.if ROM_122
;	CURPOS          = $0030                        ; Position du curseur (écran ou imprimante)
;.endif

;---------------------------------------------------------------------------
;
;			Variables en page 2
;
;---------------------------------------------------------------------------
fTextMode	= HIRES_flag			; 0:TEXT, 1:HIRES (pour DEF CHAR)

;RAMSIZEFLG      = $0220
;RAMFAULT        = $0260

;TAPE_SPEED	= $024d			; 0: Fast, 'S': Slow (mis à jour par GetTapeParams)

;MERGEFLG	= $025a
;VERIFYFLG	= $025b

;PAPER_val       = $026b
;INK_val         = $026c

;TAPE_SNAME        = $027f

;HIMEM_MAX       = $02c1

;TAPE_START       = $02a9
;TAPE_END         = $02ab
;TAPE_TYPE        = $02ae

;.ifdef ROM_122
;IF_flag         = $0252                        ; b7: Pas de IF/IF
;LPRPOS          = $0258                        ; Position tête d'impressions
;SCREENY         = $0268                        ; N° de ligne du curseur
;SCREENX         = $0269                        ; N° de colonne du curseur
;SOUNDHIRES_ERR  = $02E0                        ; Drapeau erreur pour les instructions SOUND/HIRES
;PARAMS		= SOUNDHIRES_ERR
;PARAM1          = $02E1                        ; Paramètre 1 pour instructions SOUNDS/HIRES
;PARAM2          = $02E3                        ; Paramètre 2 pour instructions SOUNDS/HIRES
;PARAM3          = $02E5                        ; Paramètre 3 pour instructions SOUNDS/HIRES
;PRINTERFLG      = $02F1                        ; b7: Imprimante HS/ Imprimante OK
;.endif
;VDU_hook        = $0238                        ; JMP Char2Scr ; $F77C


;---------------------------------------------------------------------------
;
;			Spécifique Multi-Part
; Non utilisées par le BASIC
;---------------------------------------------------------------------------
.if VERSION = 100
        OPENFFLAG	= $0221			; Flag pour détecter si un fichier .tap a été ouvert (0: Fichier ouvert, 1: Fichier fermé)
.else
        OPENFFLAG	= $020f			; Flag pour détecter si un fichier .tap a été ouvert (0: Fichier ouvert, 1: Fichier fermé)
.endif
MULTIPFLAG	= $0267			; Flag pour Multipart (0: Fichier ouvert, 1: GetTapeParams a été appelé)


;---------------------------------------------------------------------------
;
;			I/O en page 3
;
;---------------------------------------------------------------------------
;VIA             = $0300                        ; VIA IORB
;VIA_IORA        = $0301
;VIA_DDRB        = $0302
;VIA_DDRA        = $0303

;---------------------------------------------------------------------------
;
;			Spécifique Telestrat
;
;---------------------------------------------------------------------------
VIA2_IORB    = $0320
VIA2_DDRA    = $0323

.if VIA2_6522
	VIA2_IORA    = $032f
.else
	VIA2_IORA    = $0321
.endif

BUFEDT       = $0590


;---------------------------------------------------------------------------
;			Routines ROM v1.1
;---------------------------------------------------------------------------
;CharGet         = $00e2

;PrintErrorX	= $c47e

;LC496           = $c496
;Back;ToBASIC     = $c4a8
;DoNextLine      = $c8c1
;SetScreen       = $c82f

;REM             = $ca99

;NewLine         = $cbf0
;PrintString     = $ccb0
;LCCD7           = $ccd7

;TRON            = $cd16

; Pour DEF CHAR
;EvalComma	= $d065
;SYNTAX_ERROR	= $d070
;FindVar		= $D1E8
;GIVAYF		= $D499
;DEF		= $D4BA
;DEF_USR		= $D4BE
;DEF_FN		= $D4DF
;GetByteExpr	= $d8c5
;MOVMF		= $DEAD
;TapeSync        = $e4ac
;GetTapeData     = $e4e0
;GetTapeParams   = $e7b2
;GetStoreRecallParams = $ea57

;ClrTapeStatus   = $e5f5
;WriteFileHeader = $e607
LE62A           = WriteFileHeader+35
;PutTapeByte     = $e65e
;WriteLeader     = $e75a
;GetTapeByte     = $e6c9
;SyncTape        = $e735
;SetupTape       = $e76a
;CheckFoundName  = $e790

;.ifdef FAST_LOAD
;	LE810		= $e810
;.endif

;CLOAD           = $e85b
;CSAVE           = $e909
;STORE           = $e987
;RECALL          = $e9d1
;LE93D           = $e93d
;CheckKbd        = $eb78

;.if JOYSTICK_DEFAULT_CONF
;	LEC9C           = $ec9c
;.else
;	.if ROM_122
;		LEC9C           = $ec9c
;	.endif
;.endif

;.if ROM_122
;	FindLine	= $c6b3
;	RESTORE		= $c952
;	GetExpr		= $cf03
;	POS		= $d4a6
;	WAIT		= $d958
;	RowCalc		= $da0c
;	GetWord		= $e853
;	POINT		= $ec45
;	LECB9		= $ecb9			; suite de CharGet en ROM
;	Delay		= $eec9
;	DrawLine	= $eef8
;	LEFFA		= $effa
;	ResetVIA	= $f9aa
;	SOUND		= $fb40
;.endif

;StopTimer       = $ee1a

StartBASIC      = ColdStart

;ReadKbd         = $f495
;LF4C6           = ReadKbd+49

;ReadKbdCol      = $f561

;LF8B8           = $f8b8

;RamTest         = $fa14
;CharSet         = $fc78
;KeyCodeTab      = $ff78

;Reset           = $f88f

;RESET_VECTOR    = RST_vector

; Pour la copie du jeu de caractères ROM -> RAM
;MoveCharset	= $f982
;ROMRAM_table	= $f992
;CopyMem		= $edc4


