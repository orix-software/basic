; vim: set ft=asm6502-2 ts=8 et:

.ifndef SYSTEM_INC
;----------------------------------------------------------------------
; Defines / Constants
;----------------------------------------------------------------------

	;----------------------------------------------------------------------
	;				Page 3
	;----------------------------------------------------------------------
VIA             := $0300                        ; VIA IORB
VIA_IORA        := $0301
VIA_DDRB        := $0302
VIA_DDRA        := $0303
VIA_T1C         := $0304
VIA_T1L         := $0306
VIA_T2C         := $0308
VIA_SR          := $030A
VIA_ACR         := $030B
VIA_PCR         := $030C
VIA_IFR         := $030D
VIA_IER         := $030E
VIA_ORA         := $030F

	;----------------------------------------------------------------------
	;				Divers
	;----------------------------------------------------------------------
HIRESSCR_addr   := $A000                        ; Adresse de l'écran en mode HIRES
TEXTSCR_addr    := $BB80                        ; Adresse de l'écran en mode TEXT

SYSTEM_INC = 1
.endif
