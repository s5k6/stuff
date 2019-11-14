#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>


#define ENV_LOG "ARG_LOG"
#define ENV_DUMP "ARG_DUMP"
#define BUFSIZE 4096


int main(int argc, char *argv[]) {

	if (argc == 2 && strcmp(argv[1], "--help") == 0) {
		printf(
#include "help.inc"
);
	} else {
		char *logfile = getenv(ENV_LOG);
		char *dumpfile = getenv(ENV_DUMP);
		int out = STDOUT_FILENO, dump = -1;

		if (logfile) {
			out = open(logfile, O_WRONLY|O_CREAT|O_APPEND, 0666);
			if (out < 0)
				err(1, "open(%s)", logfile);
			if (close(STDOUT_FILENO))
				err(1, "close(stdout)");
			if (dup2(out, STDOUT_FILENO) < 0)
				err(1, "dup2");
		}

		printf("# Try `arg --help` for further information.\n");

		if (dumpfile) {
			dump = open(dumpfile, O_WRONLY|O_CREAT|O_APPEND, 0666);
			if (dump < 0)
				err(1, "open(%s)", dumpfile);
		}


		for (int i = 0; i < argc; i++) {
			printf("%5i\t%s\n", i, argv[i]);
		}

		if (dump >= 0) {
			char buf[BUFSIZE];
			for (int c = read(0, &buf, BUFSIZE); c > 0; c = read(0, &buf, BUFSIZE))
				if (write(dump, &buf, c) < c)
					err(1, "Write interrupted.  Dump incomplete");
		}

		if (close(out))
			err(1, "close(out)");

		if (dump>0 && close(dump))
			err(1, "close(dump)");

	}
	return 0;
}
