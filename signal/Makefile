
cflags = -std=c99 -g -Wall -Wextra -Wpedantic -Wbad-function-cast -Wconversion -Wwrite-strings -Wstrict-prototypes -Werror

targets = signal

sources = $(targets:%=%.c)

.PHONY : all clean distclean test


all : $(targets)

clean :
	rm -f *.o *.inc

distclean : clean
	rm -f signal

test : all
	timeout -k3 3 ./signal 5; true


list.inc : mksignallist
	./mksignallist >| $@

info.inc : info.txt
	sed -r '0,/#/{ /^#$$/d; s/.*/"&\\n"/; p; d }' <$< >$@

signal : signal.c list.inc info.inc
	gcc $(cflags) -o $@ $<
