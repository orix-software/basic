; vim: set ft=asm6502-2 ts=8 et:

.ifndef CH376_INC

        ;---------------------------------------------------------------------------
        ;
        ;			Adresse de l'interface CH376
        ;
        ;---------------------------------------------------------------------------
        CH376_COMMAND   = $0341
        CH376_DATA      = $0340

	;---------------------------------------------------------------------------
	;
	;			Modes du CH376
	;
	;---------------------------------------------------------------------------
	SDCARD_MODE   = $03
	USB_HOST_MODE = $06

	;---------------------------------------------------------------------------
	;
	;			Codes d'erreur du CH376
	;
	;---------------------------------------------------------------------------
	SUCCESS        = $12
	INT_SUCCESS    = $14
	INT_DISK_READ  = $1D
	INT_DISK_WRITE = $1E
	ERR_OPEN_DIR   = $41
	ABORT          = $5F

	;---------------------------------------------------------------------------
	;
	;			Codes commande du CH376
	;
	;---------------------------------------------------------------------------
	CH376_CMD_CHECK_EXIST   = $06
	CH376_CMD_SET_USB_MODE  = $15
	CH376_CMD_GET_STATUS    = $22
	CH376_CMD_RD_USB_DATA0  = $27
	CH376_CMD_WR_REQ_DATA   = $2d
	CH376_CMD_SET_FILE_NAME = $2f
	CH376_CMD_DISK_MOUNT    = $31
	CH376_CMD_FILE_OPEN     = $32
	CH376_CMD_FILE_CREATE   = $34
	CH376_CMD_FILE_CLOSE    = $36
	CH376_CMD_BYTE_READ     = $3a
	CH376_CMD_BYTE_RD_GO    = $3b
	CH376_CMD_BYTE_WRITE    = $3c
	CH376_CMD_BYTE_WR_GO    = $3d

	CH376_INC = 1

.endif
