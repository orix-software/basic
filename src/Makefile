#
# Spécifique au Projet
#

PROJECT = basicsd
BUILDPATH = ../build/cart

USB_MODE ?= sdcard
BACK_TO_ORIX ?= TRON

# %<-------------------------------------------------------------------------->%
#               Ne rien modifier au dela de cette ligne
#

#
# Récupère le nom de la branche pour en extraire le n° de  version
#
ifeq ($(TRAVIS_BRANCH),)
	GIT_BRANCH := $(shell git branch 2>/dev/null | grep '*' | cut -d' ' -f2)
else
	GIT_BRANCH := $(TRAVIS_BRANCH)
endif

ifeq ($(GIT_BRANCH),master)
	GIT_BRANCH := $(shell cat VERSION 2>/dev/null)
endif

#
# Le nom de la branche est <annee>.<trimestre>
#
PROJECT_VERSION_MAJ := $(shell echo ${GIT_BRANCH} | cut -d. -f1)
PROJECT_VERSION_MIN := $(shell echo ${GIT_BRANCH} | cut -d. -f2)

ifeq ($(PROJECT_VERSION_MAJ),$(PROJECT_VERSION_MIN))
	PROJECT_VERSION_MAJ := 66
	PROJECT_VERSION_MIN := 6
endif

#
# Sélection du type de carte (usb_host / sdcard)
#
COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1"

ifeq ($(USB_MODE),sdcard)
	PROJECT = basicsd
	# COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1 SD v$(PROJECT_VERSION_MAJ).$(PROJECT_VERSION_MIN)"
	COPYRIGHT_MSG_AUTO += ," SD"
	ASFLAGS += -DNORAMCHECK -DCH376_USB_MODE=3
else
	PROJECT = basicusb
	# COPYRIGHT_MSG_AUTO = "ORIC BASIC 1.1 USB v$(PROJECT_VERSION_MAJ).$(PROJECT_VERSION_MIN)"
	COPYRIGHT_MSG_AUTO += ," USB"
	ASFLAGS += -DNORAMCHECK -DCH376_USB_MODE=6
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



ifneq ($(JOYSTICK),)
	COPYRIGHT_MSG_AUTO += ,"/JOY"
	ASFLAGS += -DJOYSTICK_DRIVER
endif


ifeq ($(BACK_TO_ORIX),LET)
	ASFLAGS += -DBASIC_LET_IS_QUIT

else ifeq ($(BACK_TO_ORIX),TRON)
	ASFLAGS += -DBASIC_TRON_IS_QUIT

else ifeq ($(BACK_TO_ORIX),TROFF)
	ASFLAGS += -DBASIC_TROFF_IS_QUIT
endif



ifneq ($(COPYRIGHT_MSG),)
	ASFLAGS += -DCOPYRIGHT_MSG='$(COPYRIGHT_MSG)'
else
	COPYRIGHT_MSG = $(COPYRIGHT_MSG_AUTO), " v$(PROJECT_VERSION_MAJ).$(PROJECT_VERSION_MIN)"
	ASFLAGS += -DCOPYRIGHT_MSG='$(COPYRIGHT_MSG)'
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
