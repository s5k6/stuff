vpcc = gcc -std=c99 -Wall -Werror

.PHONY: all clean

all : arg

clean :
	rm -rf arg

arg : main.c help.inc
	$(vpcc) -o arg main.c
	strip arg

help.inc : help.txt

%.inc : %.txt
	sed 's/\\/\\\\/g;s/"/\\"/g;s/%/%%/g;s/^/"/;s/$$/\\n"/' < $< > $@
