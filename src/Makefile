PROJECT = basic_noram
BUILDPATH = ../build/cart

# %<-------------------------------------------------------------------------->%

AS = xa
ASFLAGS = -M -DCSAVE -DCLOAD -DNORAMCHECK

PATCH = ./patch.py
PATCHFLAGS = --rom ../original/basic11b.rom

.PHONY = configure symbols help clean mrproper

SRC = $(wildcard *.s)
OBJ = $(SRC:.s=.o)
ROM = $(PROJECT).rom
LBL = $(SRC:.s=.lbl)
SYM = $(LBL:.lbl=.sym)

#
# Règles Make
#

all: configure $(BUILDPATH)/$(ROM)


$(BUILDPATH)/%.o: %.s
	@echo "Assemble patch file"
	@$(AS) $(ASFLAGS) -o $@ -l $(BUILDPATH)/$*.lbl $<


$(BUILDPATH)/$(ROM): $(BUILDPATH)/$(OBJ)
	@echo "Create $(ROM)"
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


clean:
	cd $(BUILDPATH) && rm -f $(OBJ) $(LBL)


mrproper: clean
	cd $(BUILDPATH) && rm -f $(ROM) $(SYM)
