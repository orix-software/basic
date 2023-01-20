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

	option PRAVETZT, OFF

        option AUTO_USB_MODE, OFF
        option MULTIPART_SAVE, OFF
        option SET_CHROOT, ON

        ; Si la carte contient un vrai 6522
        option VIA2_6522, OFF
        ; Si la carte contient juste le  minimum
        option VIA2_FAKE, ON


        option NO_CHARSET, SET
        option ORIX_CLI, SET
        option LOAD_CHARSET, SET
        option ORIX_SIGNATURE, SET

        option FORCE_ROOT_DIR, SET

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
	option PARTVETZT, OFF

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
		.if PRAVETZT = 0
			.define COPYRIGHT_MSG1 "ORIC EXTENDED BASIC V1.1",$0D,$0A
			.define COPYRIGHT_MSG2 $60," 1983 TANGERINE",$0D,$0A
			.define COPYRIGHT_MSG COPYRIGHT_MSG1 , COPYRIGHT_MSG2
		.else
			.define COPYRIGHT_MSG1 "\x70\x72\x61\x77\x65\x63\x2d\x38\x64               \r\n"
			.define COPYRIGHT_MSG2 "\x62\x72\x77 _ BASIC     \r\n"
			.define COPYRIGHT_MSG COPYRIGHT_MSG1 , COPYRIGHT_MSG2
		.endif
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

.if .not GAMES
	.if .not .match(ROOT_DIR, "ROOT_DIR")
		.if VERSION = 100
			.define ROOT_DIR "/HOME/BASIC10"
		.else
                        .if .not ROM_122
			        .if PRAVETZT = 0
				        .define ROOT_DIR "/HOME/BASIC11"
			        .else
				        .define ROOT_DIR "/HOME/PRAVETZT"
			        .endif
	                .else
			        .define ROOT_DIR "/HOME/BASIC12"
		        .endif
		.endif
	.endif
.endif


.if JOYSTICK_DRIVER
	option JOYSTICK_DEFAULT_CONF, SET
.else
	option JOYSTICK_DEFAULT_CONF, OFF
.endif



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
			.if PRAVETZT = 0
				.define ROOT_DIR "/USR/SHARE/BASIC11"
			.else
				.define ROOT_DIR "/USR/SHARE/PRAVETZT"
			.endif
		.endif
	.endif
	;.define FAST_LOAD
	option EXPERIMENTAL, OFF
	option ROM_122, OFF
	option MULTIPART_SAVE, OFF

	; Cyclotron modifie l'octet en $99, donc on doit forcer le mode du CH376
	;.undef AUTO_USB_MODE
        option AUTO_USB_MODE, OFF

	option JOYSTICK_EXTERNAL_CONF, SET

        ; Nécessaire au moins pour L'aigle d'or et Rat Splat
        option FORCE_MULTIPART, ON

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
	.out .sprintf("Type                  : GAMES (v%d.%02d)", VERSION/100, VERSION-(VERSION/100)*100)
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
				.if PRAVETZT = 0
					.define DEFAULT_CHARSET "/USR/SHARE/FONTS/DEFAULT.CHS"
				.else
					.define DEFAULT_CHARSET "/USR/SHARE/FONTS/PRAVETZT.CHS"
				.endif
			.else
				.if PRAVETZT = 0
					.define DEFAULT_CHARSET .sprintf("%s/%s", ROOT_DIR, "DEFAULT.CHS")
				.else
					.define DEFAULT_CHARSET .sprintf("%s/%s", ROOT_DIR, "PRAVETZT.CHS")
				.endif
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
.if AUTO_USB_MODE
	CH376_MODE	= $99			; Mis à jour par Orix lors de l'appel
					; à la rom
					; /!\ doit être 3 ou 6, pas de vérification
.endif

JOY_TBL         = $f3


;---------------------------------------------------------------------------
;
;			Variables en page 2
;
;---------------------------------------------------------------------------
fTextMode	= HIRES_flag			; 0:TEXT, 1:HIRES (pour DEF CHAR)


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
;			    I/O en page 3
;
;---------------------------------------------------------------------------


;---------------------------------------------------------------------------
;
;		      Spécifique Twilighte / Orix
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
.if VERSION = 110
        LE62A           = WriteFileHeader+35
.endif


;---------------------------------------------------------------------------
;
;---------------------------------------------------------------------------
StartBASIC      = ColdStart

