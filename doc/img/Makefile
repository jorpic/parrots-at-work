ALL_DOT = $(wildcard *.dot)
ALL_SVG = $(ALL_DOT:dot=svg)
TMP := $(shell mktemp -d)

.PHONY: all TMP

all: $(ALL_SVG) TMP

%.svg: %.dot
	cpp -I./include $< -o $(TMP)/$<
	dot -Tsvg $(TMP)/$< -o $@

TMP:
	rm -rf $(TMP)
