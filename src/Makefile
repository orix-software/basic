#
# Spécifique au Projet
#

PROJECT = basic

USB_MODE ?= sdcard
BACK_TO_ORIX ?= yes
JOYSTICK ?= yes
EXPERIMENTAL ?= no
ROM122 ?= no
FAST ?= yes

VERSION ?= 110

# %<-------------------------------------------------------------------------->%
#               Ne rien modifier au dela de cette ligne
#

BUILDPATH = ../build
OBJPATH = $(BUILDPATH)/obj
ROMPATH = $(BUILDPATH)/rom
INCPATH = $(BUILDPATH)/include

# Sur Ubuntu, le shell par défaut est dash et non bash
# et l'option -e de echo n'est pas reconnue
# on peut aussi spécifier /bin/echo au lieu de simplement echo
SHELL = /bin/bash

#
# Définition des outils
#

ifeq ($(CC65_HOME),)
	CC = cc65
	AS = ca65
	LD = ld65
	AR = ar65
	CL = cl65
else
	CC = $(CC65_HOME)/bin/cc65
	AS = $(CC65_HOME)/bin/ca65
	LD = $(CC65_HOME)/bin/ld65
	AR = $(CC65_HOME)/bin/ar65
	CL = $(CC65_HOME)/bin/cl65
endif


#
# Définition des options pour les outils
#

PROJECT_VERSION := $(shell cat ../VERSION 2>/dev/null)

ASFLAGS += -DVERSION=$(VERSION)

PATCH = ./patch.py


ifeq ($(VERSION),100)
	HOBBIT = no
	GAMES = no
	PATCHROM := ../original/basic10
	SRC = Patch-rom10.s
	ORIX_CFG = "Oric-1 ("
else
	ifneq ($(PRAVETZT),)
		PATCHROM := ../original/pravetzt
		ORIX_CFG = "Pravetzt ("
	else
		PATCHROM := ../original/basic11b
		ORIX_CFG = "Atmos ("
	endif
	SRC = Patch-rom11.s
endif


ifneq ($(PRAVETZT),)
	VERSION=110
	ROMPATH=$(BUILDPATH)/pravetzt
else
	ifeq ($(VERSION),100)
		ROMPATH=$(BUILDPATH)/oric1
	else
	ROMPATH=$(BUILDPATH)/atmos
	endif
endif

ifeq ($(ROM122),yes)
	ORIX_CFG += "1.2"
endif

#
# Définition de la date du build
#

ifeq ($(GIT_BRANCH),master)
	BUILD_DATE :=
else
	ifeq ($(PRAVETZT),)
		BUILD_DATE := $(shell date +" %m%d-%H%M")
	else
		BUILD_DATE := $(shell date +" %m%d")
	endif
endif


#
# Copyright par défaut
#
#COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"

ifeq ($(HOBBIT),yes)
	ifeq ($(PRAVETZT),)
		COPYRIGHT_MSG_AUTO = "Hobbit BASIC 1.1"
	else
		COPYRIGHT_MSG_AUTO = "\x70\x72\x61\x77\x65\x63\x2d\x38\x64\r\nHOBBIT"
	endif

	OPTIONS += "option HOBBIT, yes\\n"
	ROMID := 0
	JOYSTICK = no
	EXPERIMENTAL = no
	ORIX_CFG += "Hobbit"
else
	ifeq ($(GAMES),yes)
		ifeq ($(PRAVETZT),)
			COPYRIGHT_MSG_AUTO = "Games BASIC 1.1"
		else
			COPYRIGHT_MSG_AUTO = "\x70\x72\x61\x77\x65\x63\x2d\x38\x64\r\nGAMES"
		endif

		OPTIONS += "option GAMES, yes\\n"
		ROMID := 1
		JOYSTICK = yes
		EXPERIMENTAL = no
		ORIX_CFG += "Games"
	else
		ifeq ($(ROM122),yes)
			ifeq ($(PRAVETZT),)
				COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.2"
			else
				COPYRIGHT_MSG_AUTO = "\x70\x72\x61\x77\x65\x63\x2d\x38\x64\r\nBASIC 1.2"
			endif

			OPTIONS += "option ROM_122, yes\\n"
			ROMID := 3
		else
			ifeq ($(VERSION),100)
				COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.0"
			else
				ifeq ($(PRAVETZT),)
					COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"
				else
					COPYRIGHT_MSG_AUTO = "\x70\x72\x61\x77\x65\x63\x2d\x38\x64\r\nBASIC"
				endif
			endif
			ROMID := 2
		endif
	endif
endif

OPTIONS += "CONFIG .set $(ROMID)\\n"
ORIX_CFG += "v$(PROJECT_VERSION)"

#
# Sélection du type de carte (usb_host / sdcard / auto)
#

ifeq ($(USB_MODE),sdcard)
	PROJECT = basicsd$(ROMID)

	COPYRIGHT_MSG_AUTO += "SD"
	OPTIONS += "CH376_USB_MODE .set SDCARD_MODE\\n"
	ORIX_CFG += "sdcard"

