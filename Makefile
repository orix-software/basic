
all: cart symbols


.PHONY: configure cart docs clean mrproper

configure:
	@$(MAKE) -s -C src $@

cart:
	@$(MAKE) -s -C src

symbols:
	@$(MAKE) -s -C src symbols

#docs:
#	@$(MAKE) -C docs

test:
	@echo "Do some tests"

clean:
	@$(MAKE) -s -C src $@
	@# @$(MAKE) -C docs $@


mrproper: clean
	@$(MAKE) -s -C src $@
	@# @$(MAKE) -C docs $@
