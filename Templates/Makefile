TEMPLATE_NAMES = 'FuturedArchitecture'
TEMPLATE_DIR = $(HOME)/Library/Developer/Xcode/Templates/

install:
	mkdir -p $(TEMPLATE_DIR)$$name ; \
	cd $$name ; \
	cp -R *.xctemplate $(TEMPLATE_DIR)$$name ; \
	cd .. ; \

.PHONY = install