; vim: set ft=asm6502-2 ts=8 et:

; ============================================================================
;                           Adresses ROM Basic
; ----------------------------------------------------------------------------

.ifndef BASIC_ROM_INC
        .if VERSION = 100
                .include "include/basic10_rom.inc"
        .else
                .include "include/basic11_rom.inc"
        .endif

        BASIC_ROM_INC = 1
.endif

