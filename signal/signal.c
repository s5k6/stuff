#define _POSIX_C_SOURCE 199309L

#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>



#include "list.inc"



/* This program waits for any defined (see `kill -l`) signal, and
 * prints a message accordingly.  It will automatically terminate
 * after MAX_IDLE seconds without reception of any signal.  The only
 * other way to get rid of the process is sending SIGKILL.
 */

#define MAX_IDLE 60
#define MIN_IDLE 1



/* Print message, prefixed with program name and pid. */

#define message(msg, ...)	  \
	printf("signal[%d] " msg "\n", getpid(), __VA_ARGS__)



/* Last signal received, or 0 if none. */

int sig;



/* Signal handler: Store signal number. */

void handler(int s)
{
	sig = s;
}



int main(int argc, char *argv[])
{
	unsigned int idle = 0;

	if (argc == 2) {
		char *end;
		long int i = strtol(argv[1], &end, 0);
		if (end && *end == '\0' && MIN_IDLE <= i && i <= MAX_IDLE)
			idle = (unsigned int)i;
	}

	if (idle < MIN_IDLE) {
		printf(
#include "info.inc"
		);
		return 1;
	}


	message("Waiting for signals.  pid=%d, timeout=%ds", getpid(), idle);


	/* Set up signal masks, to either block or allow all signals. */

	sigset_t all, none;

	if (sigfillset(&all) != 0)
		return 1;
	if (sigemptyset(&none) != 0)
		return 1;

	if (sigprocmask(SIG_BLOCK, &all, NULL) != 0)
		return 1;


	/* install signal handlers */

	struct sigaction sa;

	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = handler;
	sa.sa_mask = all;

	for (int s = 1; s <= SIGNALS; s++) {
		if (name[s])
			if (sigaction(s, &sa, NULL))
				message(
					"Failed to install handler for %s(%d).",
					name[s], s);
	}



	/* Now wait for signals.  If timer expires, terminate with info, but do
	 * not print message about reception of SIGALRM.
	 */

	alarm(idle);
	do {
		if (sig) {
			if (sig <= SIGNALS && name[sig])
				message(
					"Caught signal %s(%d).",
					name[sig], sig);
			else
				message(
					"Caught unknown signal %d.", sig);
		}
		sigsuspend(&none);
	} while (alarm(idle));

	message(
		"No signals for %d seconds.  Terminating.", idle);

	return 0;
}
