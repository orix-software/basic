#
# Spécifique au Projet
#

PROJECT = basic
BUILDPATH = ../build
OBJPATH = $(BUILDPATH)/obj
ROMPATH = $(BUILDPATH)/rom
INCPATH = $(BUILDPATH)/include

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
else
	ifneq ($(PRAVETZT),)
		PATCHROM := ../original/pravetzt
	else
		PATCHROM := ../original/basic11b
	endif
	SRC = Patch-rom11.s
endif


ifneq ($(PRAVETZT),)
	VERSION = 110
endif

ROMPATH := $(ROMPATH).$(VERSION)

#
# Définition de la date du build
#

ifeq ($(GIT_BRANCH),master)
	BUILD_DATE :=
else
	BUILD_DATE := $(shell date +" %d/%m %H:%M")
endif


#
# Copyright par défaut
#
#COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"

ifeq ($(HOBBIT),yes)
	COPYRIGHT_MSG_AUTO = "Hobbit BASIC 1.1"
	OPTIONS += "option HOBBIT, yes\\n"
	ROMID := 0
	JOYSTICK = no
	EXPERIMENTAL = no
else
	ifeq ($(GAMES),yes)
		COPYRIGHT_MSG_AUTO = "Games BASIC 1.1"
		OPTIONS += "option GAMES, yes\\n"
		ROMID := 1
		JOYSTICK = yes
		EXPERIMENTAL = no
	else
		ifeq ($(ROM122),yes)
			COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.2"
			OPTIONS += "option ROM_122, yes\\n"
			ROMID := 3
		else
			ifeq ($(VERSION),100)
				COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.0"
			else
				COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"
			endif
			ROMID := 2
		endif
	endif
endif

OPTIONS += "CONFIG .set $(ROMID)\\n"


#
# Sélection du type de carte (usb_host / sdcard)
#

ifeq ($(USB_MODE),sdcard)
	PROJECT = basicsd$(ROMID)
	COPYRIGHT_MSG_AUTO += "SD"
	OPTIONS += "CH376_USB_MODE .set SDCARD_MODE\\n"
else
	PROJECT = basicus$(ROMID)
	COPYRIGHT_MSG_AUTO += "USB"
	OPTIONS += "CH376_USB_MODE .set USB_HOST_MODE\\n"
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
	@$(CL) -t none --asm-include-dir $(INCPATH) -Wa "$(ASFLAGS)" -o $@ -l $(OBJPATH)/$*.lbl $<


$(ROMPATH)/$(ROM): $(OBJPATH)/$(OBJ)
	@echo
	@echo "Create $(ROM) - $(COPYRIGHT_MSG)" |sed -re "s# /#/#g"
	@$(PATCH) --rom $(PATCHROM).rom -p $< -o $@


%.sym: %.lbl
	@cut -d, -f1-2 $< | sed -re 's/([^,]+), 0x(.+)$$/\2 \1/' | sort > $@


$(ROMPATH)/$(PROJECT).sym: $(OBJPATH)/$(SYM)
	@echo
	@echo "Create symbols file"
	@cat $(PATCHROM).sym $^ | sort | uniq > $@


symbols: $(ROMPATH)/$(PROJECT).sym


#
#
#

help:
	@echo
	@echo 'Targets'
	@echo -e '\t- all: Patch BASIC 1.1 ROM with CH376 support'
	@echo
	@echo -e '\t- symbols: Create symbols file for use with Oricutron'
	@echo
	@echo "NOTE: need $(AS) assembler, python"
	@echo -e '\n'


configure:
	@echo
	@mkdir -p $(BUILDPATH)
	@mkdir -p $(OBJPATH)
	@mkdir -p $(ROMPATH)
	@mkdir -p $(INCPATH)
	@echo -e "; Build $(ROM)\n" > $(INCPATH)/build.inc
	@echo "; $(ASFLAGS)" >> $(INCPATH)/build.inc
	@echo ".define COPYRIGHT_MSG \"$(COPYRIGHT_MSG)\"" | sed -re "s# /#/#g" >> $(INCPATH)/build.inc
ifneq ($(CHROOT),)
	@echo ".define ROOT_DIR \"$(CHROOT)\"" >> $(INCPATH)/build.inc
endif

ifneq ($(CHARSET),)
	@echo ".define DEFAULT_CHARSET \"$(CHARSET)\"" >> $(INCPATH)/build.inc
endif
	@echo -e "\n$(OPTIONS)" >> $(INCPATH)/build.inc



clean:
	cd $(OBJPATH) && rm -f $(OBJ) $(LBL)


mrproper: clean
	cd $(ROMPATH) && rm -f $(ROM) $(SYM)
