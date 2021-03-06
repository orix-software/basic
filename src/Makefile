#
# Spécifique au Projet
#

PROJECT = basicsd
BUILDPATH = ../build/cart

USB_MODE ?= sdcard
BACK_TO_ORIX ?= yes
JOYSTICK ?= yes
EXPERIMENTAL ?= no
ROM122 ?= no
FAST ?= yes

# %<-------------------------------------------------------------------------->%
#               Ne rien modifier au dela de cette ligne
#


PROJECT_VERSION := $(shell cat ../VERSION 2>/dev/null)

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
	ASFLAGS += -DHOBBIT=yes
	ROMID := 0
	JOYSTICK = no
	EXPERIMENTAL = no
else
	ifeq ($(GAMES),yes)
		COPYRIGHT_MSG_AUTO = "Games BASIC 1.1"
		ASFLAGS += -DGAMES=yes
		ROMID := 1
		JOYSTICK = yes
		EXPERIMENTAL = no
	else
		ifeq ($(ROM122),yes)
			COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.2"
			ASFLAGS += -DROM_122=yes
			# ROMID := 3
		else
			COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"
			ROMID := 2
		endif
	endif
endif

#
# Sélection du type de carte (usb_host / sdcard)
#

ifeq ($(USB_MODE),sdcard)
	PROJECT = basicsd$(ROMID)
	# COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1 SD v$(PROJECT_VERSION)"
	COPYRIGHT_MSG_AUTO += ," SD"
	ASFLAGS += -DCH376_USB_MODE=3
else
	PROJECT = basicus$(ROMID)
	# COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1 USB v$(PROJECT_VERSION)"
	COPYRIGHT_MSG_AUTO += ," USB"
	ASFLAGS += -DCH376_USB_MODE=6
endif

#
# Personnalisations diverses
#
ifneq ($(INK),)
	ASFLAGS += -DDEFAULT_INK=$(INK)
endif

ifneq ($(PAPER),)
	ASFLAGS += -DDEFAULT_PAPER=$(PAPER)
endif



ifeq ($(JOYSTICK),yes)
	COPYRIGHT_MSG_AUTO += ,"/JOY"
	ASFLAGS += -DJOYSTICK_DRIVER
endif


ifeq ($(FAST),yes)
	COPYRIGHT_MSG_AUTO += ,"/F"
	ASFLAGS += -DFAST_LOAD
endif


ifeq ($(BACK_TO_ORIX),yes)
	ASFLAGS += -DBASIC_QUIT
endif



ifneq ($(CHARSET),)
	CHARSET :=  $(shell echo $(CHARSET) | tr a-z A-Z)
	ASFLAGS += -DDEFAULT_CHARSET='"/USR/SHARE/FONTS/$(CHARSET)"'
endif



ifeq ($(EXPERIMENTAL),yes)
	ASFLAGS += -DEXPERIMENTAL
	COPYRIGHT_MSG_AUTO += ,"/E"
endif



ifneq ($(COPYRIGHT_MSG),)
	ASFLAGS += -DCOPYRIGHT_MSG='$(COPYRIGHT_MSG)'
else
	COPYRIGHT_MSG = $(COPYRIGHT_MSG_AUTO), " v$(PROJECT_VERSION)$(BUILD_DATE)"
	ASFLAGS += -DCOPYRIGHT_MSG='$(COPYRIGHT_MSG)'
endif


ifneq ($(CHROOT),)
	CHROOT :=  $(shell echo $(CHROOT) | tr a-z A-Z)
	ASFLAGS += -DROOT_DIR='"$(CHROOT)"'
endif

#
# Définition des outils
#

# Ne pas utiliser le flag -M avec la version OSDK de xa,
# il n'est pas correctement géré...
AS = xa
ifeq ($(shell $(AS) --version 2>/dev/null),)
	OSDK_FOUND = 1
else
	# La version officielle nécessite le flag -M à cause de ':' dans les commentaires
	ASFLAGS += -M
endif

PATCH = ./patch.py
PATCHFLAGS = --rom ../original/basic11b.rom

#
# Règles Make
#

.PHONY = configure symbols help clean mrproper

SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)
ROM = $(PROJECT).rom
LBL = $(SRC:.s=.lbl)
SYM = $(LBL:.lbl=.sym)

all: configure $(BUILDPATH)/$(ROM)


$(BUILDPATH)/%.o: %.s
	@echo "Assemble patch file"
	@$(AS) $(ASFLAGS) -o $@ -l $(BUILDPATH)/$*.lbl $<


$(BUILDPATH)/$(ROM): $(BUILDPATH)/$(OBJ)
	@echo "Create $(ROM) - $(COPYRIGHT_MSG)"
	@$(PATCH) $(PATCHFLAGS) -p $< -o $@


%.sym: %.lbl
	@cut -d, -f1-2 $< | sed -re 's/([^,]+), 0x(.+)$$/\2 \1/' | sort > $@


$(BUILDPATH)/$(PROJECT).sym: $(BUILDPATH)/$(SYM)
	@echo "Create symbols file"
	@cat ../original/basic11b.sym $^ | sort | uniq > $@


symbols: $(BUILDPATH)/$(PROJECT).sym


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
ifeq ($(OSDK_FOUND),)
	@echo "Using official xa"
else
	@echo "OSDK found"
endif

clean:
	cd $(BUILDPATH) && rm -f $(OBJ) $(LBL)


mrproper: clean
	cd $(BUILDPATH) && rm -f $(ROM) $(SYM)