else
	ifeq ($(USB_MODE),usb)
		PROJECT = basicus$(ROMID)

		COPYRIGHT_MSG_AUTO += "USB"
		OPTIONS += "CH376_USB_MODE .set USB_HOST_MODE\\n"
		ORIX_CFG += "usb"

	else
		PROJECT = basicxx$(ROMID)

		COPYRIGHT_MSG_AUTO += "AUTO"
		OPTIONS += "option AUTO_USB_MODE, yes\\n"
		ORIX_CFG += "auto"

	endif
endif

#
# Personnalisations diverses
#
ifneq ($(INK),)
	OPTIONS += "DEFAULT_INK = $(INK)\\n"
endif

ifneq ($(PAPER),)
	OPTIONS += "DEFAULT_PAPER = $(PAPER)\\n"
endif



ifeq ($(JOYSTICK),yes)
	COPYRIGHT_MSG_AUTO += "/JOY"
	OPTIONS += "option JOYSTICK_DRIVER, yes\\n"
	ORIX_CFG += "/joy"
endif


ifeq ($(FAST),yes)
	COPYRIGHT_MSG_AUTO += "/F"
	OPTIONS += "option FAST_LOAD, yes\\n"
endif


ifeq ($(BACK_TO_ORIX),yes)
	OPTIONS += "option BASIC_QUIT, yes\\n"
endif



ifneq ($(CHARSET),)
	CHARSET :=  $(shell echo "/USR/SHARE/FONTS/"$(CHARSET) | tr a-z A-Z)
endif



ifeq ($(EXPERIMENTAL),yes)
	OPTIONS += "option EXPERIMENTAL, yes\\n"
	COPYRIGHT_MSG_AUTO += "/E"
endif



ifneq ($(COPYRIGHT_MSG),)
	#ASFLAGS +=,-DCOPYRIGHT_MSG='$(COPYRIGHT_MSG)'
else
	COPYRIGHT_MSG = "$(COPYRIGHT_MSG_AUTO) v$(PROJECT_VERSION)$(BUILD_DATE)"
endif


ifneq ($(CHROOT),)
	CHROOT :=  $(shell echo $(CHROOT) | tr a-z A-Z)
endif

ORIX_CFG +=");$(ROMPATH)/$(PROJECT_VERSION)/$(ROM)"

#
# Règles Make
#

.PHONY = configure symbols help clean mrproper

# SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)
ROM = $(PROJECT).rom
LBL = $(SRC:.s=.lbl)
SYM = $(LBL:.lbl=.sym)

all: configure $(ROMPATH)/$(ROM)


$(OBJPATH)/%.o: %.s
	@echo "Assemble patch file"
	@$(CL) -t none --asm-include-dir $(INCPATH) -Wa "$(ASFLAGS)" -o $@ -g -Ln $(OBJPATH)/$*.lbl $<


$(ROMPATH)/$(ROM): $(OBJPATH)/$(OBJ)
	@echo
	@echo "Create $(ROM) - $(COPYRIGHT_MSG)" |sed -re "s# /#/#g"
	@$(PATCH) --rom $(PATCHROM).rom -p $< -o $@
	@echo $(ORIX_CFG) | sed -re "s# /#/#g" >> $(BUILDPATH)/basic.cnf


%.sym: %.lbl
	@cut -d' ' -f2-3  $< | sed -re 's/00([^ ]+) \.(.+)$$/\L\1\E \2/' | grep -v '__' | sort > $@


$(ROMPATH)/$(PROJECT).sym: $(OBJPATH)/$(SYM)
	@echo
	@echo "Create symbols file"
	@cat $(PATCHROM).sym $^ | sort | uniq > $@


#
#
#

symbols: $(ROMPATH)/$(PROJECT).sym


#
#
#

help:
	@echo
	@echo 'Targets'
	@echo -e '\t- all: Patch BASIC 1.x ROM with CH376 support'
	@echo
	@echo -e '\t- symbols: Create symbols file for use with Oricutron'
	@echo
	@echo "NOTE: need $(AS) assembler, python"
	@echo


#
#
#

configure:
	@echo
	@mkdir -p $(BUILDPATH)
	@mkdir -p $(OBJPATH)
	@mkdir -p $(ROMPATH)
	@mkdir -p $(INCPATH)
	@echo "; Build $(ROM)" > $(INCPATH)/build.inc
	@echo "; $(ASFLAGS)" >> $(INCPATH)/build.inc
	@echo ".define COPYRIGHT_MSG \"$(COPYRIGHT_MSG)\"" | sed -re "s# /#/#g" >> $(INCPATH)/build.inc

ifneq ($(CHROOT),)
	@echo ".define ROOT_DIR \"$(CHROOT)\"" >> $(INCPATH)/build.inc
endif

ifneq ($(CHARSET),)
	@echo ".define DEFAULT_CHARSET \"$(CHARSET)\"" >> $(INCPATH)/build.inc
endif
	@echo -e "\n$(OPTIONS)" >> $(INCPATH)/build.inc

ifneq ($(PRAVETZT),)
	@echo "option PRAVETZT, yes" >> $(INCPATH)/build.inc
endif


#
#
#

clean:
	cd $(OBJPATH) && rm -f $(OBJ) $(LBL)


#
#
#

mrproper: clean
	cd $(ROMPATH) && rm -f $(ROM) $(SYM)
