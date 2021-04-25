# Follows conventions described here:
# https://nullprogram.com/blog/2020/01/22/ then I took further
# inspiration from jwiegley/emacs-async Makefile

.POSIX:
EMACS   = emacs
LDFLAGS = -L ../mustache.el -L ../s -L ../ht -L ../dash
BATCH   = $(EMACS) -Q -batch -L . $(LDFLAGS)
COMPILE = $(BATCH) -f batch-byte-compile
# Files to compile
EL			:= $(sort $(wildcard *.el))
# Compiled files
ELC			:= $(EL:.el=.elc)
# Test files
TESTEL			:= $(sort $(wildcard *-tests.el))
TESTELC			:= $(TESTEL:.el=.elc)

# all commands should figure here (vs build rules)
.PHONY: clean test compile compile-all

# to avoid leaving part-written output behind after failures
.DELETE_ON_ERROR:

# compile needed files
compile: $(ELC)

compile-all:
	$(COMPILE) $(EL)

$(ELC): %.elc: %.el
	$(COMPILE) $<

$(TESTELC): %-tests.elc: %.elc

test: $(TESTELC)
	$(foreach test,$^,$(BATCH) -l $(test) -f ert-run-tests-batch;)

clean:
	rm -f $(ELC)