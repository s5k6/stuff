#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <err.h>
#include <unistd.h>
#include <string.h>


enum { MAX_CMDS = 1024 };

#define envvar "PARALLEL"



/* Parse command line arguments */

void cmdline(int argc, char *argv[], int *jobs)
{
	char const *reason;

	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-h") == 0) {
			printf("\n%s\n",
#include "help.inc"
			       );
			exit(0);
		} else {
			char *end = argv[0];
			*jobs = (int)strtol(argv[1], &end, 10);
			if (*end || *jobs < 1)
				errx(1, "Try `parallel -h`");
			reason = "command line argument";
		}
	}

	if (*jobs < 1) {
		char *var = getenv(envvar);

		if (var) {
			char *end = var;
			*jobs = (int)strtol(var, &end, 10);
			if (*end || *jobs < 1)
				*jobs = 0;
			reason = "getenv(" envvar ")";
		}
	}

	if (*jobs < 1) {
		long int reply = sysconf(_SC_NPROCESSORS_ONLN);

		if (reply > 1) {
			*jobs = (int)reply;
			reason = "sysconf(_SC_NPROCESSORS_ONLN)";
		}
	}

	if (*jobs < 1) {
		*jobs = 4;
		reason = "the hard-wired default";
	}

	warnx("Set to max %d jobs from %s.", *jobs, reason);
}



void jobline(char const *const line, char **const cmdv, char *const command)
{
	int cmdc = 0;
	int p = 0;
	enum {
		START, STRONG_QUOT, WEAK_QUOT, ONE_QUOT, SPACES, ESCAPE
	} mode = START;
	cmdv[cmdc++] = command;
	for (int i = 0; line[i]; i++) {
		switch (mode) {
		case START:
			switch (line[i]) {
			case '\'':
				mode = STRONG_QUOT;
				break;
			case '"':
				mode = WEAK_QUOT;
				break;
			case '\\':
				mode = ONE_QUOT;
				break;
			case ' ':
			case '\t':
				command[p++] = 0;
				mode = SPACES;
				break;
			default:
				command[p++] = line[i];
			}
			break;
		case ONE_QUOT:
			mode = START;
			command[p++] = line[i];
			break;
		case STRONG_QUOT:
			if (line[i] == '\'')
				mode = START;
			else
				command[p++] = line[i];
			break;
		case WEAK_QUOT:
			switch (line[i]) {
			case '"':
				mode = START;
				break;
			case '\\':
				mode = ESCAPE;
				break;
			default:
				command[p++] = line[i];
			}
			break;
		case ESCAPE:
			switch (line[i]) {
			case 'n':
				command[p++] = '\n';
				break;
			case 't':
				command[p++] = '\t';
				break;
			case '\\':
				command[p++] = '\\';
				break;
			case '"':
				command[p++] = '"';
				break;
			default:
				errx(1,
				     "Invalid escape sequence: \\%c",
				     line[i]);
			}
			mode = WEAK_QUOT;
			break;
		case SPACES:
			switch (line[i]) {
			case ' ':
			case '\t':
				break;
			default:
				mode = START;
				cmdv[cmdc++] = &command[p];
				i--; /* push back non-space char */
				break;
			}
			break;
		}
	}
	cmdv[cmdc] = NULL;
	switch (mode) {
	case ESCAPE:
	case ONE_QUOT:
		errx(1, "Nothing follows backslash in %s", line);
		break;
	case STRONG_QUOT:
		errx(1, "Not terminated single quote in %s", line);
		break;
	case WEAK_QUOT:
		errx(1, "Not terminated double quote in %s", line);
		break;
	default:
		break;
	}
}



int main(int argc, char *argv[])
{

	int jobs = 0;
	char *line = NULL, *command = NULL;
	size_t len = 0;
	ssize_t read;
	pid_t pid;
	int status;

	cmdline(argc, argv, &jobs);

	while ((read = getline(&line, &len, stdin)) >= 0) {

		for (int i = 0; i < read; i++)
			if (line[i] == '\n')
				line[i] = ' ';

		char *cmdv[MAX_CMDS + 1];

		command = realloc(command, (size_t)read + 1);
		if (command == NULL)
			err(1, "realloc");
		command[0] = 0;

		jobline(line, cmdv, command);


		/* harvest dead children */
#ifdef DEBUG
		warnx("There are %d slots available", jobs);
#endif
		while ((pid = waitpid(-1, &status, jobs > 0 ?
					WNOHANG : 0)) > 0) {
			if (WIFEXITED(status))
				warnx("Child %d returned %d", pid,
				      WEXITSTATUS(status));
			else
				warnx("Child %d died", pid);
			jobs++;
		}

		/* spawn child if any */
		if (command[0]) {
#ifdef DEBUG
			for (int i = 0; i < cmdc; i++)
				warnx("cmdv[%d] = \"%s\"", i, cmdv[i]);
#endif

			jobs--;
			pid = fork();
			if (pid < 0)
				err(1, "fork");
			else if (pid == 0) {
				execvp(cmdv[0], cmdv);
				err(1, "exec");
			} else if (pid > 0)
				warnx("Launched %d: %s", pid, line);
		}
	}

	/* harvest remaining children */
	while ((pid = wait(&status)) > 0)
		warnx("Child %d exited with %d.", pid,
		      WEXITSTATUS(status));

	free(command);
	free(line);
}
