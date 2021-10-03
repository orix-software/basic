; vim: set ft=asm6502-2 ts=8 et:

.ifndef BASIC_INC
        ;----------------------------------------------------------------------
        ; Defines / Constants
        ;----------------------------------------------------------------------
        .ifdef __TEST__

                Token_USR =$90
                Token_EQ =$90
                Token_FN =$90
                Token_FOR =$90
                Token_TO =$90
                Token_STEP =$90
                Token_GOSUB =$90
                Token_POP=$90
                Token_GOTO =$90
                Token_THEN =$90
                Token_ELSE =$90
                Token_DATA =$90
                Token_SUB =$90
                Token_TAB =$90
                Token_SPC =$90
                Token_AT =$90
                Token_REPEAT =$90
                Token_PULL =$90
                Token_GT =$90
                Token_ADD =$90
                Token_NOT =$90
                Token_SGN =$90
                Token_CHR =$90
                Token_POINT =$90
                Token_SOUND =$90
                Token_STOP =$90
                Token_INK =$90
                Token_PRINT =$90
                Token_REM =$90
                Token_AUTO =$90

                COMMAND_TOKENS = $20

                Error02_msg =$90
                Error03_msg =$90
                Error04_msg =$90
                Error05_msg =$90
                Error06_msg =$90
                Error08_msg =$90
                Error09_msg =$90
                Error11_msg =$90
                Error12_msg =$90
                Error13_msg =$90
                Error14_msg =$90
                Error15_msg =$90
                Error16_msg =$90
                Error17_msg =$90
                Error18_msg =$90
                Error19_msg =$90

                ; pour LIST.s, NEW_CLEAR.s
                LC6ED := *
                ; pour IF.s (commenter pour GOTO.s)
                LCA3F = *
                ; Pour LLIST.s
                LC854 = *
                ; Pour INPUT.s
                ; LCEAC = *
                ; Pour NEXT.s
                LCF14 = *
                ; Pour RND.s
                LE346 = *
                ; Pour STOP.s
                LC960 = *
                ; Pour CLOAD_CSAVE.s (commenter pour tape.s)
                LE7AF = *
        .endif
	        ;----------------------------------------------------------------------
	        ;				Page Zéro
	        ;----------------------------------------------------------------------

        MOVEPARAMS      := $000C                        ;
        SRCPTR          := $000C                        ;
        DSTPTR          := $000E                        ;
        HRS_CURSOR      := $0010                        ;
        TXTLINE_PTR     := $0012                        ;
        SOUND_DATA      := $0014                        ;
        INPUT_FLAG      := $0017                        ;
        KEYWORD_ADDR    := $0018                        ;
        READY_vector    := $001A                        ; JMP $xxxx
        DOKE_ADDR       := $001D                        ;
        LINE_ADDR       := $001F                        ;
        USR_hook        := $0021                        ; JMP $xxxx
        TERMINATOR1     := $0024                        ;
        TERMINATOR2     := $0025                        ;
        LINESIZE        := $0026                        ;
        VARFOUND        := $0027                        ;
        STRFLAG         := $0028                        ;
        INTFLAG         := $0029                        ;
        KEYWFLAG        := $002A                        ;
        ARRAYFLAG       := $002B                        ;
        INPUTCODE       := $002C                        ;
        COMPARECODE     := $002D                        ;
        KBD_flag        := $002E                        ; b7: Actif/Inactif
        CONVERT_TMP     := $002F                        ;
        CURPOS          := $0030                        ; Position du curseur (écran ou imprimante)
        LINEWIDTH       := $0031                        ; Longueur d'une ligne (imprimante)
        TABMAX          := $0032                        ; Position maximale pour tabulation (,)
        INTTMP          := $0033                        ; Tampon pour les entiers (2 octets)
        KBDBUF          := $0035                        ; Tampon clavier

        .if VERSION = 100
                TAPE_SNAME      := $0035			;  Nom du programme demandé (v1.0)
                TAPE_FNAME      := $0049                        ;  Nom du programme trouvé (v1.0)
                TAPE_HEADER     := $005E                        ;  Début entête fichier K7 (v1.0)
                TAPE_START      := $005F                        ;  Adresse de début (v1.0)
                TAPE_END        := $0061                        ;  Adresse de fin (v1.0)
                TAPE_MODE       := $0063                        ;  $00: Normal, autre: AUTO (v1.0)
                TAPE_TYPE       := $0064                        ;  $00: BASIC, $80: LM, $40: Tableau (v1.0)
                TAPE_DUMMY1     := $0065                        ;  Inutilsé (v1.0)
                TAPE_DUMMY2     := $0066                        ;  Inutilsé (v1.0)
                TAPE_SPEED      := $0067                        ;  Erreur pendant la lecture de la K7 (v1.0)
        .endif

        DESCPTR         := $0085                        ; Pointeur sur la pile des descripteurs
        DESCPREV        := $0086                        ; Précédent pointeur sur la pile des descripteurs
        DESCSTACK       := $0088                        ; Pile des descripteurs (3 fois 3 octets)
        PTR1            := $0091                        ;
        PTR2            := $0093                        ;
        FACC3           := $0095                        ;
        BASTXT          := $009A                        ; Debut du texte BASIC
        VARTAB          := $009C                        ; Adresse de debut des variables simples, fin du texte BASIC
        ARYTAB          := $009E                        ; Debut des tableaux, fin des variables simples
        ARYEND          := $00A0                        ; Fin des tableaux
        STREND          := $00A2                        ; Plafond des chaines (adresse de la 1ere chaine)
        STRPTR_tmp      := $00A4                        ; Adresse de la chaine reservée & travail
        MEMSIZ          := $00A6                        ; HIMEM
        CURLINE         := $00A8                        ; Ligne courante
        CONTLINE        := $00AA                        ; Sauvegarde de la ligne courante pour CONT
        TXTPTR_save     := $00AC                        ; Sauvegarde de TXTPTR pour CONT
        DATALINE        := $00AE                        ; READ: N° de ligne courante
        DATAPTR         := $00B0                        ; Pointeur DATA
        DATAPTR_wrk     := $00B2                        ; Pointeur DATA (travail)
        VAR_name        := $00B4                        ; 2 premiers caractères du nom de la variable
        VARPTR2         := $00B6                        ;
        VARPTR          := $00B8                        ; Adresse d'une variable
        TXTPTR_SAV2     := $00BA                        ;
        OPCOMP_CODE     := $00BC                        ;
        FN_EVAL         := $00BD                        ;
        STRPTR_wrk      := $00BF                        ; Chaine (travail)
        STRLEN          := $00C2                        ;
        FCT_vector      := $00C3                        ; JMP xxxx ; évaluation d'une fonction
        FACC4           := $00C6                        ;
        FACC5           := $00CB                        ;
        FACC1           := $00D0                        ;
        FACC1_JUSTIF    := $00D7                        ;
        FACC2           := $00D8                        ;

        STRPTR          := $00DE                        ; Pointeur vers une chaîne
        PROD_SIGN       := $00DE                        ; Signe d'un produit
        FACC1_EXT       := $00DF                        ;

        SAVETXTPTR      := $00E0                        ;
        CharGet         := $00E2                        ; Prends le caractère suivant du tampon d'entrée
        CharGot         := $00E8                        ; Renvoie le caractère courant du tampon d'entrée
        TXTPTR          := $00E9                        ;
        RNDVal          := $00FA                        ; Valeur de RND
        NUM_BUFFER      := $00FF                        ;

	        ;----------------------------------------------------------------------
	        ;				Page 1
	        ;----------------------------------------------------------------------
        STACK           := $0100                        ; Pile du 6502

	        ;----------------------------------------------------------------------
	        ;				Page 2
	        ;----------------------------------------------------------------------
        WORK1           := $0200                        ;
        WORK2           := $0201                        ;
        WORK3           := $0202                        ;
        WORK4           := $0203                        ;
        WORK5           := $0204                        ;
        WORK6           := $0205                        ;
        .if VERSION = 100
                WORK7           := $0206                        ; Travail pour décalage (v1.0)
                WORK8           := $0207                        ; Travail pour décalage (v1.0)
        .endif

        KBD_CODE        := $0208                        ;
        KBD_CTLCODE     := $0209                        ;
        KBD_COLPATTERN  := $020A                        ;
        ;KBD_CTLCOLPATRN := $020B                       ;
        UPPERCASE_flag  := $020C                        ; $FF: Majuscules, $7F: Minuscules
        KBD_COLCNT      := $020D                        ;
        KBD_REPEATCNT   := $020E                        ;
        .if VERSION = 100
                WORK9           := $020F                        ; Travail pour le AY8912 (v1.0)
        .endif
        KBD_WORK1       := $0210                        ;
        KBD_WORK2       := $0211                        ;

        FB_CODE         := $0212                        ;
        PATTERNVAL      := $0213                        ;
        PATTERNWORK     := $0214                        ;
        HRS_VAL         := $0215                        ;
        HRS_ADR_SAVE    := $0216                        ;
        PATTERN_SAVE    := $0218                        ;
        HRS_XCOORD      := $0219                        ;
        HRS_YCOORD      := $021A                        ;
        XCIRCLE         := $021B                        ;
        YCIRCLE         := $021D                        ;
        HIRES_flag      := $021F                        ; $00; TEXT, $01: HIRES

        RAMSIZEFLG	:= $0220                        ;

        .if VERSION = 100
                IRQ_hook        := $0228                        ;  JMP IRQ ; $EC03 (v1.0)
                NMI_hook        := $022B                        ;  JMP $F430 (v1.0)
                RTI_hook        := $0230                        ;  RTI (v1.0)
        .else
                VDU_hook        := $0238                        ; JMP Char2Scr ; $F77C
                KBD_hook        := $023B                        ; JMP CheckKbd ; $EB78
                PRINTER_hook    := $023E                        ; JMP LPrintChar ; $F5C1
                PRINTSTATUS_hook:= $0241                        ; JMP PrintStatus ; Inutilisé?
                IRQ_hook        := $0244                        ; JMP IRQ ; $EE22
                NMI_hook        := $0247                        ; JMP $F8B2
                RTI_hook        := $024A                        ; RTI

                TAPE_SPEED      := $024D                        ; 0: Fast, 'S': Slow (mis à jour par GetTapeParams)
                KBDWAIT         := $024E                        ; Délai avant répétition d'une touche
                KBDREPEAT       := $024F                        ; Délai pour répétition d'une touche
                CURSOR_ENAB_SAVE:= $0251                        ;
                IF_flag         := $0252                        ; b7: Pas de IF/IF
                FIRSTCOL        := $0253                        ; n° de la première colonne valide (0 ou 2)
                PRINTER_WIDTH   := $0256                        ; Nombre de caractères par ligne
                SCREEN_WIDTH    := $0257                        ; Nombre de caractères par ligne
                LPRPOS          := $0258                        ; Position tête d'impressions
                CURPOS_SAVE     := $0259                        ;
                MERGEFLG        := $025A                        ; Flag pour MERGE
                VERIFYFLG       := $025B                        ; Flag pour VERIFY
                ERRORCOUNT      := $025C                        ; Nombre d'erreurs (pour VERIFY)
                TAPE_TYPESTR    := $025E                        ; Type du programme (B/C/I/S/R)

                RAMFAULT        := $0260                        ;
        .endif

        CTL_OUT_vector  := $0261                        ;
        LINEADDR_WORK   := $0263                        ;
        CURSOR_WORK     := $0265                        ;
        SCREENY         := $0268                        ; N° de ligne du curseur
        SCREENX         := $0269                        ; N° de colonne du curseur
        DISPKBDFLG      := $026A                        ; b6: Double hauteur, b5: 38/40 colonnes, b4: ESC, b3: Click, b1: Affichage, b0: Curseur
        PAPER_val       := $026B                        ; Couleur colonne 0 (PAPER)
        INK_val         := $026C                        ; Couleur colonne 1 (INK)

        .if VERSION = 100
                LINE0_ADDR      := $026D                        ;  Adresse de début de l'écran (v1.0)
                SCROLL_LINES    := $026F                        ;  Nombre de lignes TEXT (v1.0)
        .endif

        CURSOR_STATE    := $0271                        ;
        TIMER1          := $0272                        ; Gestion du clavier
        TIMER2          := $0274                        ; Clignotement du curseur
        TIMER3          := $0276                        ; Utilisateur (WAIT)

        .if VERSION > 100
                LINE2_ADDR      := $0278                        ;
                LINE1_ADDR      := $027A                        ;
                SCROLL_BYTES    := $027C                        ; Nombre de caractères pour le scrool TEXT
                SCROLL_LINES    := $027E                        ; Nombre de lignes TEXT

                TAPE_SNAME      := $027F                        ; Nom du programme demandé
                TAPE_FNAME      := $0293                        ; Nom du programme trouvé
                TAPE_HEADER     := $02A8                        ; Début entête fichier K7
                TAPE_START      := $02A9                        ; Adresse de début
                TAPE_END        := $02AB                        ; Adresse de fin
                TAPE_MODE       := $02AD                        ; $00: Normal, autre: AUTO
                TAPE_TYPE       := $02AE                        ; $00: BASIC, $80: LM, $40: Tableau
                TAPE_STR        := $02AF                        ; Flag Tableau Chaines / Nombres
                TAPE_INT        := $02B0                        ; Flag Tableau Entiers / Réels
                TAPE_ERR        := $02B1                        ; Erreur pendant la lecture de la K7
        .endif

        MEMMODE         := $02C0                        ; b0: TEXT/HIRES, b1: GRAB/RELEASE
        HIMEM_MAX       := $02C1                        ; Valeur HIMEM
        RELCURSOR_FLAG  := $02C3                        ;

        ASCII_CODE      := $02DF                        ;

        SOUNDHIRES_ERR  := PARAMS                       ; Drapeau erreur pour les instructions SOUND/HIRES
        PARAMS          := $02E0                        ; Début du bloc des paraamètres pour les fonctions Son/Graphqiue
        PARAM1          := $02E1                        ; Paramètre 1 pour instructions SOUNDS/HIRES
        PARAM2          := $02E3                        ; Paramètre 2 pour instructions SOUNDS/HIRES
        PARAM3          := $02E5                        ; Paramètre 3 pour instructions SOUNDS/HIRES
        PARAM4          := $02E7                        ; Paramètre 4 pour instructions SOUNDS/HIRES
        PARAMCOUNT      := $02F0                        ; Nombre de paramètres pour instructions SOUNDS/HIRES

        PRINTERFLG      := $02F1                        ; b7: Imprimante HS/ Imprimante OK
        LISTRETURNFLAG  := $02F2                        ;
        TRACEFLG        := $02F4                        ; b7: TROFF/TRON

        BANG_hook       := $02F5                        ; JMP $xxxx ; $D336

        .if VERSION = 100
                INVERSEFLG      := $02F7                        ;  Flag vidéo inverse (v1.0)
        .endif

        XPOS_SAVE       := $02F8                        ;
        AMPERSAND_hook  := $02FB                        ; JMP $xxxx ; $D336

        ;---------------------------------------------------------------------------
        ;			Couleurs
        ;---------------------------------------------------------------------------
        BLACK  .set 0
        RED    .set 1
        GREEN  .set 2
        YELLOW .set 3
        BLUE   .set 4
        PURPLE .set 5
        CYAN   .set 6
        WHITE  .set 7

        ;---------------------------------------------------------------------------
        ;---------------------------------------------------------------------------
        BASIC_INC = 1
.endif
