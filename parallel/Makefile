
cflags = -std=c99 -g -Wall -Wextra -Wpedantic -Wbad-function-cast -Wconversion -Wwrite-strings -Wstrict-prototypes -Werror

lint = checkpatch.pl -q --no-tree --no-signoff -f --ignore NEW_TYPEDEFS,AVOID_EXTERNS

targets = parallel

sources = $(targets:%=%.c)

.PHONY : all clean check distclean

all : $(targets)

clean :
	rm -f *.inc

distclean : clean
	rm -f $(targets)

check :
	$(lint) main.c


%.inc : %.txt
	sed 's/\\/\\\\/g;s/"/\\"/g;s/^/"/;s/$$/\\n"/' < $< > $@

parallel : main.c help.inc
	gcc $(cflags) -o $@ main.c
